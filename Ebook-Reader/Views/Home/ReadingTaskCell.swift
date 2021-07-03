//
//  ReadingTaskCell.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import SnapKit
import UIKit

final class ReadingTaskCell: UICollectionViewCell {

    static let titleSpacing: CGFloat = 5
    static var progressRadius: CGFloat = 0
    static var progressLineWidth: Double = 8
    var titleLabel = UILabel()
    var timeLabel = UILabel()
    var timeDescLabel = UILabel()
    var taskProgress = KYCircularProgress.init(frame: CGRect.zero, showGuide: false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = ReadingTaskCell.progressRadius
        let pi = CGFloat(Double.pi)
        let arcCenter = CGPoint(x: contentView.width / 2, y: radius)
        taskProgress.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: pi, endAngle: pi * 2, clockwise: true)
    }
    
    public var taskModel: ReadingTaskModel? {
        didSet {
            let readingTime = taskModel?.readingTime ?? 0
            taskProgress.progress = min(1, Double(readingTime) / 3600)
            let minute = min(60, readingTime / 60)
            var sceondString: String
            if minute < 60 {
                sceondString = String(format: "%02d", readingTime - minute * 60)
            } else {
                sceondString = "00"
            }
            timeLabel.text = "\(minute):\(sceondString)"
        }
    }
    
    static var titleAttributedText: NSMutableAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5
        let titleText = NSMutableAttributedString.init(string: "Daily reading", attributes: [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.black, .paragraphStyle: paragraphStyle])
        let descText = NSAttributedString.init(string: "\nRead for 1 hour a day, and accumulate less into more, gather sand into tower~", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor(hexStr: "999999"), .paragraphStyle: paragraphStyle])
        titleText.append(descText)
        return titleText
    }()
    
    class func cellHeight(with maxWidth: CGFloat) -> CGFloat {
        let textHeight = ceil(titleAttributedText.boundingRect(with: CGSize(width: maxWidth - titleSpacing * 2, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height)
        progressRadius = floor(maxWidth / 3)
        return 60 + textHeight + progressRadius + CGFloat(progressLineWidth)
    }
    
    private func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        titleLabel.attributedText = ReadingTaskCell.titleAttributedText
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(ReadingTaskCell.titleSpacing)
            make.right.equalTo(contentView).offset(-ReadingTaskCell.titleSpacing)
            make.top.equalTo(contentView).offset(20)
        }
        
        taskProgress.strokeStart = 0
        taskProgress.lineWidth = ReadingTaskCell.progressLineWidth
        taskProgress.lineCap = CAShapeLayerLineCap.round.rawValue
        taskProgress.colors = [UIColor(hexStr:"A6FFCB"), UIColor(hexStr:"12D8FA"), UIColor(hexStr:"1FA2FF")]
        taskProgress.guideColor = UIColor(hexStr:"99CCCCCC")
        taskProgress.progressChanged {
            (progress: Double, circularProgress: KYCircularProgress) in
        }
        contentView.addSubview(taskProgress)
        taskProgress.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView).offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.right.left.equalTo(contentView)
        }
        
        timeLabel.textAlignment = .center
        timeLabel.textColor = .black
        timeLabel.font = .systemFont(ofSize: 45)
        timeLabel.text = "00:00"
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(taskProgress)
            make.bottom.equalTo(taskProgress).offset(5)
        }
        
        timeDescLabel.textColor = .black
        timeDescLabel.textAlignment = .center
        timeDescLabel.font = .boldSystemFont(ofSize: 16)
        timeDescLabel.text = "Today's reading progress"
        contentView.addSubview(timeDescLabel)
        timeDescLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(taskProgress)
            make.bottom.equalTo(timeLabel.snp.top)
        }
    }
}
