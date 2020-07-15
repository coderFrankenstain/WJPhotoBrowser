//
//  WJPhotoTools.m
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import "WJPhotoTools.h"

@implementation WJPhotoTools

+ (NSString*) hhmmssWithCount:(NSInteger) secCount{
    

    NSString *tmphh = [NSString stringWithFormat:@"%ld",secCount/3600];
    if ([tmphh length] == 1)
    {
        tmphh = [NSString stringWithFormat:@"0%@",tmphh];
    }
    
    NSString *tmpmm = [NSString stringWithFormat:@"%ld",(secCount/60)%60];
    if ([tmpmm length] == 1)
    {
        tmpmm = [NSString stringWithFormat:@"0%@",tmpmm];
    }
    NSString *tmpss = [NSString stringWithFormat:@"%ld",secCount%60];
    if ([tmpss length] == 1)
    {
        tmpss = [NSString stringWithFormat:@"0%@",tmpss];
    }
    NSString* timeString = [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
    return timeString;
//        self.contractions.FrequencyStr = [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
//        self.frequencyLabel.text = self.contractions.FrequencyStr;
}


+ (NSArray*) getClusYearAlbum {
    
    NSMutableArray* momentArray = [NSMutableArray array];
    
    PHFetchOptions *momentOptions = [[PHFetchOptions alloc]init];
    momentOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];


    PHFetchResult* collectionList = [PHCollectionList  fetchCollectionListsWithType:PHCollectionListTypeMomentList subtype:PHCollectionListSubtypeMomentListCluster options:momentOptions];
    [collectionList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //创建一个时刻存放数组
        PHCollectionList* momentList = (PHCollectionList*) obj;
        NSMutableArray* dayArray = [NSMutableArray array];
        
        //获取时刻里面的Asset集合
        PHFetchResult<PHAssetCollection*>* result = [PHAssetCollection fetchMomentsInMomentList:momentList options:momentOptions];
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollection* collection = (PHAssetCollection*) obj;
            //设置筛选条件
            PHFetchOptions *asstsOptions = [[PHFetchOptions alloc]init];
            asstsOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            //获取Asset集合里面的Asset
            PHFetchResult<PHAsset*>* assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:asstsOptions];
            
            //遍历获取Asset
            [assetResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [dayArray addObject:[WJPhotoModel modelWithPHAsset:obj]];
            }];
        }];
        if (dayArray.count > 0) {
            WJPhotoAlbumModel* album = [[WJPhotoAlbumModel alloc] init];
            album.name = [self formatWithDate:momentList.startDate];
            album.assetsArray = dayArray;
            [momentArray addObject:album];
        }
    }];
    return momentArray;
}

+ (NSString*) formatWithDate:(NSDate*) date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd"];
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    return currentDateString;
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast progressHandler:progressHandler completion:completion];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}
@end
