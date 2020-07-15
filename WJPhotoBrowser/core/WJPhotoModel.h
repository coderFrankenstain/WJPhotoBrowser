//
//  WJPhotoModel.h
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//
typedef enum {
  WJMediaTypeImage = 1,
  WJMediaTypeVedio,
  WJMediaTypeDefault,
}WJMediaType;

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJPhotoModel : NSObject
@property(strong,nonatomic) PHAsset* asset;
@property(assign,nonatomic) WJMediaType mediaType;
//If is video
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong) UIImage *image;
// init func
+ (instancetype) modelWithPHAsset:(PHAsset*) asset;
@end

NS_ASSUME_NONNULL_END
