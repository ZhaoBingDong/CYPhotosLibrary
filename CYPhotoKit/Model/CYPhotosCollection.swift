//
//  CYPhotosCollection.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos

/**
 *  代表一个集合可能是一个相册组也可能是所有 PHAsset 的集合
 */
public class CYPhotosCollection: NSObject {

    /**
     *  集合里边放的是 PHAsset 对象
     */
   public var fetchResult : PHFetchResult<PHAsset>?
    /**
     *  相册名称
     */
   public var localizedTitle : String?
    /**
     *  相册里照片/视频的数量
     */
   public var count : String?
    /**
     *  相册封面取最新的一张照片作为封面
     */
   public var thumbnail : UIImage?
    
    /// 表示该相簿里选中照片的个数
    func getSelectImageCount(close :@escaping ((_ count : Int)-> Void)) {
        
        DispatchQueue.global().async { [weak self] in
            let objects     = self?.allObjects
            func filter(asset : CYPhotosAsset) -> Bool {
                if let _ = CYPhotosManager.default.selectImages[asset.localIdentifier] {
                    return true
                }
                return false
            }
            let selectAssets =  objects!.filter(filter)
            let fetchCount = selectAssets.count
            DispatchQueue.main.async {
                close(fetchCount)
            }
        }
    }
    
    /// 相册里所有 Asset 集合
    public var allObjects : [PHAsset]  {
        get {
            if let result = self.fetchResult {
                var objects = [PHAsset]()
                for index in 0..<result.count {
                    objects.append(result.object(at: index))
                }
                return objects
            } else {
                return [PHAsset]()
            }
        }
        
    }

    deinit {
//        NSLog("self deaclloc")
    }
}
