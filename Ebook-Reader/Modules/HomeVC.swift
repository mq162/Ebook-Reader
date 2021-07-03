//
//  HomeVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class HomeVC: BaseVC, CurrentReadingDelegate {
    
    var collectionView: UICollectionView!
    var currentreadingBookPath: String?
    
    
    let sectionEdgeInsetLR: CGFloat = {
        return UIScreen.main.bounds.width > 375 ? 20 : 15
    }()
    
    lazy var taskModel = ReadingTaskModel()
    lazy var readingModel = CurrentReadingModel()
    lazy var homeList: NSArray = {
        if let path = ReaderConfig.currentreadingBookPath {
            currentreadingBookPath = path
            BookshelfManager.loadBookWithPath(path) { (bookModel, error) in
                updateCurrentReadingBook(bookModel)
            }
        } else {
            readingModel.isReading = false
        }
        return NSArray.init(objects: taskModel, readingModel)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentReadingBookIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TabBarName.home.rawValue
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Update today's reading time
        if taskModel.readingTime != ReaderConfig.readingTime {
            taskModel.readingTime = ReaderConfig.readingTime
            collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 15
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hexStr:"F5F5F5")
        collectionView.alwaysBounceVertical = true
        collectionView.register(ReadingTaskCell.self, forCellWithReuseIdentifier: "IRHomeTaskCell")
        collectionView.register(CurrentReadingCell.self, forCellWithReuseIdentifier: "IRHomeCurrentReadingCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        view.addSubview(collectionView)
    }
    
    func updateCurrentReadingBookIfNeeded() {
        if currentreadingBookPath != ReaderConfig.currentreadingBookPath {
            currentreadingBookPath = ReaderConfig.currentreadingBookPath
        }
        guard let currentreadingBookPath = currentreadingBookPath else { return }
        DispatchQueue.global().async {
            BookshelfManager.loadBookWithPath(currentreadingBookPath) { (bookModel, error) in
                guard let bookModel = bookModel else {return}
                DispatchQueue.main.async {
                    self.updateCurrentReadingBook(bookModel)
                }
            }
        }
    }
    
    func updateCurrentReadingBook(_ bookModel: BookModel?) {
        if let bookModel = bookModel {
            readingModel.isReading = true
            readingModel.coverImage = bookModel.coverImage
            readingModel.bookName = bookModel.bookName
            readingModel.author = bookModel.authorName
            readingModel.progress = bookModel.progress
            collectionView.reloadData()
        } else {
            readingModel.isReading = false
        }
    }
    
    // MARK: - IRHomeCurrentReadingDelegate
    
    func homeCurrentReadingCellDidClickKeepReading() {
        guard let currentreadingBookPath = currentreadingBookPath else { return }
        let bookPath = SystemFileManager.bookUnzipPath + "/" + currentreadingBookPath
        let readerCenter = ReaderCenterVC.init(withPath: bookPath)
        readerCenter.delegate = (UIApplication.shared.delegate as? AppDelegate)?.mainViewController.bookshelfVC
        self.navigationController?.pushViewController(readerCenter, animated: true)
    }
    
    func homeCurrentReadingCellDidClickFindBook() {
        
    }
}

// MARK: - UICollectionView
extension HomeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = homeList.object(at: indexPath.item)
        var cell: UICollectionViewCell
        if cellModel is ReadingTaskModel {
            let taskCell: ReadingTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IRHomeTaskCell", for: indexPath) as! ReadingTaskCell
            taskCell.taskModel = cellModel as? ReadingTaskModel
            cell = taskCell
        } else if cellModel is CurrentReadingModel {
            let readingCell: CurrentReadingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IRHomeCurrentReadingCell", for: indexPath) as! CurrentReadingCell
            readingCell.readingModel = cellModel as? CurrentReadingModel
            readingCell.delegate = self
            cell = readingCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellModel = homeList.object(at: indexPath.item)
        let cellWidth = collectionView.width - sectionEdgeInsetLR * 2
        var cellSize: CGSize
        if cellModel is ReadingTaskModel {
            cellSize = CGSize.init(width: cellWidth, height: ReadingTaskCell.cellHeight(with: cellWidth))
        } else if cellModel is CurrentReadingModel {
            cellSize = CGSize(width: cellWidth, height: CurrentReadingCell.cellHeight)
        } else {
            cellSize = CGSize.zero
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 15, left: sectionEdgeInsetLR, bottom: 15, right: sectionEdgeInsetLR)
    }
}
