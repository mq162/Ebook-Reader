//
//  ActivityItemProvider.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit
import ZipArchive
import LinkPresentation

class ActivityItemProvider: UIActivityItemProvider {

    var title: String?
    var icon: UIImage?
    var shareUrl: URL
    var originalshareUrl: URL!
    var type: UIActivity.ActivityType?
    
    init(shareUrl: URL) {
        originalshareUrl = shareUrl
        // iPhone\ Library/Caches As the compressed output path will be problematic, the simulator is OK. No reason yet😅
        self.shareUrl = URL.init(fileURLWithPath: SystemFileManager.bookSharePath + shareUrl.lastPathComponent)
        super.init(placeholderItem: self.shareUrl)
    }
    
    override var item: Any {
        if !FileManager.default.fileExists(atPath: shareUrl.path) {
            SSZipArchive.createZipFile(atPath: shareUrl.path, withContentsOfDirectory: originalshareUrl.path)
        }
        return shareUrl
    }
    
    override var activityType: UIActivity.ActivityType? {
        return type
    }
    
    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.url = shareUrl
        metadata.title = title
        if let icon = icon {
            metadata.iconProvider = NSItemProvider(object: icon)
        }
        return metadata
    }
}
