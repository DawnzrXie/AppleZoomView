//
//  DawnXZRzoomView.m
//  AppleZoomView
//
//  Created by dawn_xzr on 2019/9/17.
//  Copyright © 2019 tttt. All rights reserved.
//

#import "DawnXZRzoomView.h"



@interface DawnXZRzoomView ()


@property (nonatomic, strong) UILabel *multipleLabel; //显示倍数的控件

@property (nonatomic, strong) UIView *bigRoundView; //大圆背景圆

@property (nonatomic, strong) UIView *smallRoundBGView; //小圆点父视图

@property (nonatomic, strong) NSMutableArray *subViewArray; ///小圆点数组

@property (nonatomic, strong) NSArray *pointArray; //小圆点的中心坐标数组

@property (nonatomic, assign) CGPoint beginPoint;//第一触碰点

@property (nonatomic, assign) CGPoint movePoint;//第二触碰点


@property (nonatomic, assign) CGFloat margin; //内外圆间距

@property (nonatomic, assign) int number; //小点的数量

@property (nonatomic, assign) CGFloat radius; //外圆半径

@property (nonatomic, assign) CGPoint roundCenterPoint;//圆心坐标

@property (nonatomic, assign) CGFloat startAngle; //第一个小圆点初始点的角度

@property (nonatomic, strong) NSTimer *drawTimer; //绘制的计时器

@property (nonatomic, assign) CGFloat drawTime; //绘制的当前时间

@property (nonatomic, assign) CGFloat zoomTotalTime; //动画的时间

@property (nonatomic, assign) CGFloat subViewAngle; //小圆点占的总角度

@property (nonatomic, assign) BOOL isBeginTouch; //是开始点击

@property (nonatomic, assign) CGFloat temPanAngle; //上一次滑动的角度

@end

@implementation DawnXZRzoomView

- (instancetype)initWithBottom:(CGFloat)bottom margin:(CGFloat)margin number:(int)number{
    
    if (self = [super initWithFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_WIDTH/3-bottom, SCREEN_WIDTH, SCREEN_WIDTH/3+bottom)]) {
        self.margin = margin;
        self.number = number;
        self.roundCenterPoint = CGPointMake(SCREEN_WIDTH/2, 13*SCREEN_WIDTH/24);
        self.radius = 13*SCREEN_WIDTH/24 - SCREEN_WIDTH/3;
        self.zoomTotalTime = 0.1;
        self.subViewAngle = M_PI_2;
        self.startAngle = M_PI_2;
        self.backgroundColor = [UIColor clearColor];
        [self configurationUI];
        self.hidden = YES;
    }
    return self;
}


- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)configurationUI {
    
    //加转动手势
    UIPanGestureRecognizer *pgr =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhuanPgr:)];
    [self addGestureRecognizer:pgr];
    
    self.layer.masksToBounds = YES;
    self.bigRoundView = [[UIView alloc] init];
    self.bigRoundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self addSubview:self.bigRoundView];
    
    self.smallRoundBGView = [[UIView alloc] init];
    [self addSubview:self.smallRoundBGView];
    
    [self.bigRoundView addSubview:self.multipleLabel];
    
    
    
    
    for (int i=0; i<self.number; i++) {
        
        if (i==0 || i==27) {
            UILabel *zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            zoomLabel.textColor = [UIColor whiteColor];
            zoomLabel.font = [UIFont systemFontOfSize:13];
            if (i == 0) {
                zoomLabel.textAlignment = NSTextAlignmentLeft;
                zoomLabel.text = @"1x";
            } else {
                zoomLabel.textAlignment = NSTextAlignmentRight;
                zoomLabel.text = @"7x";
            }
            [self.smallRoundBGView addSubview:zoomLabel];
            [self.subViewArray addObject:zoomLabel];
        } else {
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
            subView.backgroundColor = [UIColor whiteColor];
            subView.layer.cornerRadius = 2;
            subView.layer.masksToBounds = YES;
            [self.smallRoundBGView addSubview:subView];
            [self.subViewArray addObject:subView];
        }
        
        
    }
    
    [self refreshUI];
}

