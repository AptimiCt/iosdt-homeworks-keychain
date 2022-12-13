//
//  MainTabBarController.swift
//  iosdt-5
//
//  Created by Александр Востриков on 14.11.2022.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var authorise: ((Resources.Status)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
        setTabBarAppearance()
        authorise?(.NotAuthorized)
    }
    
    private func generateTabBar(){
        
        let navController = UINavigationController(rootViewController: FilesViewController())
        
        viewControllers = [
            generateVC(
                viewController: navController,
                title: "Files",
                image: UIImage(systemName: "folder"),
                selectedImage: UIImage(systemName: "folder.fill")
            ),
            generateVC(
                viewController: SettingsViewController(),
                title: "Settings",
                image: UIImage(systemName: "slider.horizontal.3"),
                selectedImage: UIImage(systemName: "slider.horizontal.3")
            )
        ]
    }
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectedImage
        
        return viewController
    }
    
    private func setTabBarAppearance() {
        tabBar.tintColor = .tabBarItemAccent
        tabBar.unselectedItemTintColor = .tabBarItemLight
    }
}

