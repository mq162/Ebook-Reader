//
//  ChapterTipView.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//
import UIKit
import SnapKit

class ChapterTipView: UIView {
    
    static let viewHeight: CGFloat = 40
    
    var titleLabel = UILabel()
    var pageIdxLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    func setupSubviews() {
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.5
        
        let spacing: CGFloat = 4
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(self).offset(spacing)
            make.right.equalTo(self).offset(-spacing)
        }
        
        pageIdxLabel.font = UIFont.systemFont(ofSize: 10)
        pageIdxLabel.textAlignment = .center
        self.addSubview(pageIdxLabel)
        pageIdxLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(spacing)
            make.right.bottom.equalTo(self).offset(-spacing)
        }
        
        self.updateThemeColor()
    }
    
    func update(title: String?, pageIndex: Int) {
        titleLabel.text = title
        pageIdxLabel.text = "第\(pageIndex)页"
    }
    
    func updateThemeColor() {
        
        self.layer.borderColor = ReaderConfig.separatorColor.cgColor
        self.backgroundColor = ReaderConfig.textColor
        titleLabel.textColor = ReaderConfig.pageColor
        pageIdxLabel.textColor = ReaderConfig.pageColor
    }
}
