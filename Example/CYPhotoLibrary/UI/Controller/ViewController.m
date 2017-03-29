//
//  ViewController.m
//  CYPhotoLibrary
//
//  Created by 董招兵 on 2017/2/28.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import "ViewController.h"
#import "CYPhotosKit.h"
#import "CYPhoto.h"
#import "CYPhotoNavigationController.h"
#import "CYCollectionViewCell.h"
#import "CYPhotosAsset.h"

static CGFloat const itemMarigin = 5.0f;

@interface ViewController ()
<
    UICollectionViewDelegate ,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    CYPhotoNavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate ,
    CYCollectionViewCellDelegate
>

@property (nonatomic,assign)   CGSize                itemSize;
@property (strong, nonatomic)  UICollectionView *collectionView;
@property (nonatomic, nonnull,strong) NSMutableArray <CYPhoto *> *dataArray;
@property (nonatomic,nullable,strong) UILongPressGestureRecognizer *longPressMoving;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    [self loadDatas];

}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        _collectionView                     = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    }
    return _collectionView;
}

- (NSMutableArray<CYPhoto *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

/**
 初始化 UI
 */
- (void) setup {
    
    [self.view addSubview:self.collectionView];
    
    CGFloat screenW                          = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemW                            = (screenW - 3*itemMarigin)/4;
    CGFloat itemH                            = itemW;
    self.itemSize                            = CGSizeMake(itemW, itemH);
    
    self.collectionView.alwaysBounceVertical = YES;

    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CYCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CYCollectionViewCell"];
    self.collectionView.delegate        = self;
    self.collectionView.dataSource      = self;
    
    
    self.longPressMoving = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    [self.collectionView addGestureRecognizer:self.longPressMoving];
    
}

- (void) loadDatas {

    CYPhoto *photo = [[CYPhoto alloc] init];
    photo.type  = CYPhotoAssetTypeAdd;
    photo.image = [UIImage imageNamed:@"hubs_uploadImage"];
    [self.dataArray addObject:photo];
    [self.collectionView reloadData];
    
}

/**
 长按拖拽手势
 */
- (void) lonePressMoving:(UILongPressGestureRecognizer *)longPressMoving {
    
    
    // 加号按钮禁止拖动
    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[self.longPressMoving locationInView:self.collectionView]];
    
    switch (self.longPressMoving.state) {
            
    case UIGestureRecognizerStateBegan:
        {
            
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
        }
            
            break;
        
    case UIGestureRecognizerStateChanged:
        {
            [self.collectionView updateInteractiveMovementTargetPosition:[self.longPressMoving locationInView:self.collectionView]];
        }
        
            break;
    case UIGestureRecognizerStateEnded :
        {
            [self.collectionView endInteractiveMovement];
        }
        
            break;
    default:
        {
            [self.collectionView cancelInteractiveMovement];
        }
        
            break;
    }
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataArray.count >= 10) {
        return 9;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYCollectionViewCell" forIndexPath:indexPath];
    cell.delegate              = self;
    CYPhoto *photo             = [self.dataArray objectAtIndex:indexPath.item];
    cell.deleteButton.hidden   = (photo.type == CYPhotoAssetTypeAdd);
    
   
     if (photo.type == CYPhotoAssetTypeAdd) {
     
         cell.imageView.image = photo.image;
     
     } else {
     
         if (photo.image != nil) {
             
             cell.imageView.image = photo.image;
             
         } else  {
             
             PHImageManager *imageManager       = [PHImageManager defaultManager];
              [imageManager requestImageForAsset:photo.asset targetSize:CGSizeMake(200.0f, 200.0f) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                  cell.imageView.image = image;
              }];
             
         }
     
     }
  
    return cell;
    
}

/**
 检查需要几张上传的图片
 */
