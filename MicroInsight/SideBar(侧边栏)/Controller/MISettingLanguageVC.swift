//
//  MISettingLanguageVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/15.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MISettingLanguageVC: MIBaseViewController {

    var languageList: Array<String>!
    
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
        
        configSettingLanguageUI()
    }

    private func configSettingLanguageUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("sideBar_key_3")
        self.view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        
        languageList = ["简体中文", "English", "日本语"]
        self.tableView.reloadData()
    }
}

extension MISettingLanguageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MISettingCell
        if cell.rightBtn.isHidden {
            
            let languageDic = MILocalData.getLanguageMapping() as Dictionary
            let key = cell.nameLab.text!
            let msg = MILocalData.appLanguage("other_key_48") + key
            
            MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: MILocalData.appLanguage("personal_key_11"), alertMessage: msg, leftAction: {
                
            }) {
                let languageType = languageDic[key] as! String
                MILocalData.setAppLanguage(languageType)
                self.title = MILocalData.appLanguage("sideBar_key_3")
                self.tableView.reloadData()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"languageSetNotification"), object: nil)
            }
        }
    }
}

extension MISettingLanguageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MISettingCell", for: indexPath) as! MISettingCell
        cell.nameLab.text = languageList[indexPath.row]
        
        if cell.nameLab.text == MILocalData.getCurrentAppLangugeName() {
            cell.rightBtn.isHidden = false
            cell.rightBtn.setImage(UIImage(named: "icon_sideBar_select_nor"), for: .normal)
        } else {
            cell.rightBtn.isHidden = true
        }
        
        return cell
    }
}
