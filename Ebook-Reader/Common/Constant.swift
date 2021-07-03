//
//  Constant.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

let bookCoverScale: CGFloat = 0.72
let bookCellBottomHeight: CGFloat = 40

let AppThemeColor = UIColor.init(red: 1, green: 156/255.0, blue: 0, alpha: 1)

let SeparatorColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05)

let ScreenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

/// Documents
let DocumentDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
/// Library
let LibraryDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
/// Library/Caches
let CachesDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
