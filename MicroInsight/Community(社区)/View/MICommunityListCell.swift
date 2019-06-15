//
//  MICommunityListCell.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

typealias communityBlock = (_ userId: Int)->Void

class MICommunityListCell: UITableViewCell {

    var clickUserIconBlock: communityBlock?
    var clickExtendBtnBlock: communityBlock?
    @IBOutlet weak var headIconBtn: UIButton!
    @IBOutlet weak var recommendBtn: UIButton!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var readingBtn: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var communityModel: MICommunityListModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configUI()
    }

    private func configUI() {
        self.selectionStyle = .none
        headIconBtn.round(20, rectCorners: .allCorners)
        tagTitle.rounded(5, width: 1, color: MIRgbaColor(rgbValue: 0x999999, alpha: 1))
        readingBtn.layoutButton(with: .left, imageTitleSpace: 5)
    }
    
    func setCell(model: MICommunityListModel) {
        communityModel = model
        nameLab.text = model.nickname
        let strs = model.createdAt.components(separatedBy: " ")
        timeLab.text = strs.first
        readingBtn.setTitle("\(model.readings)", for: .normal)
        commentBtn.setTitle("\(model.comments)", for: .normal)
        praiseBtn.setTitle("\(model.likes)", for: .normal)
        if (model.isLike) {
            praiseBtn.setImage(UIImage(named: "icon_community_praise_sel"), for: .normal)
        } else {
            praiseBtn.setImage(UIImage(named: "icon_community_praise_nor"), for: .normal)
        }
        
        contentLab.text = model.title
        if model.tags.count > 0 {
            tagTitle.isHidden = false
            let tagModel = model.tags.first
            tagTitle.text = tagModel?.title
            widthConstraint.constant = MIHelpTool.measureSingleLineStringWidth(with: tagModel?.title, font: UIFont.systemFont(ofSize: 8)) + 10
        } else {
            tagTitle.isHidden = true
        }
        
        let iconUrl = model.avatar + "?x-oss-process=image/resize,m_fill,h_40,w_40"
        headIconBtn.sd_setImage(with: NSURL(string: iconUrl) as URL?, for: .normal, placeholderImage: UIImage(named: "icon_personal_head_nor"), options: .retryFailed, completed: nil)
        
        var imgUrl: String!
        if model.contentType == 0 {
            imgUrl = model.url
        } else {
            imgUrl = model.coverUrl
        }

        imgUrl = imgUrl + "?x-oss-process=image/resize,m_fill,h_\(Int(imgView.width)),w_\(Int(imgView.height))"
        imgView.sd_setImage(with: NSURL(string: imgUrl) as URL?, placeholderImage: UIImage(named: ""), options: .retryFailed, completed: nil)
    }
    
    @IBAction func clickUserIconBtn(_ sender: UIButton) {
        if clickUserIconBlock != nil {
            clickUserIconBlock!(communityModel.userId)
        }
    }
    
    @IBAction func clickExtendBtn(_ sender: UIButton) {
        if clickExtendBtnBlock != nil {
            clickExtendBtnBlock!(communityModel.userId)
        }
    }
}
