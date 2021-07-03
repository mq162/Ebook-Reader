//
//  MainTabbar.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

enum TabBarIndex: Int {
    case home      = 0
    case bookshelf = 1
    case mine      = 2
}

enum TabBarName: String {
    case home      = "Home"
    case bookshelf = "Bookshelf"
    case explore   = "Explore"
}

final class MainTabbar: UITabBarController, UITabBarControllerDelegate {

    var initOnceAfterViewDidAppear = false
    lazy var bookshelfVC = BookshelfVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initAfterViewDidAppear()
    }
    
    override var selectedIndex: Int {
        willSet {
            self.updateNavigationItems(withIndex: newValue)
        }
    }
    
    // MARK: - Private
    
    func initAfterViewDidAppear() {
        if initOnceAfterViewDidAppear {
            return
        }
        initOnceAfterViewDidAppear = true
    }
    
    func commonInit() {
        view.backgroundColor = .white
        self.delegate = self
        self.setupTabbarItems()
        updateNavigationItems(withIndex: TabBarIndex.home.rawValue)
    }
    
    func setupTabbarItems() {
        self.tabBar.tintColor = AppThemeColor
        
        let tabbarTitles = [TabBarName.home.rawValue, TabBarName.bookshelf.rawValue, TabBarName.explore.rawValue]
        var childViewControllers = [UIViewController]()
        
        for (index, _) in tabbarTitles.enumerated() {
            childViewControllers.append(self.childViewController(withTabIndex: index))
        }
        self.viewControllers = childViewControllers
        
        for (index, item) in self.tabBar.items!.enumerated() {
            var normalName: String?, selectName: String?
            switch index {
            case TabBarIndex.home.rawValue:
                normalName = "tabbar_home_n"; selectName = "tabbar_home_s"
            case TabBarIndex.bookshelf.rawValue:
                normalName = "tabbar_bookshelf_n"; selectName = "tabbar_bookshelf_s"
            case TabBarIndex.mine.rawValue:
                normalName = "tabbar_explore_n"; selectName = "tabbar_explore_s"
            default:
                print("TabIndex: (\(index)) undefine")
            }
            item.title = tabbarTitles[index]
            if let normalName = normalName, let selectName = selectName {
                item.image = UIImage.init(named: normalName)?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = UIImage.init(named: selectName)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func childViewController(withTabIndex index: Int) -> UIViewController {
        var vc: UIViewController
        switch index {
        case TabBarIndex.home.rawValue:
            vc = HomeVC()
        case TabBarIndex.bookshelf.rawValue:
            vc = bookshelfVC
        case TabBarIndex.mine.rawValue:
            vc = ExploreVC()
        default:
            vc = UIViewController()
        }
        return vc
    }
    
    func updateNavigationItems(withIndex index: Int) {
        navigationItem.rightBarButtonItems = selectedViewController?.navigationItem.rightBarButtonItems
        navigationItem.leftBarButtonItems = selectedViewController?.navigationItem.leftBarButtonItems
        
        if let titleView = selectedViewController?.navigationItem.titleView {
            navigationItem.titleView = titleView
            navigationItem.title = nil
        } else {
            navigationItem.title = selectedViewController?.navigationItem.title
            navigationItem.titleView = nil
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.updateNavigationItems(withIndex: tabBarController.viewControllers?.firstIndex(of:viewController) ?? TabBarIndex.home.rawValue)
    }
}
