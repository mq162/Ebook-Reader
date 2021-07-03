//
//  ReadSettingView.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

protocol ReadSettingViewDelegate: AnyObject {
    func readSettingView(_ view: ReadSettingView, transitionStyleDidChange newValue: TransitionStyle)
    
    func readSettingView(_ view: ReadSettingView, didChangeSelectColor color: ReadColorModel)
    
    func readSettingView(_ view: ReadSettingView, didChangeTextSizeMultiplier textSizeMultiplier: Int)
    
    func readSettingView(_ view: ReadSettingView, didSelectFontName fontName: String)
}

class ReadSettingView: UIView, SwitchSettingViewDeleagte, ReadColorSettingViewDelegate, FontSettingViewDelegate, FontSelectViewDelegate {
    
    weak var deleage: ReadSettingViewDelegate?
    
    var fontSelectView: FontSelectView?
    var scrollView = UIScrollView()
    var contentView = UIView()
    lazy var scrollSettingView = SwitchSettingView()
    lazy var colorSettingView = ReadColorSettingView()
    lazy var fontSettingView = FontSettingView()
    lazy var brightnessSettingView = BrightnessSettingView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        
        if newWindow == nil && fontSelectView?.superview != nil {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        super.willMove(toWindow: newWindow)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = self.bounds
    }
    
    //MARK: - Private
    func setupSubviews() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        self.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalTo(scrollView)
            make.size.equalTo(ReadSettingView.viewSize)
        }
        
        scrollSettingView.titleLabel.text = "竖向翻页"
        scrollSettingView.isOn = ReaderConfig.transitionStyle == .scroll
        scrollSettingView.delegate = self
        contentView.addSubview(scrollSettingView)
        scrollSettingView.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(contentView)
            make.height.equalTo(SwitchSettingView.viewHeight)
        }
        
        colorSettingView.delegate = self
        contentView.addSubview(colorSettingView)
        colorSettingView.snp.makeConstraints { (make) in
            make.right.left.equalTo(contentView)
            make.bottom.equalTo(scrollSettingView.snp.top).offset(-ReadColorSettingView.bottomSapcing)
            make.height.equalTo(ReadColorSettingView.viewHeight)
        }
        
        fontSettingView.delegate = self
        contentView.addSubview(fontSettingView)
        fontSettingView.snp.makeConstraints { (make) in
            make.right.left.equalTo(contentView)
            make.bottom.equalTo(colorSettingView.snp.top).offset(-FontSettingView.bottomSapcing)
            make.height.equalTo(FontSettingView.viewHeight)
        }
        
        contentView.addSubview(brightnessSettingView)
        brightnessSettingView.snp.makeConstraints { (make) in
            make.right.left.equalTo(contentView)
            make.bottom.equalTo(fontSettingView.snp.top).offset(-BrightnessSettingView.bottomSapcing)
            make.height.equalTo(BrightnessSettingView.viewHeight)
        }
        
        self.updateThemeColor()
    }
    
    func updateThemeColor() {
        
        contentView.backgroundColor = ReaderConfig.pageColor
        self.backgroundColor = ReaderConfig.bgColor
        
        scrollSettingView.backgroundColor = ReaderConfig.bgColor
        scrollSettingView.titleLabel.textColor = ReaderConfig.textColor
        
        colorSettingView.updateThemeColor()
        brightnessSettingView.updateThemeColor()
        fontSettingView.updateThemeColor()
        fontSelectView?.updateThemeColor()
    }
    
    //MARK: - Public
    class var viewSize: CGSize {
        get {
            let height = SwitchSettingView.viewHeight + ReadColorSettingView.totalHeight + FontSettingView.totalHeight + BrightnessSettingView.totalHeight
            return CGSize.init(width: 280, height: height)
        }
    }
    
    //MARK: - IRFontSelectViewDelegate
    func fontSelectView(_ view: FontSelectView, didSelectFontName fontName: String) {
        
        if ReaderConfig.fontName == fontName {
            return
        }
        if ReaderConfig.isChinese {
            ReaderConfig.zhFontName = ReadZHFontName(rawValue: fontName)!
        } else {
            ReaderConfig.enFontName = ReadENFontName(rawValue: fontName)!
        }
        fontSettingView.fontTypeSelectView.detailText = ReaderConfig.fontDispalyName
        self.deleage?.readSettingView(self, didSelectFontName: fontName)
    }
    
    func fontSelectViewDidClickBackButton(_ view: FontSelectView) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    //MARK: - IRSwitchSettingViewDeleagte
    func switchSettingView(_ view: SwitchSettingView, isOn: Bool) {
        ReaderConfig.transitionStyle = isOn ? .scroll : .pageCurl
        UserDefaults.standard.set(ReaderConfig.transitionStyle.rawValue, forKey: ReadConfigKey.TransitionStyle.rawValue)
        self.deleage?.readSettingView(self, transitionStyleDidChange: ReaderConfig.transitionStyle)
    }
    
    //MARK: - IRReadColorSettingViewDelegate
    func readColorSettingView(_ view: ReadColorSettingView, didChangeSelectColor color: ReadColorModel) {
        ReaderConfig.pageColorHex = color.pageColorHex
        self.updateThemeColor()
        self.deleage?.readSettingView(self, didChangeSelectColor: color)
    }
    
    func readColorSettingView(_ view: ReadColorSettingView, isFollowSystemTheme isFollow: Bool) {
        
    }
    
    //MARK: - IRFontSettingViewDelegate
    func fontSettingView(_ view: FontSettingView, didChangeTextSizeMultiplier textSizeMultiplier: Int) {
        self.deleage?.readSettingView(self, didChangeTextSizeMultiplier: textSizeMultiplier)
        UserDefaults.standard.set(textSizeMultiplier, forKey: ReadConfigKey.TextSizeMultiplier.rawValue)
    }
    
    func fontSettingViewDidClickFontSelect(_ view: FontSettingView) {
        
        if fontSelectView == nil {
            fontSelectView = FontSelectView()
            fontSelectView?.delegate = self
            fontSelectView?.backgroundColor = self.backgroundColor
            scrollView.addSubview(fontSelectView!)
            fontSelectView?.frame = CGRect.init(x: self.width, y: 0, width: self.width, height: self.height)
            scrollView.contentSize = CGSize.init(width: self.width * 2, height: self.height)
        }
        scrollView.setContentOffset(CGPoint.init(x: self.width, y: 0), animated: true)
    }
}

