//
//  ReaderCenterVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit
import PKHUD
import SnapKit

protocol ReaderCenterDelegate: AnyObject {
    func readerCenter(didUpdateReadingProgress progress: Int, bookPath: String) -> Void
}

class ReaderCenterVC: BaseVC, UIGestureRecognizerDelegate {
    
    weak var delegate: ReaderCenterDelegate?
    var shouldHideStatusBar = true
    var bookPath: String
    var book: Book!
    var readingBegin: TimeInterval = 0
    var pageViewController: IRPageViewController?
    /// 当前阅读页VC
    var currentReadingVC: ReadPageViewController!
    /// 上一页
    var beforePageVC: ReadPageViewController?
    /// 阅读记录
    var readingRecord: IRReadingRecordModel!
    /// 当前阅读页文本起始位置
    var currentPageTextLoction: Int?
    /// 阅读导航栏
    lazy var readNavigationBar = ReadNavigationBar()
    lazy var readBottomBar = ReadBottomBar()
    var readNavigationContentView: ReadNavigationContentView?
    /// 阅读设置
    var readSettingView: CMPopTipView?
    var chapterTipView: ChapterTipView?
    
    var loadingView: UIActivityIndicatorView?
    
    
    //MARK: - Init
    
    init(withPath path:String) {
        bookPath = path
        ReaderConfig.updateCurrentreadingBookPath(path.lastPathComponent)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let book = book {
            book.cancleAllParse()
        }
    }
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ReaderConfig.pageColor
        addNavigateTapGesture()
        setupLoadingView()
        parseBook()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readingBegin = Date().timeIntervalSince1970
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if book != nil {
            saveReadingRecord()
            updateBookReadingProgress()
            ReaderConfig.readingTime += Int((Date().timeIntervalSince1970 - readingBegin))
        }
    }

    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ReaderConfig.statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController?.view.frame = view.bounds
    }
    
    //MARK: - Private
    
    func updateBookReadingProgress() {
        guard let pageModel = currentReadingVC.pageModel else { return }
        let currentChapter = book.chapter(at: pageModel.chapterIdx)
        guard let pageOffset = currentChapter.pageOffset else { return }
        let progress: Int = Int(CGFloat((pageModel.pageIdx + pageOffset + 1)) / CGFloat(book.pageCount) * 100)
        delegate?.readerCenter(didUpdateReadingProgress: progress, bookPath: bookPath.lastPathComponent)
    }
    
    func setupLoadingView() {
        let loadingView = UIActivityIndicatorView.init(style: .medium)
        loadingView.hidesWhenStopped = true
        loadingView.color = .lightGray
        view.addSubview(loadingView)
        self.loadingView = loadingView
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
    }
    
    func parseBook() {
        loadingView?.isHidden = false
        loadingView?.startAnimating()
        view.isUserInteractionEnabled = false
        DispatchQueue.global().async {
            if let bookMeta = try? FREpubParser().readEpub(epubPath: self.bookPath, unzipPath: SystemFileManager.bookUnzipPath) {
                DispatchQueue.main.async {
                    self.handleBook(Book(bookMeta))
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingView?.stopAnimating()
                    HUD.dimsBackground = false
                    HUD.flash(.label("解析失败了，看看其他书吧～"), delay: 1) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func handleBook(_ book: Book) {
        view.isUserInteractionEnabled = true
        loadingView?.isHidden = true
        self.book = book
        ReaderConfig.isChinese = book.isChinese
        book.parseDelegate = self
        book.loadBookmarkList()
        book.parseBookMeta()
        setupReadingRecord()
    }
    
    func updateReadNavigationBarDispalyState(animated: Bool) {
        addNavigationContentViewIfNeeded()
        if !shouldHideStatusBar {
            readNavigationContentView!.isHidden = false
        }
        
        updateBookmarkState()
        readBottomBar.isParseFinish = book.isFinishParse
        readBottomBar.bookPageCount = book.pageCount
        readBottomBar.curentPageIdx = currentReadingVC.pageModel?.displayPageIdx ?? 0
        
        let endY: CGFloat = shouldHideStatusBar ? -readNavigationBar.height : 0
        let height = readNavigationContentView!.height
        let bottomEndY: CGFloat = shouldHideStatusBar ? height : height - readBottomBar.height
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
                self.readNavigationBar.y = endY
                self.readBottomBar.y = bottomEndY
            } completion: { (finish) in
                self.readNavigationContentView!.isHidden = self.shouldHideStatusBar
            }
        } else {
            setNeedsStatusBarAppearanceUpdate()
            readNavigationBar.y = endY
            readBottomBar.y = bottomEndY
            readNavigationContentView!.isHidden = shouldHideStatusBar
        }
    }
    
    func updateBookmarkState() {
        readNavigationBar.bookmark.isSelected = book.isBookmark(withPage: currentReadingVC.pageModel)
    }
    
    func addNavigationContentViewIfNeeded() {
        if readNavigationContentView != nil {
            return
        }
        readNavigationContentView = ReadNavigationContentView()
        view.addSubview(readNavigationContentView!)
        readNavigationContentView?.backgroundColor = UIColor.clear
        readNavigationContentView?.frame = view.bounds
        
        readNavigationBar.delegate = self
        readNavigationContentView?.addSubview(readNavigationBar)
        var safe = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safe = view.safeAreaInsets
        }
        if safe.top <= 0 || safe.bottom <= 0 {
            safe = UIEdgeInsets.init(top: 20, left: 0, bottom: 20, right: 0)
        }
        let width = readNavigationContentView!.width
        let barH = safe.top + readNavigationBar.itemHeight
        readNavigationBar.frame = CGRect.init(x: 0, y: -barH, width: width, height: barH)
        
        readBottomBar.delegate = self
        readBottomBar.curentPageIdx = currentReadingVC.pageModel?.displayPageIdx ?? 0
        readNavigationContentView!.addSubview(readBottomBar)
        let bottomH = safe.bottom + readNavigationBar.itemHeight
        readBottomBar.frame = CGRect.init(x: 0, y: readNavigationContentView!.height, width: width, height: bottomH)
    }
    
    /// 设置页面控制器
    /// - Parameter pageModel: 展示页，nil 则展示第一章第一页
    func setupPageViewControllerWithPageModel(_ pageModel: BookPage?) {
        
        if let pageViewController = pageViewController {
            pageViewController.willMove(toParent: nil)
            pageViewController.removeFromParent()
            // pageViewController.view 必须从父视图中移除，否则会出现下面的崩溃
            // "child view controller:<iRead.IRReadPageViewController: 0x10351a420> should have parent view controller:<iRead.IRReaderCenterViewController: 0x106e080e0> but requested parent is:<IRCommonLib.IRPageViewController: 0x108010600>"
            pageViewController.view.removeFromSuperview()
        }
        
        if ReaderConfig.transitionStyle == .pageCurl {
            pageViewController = IRPageViewController.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
            pageViewController?.isDoubleSided = true
            beforePageVC = nil
        } else {
            pageViewController = IRPageViewController.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        }
        
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
        addChild(pageViewController!)
        pageViewController?.didMove(toParent: self)
        if readNavigationContentView != nil {
            view.insertSubview(pageViewController!.view, belowSubview: readNavigationContentView!)
        } else {
            view.addSubview(pageViewController!.view)
        }
        
        if currentReadingVC == nil {
            currentReadingVC = ReadPageViewController.init(withPageSize: ReaderConfig.pageSzie)
        }
        
        if pageModel == nil {
            let currentChapter = book.chapter(at: 0)
            currentReadingVC.pageModel = currentChapter.page(at: 0)
        } else {
            currentReadingVC.pageModel = pageModel
        }
        
        pageViewController!.setViewControllers([currentReadingVC], direction: .forward, animated: false, completion: nil)
    }
    
    func previousPageModel(withReadVC readVc: ReadPageViewController) -> BookPage? {
        
        var pageModel: BookPage? = nil
        
        guard var pageIndex = readVc.pageModel?.pageIdx else { return pageModel }
        guard var chapterIndex = readVc.pageModel?.chapterIdx else { return pageModel }
        var currentChapter = book.chapter(at: chapterIndex)

        if pageIndex > 0 {
            pageIndex -= 1;
            pageModel = currentChapter.page(at: pageIndex)
        } else {
            if chapterIndex > 0 {
                chapterIndex -= 1;
                currentChapter = book.chapter(at: chapterIndex)
                pageModel = currentChapter.page(at: currentChapter.pageList.count - 1)
            }
        }
        
        return pageModel
    }
    
    func nextPageModel(withReadVC readVc: ReadPageViewController) -> BookPage? {
        
        var pageModel: BookPage? = nil
        
        guard var pageIndex = readVc.pageModel?.pageIdx else { return pageModel }
        guard var chapterIndex = readVc.pageModel?.chapterIdx else { return pageModel }
        var currentChapter = book.chapter(at: chapterIndex)

        let pageCount = currentChapter.pageList.count
        if pageIndex + 1 < pageCount {
            pageIndex += 1;
            pageModel = currentChapter.page(at: pageIndex)
        } else {
            if chapterIndex + 1 < book.chapterCount {
                chapterIndex += 1;
                currentChapter = book.chapter(at: chapterIndex)
                pageModel = currentChapter.page(at: 0)
            }
        }
        
        return pageModel
    }
    
    func setupReadingRecord() {
        readingRecord = IRReadingRecordManager.readingRecord(with: book.bookName)
        let currentChapter = book.chapter(at: readingRecord.chapterIdx)
        var pageModel = currentChapter.page(at: readingRecord.pageIdx)

        if pageModel?.range != nil {
            if !NSEqualRanges(pageModel!.range, readingRecord.textRange) {
                for item in currentChapter.pageList {
                    if item.range.location + item.range.length > readingRecord.textRange.location {
                        pageModel = item
                        break
                    }
                }
            }
        }
        setupPageViewControllerWithPageModel(pageModel)
    }
    
    func saveReadingRecord() {
        guard let pageModel = currentReadingVC?.pageModel else { return }
        if readingRecord.chapterIdx == pageModel.chapterIdx && readingRecord.pageIdx == pageModel.pageIdx {
            return
        }
        let readingRecord = IRReadingRecordModel(pageModel.chapterIdx, pageModel.pageIdx, pageModel.range)
        IRReadingRecordManager.setReadingRecord(record: readingRecord, bookName: book.bookName)
    }
    
    //MARK: - Gesture
    
    func addNavigateTapGesture() {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.addTarget(self, action: #selector(didNavigateTapGestureClick(tapGesture:)))
        view.addGestureRecognizer(tap)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Tap 手势会影响其子视图中的 UICollectionView 的 didSelectItemAt 方法！！！
        // didSelectItemAt not being called
        // https://stackoverflow.com/questions/39780373/didselectitemat-not-being-called/39781185
        if let readSettingView = readSettingView {
            if readSettingView.superview != nil {
                let tapPoint = gestureRecognizer.location(in: view)
                if readSettingView.frame.contains(tapPoint) {
                    return false
                }
            }
        }
        
        if readNavigationBar.frame.contains(gestureRecognizer.location(in: readNavigationContentView)) {
            return false
        }
        
        if readBottomBar.frame.contains(gestureRecognizer.location(in: readNavigationContentView)) {
            return false
        }
        
        return true
    }
    
    @objc func didNavigateTapGestureClick(tapGesture: UITapGestureRecognizer) {
        shouldHideStatusBar = !shouldHideStatusBar;
        updateReadNavigationBarDispalyState(animated: true)
    }
}

//MARK: - IRChapterListViewControllerDelagate
extension ReaderCenterVC: IRChapterListViewControllerDelagate {
    
    func chapterListViewController(_ vc: IRChapterListViewController, didSelectTocReference tocReference: FRTocReference) {
        let chapterIndex = book.findChapterIndexByTocReference(tocReference)
        let currentChapter = book.chapter(at: chapterIndex)
        setupPageViewControllerWithPageModel(currentChapter.page(at: 0))
        
        shouldHideStatusBar = !shouldHideStatusBar;
        updateReadNavigationBarDispalyState(animated: false)
    }
    
    func chapterListViewController(_ vc: IRChapterListViewController, didSelectBookmark bookmark: BookmarkModel) {
        let currentChapter = book.chapter(at: bookmark.chapterIdx)
        setupPageViewControllerWithPageModel(currentChapter.page(in: bookmark.textLoction))
        
        shouldHideStatusBar = !shouldHideStatusBar;
        updateReadNavigationBarDispalyState(animated: false)
    }
    
    func chapterListViewController(_ vc: IRChapterListViewController, deleteBookmark bookmark: BookmarkModel) {
        book.removeBookmark(bookmark, textRange: NSMakeRange(bookmark.textLoction, 1))
        updateBookmarkState()
    }
}

//MARK: - BookParseDelegate
extension ReaderCenterVC: BookParseDelegate {

    func book(_ book: Book, didFinishLoadBookmarkList list: [BookmarkModel]) {
        if shouldHideStatusBar {
            return
        }
        readNavigationBar.bookmark.isSelected = book.isBookmark(withPage: currentReadingVC.pageModel)
    }
    
    func bookBeginParse(_ book: Book) {
        if readNavigationContentView != nil {
            readBottomBar.isParseFinish = false
        }
    }
    
    func book(_ book: Book, currentParseProgress progress: Float) {
        
        if readNavigationContentView != nil {
            readBottomBar.parseProgress = progress
        }
    }
    
    func bookDidFinishParse(_ book: Book) {
        
        if let currentPage = currentReadingVC?.pageModel {
            let currentChapter = book.chapter(at: currentPage.chapterIdx)
            currentReadingVC.pageModel = currentChapter.page(at: currentPage.pageIdx)
        }
        
        if let viewControllers = pageViewController?.viewControllers {
            for vc in viewControllers {
                if !(vc is ReadPageViewController) {
                    continue
                }
                let pageVc: ReadPageViewController = vc as! ReadPageViewController
                if let currentPage = pageVc.pageModel {
                    let currentChapter = book.chapter(at: currentPage.chapterIdx)
                    pageVc.pageModel = currentChapter.page(at: currentPage.pageIdx)
                }
            }
        }
    
        if readNavigationContentView != nil {
            readBottomBar.isParseFinish = true
            readBottomBar.curentPageIdx = currentReadingVC.pageModel?.displayPageIdx ?? 0
            readBottomBar.bookPageCount = book.pageCount
        }
    }
}

//MARK: - ReadNavigation
extension ReaderCenterVC: ReadNavigationBarDelegate, ReadBottomBarDelegate {
    
    //MARK: - ReadNavigationBarDelegate
    
    func readNavigationBar(didClickBack bar: ReadNavigationBar) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func readNavigationBar(didClickChapterList bar: ReadNavigationBar) {
        let chapterVc = ChapterListViewController()
        chapterVc.delegate = self
        chapterVc.chapterList = book.flatChapterList
        chapterVc.bookmarkList = book.bookmarkList
        if let chapterIdx = currentReadingVC.pageModel?.chapterIdx {
            chapterVc.currentChapterIdx = chapterIdx - book.chapterOffset
        }
        chapterVc.title = book.bookName
        navigationController?.pushViewController(chapterVc, animated: true)
    }
    
    func readNavigationBar(didClickReadSetting bar: ReadNavigationBar) {
        
        if let readSettingView = readSettingView {
            readSettingView.presentPointing(at: bar.readSetting, in: view, animated: true)
        } else {
            let readSettingView = ReadSettingView()
            readSettingView.deleage = self
            readSettingView.frame = CGRect.init(origin: CGPoint.zero, size: IRReadSettingView.viewSize)
            let popTipView = CMPopTipView.init(customView: readSettingView)
            popTipView?.has3DStyle = false
            popTipView?.animation = .slide
            popTipView?.backgroundColor = readSettingView.backgroundColor
            popTipView?.borderColor = SeparatorColor
            popTipView?.sidePadding = 15
            popTipView?.bubblePaddingX = -10
            popTipView?.bubblePaddingY = -10
            popTipView?.disableTapToDismiss = true
            popTipView?.dismissTapAnywhere = true
            popTipView?.presentPointing(at: bar.readSetting, in: view, animated: true)
            self.readSettingView = popTipView;
        }
    }
    
    func readNavigationBar(_ bar: ReadNavigationBar, didSelectBookmark isMark: Bool) {
        guard let pageModel = currentReadingVC.pageModel else { return }
        let bookmark = BookmarkModel.init(chapterIdx: pageModel.chapterIdx, chapterName: pageModel.chapterName, textLoction: pageModel.range.location)
        if book.isChinese {
            bookmark.content = String(pageModel.content.string.prefix(25)).replacingOccurrences(of: "\n", with: "")
        } else {
            var content = String(pageModel.content.string.prefix(50)).replacingOccurrences(of: "\n", with: "")
            let index = content.lastIndex(of: " ") ?? content.endIndex
            content = String(content[..<index])
            bookmark.content = content
        }
        
        if isMark {
            book.saveBookmark(bookmark)
        } else {
            book.removeBookmark(bookmark, textRange: pageModel.range)
        }
    }
    
    //MARK: - ReadBottomBarDelegate
    
    func readBottomBar(_: ReadBottomBar, didChangePageIndex pageIndex: Int) {
        
        if chapterTipView == nil {
            chapterTipView = ChapterTipView()
            chapterTipView!.isUserInteractionEnabled = false
            let height = ChapterTipView.viewHeight
            let width = ReaderConfig.pageSzie.width
            let x = (readNavigationContentView!.width - width) / 2.0
            let y = readBottomBar.frame.minY - height - 10
            chapterTipView!.frame = CGRect.init(x: x, y: y, width: width, height: height)
            readNavigationContentView!.addSubview(chapterTipView!)
        }
        chapterTipView!.isHidden = false
        let chapter = book.chapter(withPageIndex: pageIndex)
        chapterTipView!.update(title: chapter.title, pageIndex: pageIndex)
    }
    
    func readBottomBar(_: ReadBottomBar, didEndChangePageIndex pageIndex: Int) {
        
        chapterTipView?.isHidden = true
        let chapter = book.chapter(withPageIndex: pageIndex)
        let pageModel = chapter.page(at: pageIndex - chapter.pageOffset! - 1)
        setupPageViewControllerWithPageModel(pageModel)
    }
}

//MARK: - UIPageViewController
extension IRReaderCenterViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        // 隐藏阅读导航栏
        if !shouldHideStatusBar {
            shouldHideStatusBar = true
            updateReadNavigationBarDispalyState(animated: true)
        }
        
        guard let nextVc = pendingViewControllers.first else { return }
        if nextVc.isKind(of: ReadPageViewController.self) {
            currentReadingVC = nextVc as? ReadPageViewController
            currentPageTextLoction = nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            return
        }
        guard let preVc = previousViewControllers.first else { return }
        if preVc.isKind(of: IRReadPageViewController.self) {
            currentReadingVC = preVc as? ReadPageViewController
            currentPageTextLoction = nil
        }
    }
    
    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if pageViewController.transitionStyle == .pageCurl &&
           viewController.isKind(of: PageBackVC.self) {
            return beforePageVC
        }
        
        guard let prePage = previousPageModel(withReadVC: currentReadingVC) else {
            return nil
        }
        
        print("page:\(prePage.pageIdx) chapter: \(prePage.chapterIdx)")
        let preVc = ReadPageViewController.init(withPageSize: ReaderConfig.pageSzie)
        preVc.pageModel = prePage
        if pageViewController.transitionStyle == .pageCurl {
            beforePageVC = preVc
            return PageBackVC.pageBackViewController(WithPageView: preVc.view)
        }
        
        return preVc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if pageViewController.transitionStyle == .pageCurl &&
           viewController.isKind(of: ReadPageViewController.self) {
            return PageBackVC.pageBackViewController(WithPageView: viewController.view)
        }
        
        guard let nextPage = nextPageModel(withReadVC: currentReadingVC) else {
            return nil
        }
        
        print("page:\(nextPage.pageIdx) chapter: \(nextPage.chapterIdx)")
        let nextVc = ReadPageViewController.init(withPageSize: ReaderConfig.pageSzie)
        nextVc.pageModel = nextPage
        return nextVc
    }
}

