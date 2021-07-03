//
//  FontDownload.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

protocol FontDownloadDelegate: AnyObject {
    
    func fontDownloadDidBegin(_ downloader: FontDownload)
    
    func fontDownloadDidFinish(_ downloader: FontDownload)
    
    func fontDownloadDidFail(_ downloader: FontDownload, error: Error?)
    
    func fontDownloadDownloading(_ downloader: FontDownload, progress: Double)
}

class FontDownload: NSObject {
    
    var begin = true {
        willSet {
            stop = !newValue
        }
    }
    var stop = false
    
    weak var delegate: FontDownloadDelegate?
    
    func downloadFontWithName(_ fontName: String) {
        
        print("Download \(fontName)")
        
        // Create a dictionary with the font's PostScript name.
        let attributes = [kCTFontNameAttribute : fontName] as CFDictionary
        
        // Create a new font descriptor reference from the attributes dictionary.
        let fontDescription = CTFontDescriptorCreateWithAttributes(attributes)
        let descs = [fontDescription] as CFArray
        
        
        // Start processing the font descriptor..
        // This function returns immediately, but can potentially take long time to process.
        // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
        // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs, nil) { (state, progressParamater) -> Bool in
            
            let progressValue = (progressParamater as Dictionary)[kCTFontDescriptorMatchingPercentage]?.doubleValue
            switch state {
                case .didBegin: do {
                    OperationQueue.main.addOperation {
                        self.delegate?.fontDownloadDidBegin(self)
                    }
                }

                case .didFinish: do {
                    OperationQueue.main.addOperation {
                        self.delegate?.fontDownloadDidFinish(self)
                    }
                }

                case .downloading: do {
                    OperationQueue.main.addOperation {
                        self.delegate?.fontDownloadDownloading(self, progress: progressValue ?? 0)
                    }
                }
                    
                case .didFailWithError: do {
                    if let error = (progressParamater as Dictionary)[kCTFontDescriptorMatchingError] as? NSError {
                        OperationQueue.main.addOperation {
                            self.delegate?.fontDownloadDidFail(self, error: error)
                        }
                    } else {
                        print("ERROR MESSAGE IS NOT AVAILABLE")
                    }
                }
                    
                default: do {
                    print(String(reflecting: state))
                }
            }
            
            if self.stop {
                return false
            }
            
            return true
        }
    }
    
    static func loadFontWithName(_ fontName: String) {
        
        let attributes = [kCTFontNameAttribute : fontName] as CFDictionary
        let fontDescription = CTFontDescriptorCreateWithAttributes(attributes)
        let descs = [fontDescription] as CFArray
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs, nil) { (state, progressParamater) -> Bool in
            
            if state == .didFinish {
                print("Did Finish Load: \(fontName)")
            }
            
            return true
        }
    }
}

