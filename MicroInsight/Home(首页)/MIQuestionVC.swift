//
//  MIQuestionVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

@objcMembers
class MIQuestionVC: MIBaseViewController {

    var textView: MIPlaceholderTextView!
    var partInfo: String!
    var image: UIImage!
    var tempPath: String!
    
    deinit {
        let manager = FileManager.default
        try! manager.removeItem(atPath: tempPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configUI()
    }
    
    private func configUI() {
        super.configLeftBarButtonItem(nil)
        self.view.backgroundColor = UIColor.white
        
        let lineV = UIView.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        lineV.backgroundColor = MIRgbaColor(rgbValue: 0xDDDDDD, alpha: 1)
        view.addSubview(lineV)
        
        let imgBtn = UIButton(type: .custom)
        imgBtn.frame = CGRect(x: 15, y: lineV.bottom + 15, width: ScreenWidth - 30, height: (ScreenWidth - 30) * 210.0 / 345.0)
        imgBtn.imageView?.contentMode = .scaleAspectFill
        imgBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imgBtn.contentHorizontalAlignment = .fill
        imgBtn.contentVerticalAlignment = .fill
        imgBtn.setImage(image, for: .normal)
        imgBtn.addTarget(self, action: #selector(clickImageBtn(_ :)), for: .touchUpInside)
        view.addSubview(imgBtn)
        
        textView = MIPlaceholderTextView.init(frame: CGRect(x: 15, y: imgBtn.bottom + 20, width: ScreenWidth - 30, height: 40))
        textView.placeholder = MILocalData.appLanguage("skin_key_17")
        textView.placeholderColor = MIRgbaColor(rgbValue: 0x999999, alpha: 1)
        textView.placeholderFont = UIFont.systemFont(ofSize: 10)
        textView.rounded(1, width: 1, color: MIRgbaColor(rgbValue: 0xDDDDDD, alpha: 1))
        view.addSubview(textView)
        
        let uploadBtn = UIButton(type: .custom)
        uploadBtn.frame = CGRect(x: 40, y: self.view.height - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 85, width: ScreenWidth - 80, height: 40)
        uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        uploadBtn.setTitle(MILocalData.appLanguage("skin_key_18"), for: .normal)
        uploadBtn.setTitleColor(UIColor.white, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
        view.addSubview(uploadBtn)
        
        let assetPath = MIHelpTool.createAssetsPath()
        let name = MIHelpTool.converDate(Date(), toStringByFormat: "yyyy-MM-dd+HH:mm:ss") + ".png"
        tempPath = assetPath! + name
        let imgData = image.jpegData(compressionQuality: 0.5)
        MIHelpTool.save(imgData, toPath: tempPath)
    }

    @objc private func clickUploadBtn(_ sender: UIButton) {
        MBProgressHUD.showStatus(MILocalData.appLanguage("other_key_28") + "...")
        
        let fileName = MIHelpTool.timeStampSecond() + ".jpg"
        MIRequestManager.sendSkinImage(withTitle: textView.text, type: partInfo, fileName: fileName, image: image, requestToken: MILocalData.getCurrentRequestToken()) { (jsonData, error) in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide()
            }
            
            let dic: [String : AnyObject] = jsonData as! Dictionary
            let code = dic["code"]?.int64Value
            if code == 0 {
                MIHudView.showMsg(MILocalData.appLanguage("other_key_29"))
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @objc private func clickImageBtn(_ sender: UIButton) {
        let vc = MIReviewImageViewController.init()
        vc.imgPath = tempPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
}
