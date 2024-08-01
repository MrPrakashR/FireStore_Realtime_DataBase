//
//  TodoViewModel.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation

protocol TodoViewDelegate: AnyObject {
    func onAddTodoItem() -> ()
    func onDelete(todoId:String) -> ()
    func onDone(todoId:String) -> ()
}

protocol TodoViewPresentable {
    var newTodoItem: String? { get set }
    var items: [TodoItem] { get }
}

class TodoViewModel: TodoViewPresentable {

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
    
    init(view:TodoView,database: TodoDB = FirestoreDatabase.shared) {
        self.view = view
        self.database = database
        setup(database: database)
    }
    
}

private extension TodoViewModel {
    
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
