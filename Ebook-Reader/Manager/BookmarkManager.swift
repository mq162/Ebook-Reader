//
//  BookmarkManager.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

class BookmarkManager: NSObject {

    static var tableListdMap = [String: Bool]()
    
    class func tableName(withBookName name: String) -> String {
        var tablePrefix = name
        tablePrefix = tablePrefix.replacingOccurrences(of: " ", with: "")
        return tablePrefix + "_bookmark_table"
    }

    class func creatBookmarkTableIfNeeded(withName name: String) {
        var hasCreated = false
        if let value = tableListdMap[name] {
            hasCreated = value
        }
        if hasCreated {
            return
        }
        
        // //Mutil PRIMARY KEY: https://stackoverflow.com/questions/734689/sqlite-primary-key-on-multiple-columns
        let sql = "CREATE TABLE IF NOT EXISTS \(name)" + "(chapterIdx \(DBType.INTEGER.rawValue)," +
                                                         "textLoction \(DBType.INTEGER.rawValue)," +
                                                         "markTime \(DBType.INTEGER.rawValue)," +
                                                         "chapterName \(DBType.TEXT.rawValue)," +
                                                         "content \(DBType.TEXT.rawValue)," +
                                                         "PRIMARY KEY(chapterIdx, textLoction))"
        
        let success = DBManager.shared.executeUpdate(sql, values: nil)
        if success {
            objc_sync_enter(self)
            tableListdMap[name] = true
            objc_sync_exit(self)
            print("Bookmark table creat succeed")
        } else {
            print("Bookmark table creat failed")
        }
    }
    
    class func insertBookmark(_ mark: BookmarkModel, into bookName: String) {
        let tableName = self.tableName(withBookName: bookName)
        self.creatBookmarkTableIfNeeded(withName: tableName)
        let sql = "INSERT INTO \(tableName)" + "(chapterIdx, textLoction, markTime, chapterName, content)" + "VALUES (?,?,?,?,?)"
        let values: [Any] = [mark.chapterIdx, mark.textLoction, mark.markTime, mark.chapterName ?? NSNull(), mark.content ?? NSNull()]
        let success = DBManager.shared.executeUpdate(sql, values: values)
        if !success {
            print("Insert failed")
        } else {
            print("Insert succeed")
        }
        DBManager.shared.close()
    }
    
    /**
     1. https://stackoverflow.com/questions/9475995/delete-row-from-sqlite-database-with-fmdb
     2. DELETE FROM table_name WHERE [condition]; 使用 AND 或 OR 运算符来结合 N 个数量的条件
     */
    class func deleteBookmark(from bookName: String, chapterIdx: Int, textRange: NSRange) {
        let tableName = self.tableName(withBookName: bookName)
        self.creatBookmarkTableIfNeeded(withName: tableName)
        
        let sql = "DELETE FROM \(tableName) WHERE chapterIdx = ? AND textLoction >= ? AND textLoction < ?"
        let success = IRDBManager.shared.executeUpdate(sql, values: [chapterIdx, textRange.location, textRange.location + textRange.length])
        if !success {
            print("Delete failed")
        } else {
            print("Delete succeed")
        }
        DBManager.shared.close()
    }
}

// MARK: Public
extension BookmarkManager {
    
    class func loadBookmarkList(withBookName name: String?, completion: ([BookmarkModel]?, Error?) -> Void) {
        guard let name = name else { return }
        let tableName = self.tableName(withBookName: name)
        self.creatBookmarkTableIfNeeded(withName: tableName)
        let sql = "SELECT * FROM \(tableName)"
        DBManager.shared.executeQuery(sql, values: nil) {
            
            guard let resultSet = $0 else {
                completion(nil, $1)
                return
            }
            var bookmarkList = [BookmarkModel]()
            while resultSet.next() {
                let markTime = resultSet.double(forColumn: "markTime")
                let chapterIdx = resultSet.long(forColumn: "chapterIdx")
                let textLoction = resultSet.long(forColumn: "textLoction")
                let chapterName = resultSet.string(forColumn: "chapterName")
                let content = resultSet.string(forColumn: "content")
     
                let bookmark = BookmarkModel.init(chapterIdx: chapterIdx, chapterName: chapterName, textLoction: textLoction)
                bookmark.markTime = markTime
                bookmark.content = content
                bookmarkList.append(bookmark)
            }
            completion(bookmarkList, nil)
        }
        DBManager.shared.close()
    }
}
