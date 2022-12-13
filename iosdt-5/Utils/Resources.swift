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
        case changePassword
    }
    
    enum Status {
        case Authorized
        case NotAuthorized
    }
    
    enum message: String {
        case passwordsDoNotMatch = "Пароли не совпадают"
        case passwordDidNotChange = "Пароль не удалось обновить"
        case passwordChanged = "Пароль обновлен"
        case passwordNotCorrect = "Не корректный пароль или пароли совпадают"
        
    }
    enum key: String {
        case sort
    }
}
