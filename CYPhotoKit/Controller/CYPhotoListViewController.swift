//
//  CYPhotoListViewController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos
/**
 *  单个相册下的详情控制器
 */
public class CYPhotoListViewController: UIViewController {

    private var  needScrollToBottom  : Bool = true
    private var maxCount : Int              = maxSelectPhotoCount
    public var isShowCamera : Bool          {
        return title == "相机胶卷"
    }
    public var groupName : String?          {
        return self.title
    }
    
    // 底部的显示 bar
    private lazy var bottomView : UIView    = {
        let view = UIView(frame: CGRect(x: 0.0, y: CYScreenHeight-44.0, width: CYScreenWidth, height: 44.0))
        self.view.addSubview(view)
        // 灰色横线
        let topLineView                     = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: CYScreenWidth, height: 1.0))
        topLineView.backgroundColor         = .lightGray
        view.addSubview(topLineView)
        return view
    }()
    // 预览的按钮
    private lazy var  previewButton : UIButton    = {
        let btn               = UIButton(type: .custom)
        btn.frame             = CGRect(x: 15.0, y: 0.0, width: 40.0, height:44.0)
        btn.titleLabel?.font  = UIFont.systemFont(ofSize: 15.0)
        btn.setTitleColor(BaseTintColor, for: .normal)
        btn.setTitle("预览", for: .normal)
        btn.addTarget(self, action: #selector(previewButtonClick(_:)), for: .touchUpInside)
        self.bottomView.addSubview(btn)
        return btn
    }()
    // 完成按钮
    private lazy var  finishedButton : UIButton   = {
        let btn                           = UIButton(type: .custom)
        btn.frame                         = CGRect(x: bottomView.frame.maxX-55.0, y: 0.0, width: 40.0, height:44.0)
        btn.titleLabel?.font              = UIFont.systemFont(ofSize: 15.0)
        btn.setTitleColor(BaseTintColor, for: .normal)
        btn.setTitle("完成", for: .normal)
        btn.addTarget(self, action: #selector(finishedButtonClick(_:)), for: .touchUpInside)
        self.bottomView.addSubview(btn)
        return btn
    }()
    private lazy var  countLabel : UILabel        = {
        let label                  = UILabel()
        // 已经选择的图片的数量
        label.frame                = CGRect(x: finishedButton.frame.minX-25.0, y: 12.0 , width: 20.0, height: 20.0)
        label.font                 = UIFont.systemFont(ofSize: 15.0)
        label.textAlignment        = .center
        label.textColor            = .white
        label.backgroundColor      = BaseTintColor
        label.layer.cornerRadius        = 10.0
        label.layer.masksToBounds       = true
        self.bottomView.addSubview(label)
        return label
    }()
    private lazy var fullModeButton : UIButton = {
        let button               = UIButton(type: .custom)
        button.frame             = CGRect.init(x: self.previewButton.frame.maxX + 5.0, y: 0.0, width: 65.0, height: 44.0)
        button.imageEdgeInsets   = UIEdgeInsetsMake(0, -10, 0, 0)
        button.titleLabel?.font  = UIFont.systemFont(ofSize: 15.0)
        button.setImage(CYResourceAssets.fullImageNormal, for: .normal)
        button.setImage(CYResourceAssets.fullImageSelected, for: .selected)
        button.setTitleColor(BaseTintColor, for: .normal)
        button.setTitle("原图", for: .normal)
        button.addTarget(self, action: #selector(fullModeDidChange(_:)), for: .touchUpInside)
        self.bottomView.addSubview(button)
        return button
    }()
    //  所有原图相片的 size
    private lazy var  fullImageSizeLabel : UILabel = {
        let label                                  = UILabel()
        let labelX                                  = fullModeButton.frame.maxX + 1.0
        label.frame                                 = CGRect(x: labelX, y: 12.0 , width: 200.0, height: 20.0)
        label.font                                  = UIFont.systemFont(ofSize: 15.0)
        label.textAlignment                         = .left
        label.textColor                             = BaseTintColor
        self.bottomView.addSubview(label)
        return label
    }()
    lazy var imageManager : PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    public var fetchResult = [PHAsset]()
    private var itemMarigin : CGFloat       = 5.0
    private var itemSize : CGSize           = .zero
    private lazy var collectionView : UICollectionView = {
        let layout                          = UICollectionViewFlowLayout()
        let collectioView                   = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: CYScreenWidth, height: CYScreenHeight-44.0), collectionViewLayout: layout)
        collectioView.alwaysBounceVertical  = true
        collectioView.backgroundColor       = .white
        collectioView.scrollsToTop          = false
        return collectioView
    }()
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIActivityIndicatorView.show()
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIActivityIndicatorView.hide()
    }

    private func setup() {

        view.addSubview(self.collectionView)
        view.backgroundColor                      = .white
        self.navigationItem.rightBarButtonItem    = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(dismissViewController))
        collectionView.register(CYPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "CYPhotosCollectionViewCell")
        collectionView.delegate                   = self
        collectionView.dataSource                 = self
        let  itemW                                = (CYScreenWidth - 3*itemMarigin)/4
        let  itemH                                = itemW
        self.itemSize                             = CGSize(width:itemW, height:itemH);
        
        reloadBottomViewStatus()
    }

    @objc private func dismissViewController()  {
        NotificationCenter.default.post(name: NSNotification.Name("photosViewControllDismiss"), object: nil, userInfo: nil)
    }

    override public func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
        guard self.needScrollToBottom  else { return }
        if self.collectionView.contentSize.height > self.collectionView.frame.size.height {
            collectionViewScrollToBottom()
        }
    }
    private func showAlertMessage(with msg : String) {
        
        let alertViewControler = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alertViewControler.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { (action) in
        }))
        present(alertViewControler, animated: true, completion: nil)
    }

    deinit {
        CYPhotosManager.default.isFullMode = false
        self.fetchResult.removeAll()
    }


}
//MARK: 跟 BottomView 相关的内容
extension CYPhotoListViewController {

