//
//  MIQuestionVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIQuestionVC: MIBaseViewController {

    var textView: MIPlaceholderTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }
    
    private func configUI() {
        super.configLeftBarButtonItem(nil)
        self.view.backgroundColor = UIColor.white
        
        let lineV = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        lineV.backgroundColor = MIRgbaColor(rgbValue: 0xDDDDDD, alpha: 1)
        view.addSubview(lineV)
        
        let imgBtn = UIButton(type: .custom)
        imgBtn.frame = CGRect(x: 15, y: lineV.bottom + 15, width: ScreenWidth - 30, height: (ScreenWidth - 30) * 210.0 / 345.0)
        imgBtn.backgroundColor = UIColor.red
        view.addSubview(imgBtn)
        
        textView = MIPlaceholderTextView.init(frame: CGRect(x: 15, y: imgBtn.bottom + 20, width: ScreenWidth - 30, height: 40))
        textView.placeholder = "请描述你的问题......"
        textView.placeholderColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        textView.placeholderFont = UIFont.systemFont(ofSize: 10)
        textView.rounded(1, width: 1, color: MIRgbaColor(rgbValue: 0xDDDDDD, alpha: 1))
        view.addSubview(textView)
        
        let uploadBtn = UIButton(type: .custom)
        uploadBtn.frame = CGRect(x: 40, y: self.view.height - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 85, width: ScreenWidth - 80, height: 40)
        uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        uploadBtn.setTitle("开始上传", for: .normal)
        uploadBtn.setTitleColor(UIColor.white, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
        view.addSubview(uploadBtn)
    }

    @objc private func clickUploadBtn(_ sender: UIButton) {
        
    }
}
