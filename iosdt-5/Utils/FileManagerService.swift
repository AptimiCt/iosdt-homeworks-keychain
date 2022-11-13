//
//  FileManagerService.swift
//  Navigation
//
//  Created by Александр Востриков on 09.11.2022.
//

import Foundation

final class FileManagerService: FileManagerServiceProtocol {
    
    private let managerService = FileManager.default

    func contentsOfDirectory() throws -> [URL: String] {
        let documentsUrl = try managerService.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
        let contentsOfDirectory = try managerService.contentsOfDirectory(at: documentsUrl,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.skipsHiddenFiles])
        let contents = try urlToDict(urls: contentsOfDirectory)
//        Распечатать путь до каталога documents симулятора
//        print(documentsUrl)
        return contents
    }
    
    func createFile(name: String, data: Data) throws {
        let documentsUrl = try managerService.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
        let file = documentsUrl.appendingPathComponent(name)
        managerService.createFile(atPath: file.path, contents: data)
    }
    
    func removeContent(at url: URL) throws{
        try managerService.removeItem(at: url)
    }
    
    private func urlToDict(urls: [URL]) throws -> [URL: String] {
        var contents: [URL: String] = [:]
        for url in urls {
            let attributes = try managerService.attributesOfItem(atPath: url.path)
            let typeAttributes = attributes[.type] as? String
            contents[url] = typeAttributes
        }
        return contents
    }
}
