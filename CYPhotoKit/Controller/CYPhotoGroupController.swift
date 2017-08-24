//
//  CYPhotoGroupController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos
public class CYPhotoGroupController: UIViewController {

    private var sectionFetchResults : [CYPhotosCollection] = [CYPhotosCollection]()
    lazy private var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style:.plain)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        reqeustAuthorization()
    }

    @objc func dismissViewController()  {
        NotificationCenter.default.post(name: NSNotification.Name("photosViewControllDismiss"), object: nil, userInfo: nil)
    }

    private func setup() {

        self.view.backgroundColor                = .white
        self.navigationItem.rightBarButtonItem   = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(dismissViewController))
        title                                    = "照片"

        view.addSubview(tableView)
        tableView.register(CYPhotoLibrayGroupCell.self, forCellReuseIdentifier: "CYPhotoLibrayGroupCell")
        tableView.rowHeight         = 80.0
        tableView.delegate          = self
        tableView.dataSource        = self
        
    }
    /*
     请求访问相册的权限
     */
    private func reqeustAuthorization() {

        let authorizedStatus = PHPhotoLibrary.authorizationStatus()
        guard authorizedStatus != .authorized else {
            photosAuthorizedSuccess()
            return
        }

        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                NSLog("用户允许当前应用访问相册")
                self.perform(#selector(self.photosAuthorizedSuccess), on: Thread.main, with: nil, waitUntilDone: true)
                break
            case .denied :
                self.perform(#selector(self.showAuthorizationViewController), on: Thread.main, with: nil, waitUntilDone: true)
                NSLog("用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关")
                break
            case .notDetermined :
                self.perform(#selector(self.showAuthorizationViewController), on: Thread.main, with: nil, waitUntilDone: true)
                NSLog("用户还没有做出选择")
                break
            case .restricted :
                self.perform(#selector(self.showAuthorizationViewController), on: Thread.main, with: nil, waitUntilDone: true)
                NSLog("家长控制,不允许访问")
                break
            }
        }

    }

    /*
     获取相册权限成功
     */
    @objc private func photosAuthorizedSuccess() {

        let photosManager           = CYPhotosManager.default
        let dataArray               = photosManager.allCollections
        if let photoCollection = dataArray.first {
            self.openPhotosListViewController(with: photoCollection, animated: false)
        }
        self.sectionFetchResults     = dataArray
        self.tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(photoLibraryDidChange), name: Notification.Name.init("PHPhotoLibraryChangeObserver"), object: nil)
        
    }

    @objc private func showAuthorizationViewController(_ viewController : CYAuthorizedFailureViewController) {
        let authorizationVC = CYAuthorizedFailureViewController()
        self.navigationController?.pushViewController(authorizationVC, animated: false)
    }

    private func openPhotosListViewController(with photosCollection : CYPhotosCollection ,animated :Bool) {
        guard photosCollection.fetchResult?.count != nil else { return }
        let photoDetailVC            = CYPhotoListViewController()
        photoDetailVC.fetchResult    = photosCollection.allObjects
        photoDetailVC.title          = photosCollection.localizedTitle
        self.navigationController?.pushViewController(photoDetailVC, animated: animated)
    }

    deinit {
//        NSLog("self dealloc ")
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

}

//MARK: UITableViewDelegate & UITableViewDataSource
extension CYPhotoGroupController : UITableViewDelegate , UITableViewDataSource {
   
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionFetchResults.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CYPhotoLibrayGroupCell = tableView.dequeueReusableCell(withIdentifier: "CYPhotoLibrayGroupCell") as! CYPhotoLibrayGroupCell
        
        let  photosCollection        = self.sectionFetchResults[indexPath.row]
        cell.photoImageView.image   = photosCollection.thumbnail
        cell.titleLabel.text        = String.init(format: "%@ (%@)", arguments: [photosCollection.localizedTitle!,photosCollection.count!])
        
        photosCollection.getSelectImageCount(close: { (count) in
            cell.badgeValue.isHidden = count == 0
            print("IndexPath : \(indexPath.row) count :\(count)")
        })
        
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let  photosCollection    = self.sectionFetchResults[indexPath.item]
        openPhotosListViewController(with: photosCollection, animated: true)

    }

    
}


// MARK: PHPhotoLibraryChangeObserver
extension CYPhotoGroupController  {
    
    @objc public func photoLibraryDidChange() {
        self.sectionFetchResults     = CYPhotosManager.default.allCollections
    }
}
