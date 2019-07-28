//
//  MIActivityDetailVC.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIActivityDetailVC: MIBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configActivityDetailUI()
    }
    
    private func configActivityDetailUI() {
        super.configLeftBarButtonItem(nil)
        self.title = MILocalData.appLanguage("skin_key_20")
        self.view.backgroundColor = MIRgbaColor(rgbValue: 0xF2F3F5, alpha: 1)
        
        let bgView = UIView.init(frame: CGRect(x: 15, y: 15, width: ScreenWidth - 30, height: ScreenHeight - MINavigationBarHeight(vc: self) - MIStatusBarHeight() - 45))
        bgView.backgroundColor = UIColor.white
        bgView.round(2, rectCorners: .allCorners)
        view.addSubview(bgView)
        
//        let detailLab = UILabel.init(frame: CGRect(x: 19, y: 21, width: bgView.width - 38, height: 16))
//        detailLab.text = "活动详情"
//        detailLab.textColor = MIRgbaColor(rgbValue: 0x2D2D2D, alpha: 1)
//        detailLab.font = UIFont.boldSystemFont(ofSize: 15)
//        bgView.addSubview(detailLab)
        
        let textView = UITextView.init(frame: CGRect(x: 19, y: 21, width: bgView.width - 38, height: bgView.height - 54 - 140))
        textView.isEditable = false
        textView.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.text = MILocalData.appLanguage("skin_key_19")
        bgView.addSubview(textView)
        
        let uploadBtn = UIButton(type: .custom)
        uploadBtn.frame = CGRect(x: 80, y: bgView.height - 100, width: bgView.width - 160, height: 40)
        uploadBtn.setButtonCustomBackgroudImage(btn: uploadBtn, fromColor: MIRgbaColor(rgbValue: 0x72B3E2, alpha: 1), toColor: MIRgbaColor(rgbValue: 0x6DD1CC, alpha: 1))
        uploadBtn.setTitle(MILocalData.appLanguage("skin_key_18"), for: .normal)
        uploadBtn.setTitleColor(UIColor.white, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        uploadBtn.addTarget(self, action: #selector(clickUploadBtn(_ :)), for: .touchUpInside)
        bgView.addSubview(uploadBtn)
    }

    @objc private func clickUploadBtn(_ sender: UIButton) {
        let selectV = MISelectPhotoView.init(frame: ScreenBounds)
        let window = (UIApplication.shared.delegate!.window)!;
        window?.addSubview(selectV)
        
        weak var weakSelf = self
        selectV.selectBlcok = { (type: Int) in
            if type == 1 {
                let avStatus = AVCaptureDevice.authorizationStatus(for: .video)
                if avStatus == .denied {
                    MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "请在iPhone的\"设置-隐私-相机\"中允许访问相机", leftAction: {
                        
                    }, rightAction: {
                        UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                    })
                } else if avStatus == .notDetermined {
                    MIHudView.showMsg("此设备不支持拍照")
                }

                let vc = MIPhotographyViewController.init()
                vc.pushFrom = 1
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let albumVC = MILocalAlbumVC.init()
                albumVC.fromActivity = true
                weakSelf?.navigationController?.pushViewController(albumVC, animated: true)
            }
        }
        
//        let selectV = MISelectPhotoView.init(frame: ScreenBounds)
//        let window = (UIApplication.shared.delegate!.window)!;
//        window?.addSubview(selectV)
//
//        weak var weakSelf = self
//        selectV.selectBlcok = { (type: Int) in
//            if type == 1 {
//                let avStatus = AVCaptureDevice.authorizationStatus(for: .video)
//                if avStatus == .denied {
//                    MICustomAlertView.show(withFrame: ScreenBounds, alertTitle: "温馨提示", alertMessage: "请在iPhone的\"设置-隐私-相机\"中允许访问相机", leftAction: {
//
//                    }, rightAction: {
//                        UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
//                    })
//                } else if avStatus == .notDetermined {
//                    MIHudView.showMsg("此设备不支持拍照")
//                }
//
//                let pickerVC = UIImagePickerController.init()
//                pickerVC.allowsEditing = true
//                pickerVC.delegate = self
//                pickerVC.sourceType = .camera
//                weakSelf?.present(pickerVC, animated: true, completion: nil)
//            } else {
//                let pickerVC = UIImagePickerController.init()
//                pickerVC.allowsEditing = true
//                pickerVC.delegate = self
//                pickerVC.sourceType = .photoLibrary
//                weakSelf?.present(pickerVC, animated: true, completion: nil)
//            }
//        }
    }
}

//extension MIActivityDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        let image: UIImage!
//        if picker.allowsEditing {
//            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage;
//        } else {
//            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage;
//        }
//        picker.dismiss(animated: true, completion: nil)
//
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}

extension MIActivityDetailVC: MIPhotographyViewControllerDelegate {
    func photographyViewController(_ vc: MIPhotographyViewController!, shootPicture imgPath: String!) {
        
        let vc = MIEditOrUploadVC.init()
        vc.imgUrl = imgPath
        vc.fromActivity = "true"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func photographyViewController(_ vc: MIPhotographyViewController!, shootVideo videoPath: String!) {
    
    }
}
