//
//  Coordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 16.11.2022.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get }
    func startApp()
}
