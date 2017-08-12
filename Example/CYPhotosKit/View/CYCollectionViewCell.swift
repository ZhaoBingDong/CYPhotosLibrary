//
//  CYCollectionViewCell.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/12.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

protocol CYCollectionViewCellDelegate : NSObjectProtocol {
    /**
     *  点击了删除按钮
     */
    func bkCollectionViewCellDidSelectDelegateButton(cell : CYCollectionViewCell)

}

class CYCollectionViewCell: UICollectionViewCell {

    var deleteButton : UIButton = UIButton(type: .custom)
    var imageView : UIImageView = UIImageView()
    weak var delegate : CYCollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleToFill
        contentView.addSubview(imageView)
        deleteButton.setImage(UIImage.init(named: ""), for: .normal)
        deleteButton.frame  = CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0)
        deleteButton.setBackgroundImage(UIImage(named:"hubs_deleteUploadImage"), for: .normal)
        deleteButton.addTarget(self, action:#selector(delegateButtonClick(_:)), for: .touchUpInside)

        contentView.insertSubview(deleteButton, aboveSubview: imageView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   @objc func delegateButtonClick(_ btn : UIButton) {
        delegate?.bkCollectionViewCellDidSelectDelegateButton(cell: self)
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.frame = self.contentView.bounds
        
    }
}
