//
//  CYPhotoPreviewViewController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit


public protocol CYPhotoPreviewViewControllerDelegate : NSObjectProtocol {
    func didSelectItem(_ viewController : CYPhotoPreviewViewController ,selectPhotoAsset phAsset : CYPhotosAsset?)
}

public class CYPhotoPreviewViewController: UIViewController {

    private var collectionView : UICollectionView?
    public var soureImages : [CYPhotosAsset]?
    private var checkBoxButton : UIButton?
    private var pageIndex : Int = 0
    private var fullImageButton : UIButton = UIButton(type: .custom)
    private var fullImageSizeLabel : UILabel =  UILabel()
    weak var delegate : CYPhotoPreviewViewControllerDelegate?
    private var selectImages  = [CYPhotosAsset]()
    // 底部的显示 bar
    private lazy var bottomView : UIView         = {
        let view = UIView(frame: CGRect.init(x: 0.0, y: CYScreenHeight-44.0, width: CYScreenWidth, height: 44.0))
        view.backgroundColor                     = UIColor.CYColor(34.0, green: 34.0, blue: 34.0)
        self.view.addSubview(view)
        return view
    }()
    // 完成按钮
    private lazy var  finishedButton : UIButton   = {
        let btn                                   = UIButton(type: .custom)
        btn.frame                                 = CGRect(x: bottomView.frame.maxX-55.0, y: 0.0, width: 40.0, height:44.0)
        btn.titleLabel?.font                      = UIFont.systemFont(ofSize: 15.0)
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {

        guard let images = soureImages else { return }
        for photo in images {
            photo.isSelectedImage = true
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        title                                   = "预览"
        view.backgroundColor                    = .white

        let layout                              = UICollectionViewFlowLayout()
        layout.scrollDirection                  = .horizontal
        self.collectionView                     = UICollectionView(frame: CGRect(x: -10.0, y: 0.0, width: CYScreenWidth+20.0, height: CYScreenHeight-44.0), collectionViewLayout: layout)
        collectionView?.backgroundColor         = .black
        self.collectionView?.register(CYPhotoPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "CYPhotoPreviewCollectionViewCell")
        self.collectionView?.delegate           = self
        self.collectionView?.dataSource         = self
        self.collectionView?.isPagingEnabled    = true
        view.addSubview(self.collectionView!)

        let v                                = UIView(frame: CGRect(x:0.0, y:0.0, width:26, height:26))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: v)

        checkBoxButton                       = UIButton(type: .custom)
        checkBoxButton?.setImage(CYResourceAssets.checkmarkImage, for: .selected)
        checkBoxButton?.setImage(CYResourceAssets.checkmarkNormal, for: .normal)
        checkBoxButton?.addTarget(self, action: #selector(checkBoxClick(_:)), for: .touchUpInside)
        checkBoxButton?.frame                      = CGRect(x:0.0, y:0.0, width:26, height:26);
        v.addSubview(checkBoxButton!)

        setCheckBoxButtonState(pageIndex)
        reloadBottomViewStatus()

    }


    //  更新底部工具条的显示状态
    @objc private func reloadBottomViewStatus() {
        let selectItemCount             = CYPhotosManager.defaultManager.selectImages.count
        finishedButton.isEnabled        =  selectItemCount>0
        finishedButton.alpha            = selectItemCount == 0 ? 0.5 : 1.0
        countLabel.isHidden             = (selectItemCount == 0)
        if !countLabel.isHidden {
            countLabel.text    = String(selectItemCount)
            UIView.animate(withDuration: 0.25, animations: {
                self.countLabel.transform = CGAffineTransform(translationX: 0.8, y: 0.8)
            }, completion: { (finished) in
                self.countLabel.transform = CGAffineTransform.identity;
            })
        }
    }

    @objc private func checkBoxClick(_ btn:UIButton) {
        let            photoAsset         = self.soureImages![self.pageIndex];
        photoAsset.isSelectedImage        = !photoAsset.isSelectedImage;
        self.checkBoxButton?.isSelected   = photoAsset.isSelectedImage
        let key                           = photoAsset.localIdentifier ?? ""
        if photoAsset.isSelectedImage {
            CYPhotosManager.defaultManager.selectImages[key] = photoAsset.asset
        } else {
            CYPhotosManager.defaultManager.removeSelectPhotos(forKey: key)
        }
        reloadBottomViewStatus()
        delegate?.didSelectItem(self, selectPhotoAsset: photoAsset)
    }

    private func setCheckBoxButtonState(_ index : Int) {
        let     photoAsset               = self.soureImages![index]
        self.checkBoxButton?.isSelected  = photoAsset.isSelectedImage
        self.pageIndex                   = index
    }

    /**
     *  完成按钮选取图片结束
     */
    @objc private func finishedButtonClick(_ btn : UIButton) {
        NotificationCenter.default.post(name: Notification.Name("photosViewControllerDidFinished"), object: getSelectImagesArray())
    }

    private func getSelectImagesArray() -> [CYPhotosAsset] {
        var array           = [CYPhotosAsset]()
        for asset in CYPhotosManager.defaultManager.selectImages.values {
            let photosAsset = CYPhotosAsset(photoAsset: asset)
            array.append(photosAsset)
        }
        return array
    }


}

extension CYPhotoPreviewViewController : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.soureImages?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYPhotoPreviewCollectionViewCell", for: indexPath) as! CYPhotoPreviewCollectionViewCell
        let assetModel              = soureImages?[indexPath.item]
        cell.asset                  = assetModel

        return cell

    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let  width   = CYScreenWidth + 20.0
        let height   = CYScreenHeight - 44.0 - 104
        return CGSize(width : width, height : height)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / CYScreenWidth
        setCheckBoxButtonState(Int(index))
    }
}
