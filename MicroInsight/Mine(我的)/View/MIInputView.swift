//
//  MIInputView.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/22.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

typealias confirmBlock = (_ text: String)->Void

class MIInputView: UIView {

    var confirmBlock: confirmBlock?
    var textField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, nickName: String) {
        super.init(frame: frame)
        
        configInputUI(nickName: nickName)
    }
    
    private func configInputUI(nickName: String) {
        self.backgroundColor = MIRgbaColor(rgbValue: 0x666666, alpha: 0.8)
        
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 80, height: (ScreenWidth - 80) * 240.0 / 295.0))
        bgView.center = CGPoint(x: ScreenWidth / 2.0, y: ScreenHeight / 2.0)
        bgView.backgroundColor = UIColor.white
        bgView.round(3, rectCorners: .allCorners)
        addSubview(bgView)
        
        let titleLab = UILabel.init(frame: CGRect(x: 0, y: 50, width: bgView.width, height: 17))
        titleLab.text = MILocalData.appLanguage("personal_key_14")
        titleLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 16)
        bgView.addSubview(titleLab)
        
        textField = UITextField.init(frame: CGRect(x: 34, y: titleLab.bottom + 50, width: bgView.width - 68, height: 30))
        textField.placeholder = nickName
        textField.borderStyle = .none
        bgView.addSubview(textField)
        
        let lineView = UIView.init(frame: CGRect(x: 34, y: textField.bottom, width: bgView.width - 68, height: 1))
        lineView.backgroundColor = MIRgbaColor(rgbValue: 0xDADADA, alpha: 1)
        bgView.addSubview(lineView)
        
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect(x: 0, y: bgView.height - 50, width: bgView.width / 2.0, height: 50)
        leftBtn.backgroundColor = MIRgbaColor(rgbValue: 0xF9F9F9, alpha: 1)
        leftBtn.setTitle(MILocalData.appLanguage("personal_key_13"), for: .normal)
        leftBtn.setTitleColor(MIRgbaColor(rgbValue: 0xBEBEBE, alpha: 1), for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        leftBtn.addTarget(self, action: #selector(clickLeftBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(leftBtn)
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect(x: bgView.width / 2.0, y: bgView.height - 50, width: bgView.width / 2.0, height: 50)
        rightBtn.setButtonCustomBackgroudImage(btn: rightBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        rightBtn.setTitle(MILocalData.appLanguage("camera_key_5"), for: .normal)
        rightBtn.setTitleColor(UIColor.white, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightBtn.addTarget(self, action: #selector(clickRightBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(rightBtn)
    }
    
    @objc private func clickLeftBtn(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @objc private func clickRightBtn(_ sender: UIButton) {
        removeFromSuperview()
        
        if MIHelpTool.isBlankString(textField.text) {
            MIHudView.showMsg(MILocalData.appLanguage("personal_key_14"))
            return
        }
        
        if confirmBlock != nil {
            confirmBlock!(textField!.text!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
}
