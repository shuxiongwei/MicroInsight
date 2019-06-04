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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }

    private func configUI() {
        super.configLeftBarButtonItem(nil)
        super.configRightBarButtonItem(with: .custom, frame: CGRect(x: 0, y: 0, width: 49, height: 24), normalTitle: nil, normalTitleColor: MIRgbaColor(rgbValue: 0xF9F9F9, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 12, normalImage: UIImage(named: "icon_album_delete_nor"), highlightedImage: nil, selectedImage: nil, backgroundColor: nil, touchUpInSideTarget: self, action: #selector(clickDeleteBtn))
        self.view.backgroundColor = UIColor.white
        
        videoPlayer = QZCustomVideoPlayer.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 60), videoUrl: videoUrl)
        view.addSubview(videoPlayer)
        
        let uploadBtn = UIButton(type: .custom)
        uploadBtn.frame = CGRect(x: 0, y: self.view.height - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 60, width: ScreenWidth, height: 60)
        uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        uploadBtn.setTitle("确认上传", for: .normal)
        uploadBtn.setTitleColor(UIColor.white, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
        view.addSubview(uploadBtn)
    }

    override func popToForwardViewController() {
        videoPlayer.clear()
        super.popToForwardViewController()
    }
    
    @objc private func clickDeleteBtn() {
        MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "确定删除该视频吗？", leftAction: { () in
            
        }) { () in
            self.videoPlayer.clear()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func clickUploadBtn(_ sender: UIButton) {
        videoPlayer.setPlayerPlayOrPauseStatus()
        
        let storyBoard = UIStoryboard.init(name: "MyAlbum", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MIUploadViewController") as! MIUploadViewController
        vc.assetUrl = videoUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
