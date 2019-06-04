//
//  MIGenderView.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/23.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIGenderView: UIView {

    var maleBtn: UIButton!
    var femaleBtn: UIButton!
    var confirmBlock: confirmBlock?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, genderText: String) {
        super.init(frame: frame)
        
        configGenderUI(genderText: genderText)
    }
    
    private func configGenderUI(genderText: String) {
        self.backgroundColor = MIRgbaColor(rgbValue: 0x666666, alpha: 0.8)
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 80, height: (ScreenWidth - 80) * 240.0 / 295.0))
        bgView.center = CGPoint(x: ScreenWidth / 2.0, y: ScreenHeight / 2.0)
        bgView.backgroundColor = UIColor.white
        bgView.round(3, rectCorners: .allCorners)
        addSubview(bgView)
        
        let titleLab = UILabel.init(frame: CGRect(x: 0, y: 50, width: bgView.width, height: 17))
        titleLab.text = "请选择你的性别"
        titleLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 16)
        bgView.addSubview(titleLab)
        
        maleBtn = MIUIFactory.createButton(with: .custom, frame: CGRect(x: 55, y: titleLab.bottom + 50, width: 50, height: 20), normalTitle: "男", normalTitleColor: MIRgbaColor(rgbValue: 0x333333, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 15, normalImage: UIImage(named: "icon_personal_gender_nor"), highlightedImage: nil, selectedImage: UIImage(named: "icon_personal_gender_sel"), touchUpInSideTarget: self, action: #selector(clickMaleBtn(_ :)))
        if genderText == maleBtn.titleLabel?.text || genderText == "请选择" {
            maleBtn.isSelected = true
        }
        maleBtn.layoutButton(with: .left, imageTitleSpace: 20)
        bgView.addSubview(maleBtn)
        
        femaleBtn = MIUIFactory.createButton(with: .custom, frame: CGRect(x: bgView.width - 105, y: titleLab.bottom + 50, width: 50, height: 20), normalTitle: "女", normalTitleColor: MIRgbaColor(rgbValue: 0x333333, alpha: 1), highlightedTitleColor: nil, selectedColor: nil, titleFont: 15, normalImage: UIImage(named: "icon_personal_gender_nor"), highlightedImage: nil, selectedImage: UIImage(named: "icon_personal_gender_sel"), touchUpInSideTarget: self, action: #selector(clickFemaleBtn(_ :)))
        femaleBtn.layoutButton(with: .left, imageTitleSpace: 20)
        if genderText == femaleBtn.titleLabel?.text {
            femaleBtn.isSelected = true
        }
        bgView.addSubview(femaleBtn)
        
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: bgView.height - 50, width: bgView.width / 2.0, height: 50)
        leftBtn.backgroundColor = MIRgbaColor(rgbValue: 0xF9F9F9, alpha: 1)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.setTitleColor(MIRgbaColor(rgbValue: 0xBEBEBE, alpha: 1), for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        leftBtn.addTarget(self, action: #selector(clickLeftBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(leftBtn)
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: bgView.width / 2.0, y: bgView.height - 50, width: bgView.width / 2.0, height: 50)
        rightBtn.setButtonCustomBackgroudImage(btn: rightBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        rightBtn.setTitle("确认", for: .normal)
        rightBtn.setTitleColor(UIColor.white, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightBtn.addTarget(self, action: #selector(clickRightBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(rightBtn)
    }
    
    @objc private func clickMaleBtn(_ sender: UIButton) {
        if !maleBtn.isSelected {
            maleBtn.isSelected = true
            femaleBtn.isSelected = false
        }
    }

    @objc private func clickFemaleBtn(_ sender: UIButton) {
        if !femaleBtn.isSelected {
            maleBtn.isSelected = false
            femaleBtn.isSelected = true
        }
    }
    
    @objc private func clickLeftBtn(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @objc private func clickRightBtn(_ sender: UIButton) {
        removeFromSuperview()

        var text = "";
        if (maleBtn.isSelected) {
            text = maleBtn.titleLabel!.text!
        } else {
            text = femaleBtn.titleLabel!.text!
        }
        
        if (confirmBlock != nil) {
            confirmBlock!(text)
        }
    }
}
