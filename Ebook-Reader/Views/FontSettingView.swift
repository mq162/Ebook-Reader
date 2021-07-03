//
//  FontSettingView.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

protocol FontSettingViewDelegate: AnyObject {
    
    func fontSettingView(_ view: FontSettingView, didChangeTextSizeMultiplier textSizeMultiplier: Int)
    func fontSettingViewDidClickFontSelect(_ view: FontSettingView)
}

class FontSettingView: UIView, ArrowSettingViewDelegate {
    
    let multiplierSacle: Int = 2
    static let bottomSapcing: CGFloat = 5
    static let viewHeight: CGFloat = ArrowSettingView.viewHeight + 40
    static let totalHeight = bottomSapcing + viewHeight
    
    weak var delegate: FontSettingViewDelegate?
    
    var fontTypeSelectView = ArrowSettingView()
    lazy var bottomLine = UIView()
    lazy var midLine = UIView()
    var increaseBtn = UIButton.init(type: .custom)
    var reduceBtn = UIButton.init(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    @objc func didIncreaseBtnClick() {
        reduceBtn.isEnabled = true
        let endValue = ReaderConfig.textSizeMultiplier + multiplierSacle
        ReaderConfig.textSizeMultiplier = min(endValue, ReaderConfig.maxTextSizeMultiplier)
        increaseBtn.isEnabled = ReaderConfig.textSizeMultiplier < ReaderConfig.maxTextSizeMultiplier
        self.delegate?.fontSettingView(self, didChangeTextSizeMultiplier: ReaderConfig.textSizeMultiplier)
    }
    
    @objc func didReduceBtnClick() {
        increaseBtn.isEnabled = true
        let endValue = ReaderConfig.textSizeMultiplier - multiplierSacle
        ReaderConfig.textSizeMultiplier = max(endValue, ReaderConfig.minTextSizeMultiplier)
        reduceBtn.isEnabled = ReaderConfig.textSizeMultiplier > ReaderConfig.minTextSizeMultiplier
        self.delegate?.fontSettingView(self, didChangeTextSizeMultiplier: ReaderConfig.textSizeMultiplier)
    }
    
    func setupSubviews() {
        
        fontTypeSelectView.titleLabel.text = "字体"
        fontTypeSelectView.detailText = ReaderConfig.fontDispalyName
        fontTypeSelectView.delegate = self
        self.addSubview(fontTypeSelectView)
        fontTypeSelectView.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(self)
            make.height.equalTo(ArrowSettingView.viewHeight)
        }
        
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) -> Void in
            make.right.left.equalTo(self)
            make.height.equalTo(1)
            make.bottom.equalTo(fontTypeSelectView.snp.top)
        }
        
        increaseBtn.setTitle("A", for: .normal)
        increaseBtn.isEnabled = ReaderConfig.textSizeMultiplier < ReaderConfig.maxTextSizeMultiplier
        increaseBtn.addTarget(self, action: #selector(didIncreaseBtnClick), for: .touchUpInside)
        increaseBtn.contentHorizontalAlignment = .center
        increaseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        self.addSubview(increaseBtn)
        increaseBtn.snp.makeConstraints { (make) -> Void in
            make.right.top.equalTo(self)
            make.bottom.equalTo(fontTypeSelectView.snp.top)
            make.left.equalTo(self.snp.centerX)
        }
    
        self.addSubview(midLine)
        midLine.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.height.top.equalTo(increaseBtn)
            make.width.equalTo(1)
        }
        
        reduceBtn.setTitle("A", for: .normal)
        reduceBtn.isEnabled = ReaderConfig.textSizeMultiplier > ReaderConfig.minTextSizeMultiplier
        reduceBtn.addTarget(self, action: #selector(didReduceBtnClick), for: .touchUpInside)
        reduceBtn.contentHorizontalAlignment = .center
        reduceBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(reduceBtn)
        reduceBtn.snp.makeConstraints { (make) -> Void in
            make.left.top.equalTo(self)
            make.bottom.equalTo(increaseBtn)
            make.right.equalTo(self.snp.centerX)
        }
    }
    
    func updateThemeColor() {
        
        self.backgroundColor = ReaderConfig.bgColor
        midLine.backgroundColor = ReaderConfig.separatorColor
        bottomLine.backgroundColor = ReaderConfig.separatorColor
        fontTypeSelectView.titleLabel.textColor = ReaderConfig.textColor
        
        increaseBtn.setTitleColor(ReaderConfig.textColor, for: .normal)
        increaseBtn.setTitleColor(ReaderConfig.textColor.withAlphaComponent(0.3), for: .highlighted)
        increaseBtn.setTitleColor(ReaderConfig.textColor.withAlphaComponent(0.3), for: .disabled)
        
        reduceBtn.setTitleColor(ReaderConfig.textColor, for: .normal)
        reduceBtn.setTitleColor(ReaderConfig.textColor.withAlphaComponent(0.3), for: .highlighted)
        reduceBtn.setTitleColor(ReaderConfig.textColor.withAlphaComponent(0.3), for: .disabled)
    }
    
    // MARK: - IRArrowSettingViewDelegate
    func didClickArrowSettingView(_ view: ArrowSettingView) {
        self.delegate?.fontSettingViewDidClickFontSelect(self)
    }
}
