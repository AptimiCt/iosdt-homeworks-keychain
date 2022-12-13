//
//  FileManagerService.swift
//  iosdt-5
//
//  Created by Александр Востриков on 11.12.2022.
//

import Foundation

final class FileManagerService {
    
    private let managerService = FileManager.default
    
    private var path: URL {
        managerService.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func contentsOfDirectory() throws -> [URL] {
        let documentsUrl = try managerService.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
        let contentsOfDirectory = try managerService.contentsOfDirectory(at: documentsUrl,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.skipsHiddenFiles])
//        Распечатать путь до каталога documents симулятора
//        print(documentsUrl)
        return contentsOfDirectory
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
}

extension URL {
    func isDirectory() throws -> Bool? {
        try resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory
    }
}
