//
//  MIPersonalVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIPersonalVC: MIBaseViewController {

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
            weakSelf?.requestCommunityList(isRefresh: true)
        })
        
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            weakSelf?.curPage += 1
            weakSelf?.requestCommunityList(isRefresh: false)
        })
        
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        super.setStatusBarBackgroundColor(UIColor.clear)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        curPage = 1
        configPersonalUI()
        requestCommunityList(isRefresh: true)
    }
    
    private func configPersonalUI() {
        view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)

        let topBtn = UIButton(type: .custom)
        topBtn.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth * 168.0 / 375.0)
        topBtn.isUserInteractionEnabled = false
        topBtn.setButtonCustomBackgroudImage(btn: topBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        view.addSubview(topBtn)
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 15, y: 35, width: 19, height: 14)
        backBtn.setImage(UIImage(named: "icon_login_back_nor"), for: .normal)
        backBtn.addTarget(self, action: #selector(clickBackBtn(_ :)), for: .touchUpInside)
        view.addSubview(backBtn)
        
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
        userNameLab.text = "猫若有鱼"
        userNameLab.textColor = UIColor.black
        userNameLab.font = UIFont.systemFont(ofSize: 13)
        userNameLab.textAlignment = .left
        bgView.addSubview(userNameLab)
        
        genderLab = UILabel.init(frame: CGRect(x: userIconBtn.right + 20, y: userNameLab.bottom + 10, width: 15, height: 11))
        genderLab.text = "女"
        genderLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        genderLab.font = UIFont.systemFont(ofSize: 11)
        genderLab.textAlignment = .left
        bgView.addSubview(genderLab)
        
        ageLab = UILabel.init(frame: CGRect(x: genderLab.right + 20, y: userNameLab.bottom + 10, width: 15, height: 11))
        ageLab.text = "23"
        ageLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        ageLab.font = UIFont.systemFont(ofSize: 11)
        ageLab.textAlignment = .left
        bgView.addSubview(ageLab)
        
        jobLab = UILabel.init(frame: CGRect(x: ageLab.right + 20, y: userNameLab.bottom + 10, width: 50, height: 11))
        jobLab.text = "设计师"
        jobLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        jobLab.font = UIFont.systemFont(ofSize: 11)
        jobLab.textAlignment = .left
        bgView.addSubview(jobLab)
        
        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect(x: bgView.width - 80, y: 34, width: 60, height: 20)
        editBtn.rounded(2, width: 1, color: MIRgbaColor(rgbValue: 0x48A1D8, alpha: 1))
        editBtn.setTitle("修改资料", for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        editBtn.setTitleColor(MIRgbaColor(rgbValue: 0x48A1D8, alpha: 1), for: .normal)
        editBtn.addTarget(self, action: #selector(clickEditBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(editBtn)
        
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
    }
    
    private func requestCommunityList(isRefresh: Bool) {
        
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

    @objc private func clickBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func clickEditBtn(_ sender: UIButton) {
        let editVC = MIEditPersonalInfoVC.init(nibName: "MIEditPersonalInfoVC", bundle: nil)
        self.navigationController?.pushViewController(editVC, animated: true)
    }

}

extension MIPersonalVC: UICollectionViewDelegate {
    
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
