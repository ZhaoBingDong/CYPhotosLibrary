//
//  ViewController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {

    let itemMarigin : CGFloat = 5.0
    var itemSize : CGSize = .zero
    var dataArray : [CYPhoto] = [CYPhoto]()
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadDatas()
    }

    func setup() {


        let  itemW                            = (CYScreenWidth - 3.0*itemMarigin)/4.0
        let  itemH                            = itemW
        self.itemSize                         = CGSize(width :  itemW, height :itemH);

        self.collectionView.alwaysBounceVertical = true

        self.collectionView.backgroundColor = .clear
        collectionView.register(CYCollectionViewCell.self, forCellWithReuseIdentifier: "CYCollectionViewCell")
        self.collectionView.delegate        = self
        self.collectionView.dataSource      = self

    }

    func loadDatas()  {
        let   photo = CYPhoto()
        photo.type  = .add;
        photo.image = UIImage(named: "hubs_uploadImage")
        self.dataArray.append(photo)
        collectionView.reloadData()
    }

    deinit {
        emptySelectedList()
    }
}

//MARK:CYPhotosPickerable  是遵守者对象具有获取并使用系统相册图片的能力

extension ViewController : CYPhotosPickerable {
    
    var selectImageCount: Int {
        return 1
    }
    
    var isFullMode: Bool {
       return true
    }
    
    var currentViewController: UIViewController { return self }
    func didFinishedSelectPhotos(_ photos: [CYPhotosAsset]) {

        var array = [CYPhoto]()
        for asset in photos {
            let photo = CYPhoto()
            photo.type          = .photo;
            photo.image         = nil;
            photo.photosAsset   = asset;
            array.append(photo)
        }

        dataArray = array
        if (self.dataArray.count >= 10) {
            dataArray.removeLast()
        } else if (self.dataArray.count < 9) {
           loadDatas()
        }
        collectionView.reloadData()

    }

}


extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , CYCollectionViewCellDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard dataArray.count < 10 else { return 9 }
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CYCollectionViewCell", for: indexPath) as! CYCollectionViewCell
        cell.contentView.backgroundColor    = .white
        cell.delegate                       = self
        let photo                           = dataArray[indexPath.item]

        if photo.type == .add {
            cell.imageView.image = photo.image
        } else {
            cell.imageView.image = photo.photosAsset?.thumbnail
        }
        cell.deleteButton.isHidden   = (photo.type == .add);

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo                           = dataArray[indexPath.item]
        if photo.type                       == .photo { return }

        showImagePickerViewController()

    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 0.0, bottom: itemMarigin, right: 0.0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemMarigin
    }

     public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMarigin
    }


    func bkCollectionViewCellDidSelectDelegateButton(cell: CYCollectionViewCell) {

        
        if  let indexPath  = collectionView.indexPath(for: cell) {
            let photo       = self.dataArray[indexPath.item];
            // 从图片管理器中移除已经选择过的图片
            removeSelectPhotos(forKey: (photo.asset?.localIdentifier)!)

            dataArray.remove(at: indexPath.item)

            collectionView.deleteItems(at: [indexPath])

            if  let lastPhotot     = dataArray.last {
                if (lastPhotot.type != .add) {
                    loadDatas()
                }
            }


        }
    }

}
