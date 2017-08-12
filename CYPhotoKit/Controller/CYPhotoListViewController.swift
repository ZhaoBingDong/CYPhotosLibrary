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
    // 底部的显示 bar
    private lazy var bottomView : UIView    = {
        let view = UIView(frame: CGRect.init(x: 0.0, y: CYScreenHeight-44.0, width: CYScreenWidth, height: 44.0))
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
        btn.setTitleColor(tintColor, for: .normal)
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
        btn.setTitleColor(tintColor, for: .normal)
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
        label.backgroundColor      = tintColor
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
        button.setTitleColor(tintColor, for: .normal)
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
        label.textColor                             = tintColor
        self.bottomView.addSubview(label)
        return label
    }()

    var cacheSelectItems                    = [String : NSNumber]()
    lazy var imageManager : PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    public var fetchResult : PHFetchResult<PHAsset>? {
        didSet {
            guard fetchResult != nil else { return }
            loadDatas()
        }
    }
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
        
    }

    private func loadDatas() {
        

        DispatchQueue.global().async { [weak self] in
            let selectItems : [String : PHAsset] = CYPhotosManager.defaultManager.selectImages
            let fetchCount = self?.fetchResult?.count ?? 0
            for idx in 0..<fetchCount {
                if let photoAsset   = self?.fetchResult?.object(at: idx) {
                    let key         = String(idx)
                    var isSelect    = false
                    let selectAsset = selectItems[photoAsset.localIdentifier]
                    if  selectAsset != nil &&
                        (selectAsset?.localIdentifier == photoAsset.localIdentifier)  {
                        isSelect = true
                    }
                    self?.cacheSelectItems.updateValue(NSNumber(value: isSelect), forKey: key)
                }
            }
            self?.performSelector(onMainThread: #selector(self?.reloadBottomViewStatus), with: nil, waitUntilDone: true)
        }

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
    private func showAlertMessage() {
        let msg = "选取的照片不能超过\(maxCount)张"
        let alertViewControler = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alertViewControler.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { (action) in
        }))
        present(alertViewControler, animated: true, completion: nil)

    }

    deinit {
        CYPhotosManager.defaultManager.isFullMode = false
    }


}
//MARK: 跟 BottomView 相关的内容
extension CYPhotoListViewController {

    //  更新底部工具条的显示状态
    @objc private func reloadBottomViewStatus() {
        
        let selectItemCount             = CYPhotosManager.defaultManager.selectImages.count
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
        self.fullModeButton.isSelected  = CYPhotosManager.defaultManager.isFullMode
        self.fullModeButton.isEnabled   = previewButton.isEnabled
        self.fullModeButton.alpha       = previewButton.alpha
        let isSizeLabelHideen : Bool    = fullModeButton.isSelected && fullModeButton.isEnabled
        // 显示原图的字节
        let dataLength : String         = CYPhotosManager.defaultManager.getBytesFromDataLength(CYPhotosManager.defaultManager.fullImageTotalSize)
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
        for asset in CYPhotosManager.defaultManager.selectImages.values {
            let photosAsset = CYPhotosAsset(photoAsset: asset)
            array.append(photosAsset)
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
        CYPhotosManager.defaultManager.isFullMode = btn.isSelected
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

    @objc private func bottomViewTap(_ tap : UITapGestureRecognizer) {
        
    }
    
}

//MARK: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
extension CYPhotoListViewController : UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CYPhotosCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYPhotosCollectionViewCell", for: indexPath) as! CYPhotosCollectionViewCell
        setupCollectionViewCell(cell, at: indexPath)
        return cell
    }
    private func setupCollectionViewCell(_ cell : CYPhotosCollectionViewCell , at indexPath : IndexPath) {
        if let asset                = self.fetchResult?.object(at: indexPath.item) {
            let key                 = String(indexPath.item)
            let isSelect            = self.cacheSelectItems[key]?.boolValue
            cell.imageManager       = imageManager
            cell.photosAsset        = asset
            cell.imageManager       = imageManager
            cell.isSelectItem       = isSelect ?? false
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let asset        = fetchResult?.object(at: indexPath.item) {
            let key          = String(indexPath.item)
            let isSelect     = !(cacheSelectItems[key]?.boolValue ?? false)
            var flag         = false
            if isSelect {
                if CYPhotosManager.defaultManager.selectImages.count <= maxCount - 1 {
                    flag                        = true
                    CYPhotosManager.defaultManager.selectImages.updateValue(asset, forKey: asset.localIdentifier)
                } else {
                    showAlertMessage()
                }
            } else {
                CYPhotosManager.defaultManager.removeSelectPhotos(forKey: asset.localIdentifier)
            }
            
            cacheSelectItems[key]                   = NSNumber(value: flag)
            if let photosCell                       = collectionView.cellForItem(at: indexPath) as? CYPhotosCollectionViewCell {
                setupCollectionViewCell(photosCell, at: indexPath)
                reloadBottomViewStatus()
            }

        }

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

        guard let index = self.fetchResult?.index(of: (phAsset?.asset)!)  else {
            reloadBottomViewStatus()
            return
        }
        if  index == NSNotFound || index >=  (self.fetchResult?.count)! {
            reloadBottomViewStatus()
            return
        }

        collectionView(collectionView, didSelectItemAt: IndexPath(item: index, section: 0))

    }

}
