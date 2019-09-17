//
//  ViewController.m
//  AppleZoomView
//
//  Created by dawn_xzr on 2019/9/17.
//  Copyright © 2019 tttt. All rights reserved.
//

#import "ViewController.h"
#import "DawnXZRzoomView.h"

@interface ViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *scaleBtn; //缩放按钮

@property (nonatomic, strong) DawnXZRzoomView *zoomView; //缩放控件

@property(nonatomic, assign) int  currentScale; //当前的缩放倍数

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentScale = 1;
    [self configurationUI];
}


- (void)configurationUI {
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    CGFloat bottomView_h = ([ViewController safeAreaInset].top > 0 ? 100 : 80);
    __weak typeof(self) weakSelf = self;
    //缩放控件
    self.zoomView = [[DawnXZRzoomView alloc] initWithBottom:bottomView_h margin:30 number:28];
    [self.view addSubview:self.zoomView];
    self.zoomView.isPanBlock = ^(BOOL isPan) {
        if (isPan) { //在缩放视图上
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(zoomViewHidden) object:nil];
        } else {
            [weakSelf performSelector:@selector(zoomViewHidden) withObject:nil afterDelay:2];
            
        }
    };
    self.zoomView.currentZoom = ^(NSInteger currentScale) {
        [weakSelf scaleBtnStatus:currentScale];
    };

    
    self.scaleBtn = ({
        UIButton *scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scaleBtn.layer.cornerRadius = 17;
        scaleBtn.layer.masksToBounds = YES;
        scaleBtn.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        scaleBtn.layer.borderWidth = 1;
        scaleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [scaleBtn setTitle:@"1x" forState:UIControlStateNormal];
        [scaleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        scaleBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [scaleBtn addTarget:self action:@selector(scaleVideo) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressScale)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [scaleBtn addGestureRecognizer:longPress];
        UIPanGestureRecognizer *pgr =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhuanPgr:)];
        pgr.delegate = self;
        [scaleBtn addGestureRecognizer:pgr];
        scaleBtn.frame = CGRectMake((SCREEN_WIDTH-34)/2, SCREEN_HEIGHT-34-20-bottomView_h, 34, 34);
        
        scaleBtn;
    });
    [self.view addSubview:self.scaleBtn];

}

#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr
{
    [self.zoomView zhuanPgr:pgr];
}

//共存  A手势或者B手势 返回YES，就能共存
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)scaleBtnStatus:(NSInteger)currentScale {
    self.currentScale = (int)currentScale;
    [self.scaleBtn setTitle:[NSString stringWithFormat:@"%ldx",(long)currentScale] forState:UIControlStateNormal];

}

#pragma mark -- 缩放按钮
- (void)scaleVideo {
    
    if (self.currentScale >= 7) {
        self.currentScale = 1;
    } else {
        self.currentScale ++;
    }
    [self scaleBtnStatus:self.currentScale];
}

#pragma mark -- 缩放按钮的长按手势
- (void)longPressScale
{
    if (!self.scaleBtn.hidden) {
        [self.zoomView startZoomScaleViewWithScaleNum:self.currentScale];
    }
    self.scaleBtn.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    self.zoomView.startEndBlock = ^{
        [weakSelf performSelector:@selector(zoomViewHidden) withObject:nil afterDelay:3.0];
    };
}

- (void)zoomViewHidden
{
    [self.zoomView refreshUIWithZoomDismiss];
    __weak typeof(self) weakSelf = self;
    self.zoomView.dismissEndBlock = ^{
        weakSelf.scaleBtn.hidden = NO;
    };
}



+ (UIEdgeInsets)safeAreaInset {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (@available(iOS 11.0, *)) {
        if (keyWindow) {
            UIEdgeInsets edgeInset = keyWindow.safeAreaInsets;
            return edgeInset;
        }
    }
    return UIEdgeInsetsZero;
}
@end
