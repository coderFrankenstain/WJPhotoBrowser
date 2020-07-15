//
//  MainViewController.m
//  WJPhotoBrowser
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 mac. All rights reserved.
//

#import "MainViewController.h"
#import "WJPhotoAlbumModel.h"
#import "WJPhotoTools.h"
#import "WJCollectionViewCell.h"
#import "WJPhotoModel.h"
#define collectionMaxCount 4
#define kScreen_Width  [[UIScreen mainScreen] bounds].size.width
#define kScreen_Height [[UIScreen mainScreen] bounds].size.height
#define RGB(A,B,C) [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]

typedef NS_ENUM(NSUInteger, SlideSelectType) {
    SlideSelectTypeNone,
    SlideSelectTypeSelect,
    SlideSelectTypeCancel,
};

@interface MainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic) UICollectionView* collectionView;
@property(strong,nonatomic) NSArray* dataArray;

/**所有滑动经过的indexPath*/
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *arrSlideIndexPath;
/**所有滑动经过的indexPath的初始选择状态*/
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicOriSelectStatus;

@property (nonatomic, strong) NSMutableArray* arrSelectedModels;


@end

@implementation MainViewController
{
    BOOL _beginSelect;
       NSIndexPath* _beginSlideIndexPath;
       SlideSelectType _selectType;
       /**最后滑动经过的index，开始的indexPath不计入，优化拖动手势计算，避免单个cell中冗余计算多次*/
       NSInteger _lastSlideIndex;
}

- (NSMutableArray<NSIndexPath *> *)arrSlideIndexPath
{
    if (!_arrSlideIndexPath) {
        _arrSlideIndexPath = [NSMutableArray array];
    }
    return _arrSlideIndexPath;
}

- (NSMutableArray*) arrSelectedModels {
    
    if (_arrSelectedModels == nil) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dicOriSelectStatus
{
    if (!_dicOriSelectStatus) {
        _dicOriSelectStatus = [NSMutableDictionary dictionary];
    }
    return _dicOriSelectStatus;
}


- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [WJPhotoTools getClusYearAlbum];
    [self setupCollectionView];
    
    //添加滑动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    WJCollectionViewCell *cell = (WJCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];

    if (pan.state == UIGestureRecognizerStateBegan) {
        
        if (!indexPath) {
            _beginSelect = NO;
        }
        else {
            _beginSelect = YES;
        }
        
        if (_beginSelect) {
            WJPhotoModel* m = [self modelWithIndex:indexPath];
            _selectType = m.isSelected ? SlideSelectTypeCancel : SlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected) {
                m.selected = YES;
                [self.arrSelectedModels addObject:m];
            }
            else {
                m.selected = NO;
                for (WJPhotoModel *sm in self.arrSelectedModels) {
                    if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                        [self.arrSelectedModels removeObject:sm];
                        break;
                    }
                }
            }
            WJCollectionViewCell *c = (WJCollectionViewCell *)cell;
            c.selectButton.selected = m.isSelected;
        }
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {

    
//         //根据section 和 row 计算cell所在的真实位置
        NSInteger currentIndex = [self orderIndexWithIndexPath:indexPath];
        if (!_beginSelect ||!indexPath ||currentIndex == _lastSlideIndex ||_selectType == SlideSelectTypeNone)
            return;
        //防止重复计算
        _lastSlideIndex = currentIndex;
        //将section 和 row 转化为 一个值进行计算
        NSInteger beginIndex = [self orderIndexWithIndexPath:_beginSlideIndexPath];
        NSInteger minIndex = MIN(currentIndex, beginIndex);
        NSInteger maxIndex = MAX(currentIndex, beginIndex);
//        NSLog(@"current %ld begin %ld ",currentIndex,beginIndex);

        BOOL minIsBegin = minIndex == beginIndex;
        //计算选中区域内的indexPath
        for (NSInteger i = beginIndex; minIsBegin ? i <= maxIndex:i>=minIndex; minIsBegin ? i++ : i--) {
            if(i == beginIndex) continue; //保证不为0 保证不越界
            
            //根据index算出真实的row和path
            NSIndexPath *p = [self indexPathWithIndex:i];


            if (![self.arrSlideIndexPath containsObject:p]) {
                //P有可能不存在 还是放入到数组中 之后再进行判断
                [self.arrSlideIndexPath addObject:p];
                WJPhotoModel *m = [self modelWithIndex:indexPath];
                [self.dicOriSelectStatus setValue:@(m.isSelected) forKey:@(i).stringValue];

            }
        }
        //根据选中区域内的数组 进行Model选取

        for (NSIndexPath* path in self.arrSlideIndexPath) {

            NSInteger index = [self orderIndexWithIndexPath:path];
            //有可能先滑到大的index 并且记录下来 在滑到小的index，所以存在选中index数组中的indexPath 不在区间内 所以要判断inSection
            BOOL inSection = index >= minIndex && index <= maxIndex;
            //这里取Model 由于上面的indexPath 有可能不存在 所以这里取出来的model 会有nil
            WJPhotoModel *m = [self modelWithIndex:path];
            //如果model为nil 结束后面的操作
            if (m == nil) {
                continue;
            }
            //_selectType 表明开始操作的状态 到底是选中 还是取消选中
            switch (_selectType) {
                    //开始为选中状态 则之后的都是选中状态
               case SlideSelectTypeSelect: {
                   if (inSection &&
                       !m.isSelected) {
                       m.selected = YES;
                   }
               }
                   break;
                    //开始为取消选中 则之后都是取消选中状态
               case SlideSelectTypeCancel: {
                   if (inSection) m.selected = NO;
               }
                   break;
                    
               default:
                   break;
            }
               if (!inSection) {
                   //未在区间内的model还原为初始选择状态
                  m.selected = [self.dicOriSelectStatus[@([self orderIndexWithIndexPath:path]).stringValue] boolValue];
            }
            
            //判断当前model是否已存在于已选择数组中
               BOOL flag = NO;
               NSMutableArray *arrDel = [NSMutableArray array];
               for (WJPhotoModel *sm in self.arrSelectedModels) {
                   if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                       if (!m.isSelected) {
                           [arrDel addObject:sm];
                       }
                       flag = YES;
                       break;
                   }
               }
               
               [self.arrSelectedModels removeObjectsInArray:arrDel];
               
               if (!flag && m.isSelected) {
                   [self.arrSelectedModels addObject:m];
               }

               WJCollectionViewCell *c = (WJCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:path];
               c.selectButton.selected = m.isSelected;
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        _selectType = SlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
//        [self resetBottomBtnsStatus:YES];
    }
}


