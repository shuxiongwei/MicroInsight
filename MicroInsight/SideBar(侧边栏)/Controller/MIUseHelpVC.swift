//
//  MIUseHelpVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/16.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIUseHelpVC: MIBaseViewController {

    var helpList: Array<String>!
    
    private lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect(x: 0, y: 10, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 10), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.register(UINib.init(nibName: "MISettingCell", bundle: nil), forCellReuseIdentifier: "MISettingCell")
        self.view.addSubview(table)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUseHelpUI()
    }

    private func configUseHelpUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("sideBar_key_5")
        self.view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        
        helpList = [MILocalData.appLanguage("help_key_1"),
                    MILocalData.appLanguage("help_key_2"),
                    MILocalData.appLanguage("help_key_3"),
                    MILocalData.appLanguage("help_key_18")]
        self.tableView.reloadData()
    }
}

extension MIUseHelpVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let handleVC = MIUseHandleVC.init()
            handleVC.handleType = .Tips
            self.navigationController?.pushViewController(handleVC, animated: true)
        } else if indexPath.row == 1 {
            let handleVC = MIUseHandleVC.init()
            handleVC.handleType = .Glue
            self.navigationController?.pushViewController(handleVC, animated: true)
        } else if indexPath.row == 2 {
            let handleVC = MIUseHandleVC.init()
            handleVC.handleType = .Measure
            self.navigationController?.pushViewController(handleVC, animated: true)
        } else {
            let videoVC = MIVideoUploadVC.init()
            videoVC.networkVideoUrl = MILocalData.getVideoTutorialUrl()
            videoVC.notUpload = "1"
            self.navigationController?.pushViewController(videoVC, animated: true)
        }
    }
}

extension MIUseHelpVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MISettingCell", for: indexPath) as! MISettingCell
        cell.nameLab.text = helpList[indexPath.row]
        cell.rightBtn.isHidden = false
        cell.rightBtn.setImage(UIImage(named: "icon_sideBar_right_nor"), for: .normal)
        
        return cell
    }
}