    //  更新底部工具条的显示状态
    @objc private func reloadBottomViewStatus() {
        
        let selectItemCount             = CYPhotosManager.default.selectImages.count
        previewButton.isEnabled         = selectItemCount>0
        finishedButton.isEnabled        = previewButton.isEnabled
        finishedButton.alpha            = selectItemCount == 0 ? 0.5 : 1.0
        previewButton.alpha             = finishedButton.alpha
        countLabel.isHidden             = (selectItemCount == 0)
        if !countLabel.isHidden {
            countLabel.text    = String(selectItemCount)
            UIView.animate(withDuration: 0.25, animations: {
                self.countLabel.transform = CGAffineTransform(translationX: 0.8, y: 0.8)
            }, completion: { (finished) in
                self.countLabel.transform = CGAffineTransform.identity;
            })
        }
        // 显示原图模式按钮状态
        self.fullModeButton.isSelected  = CYPhotosManager.default.isFullMode
        self.fullModeButton.isEnabled   = previewButton.isEnabled
        self.fullModeButton.alpha       = previewButton.alpha
        let isSizeLabelHideen : Bool    = fullModeButton.isSelected && fullModeButton.isEnabled
        // 显示原图的字节
        let dataLength : String         = CYPhotosManager.default.getBytesFromDataLength(CYPhotosManager.default.fullImageTotalSize)
        fullImageSizeLabel.text         = "(\(dataLength))"
        fullImageSizeLabel.isHidden     = !isSizeLabelHideen

    }
    /**
     *  查看所选照片的按钮
     */
    @objc private func previewButtonClick(_ btn : UIButton) {
        let previewVC           = CYPhotoPreviewViewController()
        previewVC.soureImages   = getSelectImagesArray()
        previewVC.delegate      = self
        navigationController?.pushViewController(previewVC, animated: true)
    }
    /**
     *  获取选中图片的数组
     */
    private func getSelectImagesArray() -> [CYPhotosAsset] {
        var array           = [CYPhotosAsset]()
        for asset in CYPhotosManager.default.selectImages.values {
            array.append(asset)
        }
        return array
    }
    /**
     *  完成按钮选取图片结束
     */
    @objc private func finishedButtonClick(_ btn : UIButton) {
        NotificationCenter.default.post(name: Notification.Name("photosViewControllerDidFinished"), object: getSelectImagesArray())
    }
    @objc private func fullModeDidChange(_ btn : UIButton) {
        btn.isSelected = !btn.isSelected
        CYPhotosManager.default.isFullMode = btn.isSelected
        reloadBottomViewStatus()
    }
    /**
     *  自动滚动到collectionView 底部
     */
    private func collectionViewScrollToBottom() {
        var off  = collectionView.contentOffset
        off.y    = collectionView.contentSize.height - collectionView.bounds.size.height + collectionView.contentInset.bottom
        collectionView.setContentOffset(off, animated: false)
        needScrollToBottom = false
    }
    
