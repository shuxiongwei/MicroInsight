//
//  MIEditOrUploadVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/21.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit


@objcMembers
class MIEditOrUploadVC: MIBaseViewController {

    var imgView: UIImageView!
    var imgUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }
    
    private func configUI() {
        super.configLeftBarButtonItem(nil)
        self.view.backgroundColor = UIColor.white
        
        let rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        view.backgroundColor = UIColor.clear
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: 5.5, y: 3, width: 49, height: 24)
        rightBtn.setTitle("上传", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rightBtn.setTitleColor(MIRgbaColor(rgbValue: 0xF9F9F9, alpha: 1), for: .normal)
        rightBtn.backgroundColor = MIRgbaColor(rgbValue: 0x4A9DD5, alpha: 1)
        rightBtn.round(3, rectCorners: .allCorners)
        rightBtn.addTarget(self, action: #selector(clickUploadBtn), for: .touchUpInside)
        rightView.addSubview(rightBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightView)
        
        imgView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 60))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(contentsOfFile: imgUrl)
        view.addSubview(imgView)
        
        let bottomView = UIView.init(frame: CGRect(x: 0, y: imgView.bottom, width: ScreenWidth, height: 60))
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView)
        
        let deleteBtn: UIButton = MIUIFactory.createButton(with: .custom, frame: CGRect(x: 15, y: 0, width: 109, height: 60), normalTitle: "删除", normalTitleColor: MIRgbaColor(rgbValue: 0x333333, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 9, normalImage: UIImage(named: "icon_album_delete_nor"), highlightedImage: nil, selectedImage: nil, touchUpInSideTarget: self, action: #selector(clickDeleteBtn(_ :)))
        deleteBtn.layoutButton(with: .top, imageTitleSpace: 5)
        bottomView.addSubview(deleteBtn)

        let editBtn: UIButton = MIUIFactory.createButton(with: .custom, frame: CGRect(x: ScreenWidth - 109 - 15, y: 0, width: 109, height: 60), normalTitle: "编辑", normalTitleColor: MIRgbaColor(rgbValue: 0x333333, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 9, normalImage: UIImage(named: "icon_album_edit_nor"), highlightedImage: nil, selectedImage: nil, touchUpInSideTarget: self, action: #selector(clickEditBtn(_ :)))
        editBtn.layoutButton(with: .top, imageTitleSpace: 5)
        bottomView.addSubview(editBtn)
    }
    
    @objc private func clickDeleteBtn(_ sender: UIButton) {
        MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "确定删除该图片吗？", leftAction: { () in
            
        }) { () in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func clickEditBtn(_ sender: UIButton) {
        let editVC = MIImageEditVC.init()
        editVC.image = imgView.image!
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func clickUploadBtn() {
        let storyBoard = UIStoryboard.init(name: "MyAlbum", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MIUploadViewController") as! MIUploadViewController
        vc.assetUrl = imgUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
