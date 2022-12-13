//
//  OutputProtocol.swift
//  iosdt-5
//
//  Created by Александр Востриков on 08.12.2022.
//

import Foundation

protocol OutputProtocol: AnyObject {
    func exit(with status: Resources.Status, and coordinator: Coordinator)
}
