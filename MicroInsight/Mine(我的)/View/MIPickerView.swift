//
//  MIPickerView.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIPickerView: UIView {

    private var pickerView: UIPickerView!
    private var dataList: Array<String>!
    private var curIndex: NSInteger!
    var confirmBlock: confirmBlock?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, bounds: CGRect, title: String, list: Array<String>, index: NSInteger) {
        super.init(frame: frame)
        
        curIndex = index
        dataList = list
        configUI(bounds: bounds, title: title)
    }
    
    private func configUI(bounds: CGRect, title: String) {
        self.backgroundColor = MIRgbaColor(rgbValue: 0x666666, alpha: 0.8)
        
        let bgView = UIView.init(frame: bounds)
        bgView.center = CGPoint(x: ScreenWidth / 2.0, y: ScreenHeight / 2.0)
        bgView.backgroundColor = UIColor.white
        bgView.round(3, rectCorners: .allCorners)
        addSubview(bgView)
        
        let titleLab = UILabel.init(frame: CGRect(x: 10, y: 35, width: bgView.width - 20, height: 17))
        titleLab.text = title
        titleLab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textAlignment = .center
        bgView.addSubview(titleLab)
        
        pickerView = UIPickerView.init(frame: CGRect(x: 10, y: 81, width: bgView.width - 20, height: bgView.height - 81 - 77))
        pickerView.delegate = self
        pickerView.dataSource = self
        bgView.addSubview(pickerView)
        
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
        
        pickerView.selectRow(curIndex, inComponent: 0, animated: true)
        pickerView.reloadAllComponents()
    }
    
    @objc private func clickLeftBtn(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @objc private func clickRightBtn(_ sender: UIButton) {
        removeFromSuperview()
        
        if confirmBlock != nil {
            confirmBlock!(dataList[curIndex])
        }
    }
}

extension MIPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        curIndex = row
        let lab = pickerView.view(forRow: row, forComponent: 0) as! UILabel
        lab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 18)
    }
}

extension MIPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        pickerView.clearSpearatorLine()
        
        let lab = UILabel.init()
        lab.text = dataList[row]
        lab.textColor = MIRgbaColor(rgbValue: 0xD2D2D2, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textAlignment = .center
        
        if (row == curIndex) {
            lab.textColor = MIRgbaColor(rgbValue: 0x333333, alpha: 1)
            lab.font = UIFont.systemFont(ofSize: 18)
        }

        return lab
    }
}
