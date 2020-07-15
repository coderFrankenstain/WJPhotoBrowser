//
//  WJPhotoModel.m
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import "WJPhotoModel.h"

@implementation WJPhotoModel
+ (instancetype)modelWithPHAsset:(PHAsset *)asset {
    
    WJPhotoModel* model = [[WJPhotoModel alloc] init];
    model.asset = asset;
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        model.mediaType = WJMediaTypeImage;
    }
    else if (asset.mediaType == PHAssetMediaTypeVideo) {
        model.mediaType = WJMediaTypeVedio;
    }
    else {
        model.mediaType = WJMediaTypeDefault;
    }
    
    if (model.mediaType == WJMediaTypeVedio) {
        model.duration = [NSString stringWithFormat:@"%lf",asset.duration];
    }
    
    model.selected = NO;
    
    return model;
    
}
@end