#pragma mark -- 刷新UI
- (void)refreshUI
{
    
    //大圆
    self.bigRoundView.frame = CGRectMake(0, 0, 2*self.radius, 2*self.radius);
    self.bigRoundView.center = self.roundCenterPoint;
    self.bigRoundView.layer.cornerRadius = self.radius;
    self.bigRoundView.layer.masksToBounds = YES;
    self.bigRoundView.layer.borderWidth = 1;
    self.bigRoundView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    
    //小圆点背景
    self.smallRoundBGView.frame = CGRectMake(0, 0, 2*self.radius, 2*self.radius);
    self.smallRoundBGView.center = self.roundCenterPoint;
    
    
    //显示倍数的label
    self.multipleLabel.center = CGPointMake(self.radius, self.margin);
    
    self.pointArray = [self creatPointArrayWithPoint:self.roundCenterPoint r:self.radius-self.margin];
    
    for (int i=0; i<self.pointArray.count; i++) {
        CGPoint newPoint = CGPointFromString(self.pointArray[i]);
        if (i==0 || i==27) {
            UILabel *zoomLabel = self.subViewArray[i];
            zoomLabel.center = newPoint;
        } else {
            UIView *subView = self.subViewArray[i];
            subView.center = newPoint;
        }
    }
    
}


#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr
{
    
    if(pgr.state==UIGestureRecognizerStateBegan){
        
        self.beginPoint=[pgr locationInView:self];
        self.isBeginTouch = YES;
        if (self.isPanBlock) {
            self.isPanBlock(YES);
        }
    }else if (pgr.state==UIGestureRecognizerStateChanged){
        self.movePoint= [pgr locationInView:self];
        
        [self scrollowRadius];
    }else if (pgr.state==UIGestureRecognizerStateEnded){
        
        if (self.isPanBlock) {
            self.isPanBlock(NO);
        }
        [self scrollowRadius];
    }
}

#pragma mark -- 移动小点
- (void)scrollowRadius {
    
    CGFloat beginAngle = 0;
    if (self.beginPoint.x <SCREEN_WIDTH/2) {
        beginAngle = atan((self.radius-self.beginPoint.y)/(SCREEN_WIDTH/2-self.beginPoint.x));
    } else {
        beginAngle = M_PI - atan((self.radius-self.beginPoint.y)/(self.beginPoint.x-SCREEN_WIDTH/2));
    }
    
    CGFloat moveAngle = 0;
    if (self.movePoint.x <SCREEN_WIDTH/2) {
        moveAngle = atan((self.radius-self.movePoint.y)/(SCREEN_WIDTH/2-self.movePoint.x));
    } else {
        moveAngle = M_PI - atan((self.radius-self.movePoint.y)/(self.movePoint.x-SCREEN_WIDTH/2));
    }
    CGFloat moveX = self.movePoint.x-self.beginPoint.x;
    
    
    CGFloat angle = moveAngle - beginAngle;
    
    if (!self.isBeginTouch) {
        self.startAngle -= self.temPanAngle;
    }
    self.startAngle += angle;
    self.temPanAngle = angle;
    self.isBeginTouch = NO;

    NSLog(@"beginAngle= %f moveAngle= %f moveX=%f",beginAngle,moveAngle,M_PI_2*moveX/SCREEN_WIDTH);
    
    if (self.startAngle<0) {
        self.startAngle = 0;
    }
    if (self.startAngle > M_PI_2) {
        self.startAngle = M_PI_2;
    }
    NSLog(@"self.startAngle = %f",self.startAngle);
    self.pointArray = [self creatPointArrayWithPoint:self.roundCenterPoint r:self.radius-self.margin];
    for (int i=0; i<self.pointArray.count; i++) {
        
        CGPoint newPoint = CGPointFromString(self.pointArray[i]);
        UIView *subView = self.subViewArray[i];
        subView.center = newPoint;
    }
    
    NSInteger zoom = (self.subViewAngle - self.startAngle)/(self.subViewAngle/6)+1;
    self.multipleLabel.text = [NSString stringWithFormat:@"%ldx",(long)zoom];
    
    if (self.currentZoom) {
        self.currentZoom(zoom);
    }
}

#pragma mark -- 按步骤刷新

//开始动画
- (void)startZoomScaleViewWithScaleNum:(NSInteger)scaleNum {
    self.startAngle = self.subViewAngle-(scaleNum-1)*self.subViewAngle/6;
    self.pointArray = [self creatPointArrayWithPoint:self.roundCenterPoint r:self.radius-self.margin];
    for (int i=0; i<self.pointArray.count; i++) {
        
        CGPoint newPoint = CGPointFromString(self.pointArray[i]);
        UIView *subView = self.subViewArray[i];
        subView.center = newPoint;
    }
    
    self.multipleLabel.text = [NSString stringWithFormat:@"%ldx",(long)scaleNum];
    
    
    //    type == AUTZOOM_TYPE_START
    self.userInteractionEnabled = NO;
    self.radius = 13*SCREEN_WIDTH/24 - SCREEN_WIDTH/3;
    [self addShowDrawTimer];
    self.hidden = NO;
}

