//
//  ReaderConfig.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

enum ReadConfigKey: String {
    case TransitionStyle    = "TransitionStyle"
    case TextSizeMultiplier = "TextSizeMultiplier"
    case PageColorHex       = "PageColorHex"
    case ZHFontName         = "ZHFontName"
    case ENFontName         = "ENFontName"
    case ReadTimeDate       = "ReadTimeDate"
    case TodayReadTime      = "TodayReadTime"
    case CurrentReadingBookPath = "CurrentReadingBookPath"
}

enum ReadPageColorHex: String {
    case HexF8F8F8 = "F8F8F8"
    case HexE9E6D7 = "E9E6D7"
    case Hex373737 = "373737"
    case Hex000000 = "000000"
}

enum ReadZHFontName: String {
    case PingFangSC = "PingFangSC-Regular"
    case STSong     = "STSongti-SC-Regular"
    case STKaitiSC  = "STKaitiSC-Regular"
    case STYuanti   = "STYuanti-SC-Regular"
    
    func displayName() -> String {
        if self.rawValue == ReadZHFontName.STSong.rawValue {
            return "宋体"
        } else if self.rawValue == ReadZHFontName.STKaitiSC.rawValue {
            return "楷体"
        } else if self.rawValue == ReadZHFontName.STYuanti.rawValue {
            return "圆体"
        } else {
            return "苹方"
        }
    }
}

enum ReadENFontName: String {
    case TimesNewRoman = "TimesNewRomanPSMT"
    case American      = "AmericanTypewriter"
    case Georgia       = "Georgia"
    case Palatino      = "Palatino-Roman"
    
    func displayName() -> String {
        if self.rawValue == ReadENFontName.American.rawValue {
            return "American"
        } else if self.rawValue == ReadENFontName.Georgia.rawValue {
            return "Georgia"
        } else if self.rawValue == ReadENFontName.Palatino.rawValue {
            return "Palatino"
        } else {
            return "Times New Roman"
        }
    }
}

enum TransitionStyle: Int {
    case pageCurl = 0
    case scroll = 1
}

class ReaderConfig {
    
    static var isChinese = true
    
    static var pageSzie: CGSize = .zero
    
    static var horizontalSpacing: CGFloat = 26
    
