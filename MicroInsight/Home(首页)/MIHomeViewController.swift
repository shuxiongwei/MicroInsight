//
//  MIHomeViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIHomeViewController: UIViewController {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var navHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var albumBtn: UIButton!
    @IBOutlet weak var communityBtn: UIButton!
    @IBOutlet weak var recommendBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    var siderBar: MISiderBarView!
    var timer: DispatchSourceTimer!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    //移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        siderBar.refreshTopView()
        checkNotReadMessage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configHomeUI()
//        configTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSubviewsByLanguage), name: NSNotification.Name(rawValue:"languageSetNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(loginFirst), name: NSNotification.Name(rawValue:"isFirstLogin"), object: nil)
        
        let login = MILocalData.isFirstLogin()
        if login {
            loginFirst()
        }
    }

    private func configHomeUI() {
        topConstraint.constant = 221.0 / 375.0 * ScreenWidth
        navHeightConstraint.constant = MINavigationBarHeight(vc: self) + MIStatusBarHeight()
        menuBtn.setEnlargeEdge(15)
        msgBtn.setEnlargeEdge(15)
        
        siderBar = MISiderBarView.loadSiderBarNib()
        siderBar.x = -ScreenWidth;
        view.addSubview(siderBar)
        
        bgView.rounded(11)
        cameraBtn.rounded(4)
        albumBtn.rounded(4)
        communityBtn.rounded(4)
        recommendBtn.rounded(4)
        refreshSubviewsByLanguage()
        
        let swipeL = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeLeftAction(_ :)))
        swipeL.direction = .left
        view.addGestureRecognizer(swipeL)
        
        let swipeR = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeRightAction(_ :)))
        swipeR.direction = .right
        view.addGestureRecognizer(swipeR)
    }

    //定时器
    func configTimer() {
        /**创建timer
         * flags: 一个数组
         * queue: timer 在那个队列里面执行
         */
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        ///设置timer的计时参数
        /**
         wallDeadline: 什么时候开始
         leeway: 调用频率,即多久调用一次
         */
        //循环执行，马上开始，间隔为5s,误差允许10微秒
        timer?.schedule(deadline: DispatchTime.now(), repeating: .seconds(5), leeway: .milliseconds(10))
        ///执行timer
        weak var weakSelf = self
        self.timer?.setEventHandler(handler: {
            weakSelf?.checkNotReadMessage()
        })
        ///执行timer
        self.timer?.resume()
    }
    
    func checkNotReadMessage() {
        let count = MIMessageListModel.getNotReadMessageCount()
        if count > 0 {
            msgBtn.isSelected = true
        } else {
            weak var weakSelf = self
            MIRequestManager.getAllNotReadMessage(withRequestToken: MILocalData.getCurrentRequestToken(), completed: { (jsonData, error) in
                
                let dic: [String : AnyObject] = jsonData as! Dictionary
                let code = dic["code"]?.int64Value
                if code == 0 {
                    let data: [String: AnyObject] = dic["data"] as! Dictionary
                    let list: Array = data["list"] as! Array<[String: AnyObject]>
                    if list.count >= 1 { //有未读消息
                        weakSelf?.msgBtn.isSelected = true
                        NotificationCenter.default.post(name: NSNotification.Name("newMessage"), object: self, userInfo: nil)
                    } else {
                        weakSelf?.msgBtn.isSelected = false
                    }
                }
            })
        }
    }
    
    //MARK:按钮点击事件
    @IBAction func clickHomeMenuBtn(_ sender: UIButton) {
//        mm_drawerController.open(.left, animated: true, completion: nil)
        
        siderBar.showOrHideSiderBar()
    }
    
    @IBAction func clickMsgBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            let messageVC = MIMessageVC.init()
            self.navigationController?.pushViewController(messageVC, animated: true)
        } else {
            let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func clickCameraBtn(_ sender: UIButton) {
        let vc = MIPhotographyViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickAlbumBtn(_ sender: UIButton) {
        let albumVC = MILocalAlbumVC.init()
        self.navigationController?.pushViewController(albumVC, animated: true)
    }
    
    @IBAction func clickCommunityBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            let vc = MICommunityVC.init()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func clickRecommendBtn(_ sender: UIButton) {
        if MILocalData.hasLogin() {
            let vc = MIRecommendVC.init()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let loginVC: MILoginViewController = MILoginViewController(nibName: "MILoginViewController", bundle: nil)
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func clickTopBannerBtn(_ sender: UIButton) {
        let vc = MIActivityDetailVC.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func swipeRightAction(_ rec: UIGestureRecognizer) {
        siderBar.showSiderBar()
    }
    
    @objc func swipeLeftAction(_ rec: UIGestureRecognizer) {
        siderBar.hideSiderBar()
    }
    
    @objc func refreshSubviewsByLanguage() {
        cameraBtn.setTitle(MILocalData.appLanguage("home_key_1"), for: .normal)
        albumBtn.setTitle(MILocalData.appLanguage("home_key_2"), for: .normal)
        communityBtn.setTitle(MILocalData.appLanguage("home_key_3"), for: .normal)
        recommendBtn.setTitle(MILocalData.appLanguage("home_key_4"), for: .normal)
        cameraBtn.layoutButton(with: .top, imageTitleSpace: 5)
        albumBtn.layoutButton(with: .top, imageTitleSpace: 5)
        communityBtn.layoutButton(with: .top, imageTitleSpace: 5)
        recommendBtn.layoutButton(with: .top, imageTitleSpace: 5)
        
        siderBar.refreshSubviewsByLanguage()
    }
    
    @objc func loginFirst() {
        MILocalData.setIsFirstLogin("true")
        
        let videoVC = MIVideoUploadVC.init()
        videoVC.networkVideoUrl = MILocalData.getVideoTutorialUrl()
        videoVC.notUpload = "1"
        self.navigationController?.pushViewController(videoVC, animated: true)
    }
}