//动画消失
- (void)refreshUIWithZoomDismiss {
    
    //        AUTZOOM_TYPE_END
    self.userInteractionEnabled = NO;
    self.radius = 13*SCREEN_WIDTH/24;
    [self addDismissDrawTimer];
    self.hidden = YES;
}

// 添加定时器
- (void)addShowDrawTimer
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 长连接定时器
        self.drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawShowBezier) userInfo:nil repeats:YES];
        //把定时器添加到当前运行循环,并且调为通用模式
        [[NSRunLoop currentRunLoop] addTimer:self.drawTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
        
    });
}

- (void)addDismissDrawTimer
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 长连接定时器
        self.drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawDissmissBezier) userInfo:nil repeats:YES];
        //把定时器添加到当前运行循环,并且调为通用模式
        [[NSRunLoop currentRunLoop] addTimer:self.drawTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
    
    
}

- (void)drawShowBezier
{
    [self drawBezier:YES];
}

- (void)drawDissmissBezier
{
    [self drawBezier:NO];
}


- (void)drawBezier:(BOOL)isShow {
    
    if (self.drawTimer == nil) {
        return;
    }
    self.drawTime += 0.01;
    if (self.drawTime <= self.zoomTotalTime) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isShow) {
                self.radius +=  (SCREEN_WIDTH/3)*0.01/self.zoomTotalTime;
            } else {
                self.radius -=  (SCREEN_WIDTH/3)*0.01/self.zoomTotalTime;
            }
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.smallRoundBGView.bounds];
            UIBezierPath * pathCircle =[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.radius, self.margin) radius:17 startAngle:0 endAngle:2*M_PI clockwise:NO];
            [path appendPath:pathCircle];
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.path = path.CGPath;
            self.smallRoundBGView.layer.mask = shapeLayer;
            [self refreshUI];
        });
    } else {
        
        [self.drawTimer invalidate];
        self.drawTimer = nil;
        self.drawTime = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
            if (!isShow&&self.dismissEndBlock) {
                self.dismissEndBlock();
            }
            if (isShow&&self.startEndBlock) {
                self.startEndBlock();
            }
            
        });
        
    }
}


#pragma mark -- 小圆点的坐标数组
- (NSArray *)creatPointArrayWithPoint:(CGPoint)point r:(CGFloat)r {
    
    NSMutableArray *array = [NSMutableArray array];
    //        CGFloat f = M_PI*2/(number-1);
    CGFloat f = self.subViewAngle/(self.number-1);
    for (int i = 0; i < self.number; i ++) {
        
        CGFloat angle  = self.startAngle + f*i;
        
        CGFloat y = 0;
        CGFloat x = 0;
        
        
        if (angle <=M_PI_2 && angle >= 0) {
            y = self.radius - r*sin(angle);
            x = self.radius - r *cos(angle);
        } else if (angle >M_PI_2 && angle <= M_PI) {
            y = self.radius - r*sin(M_PI-angle);
            x = self.radius + r *cos(M_PI-angle);
        } else if (angle > M_PI && angle < angle <= M_PI*2/3) {
            y = self.radius + r*sin(angle-M_PI);
            x = self.radius + r*cos(angle-M_PI);
        } else if (angle > -M_PI_2 && angle < 0) {
            y = self.radius + r*cos(angle);
            x = self.radius - r*sin(angle);
        }
        
        CGPoint newPoint = CGPointMake(x, y);
        NSString *pointStr = NSStringFromCGPoint(newPoint);
        [array addObject:pointStr];
    }
    return array;
}






#pragma mark -- 旋转
- (void)transformAngle:(float)angle {
    UILabel *startLabel = self.subViewArray[0];
    UILabel *endLabel = self.subViewArray[self.subViewArray.count-1];
    self.multipleLabel.transform = CGAffineTransformMakeRotation(angle);
    startLabel.transform = CGAffineTransformMakeRotation(angle);
    endLabel.transform = CGAffineTransformMakeRotation(angle);
    
}



#pragma mark -- getter
- (NSMutableArray *)subViewArray{
    if (!_subViewArray) {
        _subViewArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _subViewArray;
}

- (UILabel *)multipleLabel {
    if (!_multipleLabel) {
        _multipleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        _multipleLabel.textColor = [UIColor whiteColor];
        _multipleLabel.textAlignment = NSTextAlignmentCenter;
        _multipleLabel.font = [UIFont systemFontOfSize:14];
        _multipleLabel.layer.cornerRadius = 17;
        _multipleLabel.layer.borderWidth = 1;
        _multipleLabel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        _multipleLabel.layer.masksToBounds = YES;
        _multipleLabel.text = @"1x";
        
    }
    return _multipleLabel;
}

@end
