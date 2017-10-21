//
//  CYResourceAssets.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// PKHUDAssets provides a set of default images, that can be supplied to the PKHUD's content views.
open class CYResourceAssets: NSObject {

    open class var addIcon: UIImage { return CYResourceAssets.bundledImage(named:"xiangqing_add2") }
    open class var checkmarkImage: UIImage { return CYResourceAssets.bundledImage(named: "AssetsPickerChecked") }
    open class var checkmarkNormal : UIImage { return CYResourceAssets.bundledImage(named: "imagepick_normal.png")
    }
    open class var fullImageNormal : UIImage { return CYResourceAssets.bundledImage(named: "photo_original_def") }

    open class var fullImageSelected: UIImage { return CYResourceAssets.bundledImage(named: "photo_original_sel") }

    open class var locked : UIImage { return CYResourceAssets.bundledImage(named: "lock") }
    open class var takePhotos : UIImage { return CYResourceAssets.bundledImage(named: "takePicture") }

    internal class func bundledImage(named name: String) -> UIImage {
        let imageName = imageNameInBundle(name: name)
        let bundle = bundleWithClass(cls: CYResourceAssets.self)
        let image = UIImage(named: imageName, in:bundle, compatibleWith:nil)
        if let image = image {
            return image
        } else {
            return UIImage()
        }
    }
}


public extension UIActivityIndicatorView {

    @discardableResult
    public class func show() -> UIActivityIndicatorView {

        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.frame  = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityView.hidesWhenStopped = true
        activityView.tag              = 1000
        activityView.center           = (CYAppKeyWindow?.center)!
        activityView.startAnimating()
        CYAppKeyWindow?.addSubview(activityView)

        return activityView
    }

    public class func hide() {

        if let activityView = CYAppKeyWindow?.viewWithTag(1000) as? UIActivityIndicatorView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }

    }


}
