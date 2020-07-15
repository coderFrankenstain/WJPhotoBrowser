//
//  WJCollectionViewCell.h
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoModel.h"
#import "WJPhotoTools.h"
NS_ASSUME_NONNULL_BEGIN

@interface WJCollectionViewCell : UICollectionViewCell
@property(strong,nonatomic) WJPhotoModel* model;
@property(strong,nonatomic) UIButton* selectButton;
+ (instancetype) cellWithCollectionView:(UICollectionView*) collectionView andIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
