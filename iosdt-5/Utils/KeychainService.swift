//
//  KeychainService.swift
//  iosdt-5
//
//  Created by Александр Востриков on 04.12.2022.
//

import Foundation

final class KeychainService {
        
    func checkUserInKeyChain(credentials: Credentials) -> Resources.state {
        
        let keychainItemQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
        ] as CFDictionary
        
        let status = SecItemCopyMatching(keychainItemQuery, nil)
        
        guard status != errSecItemNotFound else {
            return .passwordIsNotSet
        }
        return .passwordCreated
    }
    
    func save(credentials: Credentials) {
        guard let passData = credentials.password.data(using: .utf8) else {
            print("Невозможно получить Data из пароля")
            return }
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username,
            kSecValueData: passData
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        guard status == errSecDuplicateItem || status == errSecSuccess else {
            print("Невозможно добавить пароль, ошибка номер: \(status)")
            return
        }
    }
    
    func retrievePassword(with credentials: Credentials) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username,
            kSecReturnData: true
        ] as CFDictionary
        
        var extractedData: AnyObject?
        
        let status = SecItemCopyMatching(query, &extractedData)
        
        guard status == errSecItemNotFound || status == errSecSuccess else {
            print("Невозможно получить пароль, ошибка номер: \(status)")
            return nil
        }
        guard status != errSecItemNotFound else {
            print("Пароль не найден в Keychain")
            return nil
        }
        guard let passData = extractedData as? Data,
              let password = String(data: passData, encoding: .utf8) else {
            print("невозможно преобразовать data в пароль")
            return nil
        }
        return password
    }
    
    func updatePassword(with credentials: Credentials) -> Bool {
        guard let passData = credentials.password.data(using: .utf8) else {
            return false
        }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username,
            kSecReturnData: false
        ] as CFDictionary
        
        let attrToUpdate = [kSecValueData: passData] as CFDictionary
        
        let status = SecItemUpdate(query, attrToUpdate)
        
        guard status == errSecSuccess else {
            print("Не возможно обновить пароль. Ошибка номер: \(status)")
            return false
        }
        return true
    }
}
