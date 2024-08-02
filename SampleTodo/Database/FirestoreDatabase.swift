//
//  FirestoreDatabase.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol TodoDB {
    func fetch(completion: @escaping ([TodoItem]) -> Void) -> Void
    func add(usingTodoItem todoItem:TodoItem) -> Bool
    func update(usingTodoItem todoItem:TodoItem) -> Void
    func delete(usedId id:String) -> Void
    func subscribe(completion: @escaping(TodoItem) -> Void,deletion: @escaping(TodoItem) -> Void) -> Void
}

class FirestoreDatabase {
    
    private let firebaseDb = Firestore.firestore()
    static let shared: FirestoreDatabase =  FirestoreDatabase()
    private let todosCollection = "todos"
    
    private init() {}
}

extension FirestoreDatabase: TodoDB {
    
    func fetch(completion: @escaping ([TodoItem]) -> Void) {
        firebaseDb.collection(todosCollection).getDocuments { (documentQuerySnapshot, error) in
            guard error == nil,let documents = documentQuerySnapshot?.documents else { return }
            
            do {
                
                var todoList: [TodoItem] = []
                for document in documents {
                    todoList.append(try document.data(as: TodoItem.self))
                }
                
                completion(todoList)
                
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    func add(usingTodoItem todoItem: TodoItem) -> Bool {
        
        do {
            let ref = try firebaseDb
                .collection(todosCollection)
                .addDocument(from: todoItem)
            debugPrint("Add document succeded with id = \(ref.documentID)")
        } catch let error {
            debugPrint("Failed to add Document \(error)")
            return false
        }
        
        return true
    }
    
    func update(usingTodoItem todoItem: TodoItem) {
        firebaseDb
            .collection(todosCollection)
            .whereField("id", isEqualTo: todoItem.id)
            .getDocuments { (snapshot, error) in
                
                if let error = error {
                    debugPrint("Document Error: \(error)")
                } else {
                    if let document = snapshot?.documents.first {
                        do {
                            try document.reference.setData(from: todoItem)
                        } catch let error {
                            debugPrint("Failed to update Document \(error)")
                        }
                    }
                }
            }
    }
    
    func delete(usedId id: String) {
        firebaseDb
            .collection(todosCollection)
            .whereField("id", isEqualTo: id)
            .getDocuments { (snapshot, error) in
                
                if let error = error {
                    debugPrint("Document Error: \(error)")
                } else {
                    if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            debugPrint("Failed to delete Document \(String(describing: error))")
                        }
                    }
                }
            }
    }

    func subscribe(completion: @escaping (TodoItem) -> Void,deletion: @escaping (TodoItem) -> Void) {
        firebaseDb
            .collection(todosCollection)
            .addSnapshotListener { (snapshot,error) in
                
                guard let collection = snapshot else { return }
                
                collection.documentChanges.forEach { (change) in
                    do {
                        
                        if change.type == .added {
                            let item = try change.document.data(as: TodoItem.self)
                            completion(item)
                        }
                        
                        if change.type == .modified {
                            let item = try change.document.data(as: TodoItem.self)
                            completion(item)
                        }
                        
                        if change.type == .removed {
                            let item = try change.document.data(as: TodoItem.self)
                            deletion(item)
                        }
                        
                    } catch let error {
                        debugPrint("Fetch failure: \(error)")
                    }
                }
                
            }
    }
    
}
