//
//  BookshelfManager.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class BookshelfManager {

    static var hasCreated = false
    static let kTableName  = "bookshelf_table"
    static let kCoverImage = "coverImage"
    static let kBookName   = "bookName"
    static let kProgress   = "progress"
    static let kBookPath   = "bookPath"
    static let kInsertTime = "insertTime"
    static let kAuthorName = "authorName"
    
    class func creatBookshelfTableIfNeeded() {
        if hasCreated {
            return
        }
        let sql = "CREATE TABLE IF NOT EXISTS \(kTableName)" + "(\(kCoverImage) \(DBType.BLOB.rawValue)," +
                                                         "\(kBookName) \(DBType.TEXT.rawValue)," +
                                                         "\(kAuthorName) \(DBType.TEXT.rawValue)," +
                                                         "\(kProgress) \(DBType.INTEGER.rawValue)," +
                                                         "\(kInsertTime) \(DBType.REAL.rawValue)," +
                                                         "\(kBookPath) \(DBType.TEXT.rawValue))"
        let success = DBManager.shared.executeUpdate(sql, values: nil)
        if success {
            hasCreated = true
            print("Bookshelf table creat succeed")
        } else {
            print("Bookshelf table creat failed")
        }
    }
    
    class func asyncInsertBook(_ book: BookModel) {
        DispatchQueue.global().async {
            self.insertBook(book)
        }
    }
    
    class func insertBook(_ book: BookModel) {
        self.creatBookshelfTableIfNeeded()
        let sql = "INSERT INTO \(kTableName)" + "(\(kCoverImage), \(kBookName), \(kAuthorName), \(kInsertTime), \(kProgress), \(kBookPath))" + "VALUES (?,?,?,?,?,?)"
        let imgData = book.coverImage?.jpegData(compressionQuality: 0.8)
        let values: [Any] = [imgData ?? NSNull(), book.bookName, book.authorName ?? NSNull(), book.insertTime, book.progress, book.bookPath]
        let success = DBManager.shared.executeUpdate(sql, values: values)
        if !success {
            print("Insert failed")
        } else {
            print("Insert succeed")
        }
        DBManager.shared.close()
    }
    
    class func deleteBook(_ book: BookModel) {
        self.creatBookshelfTableIfNeeded()
        let sql = "DELETE FROM \(kTableName) WHERE \(kBookName) = ? AND \(kBookPath) = ?"
        let success = DBManager.shared.executeUpdate(sql, values: [book.bookName, book.bookPath])
        if !success {
            print("Delete failed")
        } else {
            print("Delete succeed")
        }
        DBManager.shared.close()
    }
    
    class func updateBookPregress(_ progress: Int, bookPath: String) {
        self.creatBookshelfTableIfNeeded()
        let sql = "UPDATE \(kTableName) SET \(kProgress) = ? WHERE \(kBookPath) = ?"
        let success = DBManager.shared.executeUpdate(sql, values: [progress, bookPath])
        if !success {
            print("Update failed")
        } else {
            print("Update succeed")
        }
        DBManager.shared.close()
    }
    
    class func loadBookWithPath(_ path: String, completion: (BookModel?, Error?) -> Void) {
        self.creatBookshelfTableIfNeeded()
        let sql = "SELECT * FROM \(kTableName) WHERE \(kBookPath) = ?"
        DBManager.shared.executeQuery(sql, values: [path]) {
            guard let resultSet = $0 else { completion(nil, $1); return }
            var bookList = [BookModel]()
            while resultSet.next() {
                let book = BookModel.init(with: resultSet.string(forColumn: kBookName)!, path: resultSet.string(forColumn: kBookPath)!)
                if let imgData = resultSet.data(forColumn: kCoverImage) {
                    book.coverImage = UIImage(data: imgData)
                }
                book.authorName = resultSet.string(forColumn: kAuthorName)
                book.insertTime = Double(resultSet.int(forColumn: kInsertTime))
                book.progress = Int(resultSet.int(forColumn: kProgress))
                bookList.append(book)
            }
            completion(bookList.first, nil)
        }
        DBManager.shared.close()
    }
    
    class func loadBookList(completion: ([BookModel]?, Error?) -> Void) {
        self.creatBookshelfTableIfNeeded()
        let sql = "SELECT * FROM \(kTableName) ORDER BY \(kInsertTime) DESC"
        DBManager.shared.executeQuery(sql, values: nil) {
            guard let resultSet = $0 else { completion(nil, $1); return }
            var bookList = [BookModel]()
            while resultSet.next() {
                let book = BookModel(with: resultSet.string(forColumn: kBookName)!, path: resultSet.string(forColumn: kBookPath)!)
                if let imgData = resultSet.data(forColumn: kCoverImage) {
                    book.coverImage = UIImage.init(data: imgData)
                }
                book.authorName = resultSet.string(forColumn: kAuthorName)
                book.insertTime = Double(resultSet.int(forColumn: kInsertTime))
                book.progress = Int(resultSet.int(forColumn: kProgress))
                bookList.append(book)
            }
            completion(bookList, nil)
        }
        DBManager.shared.close()
    }
}