    static var readingTime: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: ReadConfigKey.TodayReadTime.rawValue)
        }
        get {
            UserDefaults.standard.integer(forKey: ReadConfigKey.TodayReadTime.rawValue)
        }
    }
    
    static var currentreadingBookPath: String? = {
        UserDefaults.standard.string(forKey: ReadConfigKey.CurrentReadingBookPath.rawValue)
    }()
    
    static func updateCurrentreadingBookPath(_ path: String?) {
        if currentreadingBookPath == nil || currentreadingBookPath != path {
            currentreadingBookPath = path
            UserDefaults.standard.set(path, forKey: ReadConfigKey.CurrentReadingBookPath.rawValue)
        }
    }
    
    static var linkColorHex = "#536FFA"
    
    /// 文字颜色，默认黑色
    static var textColor: UIColor!
    static var textColorHex: String!
    
    /// 页面颜色，默认白色 pageColor
    static var pageColor: UIColor!
    static var pageColorHex: String! {
        willSet {
            UserDefaults.standard.set(newValue, forKey: ReadConfigKey.PageColorHex.rawValue)
            self.updateReadColorConfig(pageColorHex: newValue)
        }
    }
    
    static var statusBarStyle: UIStatusBarStyle = .default
    static var barStyle: UIBarStyle = .default
    
    /// 字体类型名
    static var fontName: String {
        get {
            if ReaderConfig.isChinese {
                return ReaderConfig.zhFontName.rawValue
            } else {
                return ReaderConfig.enFontName.rawValue
            }
        }
    }
    
    static var fontDispalyName: String {
        get {
            if ReaderConfig.isChinese {
                return ReaderConfig.zhFontName.displayName()
            } else {
                return ReaderConfig.enFontName.displayName()
            }
        }
    }
    
    static var zhFontName: ReadZHFontName = {
        let font: ReadZHFontName = ReadZHFontName(rawValue: UserDefaults.standard.string(forKey: ReadConfigKey.ZHFontName.rawValue) ?? ReadZHFontName.PingFangSC.rawValue) ?? ReadZHFontName.PingFangSC
        return font
    }() {
        willSet {
            UserDefaults.standard.set(newValue.rawValue, forKey: ReadConfigKey.ZHFontName.rawValue)
        }
    }
    
    static var enFontName: ReadENFontName = {
        let font: ReadENFontName = ReadENFontName(rawValue: UserDefaults.standard.string(forKey:ReadConfigKey.ENFontName.rawValue) ?? ReadENFontName.TimesNewRoman.rawValue) ?? ReadENFontName.TimesNewRoman
        return font
    }() {
        willSet {
            UserDefaults.standard.set(newValue.rawValue, forKey: ReadConfigKey.ENFontName.rawValue)
        }
    }
    
    /// 默认字体大小
    static var defaultTextSize: CGFloat = 15
    static let minTextSizeMultiplier: Int = 6
    static let maxTextSizeMultiplier: Int = 22
    /// 字体大小倍数
    static var textSizeMultiplier: Int = {
        var multiplier = UserDefaults.standard.integer(forKey: ReadConfigKey.TextSizeMultiplier.rawValue)
        if multiplier == 0 {
            multiplier = 12
        }
        return multiplier
    }()
    
    /// 文本与页码的间距
    static var pageIndexSpacing: CGFloat = 8
    /// 行距
    static var lineSpacing: CGFloat = 2
    /// 行高倍数
    static var lineHeightMultiple: CGFloat = 1.1
    /// 段落间距
    static var paragraphSpacing: CGFloat = 10
    
    /// 翻页模式，默认横向仿真翻页
    static var transitionStyle = TransitionStyle(rawValue: UserDefaults.standard.integer(forKey: ReadConfigKey.TransitionStyle.rawValue)) ?? .pageCurl
    
    //MARK: - UI Color Theme
    static var separatorColor: UIColor!
    static var bgColor: UIColor!
 
    static func updateReadColorConfig(pageColorHex: String) {
        
        if pageColorHex == ReadPageColorHex.HexF8F8F8.rawValue {
            textColorHex = "333333"
            separatorColor = UIColor.init(white: 0, alpha: 0.08)
            bgColor = UIColor(hexStr: "FFFFFF")
            statusBarStyle = .default
            barStyle = .default
        } else if pageColorHex == ReadPageColorHex.HexE9E6D7.rawValue {
            textColorHex = "4C3824"
            separatorColor = UIColor.init(white: 0, alpha: 0.08)
            bgColor = UIColor(hexStr:"FDF9EA")
            statusBarStyle = .default
            barStyle = .default
        } else if pageColorHex == ReadPageColorHex.Hex373737.rawValue {
            textColorHex = "DDDDDD"
            separatorColor = UIColor.init(white: 1, alpha: 0.08)
            bgColor = UIColor(hexStr:"454545")
            statusBarStyle = .lightContent
            barStyle = .black
        } else  {
            textColorHex = "AAAAAA"
            separatorColor = UIColor.init(white: 1, alpha: 0.08)
            bgColor = UIColor(hexStr:"282828")
            statusBarStyle = .lightContent
            barStyle = .black
        }
        
        pageColor = UIColor(hexStr: pageColorHex)
        textColor = UIColor(hexStr:textColorHex)
    }
    
    static func initReaderConfig() {
        pageColorHex = UserDefaults.standard.string(forKey: ReadConfigKey.PageColorHex.rawValue) ?? ReadPageColorHex.HexF8F8F8.rawValue
        ReaderConfig.updateReadColorConfig(pageColorHex: pageColorHex)
        if String.currentDateString != UserDefaults.standard.string(forKey: ReadConfigKey.ReadTimeDate.rawValue) {
            UserDefaults.standard.set(0, forKey: ReadConfigKey.TodayReadTime.rawValue)
            UserDefaults.standard.set(String.currentDateString, forKey: ReadConfigKey.ReadTimeDate.rawValue)
        }
        
        if UserDefaults.standard.bool(forKey: ReadZHFontName.STSong.rawValue) {
            FontDownload.loadFontWithName(ReadZHFontName.STSong.rawValue)
        }
        if UserDefaults.standard.bool(forKey: ReadZHFontName.STKaitiSC.rawValue) {
            FontDownload.loadFontWithName(ReadZHFontName.STKaitiSC.rawValue)
        }
        if UserDefaults.standard.bool(forKey: ReadZHFontName.STYuanti.rawValue) {
            FontDownload.loadFontWithName(ReadZHFontName.STYuanti.rawValue)
        }
    }
}