- (void) setupCollectionView {
    
   UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = MIN(kScreen_Width, kScreen_Height);
    
    NSInteger columnCount;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        columnCount = 6;
    } else {
        columnCount = collectionMaxCount;
    }
    
    layout.itemSize = CGSizeMake((width-1.5*columnCount)/columnCount, (width-1.5*columnCount)/columnCount);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    layout.headerReferenceSize = CGSizeMake(kScreen_Width, 40);
    layout.sectionHeadersPinToVisibleBounds = YES;

    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,kScreen_Width, kScreen_Height) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[WJCollectionViewCell class] forCellWithReuseIdentifier:@"myCollectionCell"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (WJPhotoModel*) modelWithIndex:(NSIndexPath*) indexPath {
    WJPhotoAlbumModel* album = [self.dataArray objectAtIndex:indexPath.section];
    if (indexPath.row >= album.assetsArray.count) {
        return nil;
    }
    WJPhotoModel* model = [album.assetsArray objectAtIndex:indexPath.row];
    return model;
}

//将indexPath里面的row和section 转化为递增的数据
- (NSInteger) orderIndexWithIndexPath:(NSIndexPath*) path{
    
    NSInteger sectionConout = 0;
    for (int i = 0; i < path.section; i++) {
        WJPhotoAlbumModel* model = self.dataArray[i];
        sectionConout += model.assetsArray.count;
    }
    return path.row + sectionConout;
}

- (NSIndexPath*) indexPathWithIndex:(NSInteger) index {

    NSInteger division = 0;
    NSInteger res = index;
    NSInteger count = 0;
//    NSLog(@"index %ld",index);

    for(int i = 0; i < self.dataArray.count;i++){  // 2 1 1 3
        WJPhotoAlbumModel* model = self.dataArray[i];
        count += model.assetsArray.count;
        if (index >= count) {
            //大于之前的和  则跳转到下一个section
            division++;
        }
        else {  //小于等于之前的和 则算出之前的section有多少 在求出row  并且终止循环
            NSInteger sum = count - model.assetsArray.count;
            res = index - sum;
            break;
        }
    }
    NSIndexPath* path = [NSIndexPath indexPathForRow:res inSection:division];
//    NSLog(@"res %ld",res);
//    NSLog(@"over");

    return path;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    WJPhotoAlbumModel* model = self.dataArray[section];
    return model.assetsArray.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}


-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    WJCollectionViewCell*  cell = [WJCollectionViewCell cellWithCollectionView:collectionView andIndexPath:indexPath];
    WJPhotoModel* model = [self modelWithIndex:indexPath];
    [cell setModel:model];
    
    return cell;
    
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    PHAsset* asset = self.dataArray[indexPath.row];
//    detailViewController* detailVc = [[detailViewController alloc] init];
//    detailVc.asset = asset;
//    [self.navigationController pushViewController:detailVc animated:YES];
    
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
         reusableview = headerView;
    }
    
    for (UIView* view in reusableview.subviews) {
        [view removeFromSuperview];
    }
    
    WJPhotoAlbumModel* model = self.dataArray[indexPath.section];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    label.text = model.name;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textColor = RGB(144,144,144);
    [reusableview addSubview:label];
    reusableview.backgroundColor = self.view.backgroundColor;
    return reusableview;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
