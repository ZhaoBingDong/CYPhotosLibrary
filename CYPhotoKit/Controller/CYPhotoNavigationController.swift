//
//  CYPhotoNavigationController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit


/**
 *  相册选择器的导航控制器
 */
public class CYPhotoNavigationController: UINavigationController {
    /**
     *  选取完照片的后的回调
     */
    public typealias PhotosCompletion    = ([CYPhotosAsset]) -> Void
    public var completionBlock : PhotosCompletion?
    /**
     *  最大选择图片的数量
     */
    public var maxPickerImageCount : Int = maxSelectPhotoCount
    /**
     已经选择过的图片数组
     */
    public var selectImages : [CYPhotosAsset]?
    /**
     *  类方法获取一个 photosNavigationController
     */
    public class func showPhotosViewController() -> CYPhotoNavigationController {
        let photoGroupViewController     = CYPhotoGroupController()
        let nav                          = CYPhotoNavigationController(rootViewController: photoGroupViewController)
        return nav
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor         = UIColor.CYColor(34, green: 34, blue: 34)
        self.navigationBar.tintColor           = .white
        self.navigationController?.interactivePopGestureRecognizer!.delegate    = self
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isEmpty()
        addObserver()
    }
    /**
     *  判断rootViewController 是否为 CYPhotoGroupController ,实例化方法 showPhotosViewController 不能使用其他 controlller 作为 CYPhotoNavigationController 的 rootViewController
     */
    private func isEmpty() {
        let rootViewController = self.viewControllers.first
        guard let rootVC = rootViewController ,
            (rootVC.isKind(of: CYPhotoGroupController.self))
        else {
            fatalError("\n\n请指定 CYPhotoGroupController类型的 rootViewController 或者调用 showPhotosViewController 方法\n")
        }
    }
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissViewController), name: NSNotification.Name("photosViewControllDismiss"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinished(_:)), name: NSNotification.Name("photosViewControllerDidFinished"), object: nil)
    }
    // 选择完相片后点击完成
    @objc private func didFinished(_ notification : Notification) {
        let array  = notification.object as! [CYPhotosAsset]
        completionBlock?(array)
        dismissViewController()
    }
    /// 点击了取消 关闭相册选择器
    @objc private func dismissViewController() {
        self.navigationController?.popToRootViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }

    deinit {
//        NSLog("self deaclloc")
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}

// MARK: - 控制器左侧滑动返回的代理

extension CYPhotoNavigationController : UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
