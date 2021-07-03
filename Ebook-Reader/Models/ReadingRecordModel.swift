//
//  ReadingRecordModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

class ReadingRecordModel: NSObject ,NSCoding {
    
    var chapterIdx: Int = 0
    var pageIdx: Int = 0
    var textRange = NSMakeRange(0, 0)
    
    init(_ chapterIdx: Int, _ pageIdx: Int, _ range: NSRange) {
        super.init()
        self.chapterIdx = chapterIdx
        self.pageIdx = pageIdx
        self.textRange = range
    }
    
    required init?(coder: NSCoder) {
        super.init()
        chapterIdx = coder.decodeInteger(forKey: "chapterIdx")
        pageIdx =  coder.decodeInteger(forKey: "pageIdx")
        if let range = coder.decodeObject(forKey: "textRange") as? NSRange {
            textRange = range
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(chapterIdx, forKey: "chapterIdx")
        coder.encode(pageIdx, forKey: "pageIdx")
        coder.encode(textRange, forKey: "textRange")
    }
}
