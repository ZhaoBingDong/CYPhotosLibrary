//
//  CYPhotosManager.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos

/**
 *  照片资源获取的管理者
 */
public class CYPhotosManager: NSObject {

    public static let defaultManager : CYPhotosManager = CYPhotosManager()
    private  override init() {   }
    public var  allPhotosOptions : CYPhotosCollection {
        get {
            let allPhotosOptions             = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let allPhotos                    = PHAsset.fetchAssets(with: allPhotosOptions)
            let asset                        = allPhotos.firstObject
            let photoCollection              = CYPhotosCollection()
            photoCollection.count            = String(format: "%d", allPhotos.count)
            photoCollection.thumbnail        = getImage(with: asset)
            photoCollection.fetchResult      = allPhotos
            photoCollection.localizedTitle   = "相机胶卷"
            return photoCollection
        }
    }
    public var isFullMode : Bool             = false
    public var fullImageTotalSize : Double      {
        get {
            var totalSize : Double = 0.0
            for photo in selectImages.values {
                let photoAsset = CYPhotosAsset(photoAsset: photo)
                totalSize+=photoAsset.originalImgLength
            }
            return totalSize
        }
    }
    public func getBytesFromDataLength(_ dataLength : Double) -> String {
        var bytes : String = ""
        if (dataLength >= 0.1 * (1024 * 1024)) {
            bytes = String(format: "%0.1fM", dataLength/1024.0/1024.0)
        } else if (dataLength >= 1024) {
            bytes = String(format: "%0.0fK",dataLength/1024.0)
        } else {
            bytes = String.init(format:"%zdB",dataLength)
        }
        return bytes;
    }
    /**
     *  系统创建的一些相册
     */
    public var  smartAlbums : [CYPhotosCollection] {

        let smartAlbums                 =  PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        var photoGroups                 = [CYPhotosCollection]()
        DispatchQueue.concurrentPerform(iterations: smartAlbums.count) {[weak self] (index) in
            let  collection                      = smartAlbums.object(at: index)
            let  assetsFetchResult               = PHAsset.fetchAssets(in: collection, options: nil)
            if (self?.needAddPhotoGroup(with: collection))! && assetsFetchResult.count != 0 {
                let photoCollection              = CYPhotosCollection()
                photoCollection.count            = String(format: "%d",assetsFetchResult.count)
                photoCollection.fetchResult      = assetsFetchResult;
                photoCollection.localizedTitle   = self?.getPhotoGroupName(by: collection)
                photoCollection.thumbnail        = self?.getNearbyImage(collection)
                photoGroups.append(photoCollection)
            }
        }
        return photoGroups
    }
    /**
     *  用户自己创建的相册
     */
    public var topLevelUserCollections : [CYPhotosCollection] {

        let topLevelUserCollections               =  PHCollectionList.fetchTopLevelUserCollections(with: nil)
        var userPhotoGroups                       = [CYPhotosCollection]()
        DispatchQueue.concurrentPerform(iterations: topLevelUserCollections.count) {[weak self] (index) in
            let  collection                       = topLevelUserCollections.object(at: index)
            let  assetsFetchResult                = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: nil)
            if assetsFetchResult.count != 0 {
                let photoCollection              = CYPhotosCollection()
                photoCollection.count            = String(format: "%d",assetsFetchResult.count)
                photoCollection.fetchResult      = assetsFetchResult;
                photoCollection.localizedTitle   = self?.getPhotoGroupName(by: collection)
                photoCollection.thumbnail        = self?.getNearbyImage(collection as! PHAssetCollection)
                userPhotoGroups.append(photoCollection)
            }

        }
        return userPhotoGroups
    }
    /**
     已经选择过的图片数组
     */
    public lazy var selectImages : [String : PHAsset] = {
        return [String : PHAsset]()
    }()
    /**
     移除掉已经选择过的图片
     */
    public func removeSelectPhotos(forKey localIdentifier : String) {
        if (self.selectImages.count == 0 ) { return }
        selectImages.removeValue(forKey: localIdentifier)
    }
    /**
     清空所有已经选择过图片数组
     */
    public func emptySelectedList() {
        selectImages.removeAll()
    }
    private func getImage(with asset : PHAsset?) -> UIImage? {
        guard asset             != nil else { return nil }
        let  imageManager       = PHImageManager.default()
        weak var sourceImage : UIImage?
        let option              = PHImageRequestOptions()
        option.deliveryMode     = .highQualityFormat
        option.isSynchronous    = true
        option.resizeMode       = .fast
        imageManager.requestImage(for: asset!, targetSize: CGSize(width:250.0, height:250.0), contentMode: .aspectFill, options: option) { (result, _) in
            sourceImage = result
        }
        return sourceImage
    }
    /**
     *  判断是否将一个photoGroup展示出来
     */
    private func needAddPhotoGroup(with collection : PHAssetCollection) -> Bool {
        guard collection.localizedTitle != nil else { return false }
        switch collection.localizedTitle! {
        case "Screenshots" ,
             "Selfies" ,
             "Recently Added" ,
             "Favorites" ,
             "Videos" :
            return true
        default:
            return false
        }
    }
    /**
     *  得到每个组的中文名称
     */
    private func getPhotoGroupName(by collection : PHCollection) -> String? {

        guard collection.localizedTitle != nil else { return nil }

        switch collection.localizedTitle! {
        case "Screenshots" :
            return "屏幕快照"
        case"Selfies" :
            return "自拍"
        case "Recently Added" :
            return "最新添加"
        case "Favorites" :
            return "个人收藏"
        case "Videos" :
            return "视频"
        default:
            return collection.localizedTitle
        }

    }
    /**
     *  每个相册组最近一张照片的缩略图
     */
   private func getNearbyImage(_ collection : PHAssetCollection) -> UIImage? {
        let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        if assetsFetchResult.count == 0 {
            return CYResourceAssets.addIcon
        } else {
            let asset = assetsFetchResult.firstObject
            return getImage(with: asset)
        }
    }

}
