//
//  PickerModalViewController.swift
//  DemoSSAI
//
//  Created by Pham Hai on 18/10/2024.
//

import Foundation
import UIKit

class PickerModalProfile: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var delegate: PickerModalDelegate?
    var data: [[String: String]] = []
    var selectedItem: [String: String] = [:]
    var selectedIndex: Int = 0
    var selectedIndexPure: Int = 0
    
    var pickerView: UIPickerView!
    // Custom initializer
    init(data: [[String: String]], selectedIndex: Int = 0) {
        self.data = data
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil) // Call the super initializer
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) // Required for storyboard initialization
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)

        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Choose", for: .normal)
        closeButton.addTarget(self, action: #selector(changeSource), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func changeSource() {
        delegate?.didSelectItem(selectedIndex, true)
//        updateHighlightedIndex(selectedIndex)
        dismiss(animated: true, completion: nil)
    }
    public func changeItem(_ index: Int) {
        pickerView.selectRow(index, inComponent: 0, animated: false)
        pickerView.reloadAllComponents()
    }
    public func setData(_ data: [[String: String]]) {
        self.data = data
        pickerView.reloadAllComponents()
    }

    // MARK: - UIPickerView DataSource & Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = data[row]
        let name = item["name"]
        return "\(name!) \(row == selectedIndex && false ? " (Đang phát)" : "")"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = data[row]
        selectedIndex = row
    }
}
