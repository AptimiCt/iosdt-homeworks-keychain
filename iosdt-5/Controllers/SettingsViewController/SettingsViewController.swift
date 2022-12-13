//
//  SettingsViewController.swift
//  iosdt-5
//
//  Created by Александр Востриков on 14.11.2022.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private var sortLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = "Алфавитная сортировка"
        return label
    }()
    
    private lazy var sortSwitch: UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.changeSort()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var checkButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        config.cornerStyle = .large
        config.baseBackgroundColor = .red
        config.title = "Изменить пароль"
        button.configuration = config
        button.addAction(UIAction { [weak self] _ in
            self?.changePassword()
        }, for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureLayout()
        configureSwitch()
    }
    
    private func configureLayout() {
        view.addSubview(sortLabel)
        view.addSubview(sortSwitch)
        view.addSubview(checkButton)
        [
            sortLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sortLabel.trailingAnchor.constraint(greaterThanOrEqualTo: sortSwitch.leadingAnchor, constant: 20),
            sortLabel.bottomAnchor.constraint(equalTo: sortSwitch.bottomAnchor),
            
            sortSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sortSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
            checkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            checkButton.topAnchor.constraint(greaterThanOrEqualTo: sortSwitch.bottomAnchor, constant: 40),
            checkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            checkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
        ].forEach { $0.isActive = true }
    }
    
    private func changePassword(){
        let credentials = Credentials(password: "")
        let loginCV = LoginViewController(state: .passwordCreated, screen: .changePassword)
        loginCV.credentials = credentials
        present(loginCV, animated: true)
    }
    private func changeSort(){
        writeDefaults(value: sortSwitch.isOn)
    }
    private func readDefaults() -> Bool {
        UserDefaults.standard.bool(forKey: Resources.key.sort.rawValue)
    }
    private func writeDefaults(value: Bool) {
        UserDefaults.standard.set(value, forKey: Resources.key.sort.rawValue)
    }
    private func configureSwitch(){
        if UserDefaults.standard.object(forKey: Resources.key.sort.rawValue) != nil {
            let value = readDefaults()
            sortSwitch.setOn(value, animated: false)
        } else {
            sortSwitch.setOn(true, animated: false)
            writeDefaults(value: true)
        }
    }
}
