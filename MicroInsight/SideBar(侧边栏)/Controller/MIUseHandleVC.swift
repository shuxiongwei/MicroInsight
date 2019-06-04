//
//  MIUseHandleVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/16.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIUseHandleVC: MIBaseViewController {

    public var handleType: MIHandleType?
    var handleList: Array<MIHandleModel>!
    
    private lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect(x: 10, y: 10, width: self.view.bounds.size.width - 20, height: self.view.bounds.size.height - 10 - MINavigationBarHeight(vc: self) - MITabBarHeight), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.backgroundColor = UIColor.white
        table.separatorStyle = .none
        table.register(MIUserHandleCell.self, forCellReuseIdentifier: "MIUserHandleCell")
        self.view.addSubview(table)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUserHandleUI()
        
        if handleType == .Measure {
            configMeasureDistanceUI()
        } else {
            configUserHandleData()
        }
    }
    
    private func configUserHandleUI() {
        super.configLeftBarButtonItem(nil)
        self.view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        
        var key: String!
        if handleType == .Tips {
            key = "help_key_1"
        } else if handleType == .Glue {
            key = "help_key_2"
        } else if handleType == .Measure {
            key = "help_key_3"
        }
        self.title = MILocalData.appLanguage(key)
    }
    
    private func configUserHandleData() {
        handleList = Array.init()
        var titleList: [String]!
        let width = Float(ScreenWidth - 70)
        
        if handleType == .Tips {
            titleList = ["1.从卡扣两侧将收纳盒打开，取出TipScope。",
                         "2.将TipScope背面朝上平放于桌面，打开手机 APP的闪光灯。",
                         "3.去掉手机壳，将手机摄像头对准TipScope镜 头，手机闪光灯对准TipScope镜体。",
                         "4.将手机靠近TipScope，保持光圈一直位于屏 幕中央，按压使TipScope和手机贴紧。",
                         "5. 将TipScope贴近拍待摄物体。"]
            
            for index in 0..<titleList.count {
                let model = MIHandleModel()
                model.modelTitle = titleList[index]
                model.imageName1 = "img_help_tips_\(index)"
                
                let titleWidth = MIHelpTool.measureSingleLineStringWidth(with: titleList[index], font: UIFont.systemFont(ofSize: 14))
                let titleLine = ceil(Float(titleWidth) / width)
                let titleHeight = titleLine * 14.0 + titleLine * 5.0
                model.titleHeight = titleHeight;
                
                let image1 = UIImage(named: model.imageName1!)
                var imageHeight = width * Float((image1?.size.height)!) / Float((image1?.size.width)!)
                model.image1Height = imageHeight;
                
                var margin: Float = 30.0
                if index == 3 {
                    model.imageName2 = "img_help_tips_33"
                    let image2 = UIImage(named: model.imageName2!)
                    model.image2Height = width * Float((image2?.size.height)!) / Float((image2?.size.width)!)
                    imageHeight += model.image2Height!
                    margin = 40.0
                }
                
                let footerStr = "(注：不限机型，适用于绝大部分手机)"
                let footerHeight = MIHelpTool.measureMutilineStringHeight(with: footerStr, font: UIFont.systemFont(ofSize: 11), width: CGFloat(width)) + 10
                let lab = UILabel.init(frame: CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: footerHeight))
                lab.text = footerStr
                lab.font = UIFont.systemFont(ofSize: 11)
                lab.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
                lab.numberOfLines = 0
                tableView.tableFooterView = lab
                
                model.rowHeight = titleHeight + imageHeight + margin
                handleList.append(model)
            }
        } else if handleType == .Glue {
            titleList = ["1.撕掉原来的背胶，并从收纳盒中拿出备用胶。",
                         "2.从备用胶上取下一片，去掉中间的同心圆后， 再撕掉一面离型纸，注意不要用手直接触碰胶 面。",
                         "3.将撕掉离型纸的那面胶对准TipScope的背胶 凹槽处粘上,并将TipScope朝下用力按压。",
                         "4.最后撕下外面那层离型纸。"]
            
            for index in 0..<titleList.count {
                let model = MIHandleModel()
                model.modelTitle = titleList[index]
                model.imageName1 = "img_help_glue_\(index)"
                
                let titleWidth = MIHelpTool.measureSingleLineStringWidth(with: titleList[index], font: UIFont.systemFont(ofSize: 14))
                let titleLine = ceil(Float(titleWidth) / width)
                let titleHeight = titleLine * 14.0 + titleLine * 5.0
                model.titleHeight = titleHeight;
                
                let image1 = UIImage(named: model.imageName1!)
                var imageHeight = width * Float((image1?.size.height)!) / Float((image1?.size.width)!)
                model.image1Height = imageHeight;
                
                var margin: Float = 30.0
                if index == 2 {
                    model.imageName2 = "img_help_glue_22"
                    let image2 = UIImage(named: model.imageName2!)
                    model.image2Height = width * Float((image2?.size.height)!) / Float((image2?.size.width)!)
                    imageHeight += model.image2Height!
                    margin = 40.0
                }
                
                model.rowHeight = titleHeight + imageHeight + margin
                handleList.append(model)
            }
        }
        
        tableView.reloadData()
    }
    
    private func configMeasureDistanceUI() {
        let width = ScreenWidth - 70
        
        let str1 = "1.请对准一毫米标尺"
        let height1 = MIHelpTool.measureMutilineStringHeight(with: str1, font: UIFont.systemFont(ofSize: 11), width: width) + 10
        
        let str2 = "2.点击标尺两侧"
        let height2 = MIHelpTool.measureMutilineStringHeight(with: str2, font: UIFont.systemFont(ofSize: 11), width: width) + 10
        
        let str3 = "3.确定标点准确以减少误差"
        let height3 = MIHelpTool.measureMutilineStringHeight(with: str3, font: UIFont.systemFont(ofSize: 11), width: width) + 10
        
        let bgView = UIView.init(frame: CGRect(x: 15, y: 15, width: ScreenWidth - 30, height: height1 + height2 + height3 + 100))
        bgView.round(2, rectCorners: .allCorners)
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        
        let lab = UILabel.init(frame: CGRect(x: 20, y: 20, width: ScreenWidth - 40, height: 20))
        lab.text = MILocalData.appLanguage("help_key_3")
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.textColor = MIRgbaColor(rgbValue: 0x2D2D2D, alpha: 1)
        lab.numberOfLines = 0
        bgView.addSubview(lab)
        
        let lab1 = UILabel.init(frame: CGRect(x: 20, y: lab.frame.maxY + 20, width: ScreenWidth - 40, height: height1))
        lab1.text = str1
        lab1.font = UIFont.systemFont(ofSize: 14)
        lab1.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        lab1.numberOfLines = 0
        bgView.addSubview(lab1)
        
        let lab2 = UILabel.init(frame: CGRect(x: 20, y: lab1.frame.maxY, width: ScreenWidth - 40, height: height2))
        lab2.text = str2
        lab2.font = UIFont.systemFont(ofSize: 14)
        lab2.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        lab2.numberOfLines = 0
        bgView.addSubview(lab2)
        
        let lab3 = UILabel.init(frame: CGRect(x: 20, y: lab2.frame.maxY, width: ScreenWidth - 40, height: height3))
        lab3.text = str3
        lab3.font = UIFont.systemFont(ofSize: 14)
        lab3.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        lab3.numberOfLines = 0
        bgView.addSubview(lab3)
    }
}

extension MIUseHandleVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = handleList[indexPath.row]
        return CGFloat(model.rowHeight!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MIUseHandleVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MIUserHandleCell", for: indexPath) as! MIUserHandleCell
        let model = handleList[indexPath.row]
        cell.setUserHandleCell(model: model)

        return cell
    }
}