- (NSInteger) getNeedsImageCount {
    
    CYPhoto *photos = [self.dataArray lastObject];
    if (photos != nil) {
        if (photos.type == CYPhotoAssetTypeAdd) {
            return 10 - self.dataArray.count;
        }
    }
    
    return 0;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CYPhoto *photo          = [self.dataArray objectAtIndex:indexPath.item];
    if (photo.type == CYPhotoAssetTypePhoto) return;
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    __weak typeof(self)weakSelf = self;
    [controller addAction:[UIAlertAction actionWithTitle:@"从手机选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        CYPhotoNavigationController *cyPhotoNav = [CYPhotoNavigationController showPhotosViewController];
        cyPhotoNav.maxPickerImageCount = [strongSelf getNeedsImageCount];
        cyPhotoNav.delegate    = strongSelf;
        [strongSelf presentViewController:cyPhotoNav animated:YES completion:nil];
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate      = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType    = UIImagePickerControllerSourceTypeCamera;
            [strongSelf presentViewController:imagePickerController animated:YES completion:nil];

        } else {
            printf("打开相机失败");
        }

    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}



#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20.0f, 0.0f, itemMarigin, 0.0f);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return itemMarigin;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return itemMarigin;
}

#pragma mark - CYPhotoNavigationControllerDelegate

- (void)cyPhotoNavigationController:(CYPhotoNavigationController *)controller didFinishedSelectPhotos:(NSArray<CYPhotosAsset *> *)result {
    
    NSMutableArray *array   = [NSMutableArray array];
    for (CYPhotosAsset *photoAsset in result) {
        
        CYPhoto *photo    = [[CYPhoto alloc] init];
        photo.type        = CYPhotoAssetTypePhoto;
        photo.image       = nil;
        photo.photosAsset = photoAsset;
        [array addObject:photo];
    }
    
    NSIndexSet *idnexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
    [self.dataArray insertObjects:array atIndexes:idnexSet];
    
    if (self.dataArray.count >=10) {
        [self.dataArray removeLastObject];
    }
    
    [self.collectionView reloadData];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage  *editedImage           = info[@"UIImagePickerControllerEditedImage"];
    CYPhotosAsset *photpAsset       = [[CYPhotosAsset alloc] init];
    photpAsset.originalImg          = editedImage;
    
    CYPhoto *photo                  = [[CYPhoto alloc] init];
    photo.image                     = editedImage;
    photo.type                      = CYPhotoAssetTypePhoto;
    photo.photosAsset               = photpAsset;
    
    CYPhoto *lastPhoto              = [self.dataArray lastObject];
    
    if (lastPhoto.type == CYPhotoAssetTypeAdd) {
        
        [self.dataArray removeLastObject];
        [self.dataArray addObject:photo];
        [self loadDatas];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[self.longPressMoving locationInView:self.collectionView]];
    if (!selectIndexPath) return;
    
//    self.dataSource.exchangeObject(at: ((sourceIndexPath as NSIndexPath).item), withObjectAt: (destinationIndexPath as NSIndexPath).item)
    
    [self.dataArray exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
    
    // 如果数组里最后一个元素不是 添加图片的按钮 就重新排序

    [self.dataArray sortUsingComparator:^NSComparisonResult(CYPhoto  *obj1, CYPhoto  *obj2) {
        NSString *typ1   = [NSString stringWithFormat:@"%zd",obj1.type];
        NSString *typ2   = [NSString stringWithFormat:@"%zd",obj2.type];
        return [typ2 compare:typ1];
 
    }];
    
    [self.collectionView reloadData];

    
}

/**
 *  点击了删除按钮
 */
- (void)bkCollectionViewCellDidSelectDelegateButton:(CYCollectionViewCell *_Nullable)cell {
    
    NSIndexPath *indexPath  = [self.collectionView indexPathForCell:cell];
    
    [self.dataArray removeObjectAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    CYPhoto *lastPhotot = [self.dataArray lastObject];
    
    if (lastPhotot.type != CYPhotoAssetTypeAdd) {
        
        CYPhoto *photo   = [[CYPhoto alloc] init];
        photo.type  = CYPhotoAssetTypeAdd;
        photo.image = [UIImage imageNamed:@"hubs_uploadImage"];
        [self.dataArray addObject:photo];
        [self.collectionView reloadData];
        
    }

    
}

@end
