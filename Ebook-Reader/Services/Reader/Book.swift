//
//  Book.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

protocol BookParseDelegate: AnyObject {
    
    func bookBeginParse(_ book: Book)
    func book(_ book: Book, currentParseProgress progress: Float)
    func bookDidFinishParse(_ book: Book)
    func book(_ book: Book, didFinishLoadBookmarkList list: [BookmarkModel])
}

class Book: NSObject {

    weak var parseDelegate: BookParseDelegate?
    private var bookMeta: FRBook
    var bookPath: String?
    var coverImage: UIImage?
    var isFinishParse = false
    var pageCount = 0
    var chapterCount = 0
    /// 章节目录偏移: spine.count - chapterlist.count
    var chapterOffset = 0
    
    lazy var chapterList = [BookChapter]()
    /// 当前队列解析id
    var parseQueueId = 0
    /// 当前已解析章节数
    var currentParsedCount = 0
    /// 书签列表
    var bookmarkList = [BookmarkModel]()
    
    var parseQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "book_parse_queue"
        let cores = ProcessInfo.processInfo.activeProcessorCount
        queue.maxConcurrentOperationCount = cores
        queue.qualityOfService = .default
        return queue
    }()
    
    var authorName: String? {
        return bookMeta.authorName
    }
    
    var isChinese: Bool {
        if bookMeta.metadata.language.hasPrefix("zh") {
            return true
        }
        return false
    }
    
    /// 未解析的章节列表
    var flatChapterList: [FRTocReference] {
        get {
            return bookMeta.flatTableOfContents
        }
    }
    
    var bookName: String {
        get {
#if DEBUG
            assert(bookMeta.title != nil, "Book name is nil")
#endif
            return bookMeta.title ?? "无书名"
        }
    }
    
    init(withBookMeta bookMeta: FRBook) {
        self.bookMeta = bookMeta
        super.init()
        
        if let coverUrl = bookMeta.coverImage?.fullHref {
            coverImage = UIImage.init(contentsOfFile: coverUrl)
        }
        chapterCount = bookMeta.spine.spineReferences.count
        chapterOffset = chapterCount - bookMeta.flatTableOfContents.count
    }
    
    convenience init(_ bookMeta: FRBook) {
        self.init(withBookMeta: bookMeta)
    }
    
#if DEBUG
    deinit {
        print("")
    }
#endif
    
    func findChapterIndexByTocReference(_ reference: FRTocReference) -> Int {
        var chapterIndex = 0
        for item in bookMeta.spine.spineReferences {
            if let resource = reference.resource, item.resource == resource {
                return chapterIndex
            }
            chapterIndex += 1
        }
        return chapterIndex
    }
    
    func chapter(at index: Int) -> BookChapter {
        
        if isFinishParse {
            return chapterList[index]
        } else {
            return BookChapter.init(withTocRefrence: self.tocReference(withIndex: index), chapterIndex: index)
        }
    }
    
    func chapter(withPageIndex index: Int) -> BookChapter {
        
        var chapter: BookChapter!
        // Algorithm follow-up optimization
        for item in chapterList {
            if (index >= item.pageOffset!) && (index <= (item.pageOffset! + item.pageList.count)) {
                chapter = item
                break
            }
        }
        
        return chapter
    }
    
    func tocReference(withIndex index: Int) -> FRTocReference {
        let spine = bookMeta.spine.spineReferences[index]
        return bookMeta.tableOfContentsMap[spine.resource.href] ?? FRTocReference.init(title: "", resource: spine.resource)
    }
}

//MARK: Bookmark
extension Book {
    
    func saveBookmark(_ bookmark: BookmarkModel) {
        bookmarkList.append(bookmark)
        BookmarkManager.insertBookmark(bookmark, into: bookName)
    }
    
    func removeBookmark(_ bookmark: BookmarkModel, textRange: NSRange) {
        
        var tempBookmarkList = [BookmarkModel]()
        for item in bookmarkList {
            if  bookmark.chapterIdx == item.chapterIdx &&
                item.textLoction >= textRange.location &&
                item.textLoction <  textRange.location + textRange.length {
                continue
            }
            tempBookmarkList.append(item)
        }
        bookmarkList = tempBookmarkList
        BookmarkManager.deleteBookmark(from: bookName, chapterIdx: bookmark.chapterIdx, textRange: textRange)
    }
    
