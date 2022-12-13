//
//  SceneDelegate.swift
//  iosdt-5
//
//  Created by Александр Востриков on 14.11.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var coordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window)
        self.coordinator = coordinator
        coordinator.startApp()
    }
}

