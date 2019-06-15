//
//  MISiderBarView.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/19.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MISiderBarView: UIView {

    @IBOutlet weak var headPortraitBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var personalLab: UILabel!
    @IBOutlet weak var languageLab: UILabel!
    @IBOutlet weak var watermarkLab: UILabel!
    @IBOutlet weak var helpLab: UILabel!
    @IBOutlet weak var feedbackLab: UILabel!
    @IBOutlet weak var updateLab: UILabel!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLab: UILabel!
    var myFrame: CGRect!
    
    static func loadSiderBarNib() -> MISiderBarView {
        let nibs = Bundle.main.loadNibNamed("MISiderBarView", owner: self, options: nil)
        let v = nibs?.first as! MISiderBarView
        v.configSiderBarUI()
        return v
    }
    
    private func configSiderBarUI() {
        rightConstraint.constant = ScreenWidth / 375.0 * 65.0
        headPortraitBtn.round(25, rectCorners: .allCorners)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_ :)))
        addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeLeftAction(_ :)))
        swipe.direction = .left
        addGestureRecognizer(swipe)
    }
    
    //MARK:事件响应
    @IBAction func clickHeadPortraitBtn(_ sender: UIButton) {
        let navVC = MIGetNavigationViewController()
        if MILocalData.hasLogin() {
            let personalVC: MIPersonalVC = MIPersonalVC.init()
            let userInfo = MILocalData.getCurrentLoginUserInfo()
            personalVC.userId = userInfo.uid
            navVC.pushViewController(personalVC, animated: true)
        } else {
            let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
            navVC.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func clickLoginBtn(_ sender: UIButton) {
        let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func clickPersonalPageBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            let personalVC: MIPersonalVC = MIPersonalVC.init()
            let userInfo = MILocalData.getCurrentLoginUserInfo()
            personalVC.userId = userInfo.uid
            let navVC = MIGetNavigationViewController()
            navVC.pushViewController(personalVC, animated: true)
        } else {
            clickLoginBtn(loginBtn)
        }
    }
    
    @IBAction func clickSetLanguageBtn(_ sender: UIButton) {
        let languageVC: MISettingLanguageVC = MISettingLanguageVC.init()
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(languageVC, animated: true)
    }
    
    @IBAction func clickAddWatermarkBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func clickUseHelpBtn(_ sender: UIButton) {
        let helpVC: MIUseHelpVC = MIUseHelpVC.init()
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(helpVC, animated: true)
    }
    
    @IBAction func clickFeedbackBtn(_ sender: UIButton) {
        let feedbackVC: MIFeedbackVC = MIFeedbackVC(nibName: "MIFeedbackVC", bundle: nil)
        let navVC = MIGetNavigationViewController()
        navVC.pushViewController(feedbackVC, animated: true)
    }
    
    @IBAction func clickCheckUpdateBtn(_ sender: UIButton) {
        
    }
    
    @objc func tapAction(_ rec: UIGestureRecognizer) {
        hideSiderBar()
    }
    
    @objc func swipeLeftAction(_ rec: UIGestureRecognizer) {
        hideSiderBar()
    }
    
    //MARK:外部方法
    func showOrHideSiderBar() {
        if self.x == 0 {
            hideSiderBar()
        } else {
            showSiderBar()
        }
    }
    
    func showSiderBar() {
        UIView.animate(withDuration: 0.3) {
            self.x = 0
        }
    }
    
    func hideSiderBar() {
        UIView.animate(withDuration: 0.3) {
            self.x = -ScreenWidth
        }
    }
    
    func refreshTopView() {
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
            headPortraitBtn.setImage(UIImage(named: "icon_personal_head_nor"), for: .normal)
        }
    }
}
