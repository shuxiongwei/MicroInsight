//
//  MIEditPersonalInfoVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit


class MIEditPersonalInfoVC: MIBaseViewController {

    @IBOutlet weak var headIconBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var nickNameLab: UILabel!
    @IBOutlet weak var inputBtn: UIButton!
    @IBOutlet weak var genderLab: UILabel!
    @IBOutlet weak var genderSelectBtn: UIButton!
    @IBOutlet weak var birthdayLab: UILabel!
    @IBOutlet weak var birthdaySelectBtn: UIButton!
    @IBOutlet weak var jobLab: UILabel!
    @IBOutlet weak var jobSelectBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var jumpBtn: UIButton!
    
    let jobList = [MILocalData.appLanguage("personal_key_20"),
                   MILocalData.appLanguage("personal_key_21"),
                   MILocalData.appLanguage("personal_key_22"),
                   MILocalData.appLanguage("personal_key_23"),
                   MILocalData.appLanguage("personal_key_24"),
                   MILocalData.appLanguage("personal_key_25")]
    
    private lazy var activityView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView.init(frame: CGRect(x: (ScreenWidth - 80) / 2.0, y:(ScreenHeight - 80) / 2.0, width: 80, height: 80))
        v.style = .whiteLarge
        v.hidesWhenStopped = true
        self.view.addSubview(v)

        return v
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        super.setStatusBarBackgroundColor(UIColor.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }
    
    private func configUI() {
        super.configLeftBarButtonItem(nil)
        
        if MILocalData.hasLogin() {
            self.title = MILocalData.appLanguage("personal_key_1")
            jumpBtn.setTitle(MILocalData.appLanguage("personal_key_10"), for: .normal)
            let userInfo = MILocalData.getCurrentLoginUserInfo()
            
            let iconUrl = userInfo.avatar + "?x-oss-process=image/resize,m_fill,h_60,w_60"
            headIconBtn.sd_setImage(with: NSURL(string: iconUrl) as URL?, for: .normal, placeholderImage: UIImage(named: "icon_personal_head_nor"), options: .retryFailed, completed: nil)
            
            inputBtn.setTitle(userInfo.nickname, for: .normal)
            genderSelectBtn.setTitle((userInfo.gender == 0 ? MILocalData.appLanguage("personal_key_16") : MILocalData.appLanguage("personal_key_17")), for: .normal)
            let strs = userInfo.birthday.components(separatedBy: " ")
            birthdaySelectBtn.setTitle(strs.first, for: .normal)
            
            var str = MILocalData.appLanguage("personal_key_25")
            if userInfo.profession != .other {
                str = jobList[userInfo.profession.rawValue - 1]
            }
            jobSelectBtn.setTitle(str, for: .normal)
        } else {
            self.title = MILocalData.appLanguage("personal_key_1")
            jumpBtn.setTitle("跳过", for: .normal)
        }
        
        headIconBtn.round(30, rectCorners: .allCorners)
        saveBtn.setButtonCustomBackgroudImage(btn: saveBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        saveBtn.round(2, rectCorners: .allCorners)
        saveBtn.setTitle(MILocalData.appLanguage("personal_key_9"), for: .normal)
        jumpBtn.round(2, rectCorners: .allCorners)
        
        nickNameLab.text = MILocalData.appLanguage("personal_key_3")
        genderLab.text = MILocalData.appLanguage("personal_key_5")
        birthdayLab.text = MILocalData.appLanguage("personal_key_7")
        jobLab.text = MILocalData.appLanguage("personal_key_8")
        changeBtn.setTitle(MILocalData.appLanguage("personal_key_2"), for: .normal)
    }
    
    func changeHeadIcon() {
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction.init(title: MILocalData.appLanguage("personal_key_13"), style: .cancel, handler: nil)
        let cameraAction = UIAlertAction.init(title: MILocalData.appLanguage("other_key_9"), style: .default) { (action) in
            
            let avStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if avStatus == .denied {
                MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "请在iPhone的\"设置-隐私-相机\"中允许访问相机", leftAction: {
                    
                }, rightAction: {
                    UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                })
            } else if avStatus == .notDetermined {
                MIHudView.showMsg("此设备不支持拍照")
            }
            
            let pickerVC = UIImagePickerController.init()
            pickerVC.allowsEditing = true
            pickerVC.delegate = self
            pickerVC.sourceType = .camera
            self.present(pickerVC, animated: true, completion: nil)
        }
        let photoAction = UIAlertAction.init(title: MILocalData.appLanguage("other_key_10"), style: .default) { (action) in
            let pickerVC = UIImagePickerController.init()
            pickerVC.allowsEditing = true
            pickerVC.delegate = self
            pickerVC.sourceType = .photoLibrary
            self.present(pickerVC, animated: true, completion: nil)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoAction)
        self.present(alertVC, animated: true, completion: nil)
    }

    @IBAction func clickHeadIconBtn(_ sender: UIButton) {
        changeHeadIcon()
    }
    
    @IBAction func clickChangeHeadBtn(_ sender: UIButton) {
        changeHeadIcon()
    }
    