//MARK: - IRReadSettingViewDelegate
extension ReaderCenterVC: ReadSettingViewDelegate {
    
    func readSettingView(_ view: ReadSettingView, didChangeTextSizeMultiplier textSizeMultiplier: Int) {
        guard let pageModel = currentReadingVC.pageModel else { return }
        if currentPageTextLoction == nil {
            currentPageTextLoction = pageModel.range.location
        }
        let currentChapter = book.chapter(at: pageModel.chapterIdx)
        currentChapter.updateTextSizeMultiplier(textSizeMultiplier)
        setupPageViewControllerWithPageModel(currentChapter.page(in: currentPageTextLoction ?? 0))
        updateBookmarkState()
        book.parseBookMeta()
    }
    
    func readSettingView(_ view: IRReadSettingView, transitionStyleDidChange newValue: IRTransitionStyle) {
        setupPageViewControllerWithPageModel(currentReadingVC.pageModel)
    }
    
    func readSettingView(_ view: IRReadSettingView, didChangeSelectColor color: IRReadColorModel) {
        readSettingView?.backgroundColor = view.backgroundColor
        readSettingView?.setNeedsDisplay()
        
        view.backgroundColor = ReaderConfig.pageColor
        currentReadingVC.updateThemeColor()
        readNavigationBar.updateThemeColor()
        readBottomBar.updateThemeColor()
        chapterTipView?.updateThemeColor()
        
        let pageModel = currentReadingVC.pageModel
        pageModel?.updateTextColor(ReaderConfig.textColor)
        currentReadingVC.pageModel = pageModel
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func readSettingView(_ view: ReadSettingView, didSelectFontName fontName: String) {
        guard let pageModel = currentReadingVC.pageModel else { return }
        if currentPageTextLoction == nil {
            currentPageTextLoction = pageModel.range.location
        }
        let currentChapter = book.chapter(at: pageModel.chapterIdx)
        currentChapter.updateTextFontName(fontName)
        setupPageViewControllerWithPageModel(currentChapter.page(in: currentPageTextLoction ?? 0))
        updateBookmarkState()
        book.parseBookMeta()
    }
}
