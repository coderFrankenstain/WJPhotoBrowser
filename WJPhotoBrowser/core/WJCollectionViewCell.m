//
//  WJCollectionViewCell.m
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import "WJCollectionViewCell.h"
static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}
@implementation WJCollectionViewCell
+ (instancetype) cellWithCollectionView:(UICollectionView*) collectionView andIndexPath:(NSIndexPath *)indexPath {
    
    return [[self alloc] initWithCollectionView:collectionView andIndexPath:indexPath];
}

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView andIndexPath:(NSIndexPath *)indexPath {
    
    
    WJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionCell" forIndexPath:indexPath ];
    return cell;
    
}

- (void)setModel:(WJPhotoModel *)model {
    _model = model;
    for (UIView* view in self.contentView.subviews) {
           [view removeFromSuperview];
       }
       
         UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
         imageView.contentMode = UIViewContentModeScaleAspectFill;
         imageView.layer.masksToBounds = YES;
         [self.contentView addSubview:imageView];
         [imageView setImage:[UIImage imageNamed:@"defaultImage"]];
       
       UIButton* selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-5-25, 5, 25, 25)];
       [selectButton setImage:[UIImage imageNamed:@"WJBtnUnSelected"] forState:UIControlStateNormal];
       [selectButton setImage:[UIImage imageNamed:@"WJBtnSelected"] forState:UIControlStateSelected];
       [selectButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//       [selectButton setEnlargeEdgeWithTop:5 right:20 bottom:5 left:20];
        self.selectButton = selectButton;
       [self.contentView addSubview:selectButton];
    
        selectButton.selected = model.selected;

    
       
       [WJPhotoTools requestImageForAsset:model.asset size:CGSizeMake(self.frame.size.width*2, self.frame.size.height*2) progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                  
              } completion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
                  if (model.mediaType == WJMediaTypeVedio) {
                               
                      UIImageView* videoIconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.contentView.frame.size.height-12.5
                                                                                                 -5, 16, 12.5)];
                      [videoIconView setImage:[UIImage imageNamed:@"WJVideo"]];
                      [self.contentView addSubview:videoIconView];
                      
                      UILabel* videoTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(videoIconView.frame), videoIconView.frame.origin.y, self.contentView.frame.size.width-CGRectGetMaxX(videoIconView.frame)-5, 12.5)];
                      videoTimeLabel.textAlignment = NSTextAlignmentRight;
                      videoTimeLabel.font = [UIFont systemFontOfSize:11.0f];
                      videoTimeLabel.textColor = [UIColor whiteColor];
                      videoTimeLabel.text = [WJPhotoTools hhmmssWithCount:[model.duration integerValue]];
                      [self.contentView addSubview:videoTimeLabel];
                      
               }
                          
                     [imageView setImage:image];
                  
              }];
}

- (void) buttonClick:(UIButton*) button {
    
    if (!button.selected) {
        [button.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
    
    button.selected = !button.selected;
}
@end
