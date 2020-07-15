//
//  WJPhotoTools.h
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "WJPhotoAlbumModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WJPhotoTools : NSObject
+ (NSString*) hhmmssWithCount:(NSInteger) secCount;
+ (NSArray*) getClusYearAlbum;
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *image, NSDictionary *info))completion;
@end

NS_ASSUME_NONNULL_END
