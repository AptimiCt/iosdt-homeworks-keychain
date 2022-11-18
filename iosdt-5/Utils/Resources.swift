//
//  Resources.swift
//  iosdt-5
//
//  Created by Александр Востриков on 17.11.2022.
//

import Foundation
enum Resources {
    enum state {
        case passwordCreated
        case passwordIsNotSet
    }
    enum screen {
        case first
        case second
    }
    
    enum error: String {
        case passwordIsNotCorrect = "Не пароли не совпадают"
    }
}
