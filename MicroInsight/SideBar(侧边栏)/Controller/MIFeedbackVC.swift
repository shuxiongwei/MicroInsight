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
        commitBtn.setTitle(MILocalData.appLanguage("feekback_key_2"), for: .normal)
        textView.placeholder = MILocalData.appLanguage("feekback_key_3")
        textView.placeholderColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 12)
    }
    
    @IBAction func clickCommitBtn(_ sender: UIButton) {
        if MIHelpTool.isBlankString(textView.text) {
            MIHudView.showMsg(MILocalData.appLanguage("other_key_13"))
            return
        }

        MIRequestManager.feedback(withContent: textView.text, requestToken: MILocalData.getCurrentRequestToken()) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                MIHudView.showMsg(MILocalData.appLanguage("other_key_50"))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"feedbackFinish"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
//                MIHudView.showMsg("反馈失败")
            }
        }
        
        textView.text = nil
        textView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
}
