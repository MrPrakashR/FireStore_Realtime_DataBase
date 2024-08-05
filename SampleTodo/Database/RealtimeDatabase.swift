//
//  RealtimeDatabase.swift
//  SampleTodo
//
//  Created by prautela on 02/08/24.
//

import Foundation
import FirebaseDatabase

class RealtimeDatabase {
    
    private let firebaseDb = Database.database().reference()
    static let shared: RealtimeDatabase =  RealtimeDatabase()
    private let todosRoot = "todos"
    
    private init() {}
}

extension RealtimeDatabase : TodoDB {
    
    func fetch(completion: @escaping ([TodoItem]) -> Void) {
        
        firebaseDb.child(todosRoot).queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                
                var todoList : [TodoItem] = []
                for snap in snapShot {
                    if let mainDict = snap.value as? [String:AnyObject] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: mainDict)
                            let todoItem = try JSONDecoder().decode(TodoItem.self, from: jsonData)
                            todoList.append(todoItem)
                        } catch {
                            print("Error decoding user: \(error.localizedDescription)")
                        }
                    }
                }
                completion(todoList)
            }
        }
        
        
    }
    
    func add(usingTodoItem todoItem: TodoItem) -> Bool {
        
        do {
            
            let todoData = try JSONEncoder().encode(todoItem)
            let todoDict = try JSONSerialization.jsonObject(with: todoData, options: .allowFragments) as? [String: Any]
            
            firebaseDb.child(todosRoot).child(todoItem.id).setValue(todoDict) { error, _ in
                if let error = error {
                    print("Error adding todo: \(error.localizedDescription)")
                } else {
                    print("User added successfully")
                }
            }

        } catch let error {
            debugPrint("Error adding todo: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func update(usingTodoItem todoItem: TodoItem) {
        
        do {
            let todoData = try JSONEncoder().encode(todoItem)
            let todoDict = try JSONSerialization.jsonObject(with: todoData, options: .allowFragments) as? [String: Any]
               
            firebaseDb.child(todosRoot).child(todoItem.id).updateChildValues(todoDict ?? [:]) { error, _ in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                } else {
                    print("User updated successfully")
                }
            }
           } catch {
               print("Error encoding user: \(error.localizedDescription)")
           }
    }
    
    func delete(usedId id: String) {
        
        firebaseDb.child(todosRoot).child(id).removeValue { error, _ in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("todo deleted successfully")
            }
        }
    }
    
    func subscribe(completion: @escaping (TodoItem) -> Void, deletion: @escaping (TodoItem) -> Void) {
        
        firebaseDb.child(todosRoot).queryOrderedByKey().observe(.value) { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let mainDict = snap.value as? [String:AnyObject] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: mainDict)
                            let todoItem = try JSONDecoder().decode(TodoItem.self, from: jsonData)
                            completion(todoItem)
                        } catch {
                            print("Error decoding user: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
    }
    
    
}
