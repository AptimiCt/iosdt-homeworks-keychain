//
//  LoginViewController.swift
//  iosdt-5
//
//  Created by Александр Востриков on 11.12.2022.
//

import UIKit
final class LoginViewController: UIViewController {
    
    private let keychainService = KeychainService()
    weak var output: OutputProtocol?
    
    var authorise: ((Resources.Status)->())?
    var credentials: Credentials?
    
    private var state: Resources.state
    private var screen: Resources.screen
    
    private var passwordScreenLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private var passwordTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.8
        textField.clipsToBounds = true
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
    
    init(state: Resources.state, screen:  Resources.screen) {
        self.state = state
        self.screen =  screen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        //configureButtonForState()
        configureViewFor(screen: screen)
    }
    
//    deinit {
//        print("LoginViewController удален")
//    }
    //MARK: - private func
    private func configureLayout() {
        //self.screen = .first
        view.backgroundColor = .white
        passwordTextField.delegate = self
        checkButton.isEnabled = false
        
        view.addSubview(passwordScreenLabel)
        view.addSubview(passwordTextField)
        view.addSubview(checkButton)
        
        [
            
            passwordScreenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordScreenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            passwordScreenLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordScreenLabel.bottomAnchor.constraint(lessThanOrEqualTo: passwordTextField.topAnchor, constant: -50),
            passwordScreenLabel.heightAnchor.constraint(equalTo: checkButton.heightAnchor),
            
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
                passwordScreenLabel.text = "Регистрация"
                checkButton.setTitle("Создать пароль", for: .normal)
            case .passwordCreated:
                passwordScreenLabel.text = "Вход"
                checkButton.setTitle("Введите пароль", for: .normal)
        }
    }
    
    private func configureViewFor(screen: Resources.screen) {
        switch screen {
            case .first:
                configureButtonForState()
            case .second:
                checkButton.setTitle("Повторите пароль", for: .normal)
            case .changePassword:
                passwordScreenLabel.text = "Изменение пароля"
                checkButton.setTitle("Изменить пароль", for: .normal)
        }
    }
    private func configureViewToFirst() {
        passwordTextField.text = nil
        checkButton.isEnabled = false
        credentials?.password = ""
        configureViewFor(screen: .first)
        alertForMessage(message: Resources.message.passwordsDoNotMatch.rawValue,title: "Ошибка")
    }
    
    private func checkButtonAction() {
        guard let pass = passwordTextField.text else { return }
        
        switch screen {
            case .first:
                
                passwordTextField.text = nil
                checkButton.isEnabled = false
                credentials?.password = pass
                
                if let credentials = credentials, state == .passwordCreated {
                    guard let password = keychainService.retrievePassword(with: credentials) else { return }
                    if password == pass {
                        authorise?(.Authorized)
                    } else {
                        configureViewToFirst()
                    }
                } else {
                    self.screen = .second
                    configureViewFor(screen: .second)
                }
            case .second:
                if let credentials = credentials, credentials.password == pass, state == .passwordIsNotSet {
                    keychainService.save(credentials: credentials)
                    authorise?(.Authorized)
                } else {
                    self.screen = .first
                    configureViewToFirst()
                }
            case .changePassword:
                guard let credentials = credentials else { return }
                guard let passwordKC = keychainService.retrievePassword(with: credentials), let newPassword = passwordTextField.text else { return }
                
                if passwordIsValid(newPassword), passwordKC == newPassword {
                    alertForMessage(message: Resources.message.passwordNotCorrect.rawValue, title: "Ошибка")
                } else {
                    if keychainService.updatePassword(with: Credentials(password: newPassword)) {
                        alertForMessage(message: Resources.message.passwordChanged.rawValue, title: "")
                    } else {
                        alertForMessage(message: Resources.message.passwordDidNotChange.rawValue, title: "Ошибка")
                    }
                }
        }
    }
    private func passwordIsValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{3,}")
        return passwordTest.evaluate(with: password)
    }
    private func alertForMessage(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var actionOk: UIAlertAction
        if title == "" {
            actionOk = UIAlertAction(title: "Ok", style: .default) { _ in self.dismiss(animated: true) }
        } else {
            actionOk = UIAlertAction(title: "Ok", style: .default)
        }
        alert.addAction(actionOk)
        self.present(alert, animated: true)
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

class TextFieldWithPadding: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: padding)
    }
}
