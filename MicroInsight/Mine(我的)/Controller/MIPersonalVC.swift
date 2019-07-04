//
//  MIPersonalVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

@objcMembers
class MIPersonalVC: UIViewController {

    var userId: Int = 0
    var userIconBtn: UIButton!
    var userNameLab: UILabel!
    var genderLab: UILabel!
    var ageLab: UILabel!
    var jobLab: UILabel!
    var countLab: UILabel!
    var curPage: NSInteger!
    var lineView: UIView!
    
    private lazy var dataList: Array<MICommunityListModel> = {
        let list = [MICommunityListModel]()
        return list
    }()
    
    private lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let wid: CGFloat = (ScreenWidth - 40) / 2.0
        layout.itemSize = CGSize(width: wid, height: wid * 180.0 / 168.0)
        
        let v = UICollectionView.init(frame: CGRect(x: 0, y: 245, width: ScreenWidth, height: ScreenHeight - 245), collectionViewLayout: layout)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = UIColor.clear
        v.register(UINib(nibName: "MIMyProductionCell", bundle: nil), forCellWithReuseIdentifier: "MIMyProductionCell")
        self.view.addSubview(v)

        weak var weakSelf = self
        v.mj_header = MJRefreshGifHeader.init(refreshingBlock: {
            weakSelf?.curPage = 1;
            
            let userInfo = MILocalData.getCurrentLoginUserInfo()
            if userInfo.uid == weakSelf?.userId {
                weakSelf?.requestMyCommunityList(isRefresh: true)
            } else {
                weakSelf?.requestOtherCommunityList(isRefresh: true)
            }
        })
        
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            weakSelf?.curPage += 1
            
