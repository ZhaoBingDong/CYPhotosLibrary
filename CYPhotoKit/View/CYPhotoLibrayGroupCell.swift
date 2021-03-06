//
//  CYPhotoLibrayGroupCell.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

class CYPhotoLibrayGroupCell: UITableViewCell {

    lazy var  photoImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 10.0, y: 10.0, width: 60.0, height: 60.0))
        imageView.clipsToBounds            = true
        imageView.contentMode              = UIViewContentMode.scaleAspectFill
        return imageView
    }()
    lazy var titleLabel : UILabel = {
        let label = UILabel(frame: CGRect(x: 80, y: 29.0, width: 200.0, height: 21.5))
        return label
    }()
    lazy var badgeValue : UIView = {
        let view                    = UIView(frame: CGRect(x: 42, y: 3, width: 15, height: 15))
        view.backgroundColor        = BaseTintColor
        view.layer.borderColor      = UIColor.white.cgColor
        view.layer.borderWidth      = 2.0
        view.layer.cornerRadius     = 7.5
        view.isHidden               = true
        view.layer.masksToBounds    = true
        return view
    }()

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        photoImageView.addSubview(badgeValue)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
