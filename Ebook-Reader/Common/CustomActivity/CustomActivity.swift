//
//  CustomActivity.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

extension UIActivity.ActivityType {
    static let delete = UIActivity.ActivityType.init("delete")
}

class CustomActivity: UIActivity {
    
    var title: String?
    var type: UIActivity.ActivityType?
    var image: UIImage?
    
    convenience init(withTitle title: String?, type: UIActivity.ActivityType?) {
        self.init()
        self.title = title
        self.type = type
    }
    
    override var activityTitle: String? {
        get {
            return title
        }
    }
    
    override var activityImage: UIImage? {
        get {
            return image
        }
    }
    
    override var activityType: UIActivity.ActivityType? {
        return type
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.count > 0
    }
    
    override func perform() {
        self.activityDidFinish(true)
    }
}
