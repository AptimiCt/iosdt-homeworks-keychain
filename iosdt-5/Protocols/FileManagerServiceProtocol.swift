//
//  FileManagerServiceProtocol.swift
//  Navigation
//
//  Created by Александр Востриков on 09.11.2022.
//

import Foundation

protocol FileManagerServiceProtocol {
    func contentsOfDirectory() throws -> [URL: String]
    func createFile(name: String, data: Data) throws
    func removeContent(at url: URL) throws
}
