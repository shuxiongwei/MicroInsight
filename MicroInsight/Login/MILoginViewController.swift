//
//  MILoginViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MILoginViewController: MIBaseViewController {
    
    @IBOutlet weak var phoneLab: UILabel!
    @IBOutlet weak var passwordLab: UILabel!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var authCodeLoginBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherLoginLab: UILabel!
    @IBOutlet weak var forwardPsdBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configLoginUI()
    }
    
    private func configLoginUI() {
        super.configLeftBarButtonItem(nil)
        super.configRightBarButtonItem(with: .custom, frame: CGRect(x: 0, y: 0, width: 60, height: 30), normalTitle: MILocalData.appLanguage("login_key_2"), normalTitleColor: MIRgbaColor(rgbValue: 0x333333, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 12, normalImage: nil, highlightedImage: nil, selectedImage: nil, touchUpInSideTarget: self, action: #selector(clickRegisterBtn(_:)))
        
        topConstraint.constant = 178 - MINavigationBarHeight(vc: self)
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        loginBtn.setTitle(MILocalData.appLanguage("login_key_1"), for: .normal)
        loginBtn.setButtonCustomBackgroudImage(btn: loginBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        authCodeLoginBtn.layer.cornerRadius = 2
        authCodeLoginBtn.layer.masksToBounds = true
        authCodeLoginBtn.setTitle(MILocalData.appLanguage("login_key_6"), for: .normal)
        authCodeLoginBtn.setButtonCustomBackgroudImage(btn: authCodeLoginBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E3, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        phoneLab.text = MILocalData.appLanguage("login_key_3")
        passwordLab.text = MILocalData.appLanguage("login_key_4")
        forwardPsdBtn.setTitle(MILocalData.appLanguage("login_key_5"), for: .normal)
        otherLoginLab.text = MILocalData.appLanguage("login_key_7")
    }

    //MARK:按钮点击事件
    //忘记密码
    @IBAction func forwardPassword(_ sender: UIButton) {
        let authCodeVC = MIForwardPasswordViewController.init(nibName: "MIForwardPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(authCodeVC, animated: true)
    }
    
    //登录
    @IBAction func login(_ sender: UIButton) {
        if !MIHelpTool.validateContactNumber(phoneTF.text) {
            MIHudView.showMsg("请输入正确的手机号码")
            return
        }
        if passwordTF.text!.count == 0 {
            MIHudView.showMsg("请输入密码")
            return
        }
        
        weak var weakSelf = self
        MIRequestManager.login(withUsername: phoneTF.text!, password: passwordTF.text!) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let data = dic["data"]
                let user = data?["user"]
                let model = MIUserInfoModel.yy_model(with: user as! [AnyHashable : Any])
                MILocalData.saveCurrentLoginUserInfo(model)
                
                weakSelf?.navigationController?.popViewController(animated: true)
            } else {
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    //验证码登录
    @IBAction func loginByAuthCode(_ sender: UIButton) {
        let authCodeVC = MIAuthCodeLoginViewController.init(nibName: "MIAuthCodeLoginViewController", bundle: nil)
        self.navigationController?.pushViewController(authCodeVC, animated: true)
    }
    
    //qq登录
    @IBAction func loginByQQ(_ sender: UIButton) {
        
        weak var weakSelf = self
        MIThirdPartyLoginManager.share()?.getUserInfo(withWTLoginType: .tencent, result: { (result: Dictionary?, error: String?) in
            
            if (MIHelpTool.isBlankString(error)) {
                MBProgressHUD.showStatus("QQ登录中，请稍后...")
                MIRequestManager.loginByQQ(withOpenId: result?["openId"] as! String, accessToken: result?["accessToken"] as! String, completed: { (jsonData: Any?, err: Error?) in
                    
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
                })
            } else {
                MIHudView.showMsg(error)
            }
        }, show: self)
    }
    
    //facebook登录
    @IBAction func loginByFacebook(_ sender: UIButton) {
        weak var weakSelf = self
        MIThirdPartyLoginManager.share()?.getUserInfo(withWTLoginType: .facebook, result: { (result: Dictionary?, error: String?) in
            
            if (MIHelpTool.isBlankString(error)) {
                MBProgressHUD.showStatus("Facebook登录中，请稍后...")
                MIRequestManager.loginByFacebook(withDic: result as! Dictionary, completed: { (jsonData: Any?, err: Error?) in
                    
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
                })
            } else {
                MIHudView.showMsg(error)
            }
        }, show: self)
    }
    
    //微信登录
    @IBAction func loginByWX(_ sender: UIButton) {
        weak var weakSelf = self
        MIThirdPartyLoginManager.share()?.getUserInfo(withWTLoginType: .weiXin, result: { (result: Dictionary?, error: String?) in
            
            if (MIHelpTool.isBlankString(error)) {
                MBProgressHUD.showStatus("微信登录中，请稍后...")
                MIRequestManager.loginByWX(withCode: result?["code"] as! String, completed: { (jsonData: Any?, err: Error?) in
                    
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
                })
            } else {
                MIHudView.showMsg(error)
            }
        }, show: self)
    }
    
    //注册
    @objc private func clickRegisterBtn(_ sender: UIButton) {
        let authCodeVC = MIRegisterViewController.init(nibName: "MIRegisterViewController", bundle: nil)
        self.navigationController?.pushViewController(authCodeVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
