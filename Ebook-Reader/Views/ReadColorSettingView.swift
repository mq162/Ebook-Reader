//
//  ReadColorSettingView.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit

protocol ReadColorSettingViewDelegate: AnyObject {
    
    func readColorSettingView(_ view: ReadColorSettingView, didChangeSelectColor color: ReadColorModel)
    
    func readColorSettingView(_ view: ReadColorSettingView, isFollowSystemTheme isFollow: Bool)
}

class ReadColorSettingView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    static let bottomSapcing: CGFloat = 5
    static let colorViewHeight: CGFloat = 60
    static let viewHeight: CGFloat = colorViewHeight
    static let totalHeight = bottomSapcing + viewHeight
    var collectionView: UICollectionView!
    var currentSelectCell: ReadColorCell?
    
    weak var delegate: ReadColorSettingViewDelegate?
    
    var colorLsit: [ReadColorModel] = {
        
        var list = [ReadColorModel]()
        var color_FFFFFF = ReadColorModel.init(pageHex: ReadPageColorHex.HexF8F8F8.rawValue, borderColor: UIColor(hexStr: "000000"))
        color_FFFFFF.isSelect = color_FFFFFF.pageColorHex == ReaderConfig.pageColorHex
        list.append(color_FFFFFF)
        
        var color_C9C196 = ReadColorModel.init(pageHex: ReadPageColorHex.HexE9E6D7.rawValue, borderColor: UIColor(hexStr:"AF8900"))
        color_C9C196.isSelect = color_C9C196.pageColorHex == ReaderConfig.pageColorHex
        list.append(color_C9C196)
        
        var color_505050 = ReadColorModel.init(pageHex: ReadPageColorHex.Hex373737.rawValue, borderColor: UIColor(hexStr:"FFFFFF"))
        color_505050.isSelect = color_505050.pageColorHex == ReaderConfig.pageColorHex
        list.append(color_505050)
        
        var color_000000 = ReadColorModel.init(pageHex: ReadPageColorHex.Hex000000.rawValue, borderColor: UIColor(hexStr:"FFFFFF"))
        color_000000.isSelect = color_000000.pageColorHex == ReaderConfig.pageColorHex
        list.append(color_000000)
        
        return list
    }()
    
    //MARK: - override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect.init(x: 10, y: 0, width: self.width - 20, height: self.height)
    }
    
    //MARK: - Private
    
    func setupSubviews() {
        self.setupCollectionView()
    }

    private func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(ReadColorCell.self, forCellWithReuseIdentifier: "ReadColorCell")
        self.addSubview(collectionView)
    }
    
    func updateThemeColor() {
        self.backgroundColor = ReaderConfig.bgColor
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorLsit.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let colorCell: ReadColorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadColorCell", for: indexPath) as! ReadColorCell
        colorCell.colorModel = colorLsit[indexPath.item]
        if (colorCell.colorModel!.isSelect) {
            currentSelectCell = colorCell
        }
        return colorCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.width / CGFloat(colorLsit.count), height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentSelectCell?.colorModel?.isSelect = false
        currentSelectCell?.colorModel = currentSelectCell?.colorModel
        
        currentSelectCell = collectionView.cellForItem(at: indexPath) as? ReadColorCell
        currentSelectCell?.colorModel?.isSelect = true
        currentSelectCell?.colorModel = currentSelectCell?.colorModel
        
        if let colorModel = currentSelectCell?.colorModel {
            self.delegate?.readColorSettingView(self, didChangeSelectColor: colorModel)
        }
    }
}

