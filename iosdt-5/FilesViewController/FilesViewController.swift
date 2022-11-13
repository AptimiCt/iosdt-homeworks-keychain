//
//  FilesViewController.swift
//  Navigation
//
//  Created by Александр Востриков on 08.11.2022.
//

import UIKit

final class FilesViewController: UIViewController {
    
    private var contentsDict: [URL: String] = [:] {
        didSet{
            files = dictToArray()
            tableView.reloadData()
        }
    }
    private var files: [URL] = []
    
    let fileManagerService = FileManagerService()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.separatorInset = .zero
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addButtonImagePicker()
        do {
            contentsDict = try fileManagerService.contentsOfDirectory()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        [
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { $0.isActive = true }
    }
    
    private func addButtonImagePicker(){
        let leftButtonItem = UIBarButtonItem(barButtonSystemItem: .camera,
                                             target: self,
                                             action: #selector(openImagePicker))
        navigationItem.title = "Documents"
        navigationItem.setRightBarButton(leftButtonItem, animated: true)
    }
    
    @objc private func openImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
        tableView.reloadData()
    }
    
    private func dictToArray() -> [URL] {
        Array(self.contentsDict.keys).sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}

extension FilesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let file = files[indexPath.row]
        content.text = file.lastPathComponent
        guard let val = contentsDict[file] else {
            cell.contentConfiguration = content
            return cell }

        cell.accessoryType = val == "NSFileTypeDirectory" ? .disclosureIndicator : .none
        cell.contentConfiguration = content
        return cell
    }
}
extension FilesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let urlFile = files.remove(at: indexPath.row)
            do {
                try fileManagerService.removeContent(at: urlFile)
                // Стоит ли тут перечитывать директорию, или может стоило просто удалить значение по ключу из contentsDict и tableView.reloadData()
                try contentsDict = fileManagerService.contentsOfDirectory()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

extension FilesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let url = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerImageURL")] as? URL else { return }
        do {
            let data = try Data(contentsOf: url)
            try fileManagerService.createFile(name: url.lastPathComponent, data: data)
            try contentsDict = fileManagerService.contentsOfDirectory()
        } catch let error {
            print(error.localizedDescription)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
