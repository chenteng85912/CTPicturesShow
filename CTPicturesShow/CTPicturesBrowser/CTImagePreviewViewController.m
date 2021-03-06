//
//  ImagePreviewViewController.m
//  TYKYTwoLearnOneDo
//
//  Created by Apple on 16/7/22.
//  Copyright © 2016年 TENG. All rights reserved.
//

#import "CTImagePreviewViewController.h"
#import "CTImageScrollView.h"
#import "CTImagePath.h"


NSString *const kCTImagePreviewViewControllerIdentifier = @"kCTImagePreviewViewControllerIdentifier";

@interface CTImagePreviewViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,CTImageScrollViewDelegate>

@property (strong, nonatomic) UICollectionView *colView;
@property (strong, nonatomic) NSArray *dataArray;//图片或者网址数据
@property (strong, nonatomic) UILabel *pageNumLabel;//页码显示

@end

@implementation CTImagePreviewViewController

#pragma mark 展示图片
+ (void)showPictureWithUrlOrImages:(NSArray * __nonnull)imageArray
                withCurrentPageNum:(NSInteger)currentNum{
    
    if (imageArray.count == 0) {
        return;
    }
    
    CTImagePreviewViewController *preview = [[CTImagePreviewViewController alloc] initWithImageArray:imageArray withCurrentPageNum:currentNum];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
    
    [[self p_currentViewController] presentViewController:preview animated:YES completion:nil];
}

- (instancetype)initWithImageArray:(NSArray *__nonnull)imageArray
 withCurrentPageNum:(NSInteger)currentNum{

    self = [super init];
    if (self) {
        if (imageArray.count<currentNum+1) {
            currentNum = imageArray.count-1;
        }
        
        if (imageArray.count==1) {
            self.pageNumLabel.hidden = YES;
        }else{
            self.pageNumLabel.hidden = NO;
            
        }
        self.dataArray = imageArray;
        [self.colView reloadData];
        
        [self.colView setContentOffset:CGPointMake((kPictureBrowserScreenWidth+20)*currentNum, 0)];
        self.pageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",currentNum+1,(unsigned long)imageArray.count];
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
    
}
#pragma mark UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *mycell = [collectionView dequeueReusableCellWithReuseIdentifier:kCTImagePreviewViewControllerIdentifier forIndexPath:indexPath];
    
    [mycell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CTImageScrollView *scrView = [CTImageScrollView initWithFrame:CGRectMake(0, 0, kPictureBrowserScreenWidth, kPictureBrowserScreenHeight)
                                  image:self.dataArray[indexPath.row]];
    scrView.scrollDelegate = self;
    [mycell.contentView addSubview:scrView];

    return mycell;
}

#pragma mark 正在滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int pageNum = (scrollView.contentOffset.x - (kPictureBrowserScreenWidth+20) / 2) / (kPictureBrowserScreenWidth+20) + 1;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%d/%lu",pageNum+1,(long)self.dataArray.count];
  
}

#pragma mark CTImageScrollViewDelegate
- (void)singalTapAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}
+ (BOOL)clearLocalImages{
    NSString *imgsLocalPath = CTImagePath.documentPath;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:CTImagePath.documentPath ]){
        NSError *error;
        return [[NSFileManager defaultManager] removeItemAtPath:imgsLocalPath error:&error];
      
    }

    return YES;
}
//获取最顶部控制器
+ (UIViewController *)p_currentViewController {
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
- (UICollectionView *)colView{
    if (!_colView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kPictureBrowserScreenWidth+10, kPictureBrowserScreenHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
        UICollectionView *colView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kPictureBrowserScreenWidth+20, kPictureBrowserScreenHeight) collectionViewLayout:layout];
        colView.pagingEnabled = YES;
        colView.delegate = self;
        colView.dataSource = self;
        colView.backgroundColor= [UIColor blackColor];
        colView.directionalLockEnabled  = YES;
        colView.alwaysBounceHorizontal = YES;
        _colView = colView;
        
        [_colView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCTImagePreviewViewControllerIdentifier];
        
        [self.view addSubview:_colView];
        
    }
    return _colView;
}

- (UILabel *)pageNumLabel{
    if (!_pageNumLabel) {
        UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPictureBrowserScreenWidth/2-20, kPictureBrowserScreenHeight-60, 40, 26)];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.font = [UIFont systemFontOfSize:12];
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        pageLabel.layer.masksToBounds = YES;
        pageLabel.layer.cornerRadius = 5.0;
        _pageNumLabel = pageLabel;
        [self.colView addSubview:pageLabel];
        
    }
    
    return _pageNumLabel;
}

- (void)dealloc{
    NSLog(@"dealloc  %@",self);
}
@end
