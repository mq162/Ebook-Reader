//
//  UploadVC.swift
//  Ebook-Reader
//
//  Created by Quang Phạm on 03/07/2021.
//

import UIKit
import SnapKit
import PKHUD
import GCDWebServers

class UploadVC: BaseVC, GCDWebUploaderDelegate {

    var webUploader: GCDWebUploader?
    lazy var wifiView = UIImageView(image: UIImage(named: "wifi")?.template)
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        setupLeftBackBarButton()
        if Network.shared.networkState == .wifi {
            setupWebUploader()
        } else {
            setupOpenErrorState()
        }
    }
    
    deinit {
        if let webUploader = webUploader, webUploader.isRunning {
            webUploader.stop()
            print("Web Uploader stop")
        }
    }
    
    func commonInit() {
        view.backgroundColor = .white
        title = "WiFi-传书"
        
        view.addSubview(titleLabel)
        let top = (navigationController?.navigationBar.frame.maxY ?? 0) + 30
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(top)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }
        
        wifiView.tintColor = UIColor(hexStr: "999999")
        view.addSubview(wifiView)
        wifiView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(150)
            make.width.equalTo(98)
            make.height.equalTo(71)
            make.centerX.equalTo(view)
        }
        
        view.addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(wifiView.snp.bottom).offset(10)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }
    }
    
    func setupWebUploader() {
        webUploader = GCDWebUploader.init(uploadDirectory: SystemFileManager.wifiUploadPath)
        webUploader?.delegate = self
        webUploader?.title = title!
        webUploader?.header = "iRead"
        webUploader?.start()
    }
    
    func setupOpenErrorState() {
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let font = UIFont.systemFont(ofSize: 16)
        let titleText = NSMutableAttributedString.init(string: "HTTP服务器启动失败", attributes: [.font: font, .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        titleLabel.attributedText = titleText
        
        let warningStyle = NSMutableParagraphStyle()
        warningStyle.alignment = .center
        warningStyle.lineSpacing = 5
        let warningColor = UIColor(hexStr: "999999")
        let warning = NSMutableAttributedString.init(string: "Wi-Fi服务未连接\n", attributes: [.font: font, .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let unlink = NSAttributedString.init(string: "请确认您的设备的连接状态", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        warning.append(unlink)
        warningLabel.attributedText = warning
    }
    
    // MARK: GCDWebUploaderDelegate
    
    func webServerDidStart(_ server: GCDWebServer) {
        
        guard let serverURLString = server.serverURL?.absoluteString else { return }
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let font = UIFont.systemFont(ofSize: 16)
        let titleText = NSMutableAttributedString.init(string: "在电脑浏览器地址栏输入\n", attributes: [.font: font, .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        let descText = NSAttributedString.init(string: serverURLString, attributes: [.font: font, .foregroundColor: UIColor.systemBlue, .paragraphStyle: titleStyle])
        titleText.append(descText)
        titleLabel.attributedText = titleText
        
        let warningStyle = NSMutableParagraphStyle()
        warningStyle.alignment = .center
        warningStyle.lineSpacing = 5
        let warningColor = UIColor(hexStr:"999999")
        let warning = NSMutableAttributedString.init(string: "Wi-Fi模式已开启\n", attributes: [.font: font, .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let link = NSAttributedString.init(string: "已连接Wi-Fi\n", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        let sameWifi = NSAttributedString.init(string: "手机与电脑必须在同一Wi-Fi中", attributes: [.font:  UIFont.systemFont(ofSize: 13), .foregroundColor: warningColor, .paragraphStyle: warningStyle])
        warning.append(link)
        warning.append(sameWifi)
        warningLabel.attributedText = warning
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .center
        titleStyle.lineSpacing = 15
        let titleText = NSMutableAttributedString.init(string: "已连接请传输\n", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.lightGray, .paragraphStyle: titleStyle])
        let descText = NSAttributedString.init(string: "传输过程中不要关闭此界面或锁屏", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.red, .paragraphStyle: titleStyle])
        titleText.append(descText)
        titleLabel.attributedText = titleText
        
        wifiView.tintColor = UIColor(hexStr:"73F873")
    }
    
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        HUD.dimsBackground = false
        HUD.flash(.labeledSuccess(title: "上传成功", subtitle: path.lastPathComponent), delay: 1)
        SystemFileManager.shared.addEpubBookByWifiUploadBookPath(path)
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        HUD.dimsBackground = false
        HUD.flash(.labeledSuccess(title: "删除成功", subtitle: path.lastPathComponent), delay: 1)
    }
}
