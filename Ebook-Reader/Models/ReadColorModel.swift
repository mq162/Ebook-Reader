//
//  ReadColorModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

struct ReadColorModel {
    
    var isSelect = false

    var pageColor = UIColor.white
    var pageColorHex = "FFFFFF"
    
    var borderColor = UIColor.clear
    
    init(pageHex: String, borderColor: UIColor) {

        self.pageColorHex = pageHex
        self.pageColor = UIColor(hexStr: pageHex)
        self.borderColor = borderColor
    }
}
