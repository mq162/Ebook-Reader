//
//  BaseVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class BaseVC: UIViewController {
    
    var backButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func disableLargeTitles() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func enableLargeTitles() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func setupLeftBackBarButton() {
        let backImg = UIImage.init(named: "arrow_back")?.template
        backButtonItem = UIBarButtonItem.init(image: backImg, style: .plain, target: self, action: #selector(didClickedLeftBackItem(item:)))
        backButtonItem?.tintColor = UIColor.rgba(80, 80, 80, 1)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    @objc private func didClickedLeftBackItem(item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
