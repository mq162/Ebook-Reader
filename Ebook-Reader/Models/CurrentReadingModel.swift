//
//  CurrentReadingModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

struct CurrentReadingModel {
    var isReading = false
    var coverImage: UIImage?
    var bookName: String?
    var author: String?
    var progress: Int = 0
}
