//
//  CYPhotosCollectionViewCell.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos
class CYPhotosCollectionViewCell: UICollectionViewCell {

    public var imageView     = UIImageView()
    public var coverView     = UIView()
    public var selectButton  = UIButton(type: .custom)
    public var photosAsset : PHAsset? {
        didSet {
            if let asset = self.photosAsset {
                let option              = PHImageRequestOptions()
                option.deliveryMode     = .highQualityFormat
                option.isSynchronous    = false
                option.resizeMode       = .fast
                self.imageManager?.requestImage(for:asset, targetSize: CGSize(width:250.0, height:250.0), contentMode: .aspectFill, options: option) {[weak self] (result, _) in
                    self?.performSelector(onMainThread: #selector(self?.setImage(_:)) , with: result, waitUntilDone: true)
                }
            }
        }
    }
    @objc private func setImage(_ image : UIImage?) {
        self.coverView.isHidden = !isSelectItem
        self.imageView.image = image
    }
    public var imageManager : PHCachingImageManager?
    public var isSelectItem : Bool = false 
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode           = .scaleAspectFill
        imageView.clipsToBounds         = true
        contentView.backgroundColor     = .white
        contentView.addSubview(imageView)

        contentView.insertSubview(coverView, aboveSubview: imageView)
        coverView.isHidden              = true
        coverView.backgroundColor       = UIColor.white.withAlphaComponent(0.3)

        selectButton.setImage(CYResourceAssets.checkmarkImage, for: .normal)
        selectButton.isUserInteractionEnabled = false
        coverView.addSubview(selectButton)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame     = self.contentView.bounds
        coverView.frame     = self.contentView.bounds
        selectButton.frame  = CGRect.init(x: contentView.frame.size.width-30.0, y: contentView.frame.size.height-30.0, width: 25.0, height: 25.0)

    }

}
