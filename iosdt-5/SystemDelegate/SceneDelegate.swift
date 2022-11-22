//
//  SceneDelegate.swift
//  iosdt-5
//
//  Created by Александр Востриков on 14.11.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator()
        window?.rootViewController = coordinator.startApp()
        window?.makeKeyAndVisible()
    }
}

