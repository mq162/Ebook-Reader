//
//  FontModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class FontModel {
    
    var dispalyName: String
    var fontName: String
    var isDownload = false
    
    init(dispalyName: String, fontName: String) {
        self.dispalyName = dispalyName
        self.fontName = fontName
        self.isDownload = UIFont(name: fontName, size: 20) != nil
    }
}
