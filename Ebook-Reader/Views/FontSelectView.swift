//
//  FontSelectView.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import Foundation

protocol FontSelectViewDelegate: AnyObject {
    func fontSelectView(_ view: FontSelectView, didSelectFontName fontName: String)
    func fontSelectViewDidClickBackButton(_ view: FontSelectView)
}

class FontSelectView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let topBarHeight: CGFloat = 45
    
    weak var delegate: FontSelectViewDelegate?
    
    var backButton = UIButton(type: .custom)
    var titleLabel = UILabel()
    var separatorLine = UIView()
    var collectionView: UICollectionView!
    var currentSelectIndex: IndexPath?
    
    
    var zhFontList = {
        
        return [FontModel.init(dispalyName: ReadZHFontName.PingFangSC.displayName(), fontName: ReadZHFontName.PingFangSC.rawValue),
                FontModel.init(dispalyName: ReadZHFontName.STSong.displayName(), fontName: ReadZHFontName.STSong.rawValue),
               FontModel.init(dispalyName: ReadZHFontName.STKaitiSC.displayName(), fontName: ReadZHFontName.STKaitiSC.rawValue),
                FontModel.init(dispalyName: ReadZHFontName.STYuanti.displayName(), fontName: ReadZHFontName.STYuanti.rawValue)]
    }()
    
    var enFontList = {
        
        return [FontModel.init(dispalyName: ReadENFontName.TimesNewRoman.displayName(), fontName:ReadENFontName.TimesNewRoman.rawValue),
                FontModel.init(dispalyName: ReadENFontName.American.displayName(), fontName: ReadENFontName.American.rawValue),
                FontModel.init(dispalyName: ReadENFontName.Georgia.displayName(), fontName:ReadENFontName.Georgia.rawValue),
                FontModel.init(dispalyName: ReadENFontName.Palatino.displayName(), fontName: ReadENFontName.Palatino.rawValue)]
    }()
    
    
    var fontList: [FontModel] {
        get {
            return ReaderConfig.isChinese ? zhFontList : enFontList
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    private func setupSubviews() {
        
        backButton.setImage(UIImage.init(named: "arrow_back")?.template, for: .normal)
        backButton.addTarget(self, action: #selector(didClickBackButton), for: .touchUpInside)
        self.addSubview(backButton)
        backButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(topBarHeight)
            make.top.equalTo(self)
            make.left.equalTo(self).offset(5)
        }
        
        titleLabel.text = "字体"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(backButton)
            make.centerX.equalTo(self)
            make.height.width.equalTo(topBarHeight)
        }
        
        self.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (make) -> Void in
            make.right.left.equalTo(self)
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(FontSelectCell.self, forCellWithReuseIdentifier: "FontSelectCell")
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) -> Void in
            make.right.left.bottom.equalTo(self)
            make.top.equalTo(separatorLine.snp.bottom)
        }
        
        self.updateThemeColor()
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fontList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fontCell: FontSelectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontSelectCell", for: indexPath) as! FontSelectCell
        fontCell.fontModel = fontList[indexPath.item]
        fontCell.isSelected = fontCell.fontModel?.dispalyName == ReaderConfig.fontDispalyName
        if fontCell.isSelected {
            currentSelectIndex = indexPath
        }
        return fontCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: FontSelectCell.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let font = fontList[indexPath.item]
        if font.isDownload {
            if currentSelectIndex != nil {
                let fontCell: FontSelectCell = collectionView.cellForItem(at: currentSelectIndex!) as! FontSelectCell
                fontCell.isSelected = false
            }
            currentSelectIndex = indexPath
            let fontCell: FontSelectCell = collectionView.cellForItem(at: currentSelectIndex!) as! FontSelectCell
            fontCell.isSelected = true
            
            self.delegate?.fontSelectView(self, didSelectFontName: fontList[indexPath.item].fontName)
        }
    }
    
    //MARK: - Action
    
    @objc func didClickBackButton() {
        self.delegate?.fontSelectViewDidClickBackButton(self)
    }
    
    //MARK: - Public
    
    func updateThemeColor() {
        self.backgroundColor = ReaderConfig.bgColor
        separatorLine.backgroundColor = ReaderConfig.separatorColor
        titleLabel.textColor = ReaderConfig.textColor
        backButton.tintColor = ReaderConfig.textColor
        collectionView.reloadData()
    }
}