    @objc private func openImagePickerViewController() {
        
        let  authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .denied || authStatus == .restricted {
            let msg = "请到设置-隐私-相机中打开当前应用的权限"
            showAlertMessage(with: msg)
            return
        }
        
        let  sourceType : UIImagePickerControllerSourceType = .camera;
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker              = UIImagePickerController()
            imagePicker.allowsEditing    = true
            imagePicker.sourceType       = .camera
            imagePicker.delegate         = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlertMessage(with: "模拟器中无法打开照相机,请在真机中使用")
        }
    
    }
    
}

//MARK: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
extension CYPhotoListViewController : UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.fetchResult.count != 0 else { return 0 }
        let count  = self.fetchResult.count
        return count + (self.isShowCamera ? 1 : 0)
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell : CYPhotosCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYPhotosCollectionViewCell", for: indexPath) as! CYPhotosCollectionViewCell
        setupCollectionViewCell(cell, at: indexPath)
        return cell
    }
    private func setupCollectionViewCell(_ cell : CYPhotosCollectionViewCell , at indexPath : IndexPath) {
        
        let fetchCount              = self.fetchResult.count
        if indexPath.item >= fetchCount {
            cell.imageManager       = imageManager
            cell.photosAsset        = nil
            cell.isSelectItem       = false
        } else {
            
            let asset                = self.fetchResult[indexPath.item]
            if let _                 = CYPhotosManager.default.selectImages[asset.localIdentifier] {
                asset.isSelect      = true
            } else {
                asset.isSelect      = false
            }
            
            cell.imageManager       = imageManager
            cell.photosAsset        = asset
        
        }
        
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let canSelect                   = CYPhotosManager.default.selectImages.count <= maxCount - 1
        let fetchCount                  = self.fetchResult.count
        let msg                         = "选取的照片不能超过\(maxCount)张"
        if indexPath.item >= fetchCount  {
            if canSelect {
                openImagePickerViewController()
            } else {
                showAlertMessage(with: msg)
            }
            return
        }
        
        let asset        = fetchResult[indexPath.item]
        let isSelect     = !asset.isSelect
        var flag         = false
        if isSelect {
            if canSelect {
                flag                        = true
                CYPhotosManager.default.selectImages.updateValue(asset, forKey: asset.localIdentifier)
            } else {
                showAlertMessage(with: msg)
            }
        } else {
            CYPhotosManager.default.removeSelectPhotos(forKey: asset.localIdentifier)
        }
        asset.isSelect                          = flag
        collectionView.reloadItems(at: [indexPath])
        reloadBottomViewStatus()

    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
   public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemMarigin, left: 0.0, bottom: itemMarigin, right: 0.0)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemMarigin
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMarigin
    }

}

extension CYPhotoListViewController : CYPhotoPreviewViewControllerDelegate {

    public func didSelectItem(_ viewController: CYPhotoPreviewViewController, selectPhotoAsset phAsset : CYPhotosAsset?) {
        
        guard let index = self.fetchResult.index(of: (phAsset)!)  else {
            reloadBottomViewStatus()
            return
        }
        if  index == NSNotFound || index >=  self.fetchResult.count {
            reloadBottomViewStatus()
            return
        }
        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

}

// MARK: - UIImagePickerControllerDelegate

extension CYPhotoListViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        UIActivityIndicatorView.show()
                
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            PHPhotoLibrary.shared().performChanges({
                let options              = PHAssetResourceCreationOptions()
                options.shouldMoveFile   = true
                let data                 =  UIImageJPEGRepresentation(image, 1.0)
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data!, options: options)
            }, completionHandler: {[weak self] (finisehed, error) in
  
                guard error == nil else { return }
                DispatchQueue.main.async(execute: {
                    let collection = CYPhotosManager.default.getCollection(with: (self?.title)!)
                    if let newAsset                 = collection?.fetchResult?.lastObject {
                        self?.fetchResult.append(newAsset)
                        let fetchCount              = self?.fetchResult.count ?? 0
                        let indexPath               = IndexPath(item: fetchCount-1, section: 0)
                        newAsset.isSelect           = true
                        CYPhotosManager.default.selectImages[newAsset.localIdentifier] = newAsset
                        self?.collectionView.performBatchUpdates({
                            self?.collectionView.insertItems(at:[indexPath])
                        }, completion: { (finished) in
                            self?.reloadBottomViewStatus()
                            self?.collectionViewScrollToBottom()
                            UIActivityIndicatorView.hide()
                            NotificationCenter.default.post(name: Notification.Name.init("PHPhotoLibraryChangeObserver"), object: nil)
                        })
                    }
                })
            })


        }
        
        dismiss(animated: true, completion: nil)
    }

}
