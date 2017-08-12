//
//  CYPhotoPreviewCollectionViewCell.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/10.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

public class CYPhotoPreviewCollectionViewCell: UICollectionViewCell {
    public var imageView : UIImageView?
    public var asset : CYPhotosAsset? {
        didSet {
            imageView?.image = asset?.originalImg
        }
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        contentView.addSubview(imageView!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 10.0, y: 0.0, width: self.contentView.bounds.size.width-20.0, height: self.contentView.bounds.size.height)
    }
}
