//
//  ReadPageViewController.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//
import DTCoreText

class ReadPageViewController: UIViewController {

    private var pageSize = CGSize.zero
    var pageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var contentLabel: DTAttributedLabel = {
        let label = DTAttributedLabel()
        label.backgroundColor = UIColor.clear
        return label
    }()

    var pageModel: BookPage? {
        willSet {
            self.contentLabel.attributedString = newValue?.content
            if let displayPageIdx = newValue?.displayPageIdx {
                self.pageLabel.text = String(displayPageIdx)
            } else {
                self.pageLabel.text = ""
            }
        }
    }
    
    convenience init(withPageSize pageSize: CGSize) {
        self.init()
        self.pageSize = pageSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateThemeColor()
        self.view.addSubview(contentLabel)
        self.view.addSubview(pageLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pageModel?.textColorHex != ReaderConfig.textColorHex {
            pageModel?.textColorHex = ReaderConfig.textColorHex
            pageModel?.updateTextColor(ReaderConfig.textColor)
            self.contentLabel.attributedString = pageModel?.content
        }
        self.view.backgroundColor = ReaderConfig.pageColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pageX = (self.view.width - pageSize.width) / 2.0
        let pageY = (self.view.height - pageSize.height) / 2.0
        contentLabel.frame = CGRect.init(origin: CGPoint.init(x: pageX, y: pageY), size: pageSize)
        
        pageLabel.frame = CGRect.init(x: 0, y: contentLabel.frame.maxY + ReaderConfig.pageIndexSpacing, width: self.view.width, height: 12)
    }
    
    func updateThemeColor() {
        self.view.backgroundColor = ReaderConfig.pageColor
        pageLabel.textColor = ReaderConfig.textColor
    }
}
