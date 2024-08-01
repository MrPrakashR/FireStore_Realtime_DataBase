//
//  TodoDB.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation

protocol TodoDB {
    func add(usingTodoItem todoItem:TodoItem) -> Bool
    func update(usingTodoItem todoItem:TodoItem) -> Void
    func delete(usedId id:String) -> Void
    func subscribe(completion: @escaping(TodoItem) -> Void,deletion: @escaping(TodoItem) -> Void) -> Void
}
