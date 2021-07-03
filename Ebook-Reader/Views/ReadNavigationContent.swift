//
//  ReadNavigationContent.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

class ReadNavigationContentView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let targetView = super.hitTest(point, with: event)
        if targetView == self {
            return nil
        }
        return targetView
    }
}
