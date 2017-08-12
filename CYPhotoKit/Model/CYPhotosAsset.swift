//
//  CYPhotosAsset.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos

public class CYPhotosAsset: NSObject {

    public var asset : PHAsset = PHAsset()
    public var thumbnail : UIImage = UIImage()
    public var originalImg : UIImage = UIImage()
    public var imageURL : URL?
    public var originalImgLength : Double = 0.0
    public var imageData : Data? {
        get {
            if CYPhotosManager.defaultManager.isFullMode {
                return UIImageJPEGRepresentation(self.originalImg,1.0)
            } else {
                return UIImageJPEGRepresentation(self.thumbnail,1.0)
            }
        }
    }
    public var isSelectedImage : Bool = false
    public var localIdentifier : String? {
        get {
            return self.asset.localIdentifier
        }
    }
    public  convenience init(photoAsset : PHAsset) {
        self.init()
        self.asset              = photoAsset

        let imageManager        = PHImageManager.default()
        let option              = PHImageRequestOptions()
        option.isSynchronous    = true
        option.resizeMode       = .fast
        option.deliveryMode     = .highQualityFormat
        imageManager.requestImage(for: self.asset, targetSize: CGSize.init(width: 250.0, height: 250.0), contentMode: .aspectFill, options: option) {[weak self] (image, info) in
            self?.thumbnail = image ?? UIImage()
        }
        imageManager.requestImageData(for: self.asset, options: option) {[weak self] (imageData, dataUTI, orientation, info) in
            self?.imageURL = info?["PHImageFileURLKey"] as? URL
            if let data = imageData {

                self?.originalImg = UIImage(data: data)!
                guard let obj = (info?["PHImageFileDataKey"] as? NSObject) else {
                    self?.originalImgLength = Double(data.count)
                    return
                }
                guard !obj.isKind(of: NSData.self) else {
                    self?.originalImgLength = Double((obj as! NSData).length)
                    return
                }
                guard  let dataLength  = obj.value(forKey: "dataLength") as? Double else {
                    self?.originalImgLength = Double(data.count)
                    return
                }
                self?.originalImgLength = dataLength
            }

        }
    }
}


