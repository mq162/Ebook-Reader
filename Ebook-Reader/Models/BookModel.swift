//
//  BookModel.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class BookModel {
    
    var coverImage: UIImage?
    var bookName: String
    var progress: Int = 0
    var bookPath: String
    var authorName: String?
    
    lazy var insertTime: TimeInterval = NSDate().timeIntervalSince1970
    
    var fullPath: String {
        get {
            return SystemFileManager.bookUnzipPath + "/" + bookPath
        }
    }
    
    init(with bookName: String, path: String) {
        self.bookName = bookName
        self.bookPath = path
    }
    
    static func model(with bookMeta: FRBook, path: String, imageMaxWidth: CGFloat?) -> BookModel {
        let book = BookModel.init(with: bookMeta.title ?? "No title", path: path)
        if let coverUrl = bookMeta.coverImage?.fullHref {
            if let imageMaxWidth = imageMaxWidth {
                book.coverImage = UIImage(contentsOfFile: coverUrl)?.scaled(toWidth:imageMaxWidth, scale: 2)
            } else {
                book.coverImage = UIImage(contentsOfFile: coverUrl)
            }
        }
        book.authorName = bookMeta.authorName
        return book
    }
}
