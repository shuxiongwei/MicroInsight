//
//  MICommunityVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MICommunityVC: MIBaseViewController {

    var searchBar: UISearchBar!
    var searchTF: UITextField!
    var curPage: NSInteger!
    var curSearchPage: NSInteger!
    
    private lazy var emptyView: UIView = {
        let v = UIView.init(frame: CGRect(x: 0, y: 60, width: self.view.width, height: ScreenHeight - MINavigationBarHeight(vc: self) - 20 - 60))
        v.backgroundColor = UIColor.white
        v.isHidden = true
        self.view.addSubview(v)
        
        let imgV = UIImageView.init(frame: CGRect(x: (v.width - 112) / 2.0, y: (v.height - 90) / 2.0 - 10, width: 112, height: 90))
        imgV.image = UIImage(named: "empty")
        v.addSubview(imgV)
        
        let lab = UILabel.init(frame: CGRect(x: 0, y: imgV.bottom + 5, width: v.width, height: 15))
        lab.text = "什么都没有哦"
        lab.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 13)
        v.addSubview(lab)
        
        return v
    }()
    
    private lazy var dataList: Array<MICommunityListModel> = {
        let list = [MICommunityListModel]()
        return list
    }()
    
    private lazy var searchDataList: Array<MICommunityListModel> = {
        let list = [MICommunityListModel]()
        return list
    }()
    
    private lazy var table: UITableView = {
        let table = UITableView.init(frame: CGRect(x: 0, y: 60, width: ScreenWidth, height: ScreenHeight - MINavigationBarHeight(vc: self) - 20 - 60), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.tag = 1000
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.register(UINib(nibName: "MICommunityListCell", bundle: nil), forCellReuseIdentifier: "MICommunityListCell")
        
        weak var weakSelf = self
        table.mj_header = MJRefreshGifHeader.init(refreshingBlock: {
            weakSelf?.curPage = 1;
            weakSelf?.requestCommunityList(isRefresh: true)
        })
        
        table.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            weakSelf?.curPage += 1
            weakSelf?.requestCommunityList(isRefresh: false)
        })
        
        self.view.addSubview(table)
        
        return table
    }()
    
    private lazy var searchT: UITableView = {
        let tab = UITableView.init(frame: CGRect(x: 0, y: 60, width: ScreenWidth, height: ScreenHeight - MINavigationBarHeight(vc: self) - 20 - 60), style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.tag = 2000
        tab.backgroundColor = UIColor.clear
        tab.separatorStyle = .none
        tab.isHidden = true
        tab.register(UINib(nibName: "MICommunityListCell", bundle: nil), forCellReuseIdentifier: "MICommunityListCell")

        weak var weakSelf = self
        tab.mj_header = MJRefreshGifHeader.init(refreshingBlock: {
            weakSelf?.curSearchPage = 1
            weakSelf?.requestCommunityList(isRefresh: true)
        })

        tab.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            weakSelf?.curSearchPage += 1
            weakSelf?.requestCommunityList(isRefresh: false)
        })

        self.view.addSubview(tab)

        return tab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configCommunityUI()
        requestCommunityList(isRefresh: true)
    }
    
    private func configCommunityUI() {
        super.configLeftBarButtonItem(nil)
        self.title = "社区"
        self.view.backgroundColor = UIColor.white
        curPage = 1
        curSearchPage = 1

        let cameraBtn = UIButton(type: .custom)
        cameraBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cameraBtn.setImage(UIImage(named: "icon_community_camera_nor"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(clickCameraBtn), for: .touchUpInside)
        let cameraItem = UIBarButtonItem.init(customView: cameraBtn)
        
        let messageBtn = UIButton(type: .custom)
        messageBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        messageBtn.setImage(UIImage(named: "icon_community_message_nor"), for: .normal)
        messageBtn.addTarget(self, action: #selector(clickMessageBtn), for: .touchUpInside)
        let messageItem = UIBarButtonItem.init(customView: messageBtn)
        self.navigationItem.rightBarButtonItems = [messageItem, cameraItem]
        
        let lineV = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        lineV.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        view.addSubview(lineV)
        
        searchTF = UITextField.init(frame: CGRect(x: 15, y: 11, width: ScreenWidth - 30, height: 30))
        searchTF.font = UIFont.systemFont(ofSize: 10)
        searchTF.textColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        searchTF.placeholder = "    点击搜索你感兴趣的"
        searchTF.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        searchTF.returnKeyType = .search
        searchTF.delegate = self
        view.addSubview(searchTF)

        searchTF.clearButtonMode = .whileEditing
        
//        let searchImage = UIImage(named: "icon_community_search_nor")
//        let imgView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        imgView.contentMode = .left
//        imgView.image = searchImage
//        searchTF.rightView = imgView
//        searchTF.rightViewMode = .always
    }

    private func requestCommunityList(isRefresh: Bool) {
    
        var page = 0
        if searchTF.text?.count == 0 {
            page = curPage
        } else {
            page = curSearchPage
        }
        
        weak var weakSelf = self
        MIRequestManager.getCommunityDataList(withSearchTitle: searchTF.text ?? "", requestToken: MILocalData.getCurrentRequestToken(), page: page, pageSize: 10, isMine: false) { (jsonData, error) in
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                
                if isRefresh {
                    if weakSelf?.searchTF.text?.count == 0 {
                        weakSelf?.dataList.removeAll()
                        weakSelf?.table.mj_header.endRefreshing()
                    } else {
                        weakSelf?.searchDataList.removeAll()
                        weakSelf?.searchT.mj_header.endRefreshing()
                    }
                }
                
                let data: [String: AnyObject] = dic["data"] as! Dictionary
                let list: Array = data["list"] as! Array<[String: AnyObject]>
                
                for modelDic: [String: AnyObject] in list {
                    let model = MICommunityListModel.yy_model(with: modelDic)
                    
                    let imgHeight = ScreenWidth * 190.0 / 345.0
                    model?.rowHeight = 139 + imgHeight + 15 + 15

                    if weakSelf?.searchTF.text?.count == 0 {
                        weakSelf?.dataList.append(model!)
                    } else {
                        weakSelf?.searchDataList.append(model!)
                    }
                }
                
                if list.count > 0 {
                    weakSelf?.emptyView.isHidden = true
                }
                
                if list.count < 10 {
                    if weakSelf?.searchTF.text?.count == 0 {
                        //没有数据
                        if list.count == 0 && weakSelf?.curPage == 1 {
                            weakSelf?.emptyView.isHidden = false
                            weakSelf?.view.bringSubviewToFront(weakSelf!.emptyView)
                        } else {
                            weakSelf?.searchT.isHidden = true
                            weakSelf?.table.isHidden = false
                            weakSelf?.table.mj_footer.endRefreshingWithNoMoreData()
                        }
                    } else {
                        //没有搜索数据
                        if list.count == 0 && weakSelf?.curSearchPage == 1 {
                            weakSelf?.emptyView.isHidden = false
                            weakSelf?.view.bringSubviewToFront(weakSelf!.emptyView)
                        } else {
                            weakSelf?.searchT.isHidden = false
                            weakSelf?.table.isHidden = true
                            weakSelf?.searchT.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                } else {
                    if weakSelf?.searchTF.text?.count == 0 {
                        weakSelf?.searchT.isHidden = true
                        weakSelf?.table.isHidden = false
                        weakSelf?.table.mj_footer.endRefreshing()
                    } else {
                        weakSelf?.searchT.isHidden = false
                        weakSelf?.table.isHidden = true
                        weakSelf?.searchT.mj_footer.endRefreshing()
                    }
                }
                
                if weakSelf?.searchTF.text?.count == 0 {
                    weakSelf?.table.reloadData()
                } else {
                    weakSelf?.searchT.reloadData()
                }
            } else {
                if weakSelf?.searchTF.text?.count == 0 {
                    weakSelf?.table.mj_footer.endRefreshing()
                } else {
                    weakSelf?.searchT.mj_footer.endRefreshing()
                }
                
                let msg = dic["message"] as! String
                MIHudView.showMsg(msg)
            }
        }
    }
    
    @objc func clickCameraBtn() {
        
    }
    
    @objc func clickMessageBtn() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MICommunityVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model: MICommunityListModel!
        if tableView.tag == 1000 {
            model = self.dataList[indexPath.row]
        } else {
            model = self.searchDataList[indexPath.row]
        }
        
        return model.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

extension MICommunityVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1000 {
            return self.dataList.count
        } else {
            return self.searchDataList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MICommunityListCell", for: indexPath) as! MICommunityListCell
        let model: MICommunityListModel!
        if tableView.tag == 1000 {
            model = self.dataList[indexPath.row]
        } else {
            model = self.searchDataList[indexPath.row]
        }
        cell.setCell(model: model)
        
        return cell
    }
}

extension MICommunityVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTF.resignFirstResponder()
    }
}

extension MICommunityVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTF.text?.count == 0 {
            MIHudView.showMsg("请输入搜索内容")
            return true
        }
        
        textField.resignFirstResponder()
        curSearchPage = 1
        requestCommunityList(isRefresh: true)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        textField.text = nil
        textField.resignFirstResponder()
        curSearchPage = 1
        searchT.isHidden = true
        emptyView.isHidden = true
        
        return false
    }
}

