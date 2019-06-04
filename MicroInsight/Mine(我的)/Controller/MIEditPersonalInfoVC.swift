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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        super.setStatusBarBackgroundColor(UIColor.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }
    
    private func configUI() {
        super.configLeftBarButtonItem(nil)
        
        if MILocalData.hasLogin() {
            self.title = "个人资料"
            jumpBtn .setTitle("退出登录", for: .normal)
        } else {
            self.title = "完善个人资料"
            jumpBtn .setTitle("跳过", for: .normal)
        }
        
        headIconBtn.round(30, rectCorners: .allCorners)
        saveBtn.setButtonCustomBackgroudImage(btn: saveBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        saveBtn.round(2, rectCorners: .allCorners)
        jumpBtn.round(2, rectCorners: .allCorners)
    }

    @IBAction func clickHeadIconBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func clickChangeHeadBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func clickInputBtn(_ sender: UIButton) {
        let inputV = MIInputView.init(frame: ScreenBounds, nickName: sender.titleLabel?.text ?? "请输入您的昵称")
        let window = (UIApplication.shared.delegate!.window)!;
        window?.addSubview(inputV)
        
        weak var weakSelf = self
        inputV.confirmBlock = { (text: String) in
            weakSelf?.inputBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickGenderSelectBtn(_ sender: UIButton) {
        let genderV = MIGenderView.init(frame: ScreenBounds, genderText: sender.titleLabel!.text!)
        let window = (UIApplication.shared.delegate!.window)!;
        window?.addSubview(genderV)
        
        weak var weakSelf = self
        genderV.confirmBlock = { (text: String) in
            weakSelf?.genderSelectBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickBirthdaySelectBtn(_ sender: UIButton) {
        let birthdayV = LVDatePickerView.init(frame: ScreenBounds)
        var date: Date!
        if sender.titleLabel?.text == "请选择" {
            date = LVDateHelper.fetchLocalDate()
        } else {
            date = LVDateHelper.fetchDate(from: sender.titleLabel?.text, withFormat: "yyyy-MM-dd")
        }
        birthdayV.scrollToDate = date
        
        let window = (UIApplication.shared.delegate!.window)!;
        window?.addSubview(birthdayV)
        
        weak var weakSelf = self
        birthdayV.confimAction = { (time: String?) -> Void in
            weakSelf?.birthdaySelectBtn.setTitle(time, for: .normal)
        }
    }
    
    @IBAction func clickJobSelectBtn(_ sender: UIButton) {
        let wid = ScreenWidth - 80
        let bounds = CGRect(x: 40, y: (ScreenHeight - wid * 340.0 / 295.0) / 2.0, width: wid, height: wid * 340.0 / 295.0)
        let title = "请选择你的职业"
        let list = ["程序", "科研", "教育", "收藏", "美业", "其他"]
        
        let pickerV = MIPickerView.init(frame: ScreenBounds, bounds: bounds, title: title, list: list)
        let window = (UIApplication.shared.delegate!.window)!;
        window?.addSubview(pickerV)
        
        weak var weakSelf = self
        pickerV.confirmBlock = { (text: String) in
            weakSelf?.jobSelectBtn.setTitle(text, for: .normal)
        }
    }
    
    @IBAction func clickSaveBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func clickJumpBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "确认要退出登录么？", leftAction: {
                
            }) {
                MILocalData.saveCurrentLoginUserInfo(nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            
        }
    }
}
