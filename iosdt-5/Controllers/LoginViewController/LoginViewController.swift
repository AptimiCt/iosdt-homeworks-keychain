//
//  LoginViewController.swift
//  iosdt-5
//
//  Created by Александр Востриков on 16.11.2022.
//

import UIKit

final class LoginViewController: UIViewController {
    
    var credentials: Credentials?
    var coordinator: FlowCoordinator?
    
    private var state: Resources.state
    private var screen: Resources.screen?
    
    private var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    private lazy var checkButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        config.cornerStyle = .large
        config.baseBackgroundColor = .blue
        button.configuration = config
        button.addAction(UIAction { [weak self] _ in
            self?.checkButtonAction()
        }, for: .touchUpInside)
        return button
    }()
    
    init(state: Resources.state) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureButtonForState()
    }
    //MARK: - private func
    private func configureLayout() {
        self.screen = .first
        view.backgroundColor = .white
        passwordTextField.delegate = self
        checkButton.isEnabled = false
        
        view.addSubview(passwordTextField)
        view.addSubview(checkButton)
        
        [
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIScreen.main.bounds.height / 3),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.bottomAnchor.constraint(equalTo: checkButton.topAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalTo: checkButton.heightAnchor),
            
            checkButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            checkButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            checkButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ].forEach { $0.isActive = true }
    }
    
    private func configureButtonForState() {
        switch state {
            case .passwordIsNotSet:
                checkButton.setTitle("Создать пароль", for: .normal)
            case .passwordCreated:
                checkButton.setTitle("Введите пароль", for: .normal)
        }
    }
    
    private func configureButtonFor(screen: Resources.screen) {
        switch screen {
            case .first:
                let title = state == .passwordIsNotSet ? "Создать пароль" : "Введите пароль"
                checkButton.setTitle(title, for: .normal)
            case .second:
                checkButton.setTitle("Повторите пароль", for: .normal)
        }
    }
    private func configureViewToFirst() {
        passwordTextField.text = nil
        checkButton.isEnabled = false
        credentials?.password = ""
        configureButtonFor(screen: .first)
        alertForError(message: Resources.error.passwordsDoNotMatch.rawValue)
    }
    
    private func checkButtonAction() {
        guard let pass = passwordTextField.text else { return }
        guard let screen = screen else { return }
        
        switch screen {
            case .first:
                
                passwordTextField.text = nil
                checkButton.isEnabled = false
                credentials?.password = pass
                
                if let credentials = credentials, state == .passwordCreated {
                    guard let password = retrievePassword(with: credentials) else { return }
                    if password == pass {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = MainTabBarController()
                    } else {
                        configureViewToFirst()
                        //configureButtonFor(screen: .first)
                    }
                } else {
                    self.screen = .second
                    configureButtonFor(screen: .second)
                }
            case .second:
                if let credentials = credentials, credentials.password == pass, state == .passwordIsNotSet {
                    save(credentials: credentials)
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = MainTabBarController()
                    #warning("Убрать код ниже")
                    self.screen = .first
                    configureViewToFirst()
                    //configureButtonFor(screen: .first)
                    
                } else {
                    self.screen = .first
                    configureViewToFirst()
                    //configureButtonFor(screen: .first)
                }
        }
    }
    private func passwordIsValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{3,}")
        return passwordTest.evaluate(with: password)
    }
    private func alertForError(message: String) {
        
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func save(credentials: Credentials) {
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
    
    private func retrievePassword(with credentials: Credentials) -> String? {
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
    
}
//MARK: - extension LoginViewController: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false}
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if passwordIsValid(updatedText) {
            checkButton.isEnabled = true
        } else {
            checkButton.isEnabled = false
        }
        return true
    }
}
