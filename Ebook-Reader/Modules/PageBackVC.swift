//
//  PageBackVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

final class PageBackVC: UIViewController {

    var contentView: UIView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView?.frame = self.view.bounds
    }
    
    class func pageBackViewController(WithPageView content: UIView?) -> PageBackVC {
        
        let backVc = PageBackVC()

        guard let snap = content?.snapshotView(afterScreenUpdates: true) else {
            return backVc
        }
        
        snap.transform = CGAffineTransform.init(a: -1, b: 0, c: 0, d: 1, tx: snap.frame.size.width, ty: 0)
        backVc.contentView = snap;
        backVc.view.addSubview(snap)
        
        return backVc
    }
}
