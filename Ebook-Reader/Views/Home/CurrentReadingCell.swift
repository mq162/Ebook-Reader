//
//  CurrentReadingCell.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit
import SnapKit

protocol CurrentReadingDelegate: AnyObject {
    func homeCurrentReadingCellDidClickKeepReading()
    func homeCurrentReadingCellDidClickFindBook()
}

final class CurrentReadingCell: UICollectionViewCell {
    
    static let bookCoverH: CGFloat = 70
    static let bookContentH: CGFloat = bookCoverH / bookCoverScale
    static let cellHeight: CGFloat = 153.5 + bookContentH
    
    let pogressH: CGFloat = 20
    
    var bookContentView: UIView?
    
    var bookCover: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 3
        img.layer.masksToBounds = true
        return img
    }()
    
    var bookNameLabel: UILabel?
    
    var authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(hexStr:"333333")
        return lbl
    }()
    
    var progressLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(hexStr:"999999")
        lbl.layer.masksToBounds = true
        return lbl
    }()
    
    var emptyLabel: UILabel?
    
    var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.font = .systemFont(ofSize: 18)
        lbl.textColor = .black
        return lbl
    }()
    
    weak var delegate: CurrentReadingDelegate?
    
    
    var readingBtn = UIButton.init(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bookContentView != nil {
            let progressY = authorLabel.frame.maxY + 10
            let progressW = ((progressLabel.text ?? "") as NSString).size(withAttributes: [.font: progressLabel.font!]).width + 12
            progressLabel.frame = CGRect(x: authorLabel.x, y: progressY, width: progressW, height: pogressH)
        }
    }
    
    var readingModel: CurrentReadingModel? {
        didSet {
            if let isReading = readingModel?.isReading, isReading {
                addBookContentViewIfNeeded()
                emptyLabel?.isHidden = true
                bookContentView?.isHidden = false
                readingBtn.setTitle("Continue Reading", for: .normal)
                
                bookCover.image = readingModel?.coverImage
                bookNameLabel?.text = readingModel?.bookName
                authorLabel.text = readingModel?.author ?? "Anonymous"
                
                updateProgressLabelText()
            } else {
                addEmptyLabelIfNeeded()
                bookContentView?.isHidden = true
                emptyLabel?.isHidden = false
                readingBtn.setTitle("Add book", for: .normal)
            }
        }
    }
    
    func updateProgressLabelText() {
        var textColor: UIColor?
        var bgColor: UIColor?
        var textAlignment: NSTextAlignment?
        if let progress = readingModel?.progress {
            if progress <= 0 {
                progressLabel.text = "Add"
                bgColor = UIColor.rgba(255, 156, 0, 1)
                textAlignment = .center
                textColor = .white
            } else if progress >= 100 {
                progressLabel.text = "Finished"
            } else {
                progressLabel.text = "\(progress)%"
            }
        } else {
            progressLabel.text = ""
        }
        progressLabel.textColor = textColor ?? UIColor(hexStr: "666666")
        progressLabel.textAlignment = textAlignment ?? .left
        progressLabel.backgroundColor = bgColor ?? UIColor.clear
    }
    
    func addEmptyLabelIfNeeded() {
        if emptyLabel != nil {
            return
        }
        let emptyLabel = UILabel()
        self.emptyLabel = emptyLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textColor = UIColor(hexStr: "666666")
        emptyLabel.text = "Dear, you don’t have any books you are currently reading, so let’s add a good book and have a look~"
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(readingBtn.snp.top).offset(-20)
        }
    }
    
    func addBookContentViewIfNeeded() {
        if bookContentView != nil {
            return
        }
        
        bookContentView = UIView()
        addSubview(bookContentView!)
        
        bookContentView!.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(CurrentReadingCell.bookContentH)
        }
        
        bookContentView!.addSubview(bookCover)
        bookCover.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(bookContentView!)
            make.width.equalTo(CurrentReadingCell.bookCoverH)
        }
        
        bookContentView!.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.centerY.right.equalTo(bookContentView!)
            make.left.equalTo(bookCover.snp.right).offset(10)
        }
       
        bookContentView!.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(authorLabel.snp.top).offset(-10)
            make.left.equalTo(authorLabel)
            make.right.equalTo(bookContentView!)
        }
        
        progressLabel.layer.cornerRadius = pogressH * 0.5
        bookContentView!.addSubview(progressLabel)
    }
    
    func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        titleLabel.textColor = .black
        titleLabel.text = "Current reading"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.top.left.equalTo(self).offset(20)
        }
        
        let readingBtnH: CGFloat = 49.5
        readingBtn.addTarget(self, action: #selector(didClickReadingButton), for: .touchUpInside)
        readingBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        readingBtn.backgroundColor = .black
        readingBtn.layer.cornerRadius = readingBtnH / 2
        addSubview(readingBtn)
        readingBtn.snp.makeConstraints { (make) in
            make.height.equalTo(readingBtnH)
            make.bottom.equalTo(self).offset(-20)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
    }
    
    @objc func didClickReadingButton() {
        guard let readingModel = readingModel else { return }
        if readingModel.isReading {
            delegate?.homeCurrentReadingCellDidClickKeepReading()
        } else {
            delegate?.homeCurrentReadingCellDidClickFindBook()
        }
    }
}
