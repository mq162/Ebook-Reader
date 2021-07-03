//
//  ReadColorCell.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class ReadColorCell: UICollectionViewCell {
    
    let colorViewSize: CGFloat = 46
    var colorView = UIView()
    
    
    var colorModel: ReadColorModel? {
        willSet {
            
            colorView.backgroundColor = newValue?.pageColor
            var borderWidth: CGFloat = 1
            var borderColor = UIColor.init(white: 0, alpha: 0.1)
            
            if let newValue = newValue {
                if newValue.isSelect {
                    borderWidth = 2.5
                    borderColor = newValue.borderColor
                }
            }
            colorView.layer.borderWidth = borderWidth
            colorView.layer.borderColor = borderColor.cgColor
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
    
    private func setupSubviews() {
        
        colorView.layer.cornerRadius = colorViewSize * 0.5
        self.contentView.addSubview(colorView)
        colorView.snp.makeConstraints { (make) in
            make.height.width.equalTo(colorViewSize)
            make.center.equalTo(self.contentView)
        }
    }
}
