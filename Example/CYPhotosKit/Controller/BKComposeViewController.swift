//
//  BKComposeViewController.swift
//  Baye
//
//  Created by 董招兵 on 16/9/7.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit


/// 发动态的控制器

class BKComposeViewController: UIViewController {

    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
        
            self.collectionView.backgroundColor = UIColor.clear
            self.collectionView.register(UINib(nibName: "CYCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CYCollectionViewCell")
            self.collectionView.delegate        = self
            self.collectionView.dataSource      = self

        }
    }
    var itemSize : CGSize     = CGSize(width: 100.0, height: 100.0)
    var dataSource            = NSMutableArray()
    var longPressMoving : UILongPressGestureRecognizer?
    var imageArray : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        
        // 自定义返回 item
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(named: "back_white"), style: .plain, target: self, action: #selector(BKComposeViewController.back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(BKComposeViewController.sendAction))
        self.longPressMoving                   = UILongPressGestureRecognizer(target: self, action: #selector(BKComposeViewController.lonePressMoving(_:)))
        self.collectionView.addGestureRecognizer(self.longPressMoving!)
        
        self.loadDatas()

    }
    /**
     发送帖子
     */
    @objc func sendAction() {
        
        if self.textView.text.isEmpty {
            UnitTools.addLabelInWindow("发帖内容不能为空", vc:  self)
            return
        }
        self.textView.resignFirstResponder()
        // 需要上传图片的数组,过滤掉 + 号的按钮模型
        var uploadImages = [CYPhoto]()
        for photo in self.dataSource {
            if (photo as! CYPhoto).type == .photo {
                uploadImages.append(photo as! CYPhoto)
            }
        }

        // 发帖内容带图片 需要获取 token 并上传到阿里云服务器 然后调用发帖的接口
        if uploadImages.count != 0 {
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
            self.uploadImageWithResult(images: uploadImages)
        }  else {
            // 发帖内容没有图片直接发帖
            self.PostedTextReqeust()
        }
        
    }
    /**
     上传图片
     */
    func uploadImageWithResult(images:[CYPhoto]) {
        

    }
    
    /**
     发帖
     */
    func PostedTextReqeust() {
        

        
    }

    /**
     加载数据
     */
    func loadDatas() {

        let photo   = CYPhoto()
        photo.type  = CYPhotoAssetType.add; 
        photo.image = UIImage(named: "hubs_uploadImage")
        self.dataSource.add(photo)
        self.collectionView.reloadData()

    }
    
    /**
     返回上一页
     */
    @objc func back() {
        
        self.textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
   
    }
    /**
     移动 CollectionView 的 cell
    */
    @objc func lonePressMoving(_ longGestureRecognizer : UILongPressGestureRecognizer) {
        // 加号按钮禁止拖动
        let selectIndexPath = self.collectionView.indexPathForItem(at: self.longPressMoving!.location(in: self.collectionView))
        
        switch self.longPressMoving!.state {
        case .began:
         
            self.collectionView.beginInteractiveMovementForItem(at: selectIndexPath!)
            break
            
        case .changed :
            
             self.collectionView.updateInteractiveMovementTargetPosition(self.longPressMoving!.location(in: self.collectionView))
            
            break
        case .ended :
            self.collectionView.endInteractiveMovement()
            
            break
        default:
            self.collectionView.cancelInteractiveMovement()
            
            break
        }
        
    }

}

