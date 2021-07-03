//
//  AppDelegate.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit
import PKHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var rootViewController: UINavigationController!
    lazy var mainViewController = MainTabbar()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Network.shared.startNotifier()
        setupMainViewController()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        addEpubBookByShareUrl(url)
        return true
    }
}

// MARK: Private
extension AppDelegate {
    
    func setupMainViewController() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        mainViewController.view.backgroundColor = .white
        rootViewController = UINavigationController.init(rootViewController: mainViewController)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        initReadConfig()
    }
    
    func initReadConfig() {
        var safeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeInsets = window!.safeAreaInsets
        }
        
        if safeInsets.bottom == 0 || safeInsets.top == 0 {
            safeInsets = UIEdgeInsets.init(top: 30, left: 0, bottom: 30, right: 0)
        }
        
        let width = window!.width - ReaderConfig.horizontalSpacing * 2
        let height = window!.height - safeInsets.top - safeInsets.bottom - ReaderConfig.pageIndexSpacing
        let maxSize: CGFloat = 1000
        ReaderConfig.pageSzie = CGSize.init(width: min(maxSize, width), height: min(maxSize, height))
        ReaderConfig.initReaderConfig()
    }
    
    func addEpubBookByShareUrl(_ url: URL) {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        indicatorView.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        HUD.show(.customView(view: indicatorView))
        SystemFileManager.shared.addEpubBookByShareUrl(url) { bookPath, success in
            defer {
                HUD.hide()
            }
            guard let bookPath = bookPath, success else {
                return
            }
            if let topViewController = self.rootViewController.topViewController {
                if topViewController.isMember(of: ReaderCenterVC.self) {
                    topViewController.navigationController?.popViewController(animated: false)
                }
            }
            
            let readerCenter = ReaderCenterVC(withPath: bookPath)
            readerCenter.delegate = self.mainViewController.bookshelfVC
            self.rootViewController.pushViewController(readerCenter, animated: true)
        }
    }
}