            let userInfo = MILocalData.getCurrentLoginUserInfo()
            if userInfo.uid == weakSelf?.userId {
                weakSelf?.requestMyCommunityList(isRefresh: false)
            } else {
                weakSelf?.requestOtherCommunityList(isRefresh: false)
            }
        })
        
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        super.setStatusBarBackgroundColor(UIColor.clear)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        curPage = 1
        configPersonalUI()
    }
    
    private func configPersonalUI() {
        view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)

        let topBtn = UIButton(type: .custom)
        topBtn.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth * 168.0 / 375.0)
        topBtn.isUserInteractionEnabled = false
        topBtn.setButtonCustomBackgroudImage(btn: topBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        view.addSubview(topBtn)
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 30, width: 60, height: 30)
        backBtn.setImage(UIImage(named: "icon_login_back_nor"), for: .normal)
        backBtn.addTarget(self, action: #selector(clickBackBtn(_ :)), for: .touchUpInside)
        view.addSubview(backBtn)
        
        let userInfo = MILocalData.getCurrentLoginUserInfo()
        if userInfo.uid == userId {
            let blackBtn = UIButton(type: .custom)
            blackBtn.frame = CGRect(x: ScreenWidth - 70, y: 30, width: 70, height: 30)
            blackBtn.setTitle("黑名单", for: .normal)
            blackBtn.setTitleColor(MIRgbaColor(rgbValue: 0x333333, alpha: 1), for: .normal)
            blackBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            blackBtn.addTarget(self, action: #selector(clickBlackBtn(_ :)), for: .touchUpInside)
            view.addSubview(blackBtn)
        }
        
        configTopView()
    }
    
    private func configTopView() {
        let bgView = UIView.init(frame: CGRect(x: 15, y: 79, width: ScreenWidth - 30, height: 110))
        bgView.backgroundColor = UIColor.white
        bgView.round(5, rectCorners: .allCorners)
        view.addSubview(bgView)
        
        userIconBtn = UIButton(type: .custom)
        userIconBtn.frame = CGRect(x: 20, y: 21, width: 60, height: 60)
        userIconBtn.round(30, rectCorners: .allCorners)
        userIconBtn.setImage(UIImage(named: "icon_personal_head_nor"), for: .normal)
        userIconBtn.isUserInteractionEnabled = false
        bgView.addSubview(userIconBtn)
        
        userNameLab = UILabel.init(frame: CGRect(x: userIconBtn.right + 20, y: 37, width: ScreenWidth - 200, height: 15))
        userNameLab.centerY = userIconBtn.centerY - 22
        userNameLab.text = "猫若有鱼"
        userNameLab.textColor = UIColor.black
        userNameLab.font = UIFont.systemFont(ofSize: 13)
        userNameLab.textAlignment = .left
        bgView.addSubview(userNameLab)
        
        genderLab = UILabel.init(frame: CGRect(x: userIconBtn.right + 20, y: userNameLab.bottom + 10, width: 15, height: 11))
        genderLab.centerY = userIconBtn.centerY
        genderLab.text = "女"
        genderLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        genderLab.font = UIFont.systemFont(ofSize: 11)
        genderLab.textAlignment = .left
        bgView.addSubview(genderLab)
        
        ageLab = UILabel.init(frame: CGRect(x: genderLab.right + 20, y: userNameLab.bottom + 10, width: 15, height: 11))
        ageLab.centerY = genderLab.centerY
        ageLab.text = "23"
        ageLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        ageLab.font = UIFont.systemFont(ofSize: 11)
        ageLab.textAlignment = .left
        bgView.addSubview(ageLab)
        
        jobLab = UILabel.init(frame: CGRect(x: ageLab.right + 20, y: userNameLab.bottom + 10, width: 50, height: 11))
        jobLab.centerY = genderLab.centerY
        jobLab.text = "设计师"
        jobLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        jobLab.font = UIFont.systemFont(ofSize: 11)
        jobLab.textAlignment = .left
        bgView.addSubview(jobLab)
        
        let allLab = UILabel.init(frame: CGRect(x: 20, y: bgView.bottom + 25, width: 31, height: 15))
        allLab.text = "全部"
        allLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        allLab.font = UIFont.systemFont(ofSize: 15)
        allLab.textAlignment = .center
        view.addSubview(allLab)
        
        countLab = UILabel.init(frame: CGRect(x: ScreenWidth - 65, y: 0, width: 50, height: 12))
        countLab.centerY = allLab.centerY
        countLab.text = "共7个"
        countLab.textColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        countLab.font = UIFont.systemFont(ofSize: 12)
        countLab.textAlignment = .right
        view.addSubview(countLab)
        
        lineView = UIView.init(frame: CGRect(x: 20, y: allLab.bottom + 15, width: ScreenWidth - 40, height: 1))
        lineView.backgroundColor = MIRgbaColor(rgbValue: 0xD7D7D7, alpha: 1)
        view.addSubview(lineView)
        
        let userInfo = MILocalData.getCurrentLoginUserInfo()
        if userInfo.uid == userId {
            let editBtn = UIButton(type: .custom)
            editBtn.frame = CGRect(x: bgView.width - 80, y: 0, width: 60, height: 20)
            editBtn.centerY = userNameLab.centerY
            editBtn.setEnlargeEdge(5)
            editBtn.setTitle("修改资料", for: .normal)
            editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            editBtn.rounded(2, width: 1, color: MIRgbaColor(rgbValue: 0x48A1D8, alpha: 1))
            editBtn.setTitleColor(MIRgbaColor(rgbValue: 0x48A1D8, alpha: 1), for: .normal)
            editBtn.addTarget(self, action: #selector(clickEditBtn(_ :)), for: .touchUpInside)
            bgView.addSubview(editBtn)
            
            refreshSubViews(model: userInfo)
            requestMyCommunityList(isRefresh: true)
        } else {
            requestOtherUserInfo()
            requestOtherCommunityList(isRefresh: true)
        }
    }
    
    private func requestOtherUserInfo() {
        weak var weakSelf = self
        MIRequestManager.getOtherUserInfo(withUserId: userId, requestToken: MILocalData.getCurrentRequestToken()) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                let data: [String: AnyObject] = dic["data"] as! Dictionary
                let user: [String: AnyObject] = data["user"] as! Dictionary
                let model = MIUserInfoModel.yy_model(with: user)
                weakSelf?.refreshSubViews(model: model!)
            }
        }
    }
    
    private func requestMyCommunityList(isRefresh: Bool) {
        
        weak var weakSelf = self
        MIRequestManager.getCommunityDataList(withSearchTitle: "", requestToken: MILocalData.getCurrentRequestToken(), page: curPage, pageSize: 10, isMine: true) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                
                if isRefresh {
                    weakSelf?.dataList.removeAll()
                    weakSelf?.collectionV.mj_header.endRefreshing()
                }
                
                let data: [String: AnyObject] = dic["data"] as! Dictionary
                let pagination: Dictionary = data["pagination"] as! [String: Int]
                let totalCount: Int = pagination["totalCount"]!
                weakSelf?.countLab.text = "共\(totalCount)个"
                
                let list: Array = data["list"] as! Array<[String: AnyObject]>
                for modelDic: [String: AnyObject] in list {
                    let model = MICommunityListModel.yy_model(with: modelDic)
                    weakSelf?.dataList.append(model!)
                }
                
                if list.count > 0 {
                    weakSelf?.collectionV.isHidden = false
                    weakSelf?.lineView.isHidden = true
                }
                
                if list.count < 10 {
                    //没有数据
                    if list.count == 0 && weakSelf?.curPage == 1 {
                        weakSelf?.collectionV.isHidden = true
                        weakSelf?.lineView.isHidden = false
                    }
                    weakSelf?.collectionV.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    weakSelf?.collectionV.mj_footer.endRefreshing()
                }

                weakSelf?.collectionV.reloadData()
            } else {
                weakSelf?.collectionV.mj_footer.endRefreshing()
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    private func requestOtherCommunityList(isRefresh: Bool) {
        
        weak var weakSelf = self
        MIRequestManager.getOtherCommunityDataList(withUserId: userId, requestToken: MILocalData.getCurrentRequestToken(), page: curPage, pageSize: 10) { (jsonData, error) in
        
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                
                if isRefresh {
                    weakSelf?.dataList.removeAll()
                    weakSelf?.collectionV.mj_header.endRefreshing()
                }
                
                let data: [String: AnyObject] = dic["data"] as! Dictionary
                let pagination: Dictionary = data["pagination"] as! [String: Int]
                let totalCount: Int = pagination["totalCount"]!
                weakSelf?.countLab.text = "共\(totalCount)个"
                
                let list: Array = data["list"] as! Array<[String: AnyObject]>
                for modelDic: [String: AnyObject] in list {
                    let model = MICommunityListModel.yy_model(with: modelDic)
                    weakSelf?.dataList.append(model!)
                }
                
                if list.count > 0 {
                    weakSelf?.collectionV.isHidden = false
                    weakSelf?.lineView.isHidden = true
                }
                
                if list.count < 10 {
                    //没有数据
                    if list.count == 0 && weakSelf?.curPage == 1 {
                        weakSelf?.collectionV.isHidden = true
                        weakSelf?.lineView.isHidden = false
                    }
                    weakSelf?.collectionV.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    weakSelf?.collectionV.mj_footer.endRefreshing()
                }
                
                weakSelf?.collectionV.reloadData()
            } else {
                weakSelf?.collectionV.mj_footer.endRefreshing()
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    private func refreshSubViews(model: MIUserInfoModel) {
        let iconUrl = model.avatar + "?x-oss-process=image/resize,m_fill,h_60,w_60"
        userIconBtn.sd_setImage(with: NSURL(string: iconUrl) as URL?, for: .normal, placeholderImage: UIImage(named: "icon_personal_head_nor"), options: .retryFailed, completed: nil)
        
        userNameLab.text = model.nickname
        genderLab.text = (model.gender == 0 ? "男" : "女")
        
        let jobList = ["程序", "科研", "教育", "收藏", "美业", "其他"]
        var str = "其他"
        if model.profession != .other {
            str = jobList[model.profession.rawValue - 1]
        }
        jobLab.text = str
        ageLab.text = "\(model.age)"
    }

    @objc private func clickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func clickBlackBtn(_ sender: UIButton) {
        let vc = MIBlackListViewController.init(nibName: "MIBlackListViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickEditBtn(_ sender: UIButton) {
        let editVC = MIEditPersonalInfoVC.init(nibName: "MIEditPersonalInfoVC", bundle: nil)
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}

extension MIPersonalVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = self.dataList[indexPath.item]
        let detailVC = MICommunityDetailVC.init()
        detailVC.contentId = model.contentId
        detailVC.contentType = model.contentType
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MIPersonalVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIMyProductionCell", for: indexPath) as! MIMyProductionCell
        let model = self.dataList[indexPath.item]
        cell.setCellWith(model)
        
        return cell
    }
}

extension MIPersonalVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController!.viewControllers.count <= 1 {
            return false;
        }
        return true;
        
    }
}