    func loadBookmarkList() {
        DispatchQueue.global().async { [weak self] in
            BookmarkManager.loadBookmarkList(withBookName: self?.bookName) {list, error in
                DispatchQueue.main.async {
                    self?.handleBookmarkList(list, error: error)
                }
            }
        }
    }
    
    func handleBookmarkList(_ list: [BookmarkModel]?, error: Error?) {
        bookmarkList = list ?? [BookmarkModel]()
        self.parseDelegate?.book(self, didFinishLoadBookmarkList: bookmarkList)
        print("finish")
    }
    
    func isBookmark(withPage page: BookPage?) -> Bool {
        
        guard let pageModel = page else { return false }
        
        var isBookmark = false
        for bookmark in bookmarkList {
            if bookmark.chapterIdx != pageModel.chapterIdx {
                continue
            }
            if bookmark.textLoction == pageModel.range.location {
                isBookmark = true
                break
            }
            if bookmark.textLoction >= pageModel.range.location && bookmark.textLoction < pageModel.range.location + pageModel.range.length  {
                isBookmark = true
                break
            }
        }
        return isBookmark
    }
}

//MARK: Parse
extension Book {
    
    func finishParse(chapterList: [AnyObject]) {
        self.chapterList.removeAll()
        var pageOffset = 0
        var pageCount = 0
        for item in chapterList {
            if !(item is BookChapter) {
                continue
            }
            let chapter = item as! BookChapter
            chapter.pageOffset = pageOffset
            pageOffset += chapter.pageList.count
            pageCount += chapter.pageList.count
            self.chapterList.append(chapter)
        }
        self.pageCount = pageCount
        isFinishParse = true
        self.parseDelegate?.bookDidFinishParse(self)
        print("Finish parse")
    }
    
    func parseChapter(_ chapter: BookChapter, resultList: NSMutableArray, queueId: Int) {
        if chapter.fontName != ReaderConfig.fontName {
            chapter.updateTextFontName(ReaderConfig.fontName)
        } else if chapter.textSizeMultiplier != ReaderConfig.textSizeMultiplier {
            chapter.updateTextSizeMultiplier(ReaderConfig.textSizeMultiplier)
        }
        print(" \(Thread.current) \(chapter.title ?? "") pageCount: \(chapter.pageList.count)")
        DispatchQueue.main.async {
            if queueId != self.parseQueueId { return }
            self.currentParsedCount += 1
            resultList.replaceObject(at: chapter.chapterIdx, with: chapter)
            self.parseDelegate?.book(self, currentParseProgress: Float(self.currentParsedCount) / Float(self.chapterCount))
            if self.currentParsedCount >= self.chapterCount {
                self.finishParse(chapterList: resultList as Array)
            }
        }
    }
    
    func parseSpine(_ spine: Spine, index: Int, resultList: NSMutableArray, queueId: Int) {
        let tocReference: FRTocReference = self.bookMeta.tableOfContentsMap[spine.resource.href] ?? FRTocReference.init(title: "", resource: spine.resource)
        let chapter = BookChapter.init(withTocRefrence: tocReference, chapterIndex: index)
        print(" \(Thread.current) \(chapter.title ?? "") pageCount: \(chapter.pageList.count)")
        DispatchQueue.main.async {
            if queueId != self.parseQueueId { return }
            self.currentParsedCount += 1
            resultList.replaceObject(at: chapter.chapterIdx, with: chapter)
            self.parseDelegate?.book(self, currentParseProgress: Float(self.currentParsedCount) / Float(self.chapterCount))
            if self.currentParsedCount >= self.chapterCount {
                self.finishParse(chapterList: resultList as Array)
            }
        }
    }
    
    func cancleAllParse() {
        parseQueue.cancelAllOperations()
    }
    
    func parseBookMeta() {
        parseQueueId += 1
        parseQueue.cancelAllOperations()
        isFinishParse = false
        currentParsedCount = 0
        self.parseDelegate?.bookBeginParse(self)
        let currentQueueId = parseQueueId
        
        let resultList = NSMutableArray()
        for _ in 0..<chapterCount {
            resultList.add(NSNull())
        }
        if chapterList.count > 0 && chapterList.count == self.chapterCount {
            for chapter in chapterList {
                parseQueue.addOperation { [weak self] in
                    self?.parseChapter(chapter, resultList: resultList, queueId: currentQueueId)
                }
            }
        } else {
            for (index, spine) in bookMeta.spine.spineReferences.enumerated() {
                parseQueue.addOperation { [weak self] in
                    self?.parseSpine(spine, index: index, resultList: resultList, queueId: currentQueueId)
                }
            }
        }
    }
}
