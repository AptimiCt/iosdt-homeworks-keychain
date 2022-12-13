//
//  AppCoordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 20.11.2022.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    private(set) var childCoordinators: [Coordinator] = []
    
    private let window: UIWindow
    private var status: Resources.Status = .NotAuthorized
    
    init(window: UIWindow) {
        self.window = window
    }
    deinit{
        print("AppCoordinator удален")
    }
    
    //Насколько корректно реализован Главный координатор?
    func startApp() {
        switch status {
            case .NotAuthorized:
                runAuth()
            case .Authorized:
                runMain()
        }
        window.makeKeyAndVisible()
    }
    
    private func runAuth() {
        let loginCoordinator = LoginCoordinator()
        loginCoordinator.output = self
        loginCoordinator.startApp()
        window.rootViewController = loginCoordinator.rootViewController
        childCoordinators.append(loginCoordinator)
    }
    
    private func runMain() {
        let tabBarCoordinator = TabBarCoordinator()
        tabBarCoordinator.output = self
        tabBarCoordinator.startApp()
        window.rootViewController = tabBarCoordinator.rootViewController
        childCoordinators.append(tabBarCoordinator)
    }
    
    private func add(coordinator: Coordinator){
        for childCoordinator in childCoordinators {
            if childCoordinator === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    private func remove(coordinator: Coordinator) {
        guard childCoordinators.isEmpty == false else { return }
        for (index, item) in childCoordinators.enumerated() {
            if item === coordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
}

extension AppCoordinator: OutputProtocol {
    func exit(with status: Resources.Status, and coordinator: Coordinator) {
        remove(coordinator: coordinator)
        self.status = status
        self.startApp()
    }
}
