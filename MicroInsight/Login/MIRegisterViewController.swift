//
//  MIRegisterViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/14.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIRegisterViewController: MIBaseViewController {

    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var authCodeBtn: UIButton!
    @IBOutlet weak var authCodeTF: UITextField!
    @IBOutlet weak var setPsdTF: UITextField!
    @IBOutlet weak var againSetPsdTF: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var agreementBtn: UIButton!
    var token: String?
    var timer: Timer?
    var downCount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configRegisterUI()
    }
    
    private func configRegisterUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("login_key_2")
        topConstraint.constant = 73 - MINavigationBarHeight(vc: self)
        
        authCodeBtn.layer.cornerRadius = 2
        authCodeBtn.layer.masksToBounds = true
        authCodeBtn.setTitle(MILocalData.appLanguage("login_key_12"), for: .normal)
        authCodeBtn.setButtonCustomBackgroudImage(btn: authCodeBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        registerBtn.layer.cornerRadius = 2
        registerBtn.layer.masksToBounds = true
        registerBtn.setTitle(MILocalData.appLanguage("login_key_2"), for: .normal)
        registerBtn.setButtonCustomBackgroudImage(btn: registerBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        phoneTF.setValue(MILocalData.appLanguage("login_key_8"), forKeyPath: "_placeholderLabel.text")
        authCodeTF.setValue(MILocalData.appLanguage("login_key_9"), forKeyPath: "_placeholderLabel.text")
        setPsdTF.setValue(MILocalData.appLanguage("login_key_10"), forKeyPath: "_placeholderLabel.text")
        againSetPsdTF.setValue(MILocalData.appLanguage("login_key_11"), forKeyPath: "_placeholderLabel.text")
    }

    //发送验证码
    @IBAction func clickAuthCodeBtn(_ sender: UIButton) {
        if !MIHelpTool.validateContactNumber(phoneTF.text) {
            MIHudView.showMsg("请输入正确的手机号码")
            return
        }

        weak var weakSelf = self
        MIRequestManager.getMessageVerificationCode(withMobile: phoneTF.text!, type: 0) { (jsonData: Any?, error: Error?) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let data = dic["data"]
                let token = data?["verifyToken"] as? Int
                weakSelf?.token = token?.description
                weakSelf?.downCount = 60
                weakSelf?.authCodeBtn.isUserInteractionEnabled = false
                weakSelf?.authCodeBtn.setBackgroundImage(nil, for: .normal)
                weakSelf?.authCodeBtn.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
                weakSelf?.authCodeBtn.setTitle("\(weakSelf!.downCount!)" + "s", for: .normal)
                weakSelf?.authCodeBtn.setTitleColor(MIRgbaColor(rgbValue: 0x999999, alpha: 1), for: .normal)
                weakSelf?.initTimer()
            }
        }
    }
    
    //注册
    @IBAction func clickRegisterBtn(_ sender: UIButton) {
        if !MIHelpTool.validateContactNumber(phoneTF.text) {
            MIHudView.showMsg("请输入正确的手机号码")
            return
        }
        
        if setPsdTF.text!.count < 6 || setPsdTF.text!.count > 32 {
            MIHudView.showMsg("请输入6-32位的密码")
            return
        }
        
        if setPsdTF.text != againSetPsdTF.text {
            MIHudView.showMsg("两次输入的密码不一样")
            return
        }
        
        if !agreementBtn.isSelected {
            MIHudView.showMsg("注册需同意用户协议")
            return
        }
        
        weak var weakSelf = self
        MIRequestManager.register(withUsername: phoneTF.text!, password: setPsdTF.text!) { (jsonData: Any?, error: Error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                weakSelf?.navigationController?.popToRootViewController(animated: true)
            } else {
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    @IBAction func selectUserServiceAgreement(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func clickUserServiceAgreementBtn(_ sender: UIButton) {
//        let serviceV = MIUserAgreementView.init(frame: ScreenBounds)
//        let window = (UIApplication.shared.delegate!.window)!;
//        window?.addSubview(serviceV)
        
        let vc = MIUserAgreementVC.init()
        weak var weakSelf = self
        vc.agreeBlock = { (text) in
            weakSelf?.agreementBtn.isSelected = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
