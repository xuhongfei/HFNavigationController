//
//  HFNavigationController.m
//  HFNavigationController
//
//  Created by xhf on 16/5/11.
//  Copyright © 2016年 xuhongfei. All rights reserved.
//

#import "HFNavigationController.h"
#import "AppDelegate.h"


#define HF_KEY_WINDOW  ((AppDelegate *)[UIApplication sharedApplication].delegate).window
#define HF_TOP_VIEW  ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController.view
#define HF_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface HFNavigationController () <UIGestureRecognizerDelegate>
{
    CGPoint startTouch;
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *screenShotsList;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation HFNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.screenShotsList = [NSMutableArray arrayWithCapacity:0];
        self.canInteractive = YES;
        self.popAnimationType = PopAnimationTypeLiner;
        self.navigationBar.translucent = false;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer *screenEdgePanGP = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    screenEdgePanGP.edges = UIRectEdgeLeft;
    screenEdgePanGP.delegate = self;
    [self.view addGestureRecognizer:screenEdgePanGP];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.screenShotsList.count == 0) {
        UIImage *capturedImage = [self capture];
        if (capturedImage) {
            [self.screenShotsList addObject:capturedImage];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.screenShotsList = nil;
    self.backgroundView = nil;
}

#pragma mark - Get Set
- (void)setPopAnimationType:(PopAnimationType)popAnimationType
{
    _popAnimationType = popAnimationType;
}

#pragma mark -
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage *capturedImage = [self capture];
    if (capturedImage) {
        [self.screenShotsList addObject:capturedImage];
    }
    
    if (self.viewControllers.count) {
        viewController.navigationItem.leftBarButtonItem = [self itemWithImage:@"tab_return" higlightedImage:@"tab_return" target:self action:@selector(back)];
    }
    
    if (self.viewControllers.count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)back
{
    [self popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)itemWithImage:(NSString *)image higlightedImage:(NSString *)higlightedImage  target:(id)target action:(SEL)action
{
    // 1.创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 2.设置按钮背景图片
    UIImage *normal = [UIImage imageNamed:image];
    [btn setBackgroundImage:normal forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:higlightedImage] forState:UIControlStateHighlighted];
    
    // 3.设置按钮的尺寸
    btn.bounds = CGRectMake(0, 0, 24, 24);
    
    // 4.监听按钮点击
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    // 5.返回创建好的item
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated: animated];
}

#pragma mark -
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(HF_TOP_VIEW.bounds.size, HF_TOP_VIEW.opaque, 0.0);
    [HF_TOP_VIEW.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


#pragma mark -
- (void)panGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canInteractive) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:HF_KEY_WINDOW];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = HF_TOP_VIEW.frame;
            self.backgroundView = [[UIView alloc]init];
            CGRect backgroundViewFrame = CGRectMake(0, 0, frame.size.width , frame.size.height);
            self.backgroundView.frame = backgroundViewFrame;
            self.backgroundView.backgroundColor = [UIColor whiteColor];
            [HF_TOP_VIEW.superview insertSubview:self.backgroundView belowSubview:HF_TOP_VIEW];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > HF_SCREEN_WIDTH * .4f)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX: HF_SCREEN_WIDTH];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = HF_TOP_VIEW.frame;
                frame.origin.x = 0;
                HF_TOP_VIEW.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
                
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    NSLog(@"Move to:%f",x);
    x = x > HF_SCREEN_WIDTH ? HF_SCREEN_WIDTH : x;
    x = x < 0 ? 0 : x;
    
    CGRect frame = HF_TOP_VIEW.frame;
    frame.origin.x = x;
    HF_TOP_VIEW.frame = frame;
    
    float alpha = 0.5 - (x / HF_SCREEN_WIDTH * .5f);
    float scale = (x / HF_SCREEN_WIDTH * 0.05) + 0.95;

    switch (self.popAnimationType) {
        case PopAnimationTypeLiner:
            lastScreenShotView.transform = CGAffineTransformMakeTranslation( x / 2.f - lastScreenShotView.center.x, 0);
            break;
        case PopAnimationTypeScale:
            lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
            break;
        default:
            break;
    }
    

    blackMask.alpha = alpha;
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.viewControllers.count > 1 && self.canInteractive ? YES : NO;
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
