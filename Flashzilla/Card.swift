//
//  Card.swift
//  Flashzilla
//
//  Created by Vladimir on 16.07.2021.
//

import Foundation

struct Card: Codable {
    
    let prompt: String
    let answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker ")
    }
}
