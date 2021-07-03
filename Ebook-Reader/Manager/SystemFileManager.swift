//
//  SystemFileManager.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

enum FileType: String {
    case Epub = "epub"
}

enum DirectoryType: String {
    case Books = "books"
    /// AirDrop
    case Inbox = "Inbox"
    case Share = "Share"
}

class SystemFileManager: NSObject {
    
    static let shared: SystemFileManager = SystemFileManager()
    
    /// epub books path
    static let bookUnzipPath: String = {
        let path = DocumentDirectoryPath + "/" + DirectoryType.Books.rawValue
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    static let bookSharePath: String = {
        let path = DocumentDirectoryPath + "/" + DirectoryType.Share.rawValue
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    static let wifiUploadPath: String = {
        let path = CachesDirectoryPath + "/wifiupload"
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    var fileQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "ir_file_queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        return queue
    }()
    
    var bookPathList: [String] {
        get {
            // 注意：subpathsOfDirectory 会返回所有子路径(递归)
            guard let pathList = try? FileManager.default.contentsOfDirectory(atPath: SystemFileManager.bookUnzipPath) else { return [String]() }
            var bookPaths = [String]()
            for path in pathList {
                if !path.hasSuffix(FileType.Epub.rawValue) {
                    continue
                }
                bookPaths.append(SystemFileManager.bookUnzipPath + "/" + path)
            }
            return bookPaths
        }
    }
    
    func deleteAirDropFileContents() {
        let path = DocumentDirectoryPath + "/" + DirectoryType.Inbox.rawValue
        try? FileManager.default.removeItem(atPath: path)
        print("")
    }
    
    func addEpubBookByShareUrl(_ url: URL, completion: @escaping (_ bookPath: String?, _ success: Bool) -> Void) {
        // System-Declared Uniform Type Identifiers: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
        let isEpub = url.isFileURL && url.pathExtension == FileType.Epub.rawValue
        if !isEpub { return }
        
        fileQueue.addOperation {
            defer {
                self.deleteAirDropFileContents()
            }
            
            let bookPath = url.lastPathComponent
            let fullPath = SystemFileManager.bookUnzipPath + "/" + bookPath
            // filter duplicate file which shared by Airdrop if needed
            if let airdropFlagIdx = bookPath.lastIndex(of: "-") {
                let bookName = String(bookPath[..<airdropFlagIdx]) + "." + FileType.Epub.rawValue
                if FileManager.default.fileExists(atPath: SystemFileManager.bookUnzipPath + "/" + bookName) {
                    print("Duplicate file \(bookName)")
                    DispatchQueue.main.async {
                        completion(fullPath, true)
                    }
                    return
                }
            }
            
            if FileManager.default.fileExists(atPath: fullPath) {
                print("Exist file \(bookPath)")
                DispatchQueue.main.async {
                    completion(fullPath, true)
                }
                return
            }
            
            // 注意：不要使用 url.absoluteString，否则会报下面错误： couldn’t be moved to “tmp” because either the former doesn't exist, or the folder containing the latter doesn't exist
            let epubParser: FREpubParser = FREpubParser()
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: url.path, unzipPath: SystemFileManager.bookUnzipPath) else {
                print("Import failed")
                DispatchQueue.main.async {
                    completion(nil, false)
                }
                return
            }
            let book = BookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: ScreenWidth * 0.5)
            BookshelfManager.insertBook(book)
            DispatchQueue.main.async {
                completion(fullPath, true)
                NotificationCenter.default.post(name: .ImportEpubBookNotification, object: bookPath)
            }
        }
    }
    
    func addEpubBookByWifiUploadBookPath(_ path: String) {
        let bookUrl = URL.init(fileURLWithPath: path)
        let isEpub = bookUrl.pathExtension == FileType.Epub.rawValue
        if !isEpub { return }
        
        fileQueue.addOperation {
            
            let bookPath = bookUrl.lastPathComponent
            let fullPath = SystemFileManager.bookUnzipPath + "/" + bookPath
            
            if FileManager.default.fileExists(atPath: fullPath) {
                print("Exist file \(bookPath)")
                return
            }
            let epubParser: FREpubParser = FREpubParser()
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: bookUrl.path, unzipPath: SystemFileManager.bookUnzipPath) else {
                print("Import failed")
                return
            }
            let book = BookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: ScreenWidth * 0.5)
            BookshelfManager.insertBook(book)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .ImportEpubBookNotification, object: bookPath)
            }
        }
    }
}
