//
//  TabBarCoordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 08.12.2022.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var rootViewController = UITabBarController()
    weak var output: OutputProtocol?
    
    func startApp() {
        let tabBarController = MainTabBarController()
        tabBarController.authorise = { [weak self] status in
            guard let strongSelf = self else { return }
            strongSelf.output?.exit(with: status, and: strongSelf)
        }
        self.rootViewController = tabBarController
    }
    
//    deinit{
//        print("TabBarCoordinator удален")
//    }
}
