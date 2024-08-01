//
//  TodoViewModel+Extension.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation

extension TodoViewModel: TodoViewDelegate {
    
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

