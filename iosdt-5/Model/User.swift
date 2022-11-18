//
//  User.swift
//  iosdt-5
//
//  Created by Александр Востриков on 19.11.2022.
//

import Foundation

struct User {
    let name: String
    let surname: String
    
    func getFullName() -> String{
        "\(surname) \(name)"
    }
}