// MARK: - UICollectionViewDelegate , UICollectionViewDataSource
extension BKComposeViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.dataSource.count >= 10 {
            return 9
        }
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        weak var  cell             = collectionView.dequeueReusableCell(withReuseIdentifier: "CYCollectionViewCell", for: indexPath) as? CYCollectionViewCell
        cell?.delegate             = self
        let photo                  = self.dataSource[(indexPath as NSIndexPath).item] as! CYPhoto
        cell?.deleteButton?.isHidden = photo.type == .add
        
        if (photo.type == .add) {
            
             cell!.imageView!.image = photo.image;
            
        } else {
            
            if photo.image != nil {
                
                cell!.imageView!.image = photo.image
                
            } else  {
                
                let imageManager       = PHImageManager.default()
                imageManager.requestImage(for: photo.asset!, targetSize:CGSize(width: 200.0,height: 200.0) , contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                    cell!.imageView!.image = image;
                })
                
            }

        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo            = self.dataSource[(indexPath as NSIndexPath).item] as! CYPhoto
        if (photo.type == .photo) {
            return
        }
        
        let alertController = UIAlertController(title:nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 打开相册
        alertController.addAction(UIAlertAction(title: "从手机选择", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in

            let cyPhotoNav                 = CYPhotoNavigationController.showPhotosView()
            self.present(cyPhotoNav, animated: true, completion: nil)
            cyPhotoNav.maxPickerImageCount = self.getNeedsImageCount()
            cyPhotoNav.delegate    = self
            
        }))
        // 拍照
        alertController.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.default, handler: { (action) in
           
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                
                //初始化图片控制器
                let imagePickerController           = UIImagePickerController()
                imagePickerController.delegate      = self
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType    = .camera
                self.present(imagePickerController, animated: true, completion: nil)

            } else {
                
                print("读取相册错误")
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let selectIndexPath = self.collectionView.indexPathForItem(at: self.longPressMoving!.location(in: self.collectionView))
        guard selectIndexPath != nil else {
            return
        }

        self.dataSource.exchangeObject(at: ((sourceIndexPath as NSIndexPath).item), withObjectAt: (destinationIndexPath as NSIndexPath).item)
        
        // 如果数组里最后一个元素不是 添加图片的按钮 就重新排序
         self.dataSource.sort(comparator: { (obj1, obj2) -> ComparisonResult in
            
            let photo1 = obj1 as! CYPhoto
            let photo2 = obj2 as! CYPhoto
            let typ1   = "\(photo1.type.rawValue)"
            let typ2   = "\(photo2.type.rawValue)"
            return typ2.compare(typ1)
            
         })
  
        self.collectionView.reloadData()
        
    }
    /**
     获取未选取图片的数量,最大为9 最小为0
     */
    func getNeedsImageCount() -> Int {
        
        let photos = self.dataSource.lastObject as? CYPhoto
        if photos != nil {
            if photos!.type == .add {
                return 10 - self.dataSource.count
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth  = 310.0 / 4.0
        let itemHeight = itemWidth * 0.95
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

}

// MARK: - CYPhotoNavigationControllerDelegate
extension BKComposeViewController : CYPhotoNavigationControllerDelegate {
    
    func cyPhotoNavigationController(_ controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {
        
        let array   = NSMutableArray()
        
        for i in 0..<result!.count {
            
            let photoAsset    = result![i] 
            let photo         = CYPhoto()
            photo.type        = .photo
            photo.image       = nil
            photo.photosAsset = photoAsset
            array.add(photo)
            
        }
        
        let indexSet = IndexSet(integersIn: Range()!)
        self.dataSource.insert(array as [AnyObject], at: indexSet)
        if self.dataSource.count >= 10 {
            self.dataSource.removeLastObject()
        }
        
        self.collectionView.reloadData()
        
    }
    
}

// MARK: - CYCollectionViewCellDelegate
extension BKComposeViewController : CYCollectionViewCellDelegate {
    
    
    func bkCollectionViewCellDidSelectButton(_ cell: CYCollectionViewCell?) {

        let indexPath  = collectionView.indexPath(for: cell!)
        self.dataSource.removeObject(at: ((indexPath as NSIndexPath?)?.item)!)
        self.collectionView.deleteItems(at: [indexPath!])
        let lastPhotot = self.dataSource.lastObject as! CYPhoto
 
        if lastPhotot.type != .add {
            
            let photo   = CYPhoto()
            photo.type  = CYPhotoAssetType.add;
            photo.image = UIImage(named: "hubs_uploadImage")
            self.dataSource.add(photo)
            self.collectionView.reloadData()
            
        }
        
    
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension BKComposeViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let editedImage        = info["UIImagePickerControllerEditedImage"] as! UIImage
        let photpAsset         = CYPhotosAsset()
        photpAsset.originalImg = editedImage

        let photo              = CYPhoto()
        photo.image            = editedImage
        photo.type             = .photo
        photo.photosAsset      = photpAsset

        let lastPhoto          = self.dataSource.lastObject as! CYPhoto

        if lastPhoto.type == .add {
            
            self.dataSource.removeLastObject()
            self.dataSource.add(photo)
            self.loadDatas()
            
        }
        picker.dismiss(animated: true, completion: nil)
     }
    
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
     }
    
    
}

//MARK: UITextViewDelegate
extension BKComposeViewController : UITextViewDelegate {

    
    func textViewDidChange(_ textView: UITextView) {
        
        let length = textView.text.length
        if length > 190 {
            UnitTools.addLabelInWindow("发帖内容不能超过190字", vc:  self)
            textView.text = (textView.text as NSString).substring(to: 190)
        }
        
    }
    
    
}

