//
//  DawnXZRzoomView.h
//  AppleZoomView
//
//  Created by dawn_xzr on 2019/9/17.
//  Copyright © 2019 tttt. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef enum : NSUInteger {
    DawnXZRZOOM_TYPE_START,
    DawnXZRZOOM_TYPE_ING,
    DawnXZRZOOM_TYPE_END
} DawnXZRZOOM_TYPE;


typedef void(^DawnXZRZoomViewEndBlock)(void);
typedef void(^DawnXZRZoomViewIsPanBlock)(BOOL isPan);
typedef void(^DawnXZRZoomViewScrollPanBlock)(NSInteger currentScale);

NS_ASSUME_NONNULL_BEGIN

@interface DawnXZRzoomView : UIView

@property (nonatomic, assign) DawnXZRZOOM_TYPE type;

@property (nonatomic, copy) DawnXZRZoomViewEndBlock dismissEndBlock; //视图消失结束

@property (nonatomic, copy) DawnXZRZoomViewEndBlock startEndBlock; //视图开始结束

@property (nonatomic, copy) DawnXZRZoomViewIsPanBlock isPanBlock; //手是否在视图上

@property (nonatomic, copy) DawnXZRZoomViewScrollPanBlock currentZoom; //目前缩放的倍数

- (instancetype)initWithBottom:(CGFloat)bottom margin:(CGFloat)margin number:(int)number;

#pragma mark -- 按步骤刷新
//开始动画
- (void)startZoomScaleViewWithScaleNum:(NSInteger)scaleNum;

//动画消失
- (void)refreshUIWithZoomDismiss;

#pragma mark -- 旋转
- (void)transformAngle:(float)angle;

#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr;

@end

NS_ASSUME_NONNULL_END
