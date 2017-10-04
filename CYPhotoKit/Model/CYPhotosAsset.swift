//
//  CYPhotosAsset.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos

public typealias CYPhotosAsset = PHAsset
private var SelectKey : String = "isSelect"
public extension CYPhotosAsset {
    
    public var isSelect : Bool {
        set {
            objc_setAssociatedObject(self, &SelectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            if  let select = objc_getAssociatedObject(self, &SelectKey) as? Bool {
                return select
            }
            return false
        }
    }
    public var originalImg : UIImage {
        get {
            let data = self.tuple.data
            return UIImage(data: data) ?? UIImage()
        }
    }
    
    private var tuple : (data : Data , info : [AnyHashable : Any]?) {
        var imageData       = Data()
        var dict : [AnyHashable : Any]?
        self.imageManager.requestImageData(for: self, options: self.requestOption) { (data, dataUTI, orientation, info) in
            dict = info
            if let da = data {
                imageData = da
            }
        }
        return (imageData,dict)
    }
    public var imageData : Data? {
        get {
            if CYPhotosManager.default.isFullMode {
                return UIImageJPEGRepresentation(self.originalImg,0.5)
            } else {
                return UIImageJPEGRepresentation(self.thumbnail,1.0)
            }
        }
    }
    public var thumbnail : UIImage {
        var thumbnail           = UIImage()
        self.imageManager.requestImage(for: self, targetSize: CGSize.init(width: 250.0, height: 250.0), contentMode: .aspectFill, options: self.requestOption) { (image, info) in
            thumbnail = image ?? UIImage()
        }
        return thumbnail
    }
    
    public var imageURL : URL? {
        get {
            if let info = self.tuple.info {
                return info["PHImageFileURLKey"] as? URL
            } else {
                return nil
            }
        }
    }
    
    public var originalImgLength : Double  {
        
        let tuple           = self.tuple
        let info            = tuple.info
        let data            = tuple.data
        
        guard info          != nil else { return 0.0 }
        
        guard let obj = (info!["PHImageFileDataKey"] as? NSObject) else {
            return Double(data.count)
        }
        guard !obj.isKind(of: NSData.self) else {
           return Double((obj as! NSData).length)
        }
        guard  let dataLength  = obj.value(forKey: "dataLength") as? Double else {
             return  Double(data.count)
        }
        
        return dataLength
    }

    private  var requestOption : PHImageRequestOptions {
        get {
            let option              = PHImageRequestOptions()
            option.isSynchronous    = true
            option.resizeMode       = .fast
            option.deliveryMode     = .highQualityFormat
            return option
        }
    }
    
    private var  imageManager   : PHImageManager {
        return PHImageManager.default()
    }
    
}
