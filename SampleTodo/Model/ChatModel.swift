//
//  ChatModel.swift
//  SampleTodo
//
//  Created by prautela on 01/08/24.
//

import Foundation

class ChatModel {
    var name: String
    var text: String
    var profileImage: String
    
    init(name: String, text: String, profileImage: String) {
        self.name = name
        self.text = text
        self.profileImage = profileImage
    }
}
