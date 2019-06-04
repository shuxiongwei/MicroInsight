//
//  MIUserHandleCell.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/17.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MIUserHandleCell: UITableViewCell {

    var titleLab: UILabel?
    var imageView1: UIImageView?
    var imageView2: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCellUI()
    }
    
    private func configCellUI() {
        selectionStyle = .none
        
        titleLab = UILabel()
        titleLab?.textAlignment = .left
        titleLab?.textColor = MIRgbaColor(rgbValue: 0x666666, alpha: 1)
        titleLab?.font = UIFont.systemFont(ofSize: 14)
        titleLab?.numberOfLines = 0
        self.addSubview(titleLab!)
        titleLab?.mas_makeConstraints({ (make) in
            make?.left.offset()(10)
            make?.right.offset()(-10)
        })
        
        imageView1 = UIImageView()
        self.addSubview(imageView1!)
        imageView1?.mas_makeConstraints({ (make) in
            make?.left.offset()(10)
            make?.right.offset()(-10)
        })
        
        imageView2 = UIImageView()
        self.addSubview(imageView2!)
        imageView2?.mas_makeConstraints({ (make) in
            make?.left.offset()(10)
            make?.right.offset()(-10)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setUserHandleCell(model: MIHandleModel) {
        titleLab?.text = model.modelTitle
        titleLab?.mas_updateConstraints({ (make) in
            make?.top.offset()(10)
            make?.height.equalTo()(model.titleHeight)
        })
        
        imageView1?.image = UIImage(named: model.imageName1!)
        imageView1?.mas_updateConstraints({ (make) in
            make?.top.offset()(CGFloat(model.titleHeight! + 20))
            make?.height.equalTo()(model.image1Height)
        })
        
        if model.imageName2 != nil {
            imageView2?.isHidden = false
            imageView2?.image = UIImage(named: model.imageName2!)
            imageView2?.mas_updateConstraints({ (make) in
                make?.top.offset()(CGFloat(model.titleHeight! + model.image2Height! + 30))
                make?.height.equalTo()(model.image2Height)
            })
        } else {
            imageView2?.isHidden = true
        }
    }
}
