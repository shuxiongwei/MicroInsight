//
//  MIAuthCodeLoginViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIAuthCodeLoginViewController: MIBaseViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var authCodeBtn: UIButton!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var token: String?
    var timer: Timer?
    var downCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configAuthCodeLoginUI()
    }
    
    private func configAuthCodeLoginUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("login_key_6")
        topConstraint.constant = 73 - MINavigationBarHeight(vc: self)
    
        authCodeBtn.layer.cornerRadius = 2
        authCodeBtn.layer.masksToBounds = true
        authCodeBtn.setTitle(MILocalData.appLanguage("login_key_12"), for: .normal)
        authCodeBtn.setButtonCustomBackgroudImage(btn: authCodeBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        loginBtn.setTitle(MILocalData.appLanguage("login_key_1"), for: .normal)
        loginBtn.setButtonCustomBackgroudImage(btn: loginBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        phoneTF.setValue(MILocalData.appLanguage("login_key_8"), forKeyPath: "_placeholderLabel.text")
        authCodeTF.setValue(MILocalData.appLanguage("login_key_9"), forKeyPath: "_placeholderLabel.text")
    }

    //发送验证码
    @IBAction func clickAuthCodeBtn(_ sender: UIButton) {
        if !MIHelpTool.validateContactNumber(phoneTF.text) {
            MIHudView.showMsg("请输入正确的手机号码")
            return
        }
        
        weak var weakSelf = self
        MIRequestManager.getMessageVerificationCode(withMobile: phoneTF.text!, type: 2) { (jsonData: Any?, error: Error?) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let data = dic["data"]
                let token = data?["verifyToken"] as? Int
                weakSelf?.token = token?.description
            }
            
            weakSelf?.downCount = 60
            weakSelf?.authCodeBtn.isUserInteractionEnabled = false
            weakSelf?.authCodeBtn.setBackgroundImage(nil, for: .normal)
            weakSelf?.authCodeBtn.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
            weakSelf?.authCodeBtn.setTitle("\(weakSelf!.downCount!)" + "s", for: .normal)
            weakSelf?.authCodeBtn.setTitleColor(MIRgbaColor(rgbValue: 0x999999, alpha: 1), for: .normal)
            weakSelf?.initTimer()
        }
    }
    
    //登录
    @IBAction func clickLoginBtn(_ sender: UIButton) {
        if !MIHelpTool.validateContactNumber(phoneTF.text) {
            MIHudView.showMsg("请输入正确的手机号码")
            return
        }
        
        if authCodeTF.text!.count == 0 {
            MIHudView.showMsg("请输入验证码")
            return
        }
        
        MBProgressHUD.showStatus("登录中，请稍后...")
        weak var weakSelf = self
        MIRequestManager.login(withMobile: phoneTF.text!, verifyToken: token!, verifyCode: authCodeTF.text!) { (jsonData, error) in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide()
            }
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let data = dic["data"]
                let user = data?["user"]
                let model = MIUserInfoModel.yy_model(with: user as! [AnyHashable : Any])
                MILocalData.saveCurrentLoginUserInfo(model)
                
                weakSelf?.navigationController?.popToRootViewController(animated: true)
            } else {
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    //MARK:定时器
    private func initTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
    }
    
    @objc private func timerRun() {
        downCount -= 1
        if downCount == 0 {
            authCodeBtn.isUserInteractionEnabled = true
            authCodeBtn.backgroundColor = nil
            authCodeBtn.setButtonCustomBackgroudImage(btn: authCodeBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
            authCodeBtn.setTitle("发送验证码", for: .normal)
            authCodeBtn.setTitleColor(MIRgbaColor(rgbValue: 0xffffff, alpha: 1), for: .normal)
        } else {
            authCodeBtn.setTitle("\(downCount!)" + "s", for: .normal)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
