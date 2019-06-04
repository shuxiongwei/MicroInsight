//
//  MISideBarViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/11.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MISideBarViewController: UIViewController {

    @IBOutlet weak var headPortraitBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var personalLab: UILabel!
    @IBOutlet weak var languageLab: UILabel!
    @IBOutlet weak var watermarkLab: UILabel!
    @IBOutlet weak var watermarkSwitch: UISwitch!
    @IBOutlet weak var helpLab: UILabel!
    @IBOutlet weak var optionLab: UILabel!
    @IBOutlet weak var updateLab: UILabel!
    @IBOutlet weak var usernameLab: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        refreshTopView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        configSideBarUI()
    }
    
    private func configSideBarUI() {
        loginBtn.round(8, rectCorners: .allCorners)
        watermarkSwitch.transform = CGAffineTransform(scaleX: 38.0 / 51.0, y: 38.0 / 51.0)
    }
    
    private func refreshTopView() {
        if MILocalData.hasLogin() {
            usernameLab.isHidden = false
            loginBtn.isHidden = true
            
            let model = MILocalData.getCurrentLoginUserInfo()
            let imgUrl = model.avatar + "?x-oss-process=image/resize,m_fill,h_\(Int(headPortraitBtn.width)),w_\(Int(headPortraitBtn.height))"
            headPortraitBtn.sd_setImage(with: NSURL(string: imgUrl) as URL?, for: .normal, placeholderImage: UIImage(named: "icon_personal_head_nor"), options: .retryFailed, completed: nil)
            
            usernameLab.text = model.username
        } else {
            usernameLab.isHidden = true
            loginBtn.isHidden = false
            headPortraitBtn.setImage(UIImage(named: ""), for: .normal)
        }
    }

    //MARK:按钮点击事件
    //头像
    @IBAction func clickHeadPortraitBtn(_ sender: UIButton) {
        
    }
    
    //登录
    @IBAction func clickLoginBtn(_ sender: UIButton) {
        mm_drawerController.closeDrawer(animated: true, completion: nil)
        
        let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let navVC = appDelegate.drawerController.centerViewController as! UINavigationController
        navVC.pushViewController(loginVC, animated: true)
    }
    
    //个人主页
    @IBAction func gotoPersonalHomepage(_ sender: UIButton) {
        
    }
    
    //设置语言
    @IBAction func settingLanguage(_ sender: UIButton) {
        mm_drawerController.closeDrawer(animated: true, completion: nil)
        
        let languageVC: MISettingLanguageVC = MISettingLanguageVC.init()
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(languageVC, animated: true)
    }
    
    //添加水印
    @IBAction func addWatermark(_ sender: UISwitch) {
        
    }
    
    //用户帮助
    @IBAction func useHelp(_ sender: UIButton) {
        mm_drawerController.closeDrawer(animated: true, completion: nil)
        
        let helpVC: MIUseHelpVC = MIUseHelpVC.init()
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(helpVC, animated: true)
    }
    
    //意见反馈
    @IBAction func optionFeedback(_ sender: UIButton) {
        mm_drawerController.closeDrawer(animated: true, completion: nil)
        
        let feedbackVC: MIFeedbackVC = MIFeedbackVC(nibName: "MIFeedbackVC", bundle: nil)
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(feedbackVC, animated: true)
    }
    
    //检查更新
    @IBAction func checkUpdate(_ sender: UIButton) {
        
    }
    
}
