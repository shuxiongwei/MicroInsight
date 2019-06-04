//
//  MIActivityDetailVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIActivityDetailVC: MIBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configActivityDetailUI()
    }
    
    private func configActivityDetailUI() {
        super.configLeftBarButtonItem(nil)
        self.title = "活动详情"
        self.view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        
        let bgView = UIView.init(frame: CGRect(x: 15, y: 15, width: ScreenWidth - 30, height: ScreenHeight - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 45))
        bgView.backgroundColor = UIColor.white
        bgView.round(2, rectCorners: .allCorners)
        view.addSubview(bgView)
        
        let detailLab = UILabel.init(frame: CGRect(x: 19, y: 21, width: bgView.width - 38, height: 16))
        detailLab.text = "活动详情"
        detailLab.textColor = MIRgbaColor(rgbValue: 0x2D2D2D, alpha: 1)
        detailLab.font = UIFont.boldSystemFont(ofSize: 15)
        bgView.addSubview(detailLab)
        
        let textView = UITextView.init(frame: CGRect(x: 19, y: detailLab.bottom + 20, width: bgView.width - 38, height: bgView.height - 54 - 140))
        textView.isEditable = false
        textView.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.text = "你是否还在为自己的皮肤问题苦恼\n还在纠结化妆品是否适合自己\n别担心\n小T免费为您解决\n\r即日起\n使用小贴显微镜拍摄自己的皮肤\n上传至TipScope公众号后台\n留言告诉小T，您对于自己的皮肤有什么疑问\n我们将依据您的照片制作\n「T医生皮肤自检程序」\n您上传的照片越多，越能够优先免费体验\nTipScope也会全力保护您和照片的隐私\n\r发送皮肤照片最多的十位粉丝可免费获得\n由武汉协和医院皮肤教授与TipScope合力制作\n专属于您的皮肤分析报告\n\r发送照片数量未达到前十的粉丝也不用担心\n您只需要发送任意一张由小贴拍摄的皮肤照片\n即可免费获得「T医生皮肤自检程序」优先体验权\n\r还等什么\n轻松拍照就能做一次皮肤检测\n快拿起手机上传吧"
        bgView.addSubview(textView)
        
        let uploadBtn = UIButton(type: .custom)
        uploadBtn.frame = CGRect(x: 80, y: bgView.height - 100, width: bgView.width - 160, height: 40)
        uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        uploadBtn.setTitle("开始上传", for: .normal)
        uploadBtn.setTitleColor(UIColor.white, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(uploadBtn)
    }

    @objc private func clickUploadBtn(_ sender: UIButton) {
        
    }
}
