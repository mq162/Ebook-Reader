//
//  ChapterCell.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import SnapKit

class ChapterCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    var separatorLine = UIView()
    var isSection = false
    
    var tocReference :FRTocReference! {
        didSet {
            titleLabel.text = tocReference.title
            isSection = tocReference.children.count > 0
            if isSection {
                titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 15)
            }
            self.setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    override var isHighlighted: Bool {
        willSet {
            if newValue {
                contentView.backgroundColor = UIColor.rgba(200, 200, 200, 0.5)
            } else {
                contentView.backgroundColor = UIColor.clear
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? UIColor.rgba(255, 156, 0, 1) : ReaderConfig.textColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = 20
        let titleX: CGFloat = isSection ? 10 : spacing
        titleLabel.frame = CGRect(x: titleX, y: 0, width: contentView.width - titleX - spacing, height: contentView.height)
    }
    
    // MARK: - Private
    
    private func setupSubviews() {
        
        titleLabel.textAlignment = .left
        titleLabel.textColor = ReaderConfig.textColor
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(separatorLine)
        separatorLine.backgroundColor = ReaderConfig.separatorColor
        separatorLine.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(contentView)
            make.height.equalTo(1)
        }
    }
}

