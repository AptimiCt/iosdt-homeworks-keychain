//
//  AppCoordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 16.11.2022.
//

import UIKit

final class AppCoordinator: Coordinator {
    enum State {
        case Authorized
        case NotAuthorized
    }
    
    func startApp() -> UIViewController {
        
        let credentials = Credentials(password: "")
        
        let state = checkUserInKeyChain(credentials: credentials)
        
        switch state {
            case .Authorized:
                let loginViewController = LoginViewController(state: .passwordCreated)
                loginViewController.credentials = credentials
                return loginViewController
            case .NotAuthorized:
                let loginViewController = LoginViewController(state: .passwordIsNotSet)
                loginViewController.credentials = credentials
                return loginViewController
        }
    }
    
    private func checkUserInKeyChain(credentials: Credentials) -> State {
        
        let keychainItemQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
        ] as CFDictionary
        
        let status = SecItemCopyMatching(keychainItemQuery, nil)
        
        guard status != errSecItemNotFound else {
            return .NotAuthorized
        }
        return .Authorized
    }
}
