//
//  MIVideoUploadVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/30.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

@objcMembers
class MIVideoUploadVC: MIBaseViewController {

    var videoUrl: String!
    var videoPlayer: QZCustomVideoPlayer!
    var notClearPlayer: Bool!
    var asset: AVAsset!
    var phAsset: PHAsset!
    var networkVideoUrl: String!
    var notUpload: String! //用来标识是上传视频界面，还是普通视频播放界面(不为空就代表是普通视频播放)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notClearPlayer = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !notClearPlayer {
            videoPlayer.clear()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }

    private func configUI() {
        super.configLeftBarButtonItem(nil)
        self.view.backgroundColor = UIColor.white
        
        let url = (videoUrl != nil ? videoUrl : nil)
        let ass = (asset != nil ? asset : nil)
        let networkUrl = (networkVideoUrl != nil ? networkVideoUrl : nil)
        let hgt: CGFloat = (!MIHelpTool.isBlankString(notUpload) ? 0 : 60)
        videoPlayer = QZCustomVideoPlayer.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - hgt), videoUrl: url, videoAsset: ass, networkVideoUrl:networkUrl)
        view.addSubview(videoPlayer)
        
        if MIHelpTool.isBlankString(notUpload) {
            let uploadBtn = UIButton(type: .custom)
            uploadBtn.frame = CGRect(x: 0, y: self.view.height - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 60, width: ScreenWidth, height: 60)
            uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
            uploadBtn.setTitle(MILocalData.appLanguage("album_key_11"), for: .normal)
            uploadBtn.setTitleColor(UIColor.white, for: .normal)
            uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
            view.addSubview(uploadBtn)
            
            super.configRightBarButtonItem(with: .custom, frame: CGRect(x: 0, y: 0, width: 49, height: 24), normalTitle: nil, normalTitleColor: MIRgbaColor(rgbValue: 0xF9F9F9, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 12, normalImage: UIImage(named: "icon_album_delete_nor"), highlightedImage: nil, selectedImage: nil, backgroundColor: nil, touchUpInSideTarget: self, action: #selector(clickDeleteBtn))
        }
    }

    override func popToForwardViewController() {
        videoPlayer.clear()
        super.popToForwardViewController()
    }
    
    @objc private func clickDeleteBtn() {
        MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: MILocalData.appLanguage("personal_key_11"), alertMessage: MILocalData.appLanguage("other_key_32"), leftAction: { () in
            
        }) { () in
            self.videoPlayer.clear()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func clickUploadBtn(_ sender: UIButton) {
        videoPlayer.setPlayerPlayOrPauseStatus()
        notClearPlayer = true
        
        let storyBoard = UIStoryboard.init(name: "MyAlbum", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MIUploadViewController") as! MIUploadViewController

        if MIHelpTool.isBlankString(videoUrl) {
            vc.asset = phAsset
        } else {
            vc.assetUrl = videoUrl
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
