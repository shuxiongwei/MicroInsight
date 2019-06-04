//
//  MICommunityListCell.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/25.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MICommunityListCell: UITableViewCell {

    @IBOutlet weak var headIconBtn: UIButton!
    @IBOutlet weak var recommendBtn: UIButton!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configUI()
    }

    private func configUI() {
        self.selectionStyle = .none
        headIconBtn.round(20, rectCorners: .allCorners)
        tagTitle.rounded(5, width: 1, color: MIRgbaColor(rgbValue: 0x999999, alpha: 1))
    }
    
    func setCell(model: MICommunityListModel) {

        nameLab.text = model.nickname
        timeLab.text = model.createdAt
        commentBtn.setTitle("124", for: .normal)
        praiseBtn.setTitle("135", for: .normal)
        contentLab.text = model.avatar
        let tagModel = model.tags.first
        tagTitle.text = tagModel?.title
        widthConstraint.constant = MIHelpTool.measureSingleLineStringWidth(with: tagModel?.title, font: UIFont.systemFont(ofSize: 8)) + 10
        
        let iconUrl = model.avatar + "?x-oss-process=image/resize,m_fill,h_40,w_40"
        headIconBtn.sd_setImage(with: NSURL(string: iconUrl) as URL?, for: .normal, placeholderImage: UIImage(named: "icon_personal_head_nor"), options: .retryFailed, completed: nil)
        
        var imgUrl: String!
        if model.contentType == "0" {
            imgUrl = model.url
        } else {
            imgUrl = model.coverUrl
        }

        imgUrl = imgUrl + "?x-oss-process=image/resize,m_fill,h_\(Int(imgView.width)),w_\(Int(imgView.height))"
        imgView.sd_setImage(with: NSURL(string: imgUrl) as URL?, placeholderImage: UIImage(named: ""), options: .retryFailed, completed: nil)
    }
}
