//
//  TodoItem.swift
//  SampleTodo
//
//  Created by prautela on 31/07/24.
//

import Foundation

struct TodoItem : Codable {
    
    let id: String
    let name: String
    var completed: Bool
    
    enum CodingKeys:String,CodingKey {
        case id
        case name
        case completed
    }
    
    init(id: String = UUID().uuidString, name: String, completed: Bool = false) {
        self.id = id
        self.name = name
        self.completed = completed
    }
    
    mutating func setCompletion() {
        self.completed = !self.completed
    }
}
