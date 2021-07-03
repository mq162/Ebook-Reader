//
//  DBManager.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import FMDB


enum DBType: String {
    case NULL    = "NULL"
    
    case INTEGER = "INTEGER"
    
    case REAL    = "REAL"
    
    case TEXT    = "TEXT"
    
    case BLOB    = "BLOB"
}

class DBManager: NSObject {

    static let shared: DBManager = DBManager()
    
    lazy var fmdbQueue: FMDatabaseQueue? = {
        var dbPath = DocumentDirectoryPath
        dbPath = dbPath.appendingPathComponent("iread.sqlite")
        print(dbPath);
        let queue = FMDatabaseQueue.init(path: dbPath)
        return queue
    }()
    
    func close() {
        fmdbQueue?.close()
    }
    
    func executeQuery(_ sql: String, values: [Any]?, completion: (FMResultSet?, Error?) -> Void) {
        fmdbQueue?.inDatabase({ (db) in
            do {
                let resultSet = try db.executeQuery(sql, values: values)
                completion(resultSet, nil)
            } catch {
                completion(nil, error)
                print("failed: \(error.localizedDescription)")
            }
        })
    }
    
    func executeUpdate(_ sql: String, values: [Any]?) -> Bool {
        
        var success = false
        fmdbQueue?.inDatabase({ (db) in
            do {
                try db.executeUpdate(sql, values: values)
                success = true
            } catch {
                print("failed: \(error.localizedDescription)")
            }
        })
        return success
    }
}
