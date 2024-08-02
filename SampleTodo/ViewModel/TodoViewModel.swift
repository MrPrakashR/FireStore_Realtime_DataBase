//
//  TodoViewModel.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation

protocol TodoViewDelegate: AnyObject {
    func onFetchItem() -> ()
    func onAddTodoItem() -> ()
    func onDelete(todoId:String) -> ()
    func onDone(todoId:String) -> ()
}

class TodoViewModel {

    weak var view: TodoView?
    var items: [TodoItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.view?.reloadItems()
            }
        }
    }
    var newTodoItem: String?
    let database: TodoDB
    var isRealTime: Bool = false
    
    init(view:TodoView,database: TodoDB = FirestoreDatabase.shared) {
        self.view = view
        self.database = database
        setup(database: database)
    }
    
}

private extension TodoViewModel {
    
    // For RealTime Observer
    func setup(database:TodoDB) -> Void {
        database.subscribe { (todoItem) in
            print("Todo Item: \(todoItem.name)")
            
            if let index = self.items.firstIndex(where: { $0.id == todoItem.id }) {
                self.items[index] = TodoItem(id:todoItem.id,name: todoItem.name,completed: todoItem.completed)
            } else {
                self.items.append(TodoItem(id:todoItem.id,name: todoItem.name,completed: todoItem.completed))
            }
        } deletion: { (todoItem) in
            self.items.removeAll(where: { $0.id == todoItem.id })
        }
    }
}

extension TodoViewModel : TodoViewDelegate {
    
    // For One Time Fetch
    func onFetchItem() {
        database.fetch { response in
            self.items = response
        }
    }
    
    func onAddTodoItem() {
        
        guard let todoValue = self.newTodoItem else {
            print("Todo value is empty")
            return
        }
        
        let success = database.add(usingTodoItem: TodoItem(name: todoValue))
        debugPrint("Item Added from viewModel : \(success)")
        
        DispatchQueue.main.async { [view] in
            view?.reset()
        }
    }
    
    func onDelete(todoId: String) {
        database.delete(usedId: todoId)
        if isRealTime {
            self.items.removeAll()
        }
    }
    
    func onDone(todoId: String) {
        guard var vm : TodoItem = self.items.filter({ $0.id == todoId }).first else {
            debugPrint("Document id doesn't exist")
            return
        }
        vm.setCompletion()
        
        database.update(usingTodoItem: vm)
    }
}
