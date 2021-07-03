//
//  BookshelfVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class BookshelfVC: BaseVC, ReaderCenterDelegate {
    
    var collectionView: UICollectionView!
    var emptyView: EmptyView?
    var bookList = [BookModel]()
    let sectionEdgeInsetsLR: CGFloat = 30
    let minimumInteritemSpacing: CGFloat = 25
    
    var rowCount: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TabBarName.bookshelf.rawValue
        setupBarButtonItems()
        setupCollectionView()
        addNotifications()
        loadLocalBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        emptyView?.frame = view.bounds
    }
    
    // MARK: - Notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(importEpubBookNotification(_:)), name: .ImportEpubBookNotification, object: nil)
    }
    
    @objc func importEpubBookNotification(_ notification: Notification) {
        guard let bookPath = notification.object as? String else { return }
        
        let epubParser: FREpubParser = FREpubParser()
        let fullPath = SystemFileManager.bookUnzipPath + "/" + bookPath
        guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: fullPath, unzipPath: SystemFileManager.bookUnzipPath) else { return }
        let book = BookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: ScreenWidth * 0.5)
        bookList.insert(book, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    // MARK: - IRReaderCenterDelegate
    func readerCenter(didUpdateReadingProgress progress: Int, bookPath: String) {
        if !self.isViewLoaded {
            BookshelfManager.updateBookPregress(progress, bookPath: bookPath)
            return
        }
        var shouldUpdate = false
        for index in 0..<bookList.count {
            if bookList[index].bookPath == bookPath && bookList[index].progress != progress {
                shouldUpdate = true
                bookList[index].progress = progress
                break
            }
        }
        if shouldUpdate {
            BookshelfManager.updateBookPregress(progress, bookPath: bookPath)
            collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc func wifiButtonDidClick() {
        let wifiVC = UploadVC()
        navigationController?.pushViewController(wifiVC, animated: true)
    }
    
    // MARK: - Private
    
    func setupBarButtonItems() {
        let wifiItem = UIBarButtonItem.init(image: UIImage(named: "file_upload")?.original, style: .plain, target: self, action: #selector(wifiButtonDidClick))
        navigationItem.rightBarButtonItems = [wifiItem]
    }
    
    func loadLocalBooks() {
        self.updateEmptyViewState(.loading)
        DispatchQueue.global().async {
            var bookList: [BookModel]?
            BookshelfManager.loadBookList { (list, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
                bookList = list
            }
            #if DEBUG
            if bookList?.count == 0 {
                bookList = self.testBooks()
            }
            #endif
            
            DispatchQueue.main.async {
                self.bookList = bookList ?? [BookModel]()
                self.collectionView.reloadData()
                self.updateEmptyViewState(.empty)
            }
        }
    }

    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        self.view.addSubview(collectionView)
    }
    
    func updateEmptyViewState(_ state: EmptyState) {
        if (bookList.count == 0) {
            if emptyView == nil {
                emptyView = EmptyView(frame: self.view.bounds)
                emptyView?.setTitle("Empty", subTitle: "Fill up the bookshelf with good books~")
                self.view.addSubview(emptyView!)
            }
            emptyView?.state = state
            emptyView?.isHidden = false
            self.view.bringSubviewToFront(emptyView!)
        } else {
            emptyView?.isHidden = true
        }
    }
}

// MARK: - BookCellDelegate
extension BookshelfVC: BookCellDelegate {
    
    func bookCellDidClickOptionButton(_ cell: BookCell) {
        guard let bookModel = cell.bookModel else { return }
        let bookFullPath = bookModel.fullPath
        let bookPathUrl = URL(fileURLWithPath: bookFullPath)
        let epubItem = ActivityItemProvider(shareUrl: bookPathUrl)
        epubItem.title = bookModel.bookName
        epubItem.icon = bookModel.coverImage
        
        let delete = CustomActivity.init(withTitle: "delete", type: .delete)
        delete.image = UIImage(named: "trash")
        
        let activityVC = UIActivityViewController(activityItems: [epubItem], applicationActivities: [delete])
        // Try to exclude add tags, but failed. I don't konw why 😭
        //        let tagType = UIActivity.ActivityType.init("com.apple.DocumentManagerUICore.AddTagsActionExtension")
        //        activityVC.excludedActivityTypes = [tagType]
        let cellIndex = collectionView.indexPath(for: cell)
        activityVC.completionWithItemsHandler = { (type: UIActivity.ActivityType?, finish: Bool, items: [Any]?, error: Error?) in
            if type == .delete {
                self.showDeleteAlert(with: bookFullPath, at: cellIndex)
            }
        }
        let popover = activityVC.popoverPresentationController
        if popover != nil {
            popover?.sourceView = cell.optionButton
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func deleteBook(at index: IndexPath?, bookPath: String) {
        guard let index = index else { return }
        let book = bookList[index.item]
        BookshelfManager.deleteBook(book)
        bookList.remove(at: index.item)
        collectionView.deleteItems(at: [index])
        self.updateEmptyViewState(.empty)
        do {
            try FileManager.default.removeItem(atPath: bookPath)
        } catch  {
            print(error)
        }
    }
    
    func showDeleteAlert(with bookPath: String, at index: IndexPath?) {
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.view.tintColor = .black
        let delete = UIAlertAction.init(title: "delete", style: .destructive) { (action) in
            self.deleteBook(at: index, bookPath: bookPath)
        }
        let cancle = UIAlertAction.init(title: "cancel", style: .cancel, handler: nil)
        alertVC.addAction(delete)
        alertVC.addAction(cancle)
        self.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView
extension BookshelfVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let bookCell: BookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        bookCell.bookModel = bookList[indexPath.item]
        bookCell.delegate = self
        return bookCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.width - minimumInteritemSpacing * (rowCount - 1) - sectionEdgeInsetsLR * 2) / rowCount)
        return CGSize.init(width: width, height: BookCell.cellHeightWithWidth(width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 15, left: sectionEdgeInsetsLR, bottom: 15, right: sectionEdgeInsetsLR)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = bookList[indexPath.item]
        let readerCenter = ReaderCenterVC.init(withPath: book.fullPath)
        readerCenter.delegate = self
        self.navigationController?.pushViewController(readerCenter, animated: true)
    }
}

// MARK: - DEBUG
#if DEBUG
extension BookshelfVC {
    func testBooks() -> [BookModel] {
        var bookList = [BookModel]()
        if let book = testBook(name: "细说明朝") {
            bookList.append(book)
        }
        if let book = testBook(name: "支付战争") {
            bookList.append(book)
        }
        if let book = testBook(name: "Гарри Поттер") {
            bookList.append(book)
        }
        if let book = testBook(name: "The Silver Chair") {
            bookList.append(book)
        }
        if let book = testBook(name: "Крушение империи") {
            bookList.append(book)
        }
        return bookList
    }
    
    func testBook(name: String) -> BookModel? {
        let epubParser: FREpubParser = FREpubParser()
        
        let bundle = Bundle.init(for: HomeVC.self)
        var bookPath = bundle.path(forResource: name, ofType: "epub")
        if bookPath == nil {
            let budlePath = bundle.path(forResource: "EpubBooks", ofType: "bundle")
            let resourcesBundle = Bundle.init(path: budlePath ?? "")
            bookPath = resourcesBundle?.path(forResource: name, ofType: "epub")
        }
        if let bookPath = bookPath {
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: bookPath, unzipPath: SystemFileManager.bookUnzipPath) else { return nil}
            let bookPath = name + "." + FileType.Epub.rawValue
            let book = BookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: ScreenWidth * 0.5)
            BookshelfManager.asyncInsertBook(book)
            return book
        }
        return nil
    }
}
#endif

