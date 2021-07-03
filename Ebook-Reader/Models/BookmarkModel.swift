//
//  BookmarkModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

struct BookmarkModel {

    var markTime: TimeInterval = 0
    var chapterName: String?
    var content: String?
    var chapterIdx: Int = 0
    /// Start of bookmark text
    var textLoction: Int = 0
    
    init(chapterIdx: Int, chapterName: String?, textLoction: Int) {
        self.chapterIdx = chapterIdx
        self.chapterName = chapterName
        self.markTime = Date().timeIntervalSince1970
        self.textLoction = textLoction
    }
}
