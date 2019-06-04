//
//  MIFeedbackVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIFeedbackVC: MIBaseViewController {

    @IBOutlet weak var textView: MIPlaceholderTextView!
    @IBOutlet weak var commitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configFeekbackUI()
    }

    private func configFeekbackUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("feekback_key_1")
        commitBtn.round(2, rectCorners: .allCorners)
        commitBtn.setButtonCustomBackgroudImage(btn: commitBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        textView.placeholder = "感谢您使用Tipscope APP,使用过程中有任何意见或建议请 反馈给我们。"
        textView.placeholderColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 12)
    }
    
    @IBAction func clickCommitBtn(_ sender: UIButton) {
        
    }
}
