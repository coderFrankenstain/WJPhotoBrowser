//
//  WJPhotoAlbumModel.h
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJPhotoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WJPhotoAlbumModel : NSObject
@property(copy,nonatomic) NSString* name;
@property(strong,nonatomic) NSArray<WJPhotoModel*>* assetsArray;
@end

NS_ASSUME_NONNULL_END
