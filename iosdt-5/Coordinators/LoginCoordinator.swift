//
//  LoginCoordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 16.11.2022.
//

import UIKit

final class LoginCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController = UIViewController()
    private let keychainService = KeychainService()
    
    private let credentials = Credentials(password: "")
    private lazy var passwordStatus = keychainService.checkUserInKeyChain(credentials: credentials)

    weak var output: OutputProtocol?
    
    func startApp() {
        let loginViewController = LoginViewController(state: passwordStatus, screen: .first)
        loginViewController.credentials = credentials
        loginViewController.authorise = { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.output?.exit(with: status, and: strongSelf)
        }
        self.rootViewController = loginViewController
    }
//    deinit{
//        print("LoginCoordinator удален")
//    }
}
