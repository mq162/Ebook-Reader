//
//  ReadingRecordManager.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

class ReadingRecordManager {

    static let directoryPath = "/ReadingRecord"
    
    class func readingRecord(with bookName: String) -> ReadingRecordModel {
        guard let archiveURL = URL(string: readingRecordPath(with: bookName)),
              let archivedData = try? Data(contentsOf: archiveURL),
              let customObject = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData)) as? ReadingRecordModel
        else {
            return ReadingRecordModel(0, 0, NSMakeRange(0, 0))
        }
        
        return customObject
        //        if let readingRecord = NSKeyedUnarchiver.unarchiveObject(withFile: self.readingRecordPath(with: bookName)) as? IRReadingRecordModel {
        //            return readingRecord
        //        }
        //        return IRReadingRecordModel(0, 0, NSMakeRange(0, 0))
    }
    
    class func setReadingRecord(record: ReadingRecordModel, bookName: String) {
        guard let dataToBeArchived = try? NSKeyedArchiver.archivedData(withRootObject: record, requiringSecureCoding: true),
              let archiveURL = URL(string: readingRecordPath(with: bookName))
        else  {
            return
        }
        
        try? dataToBeArchived.write(to: archiveURL)
        
        //        DispatchQueue.global().async {
        //            NSKeyedArchiver.archiveRootObject(record, toFile: self.readingRecordPath(with: bookName))
        //        }
    }
    
    class func readingRecordPath(with bookName: String) -> String  {
        let dirPath = DocumentDirectoryPath + directoryPath
        let isExist = FileManager.default.fileExists(atPath: dirPath)
        if !isExist {
            do {
                try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: dirPath), withIntermediateDirectories: true, attributes: nil)
            } catch  {
                print("Create Directory faile: \(error)")
                return DocumentDirectoryPath + "/" + bookName
            }
        }
        return dirPath + "/" + bookName
    }
}