    @IBAction func clickInputBtn(_ sender: UIButton) {
        let inputV = MIInputView.init(frame: ScreenBounds, nickName: sender.titleLabel?.text ?? MILocalData.appLanguage("personal_key_14"))
        let window = (UIApplication.shared.delegate!.window)!
        window?.addSubview(inputV)
        
        weak var weakSelf = self
        inputV.confirmBlock = { (text: String) in
            weakSelf?.inputBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickGenderSelectBtn(_ sender: UIButton) {
        let genderV = MIGenderView.init(frame: ScreenBounds, genderText: sender.titleLabel!.text!)
        let window = (UIApplication.shared.delegate!.window)!
        window?.addSubview(genderV)
        
        weak var weakSelf = self
        genderV.confirmBlock = { (text: String) in
            weakSelf?.genderSelectBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickBirthdaySelectBtn(_ sender: UIButton) {
        
        var date: Date!
        if sender.titleLabel?.text == MILocalData.appLanguage("personal_key_6") {
            date = LVDateHelper.fetchLocalDate()
        } else {
            date = LVDateHelper.fetchDate(from: sender.titleLabel?.text, withFormat: "yyyy-MM-dd")
        }
        
        let birthdayV = LVDatePickerView.init(frame: ScreenBounds, currentDate: date, maxDate: LVDateHelper.fetchLocalDate())
        let window = (UIApplication.shared.delegate!.window)!
        window?.addSubview(birthdayV!)
        
        weak var weakSelf = self
        birthdayV?.confimAction = { (time: String?) -> Void in
            weakSelf?.birthdaySelectBtn.setTitle(time, for: .normal)
        }
    }
    
    @IBAction func clickJobSelectBtn(_ sender: UIButton) {
        let wid = ScreenWidth - 80
        let bounds = CGRect(x: 40, y: (ScreenHeight - wid * 340.0 / 295.0) / 2.0, width: wid, height: wid * 340.0 / 295.0)
        let title = MILocalData.appLanguage("personal_key_19")

        let userInfo = MILocalData.getCurrentLoginUserInfo()
        var index = 5
        if userInfo.profession != .other {
            index = userInfo.profession.rawValue - 1
        }
        
        let pickerV = MIPickerView.init(frame: ScreenBounds, bounds: bounds, title: title, list: jobList, index: index)
        let window = (UIApplication.shared.delegate!.window)!
        window?.addSubview(pickerV)
        
        weak var weakSelf = self
        pickerV.confirmBlock = { (text: String) in
            weakSelf?.jobSelectBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickSaveBtn(_ sender: UIButton) {
        if inputBtn.titleLabel?.text == nil {
            MIHudView.showMsg(MILocalData.appLanguage("personal_key_14"))
            return
        }
        
        if genderSelectBtn.titleLabel?.text != MILocalData.appLanguage("personal_key_16") && genderSelectBtn.titleLabel?.text != MILocalData.appLanguage("personal_key_17") {
            MIHudView.showMsg(MILocalData.appLanguage("personal_key_15"))
            return
        }
        
        if birthdaySelectBtn.titleLabel?.text == nil || birthdaySelectBtn.titleLabel?.text == MILocalData.appLanguage("personal_key_6") {
            MIHudView.showMsg(MILocalData.appLanguage("personal_key_18"))
            return
        }
        
        var job = jobSelectBtn.titleLabel?.text
        if jobSelectBtn.titleLabel?.text == nil || jobSelectBtn.titleLabel?.text == MILocalData.appLanguage("personal_key_6") {
            job = MILocalData.appLanguage("personal_key_25")
        }
        
        var index = jobList.firstIndex(of: job!)! + 1
        if job == MILocalData.appLanguage("personal_key_25") {
            index = 0
        }
        
        weak var weakSelf = self
        MIRequestManager.modifyUserInfo(withNickname: inputBtn.titleLabel!.text!, gender: (genderSelectBtn.titleLabel?.text == MILocalData.appLanguage("personal_key_16") ? 0 : 1), birthday: birthdaySelectBtn.titleLabel!.text!, profession: index , requestToken: MILocalData.getCurrentRequestToken()) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let model: MIUserInfoModel = MILocalData.getCurrentLoginUserInfo()
                model.nickname = (weakSelf?.inputBtn.titleLabel!.text)!
                model.gender = (weakSelf?.genderSelectBtn.titleLabel?.text == MILocalData.appLanguage("personal_key_16") ? 0 : 1)
                model.birthday = (weakSelf?.birthdaySelectBtn.titleLabel!.text)!
                model.profession = MIProfessionType(rawValue: index)!
                MILocalData.saveCurrentLoginUserInfo(model)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"refreshHeadView"), object: nil)
            }
 
//            let msg = dic["message"] as! String
//            MIHudView.showMsg(msg)
        }
    }
    
    @IBAction func clickJumpBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: MILocalData.appLanguage("personal_key_11"), alertMessage: MILocalData.appLanguage("personal_key_12"), leftAction: {
                
            }) {
                MILocalData.saveCurrentLoginUserInfo(nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            
        }
    }
    
    func modifyUserAvatar(image: UIImage) {
        if !self.activityView.isAnimating {
            self.activityView.startAnimating()
        }
        
        var fileName: String = MIHelpTool.timeStampSecond()
        fileName.append(".jpg")
        
        weak var weakSelf = self
        MIRequestManager.uploadUserAvatar(withFile: "file", fileName: fileName, avatar: image, requestToken: MILocalData.getCurrentRequestToken()) { (jsonData, error) in
        
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let model: MIUserInfoModel = MILocalData.getCurrentLoginUserInfo()
                let data = dic["data"]
                model.avatar = data!["avatar"] as! String
                MILocalData.saveCurrentLoginUserInfo(model)
                
                weakSelf?.headIconBtn .setImage(image, for: .normal)
                weakSelf?.activityView.stopAnimating()
            } else {
//                MIHudView.showMsg("头像设置失败")
            }
        }
    }
}

extension MIEditPersonalInfoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image: UIImage!
        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage;
        } else {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage;
        }
        picker.dismiss(animated: true, completion: nil)
        modifyUserAvatar(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
