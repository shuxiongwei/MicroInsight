//
//  MIHomeViewController.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/12.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIHomeViewController: MIBaseViewController {

    @IBOutlet weak var navHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var albumBtn: UIButton!
    @IBOutlet weak var communityBtn: UIButton!
    @IBOutlet weak var recommendBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    var siderBar: MISiderBarView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        siderBar.refreshTopView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        super.setStatusBarBackgroundColor(.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configHomeUI()
    }

    private func configHomeUI() {
        navHeightConstraint.constant = MINavigationBarHeight(vc: self) + MIStatusBarHeight()
        
        siderBar = MISiderBarView.loadSiderBarNib()
        siderBar.x = -ScreenWidth;
        view.addSubview(siderBar)
        
        bgView.rounded(11)
        cameraBtn.layoutButton(with: .top, imageTitleSpace: 5)
        albumBtn.layoutButton(with: .top, imageTitleSpace: 5)
        communityBtn.layoutButton(with: .top, imageTitleSpace: 5)
        recommendBtn.layoutButton(with: .top, imageTitleSpace: 5)
        cameraBtn.rounded(4)
        albumBtn.rounded(4)
        communityBtn.rounded(4)
        recommendBtn.rounded(4)
        
        let swipeL = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeLeftAction(_ :)))
        swipeL.direction = .left
        view.addGestureRecognizer(swipeL)
        
        let swipeR = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeRightAction(_ :)))
        swipeR.direction = .right
        view.addGestureRecognizer(swipeR)
    }
    
    //MARK:按钮点击事件
    @IBAction func clickHomeMenuBtn(_ sender: UIButton) {
//        mm_drawerController.open(.left, animated: true, completion: nil)
        
        siderBar.showOrHideSiderBar()
    }
    
    @IBAction func clickMsgBtn(_ sender: UIButton) {
        
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
        let vc = MICommunityVC.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickRecommendBtn(_ sender: UIButton) {
        
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
    
}
