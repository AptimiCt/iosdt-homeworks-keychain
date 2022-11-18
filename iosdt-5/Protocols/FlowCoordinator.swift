//
//  FlowCoordinator.swift
//  iosdt-5
//
//  Created by Александр Востриков on 16.11.2022.
//

import UIKit

protocol FlowCoordinator: AnyObject {
    func startFlow(coordinator: FlowCoordinator)
}
