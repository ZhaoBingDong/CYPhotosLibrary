//
//  Requst.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/12.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import Foundation
import UIKit

/// CYPhotosPickerable
public protocol CYPhotosPickerable : class  {

    /// 当前正在显示的控制器
    var currentViewController : UIViewController { get }
    
    /// 最多可以选择几张图片
    var selectImageCount : Int { get }
    /// 完成选择相片后的方法
    ///
    /// - Parameter photos: 拿到用户选取图片的集合
    func didFinishedSelectPhotos(_ photos : [CYPhotosAsset])
    
    var isFullMode : Bool { get }
}

// MARK: - CYPhotosPickerable
public extension CYPhotosPickerable  {
    
    /// 打开相册选择器
    func showImagePickerViewController() {
        let nav                  = CYPhotoNavigationController.showPhotosViewController()
        self.currentViewController.present(nav, animated: true, completion: nil)
        nav.maxPickerImageCount  = selectImageCount
        nav.completionBlock      = {[weak self] (photos) in
            self?.didFinishedSelectPhotos(photos)
        }
        CYPhotosManager.default.isFullMode = isFullMode
    }

    /// 清空相册选择器全部已经选过的图片
    func emptySelectedList() {
        CYPhotosManager.default.emptySelectedList()
    }

    func removeSelectPhotos(forKey key : String) {
        CYPhotosManager.default.removeSelectPhotos(forKey: key)
    }

}
