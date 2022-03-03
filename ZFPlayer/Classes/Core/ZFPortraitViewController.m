#import "ZFPortraitViewController.h"
#import "ZFPersentInteractiveTransition.h"
#import "ZFPresentTransition.h"

@interface ZFPortraitViewController ()<UIViewControllerTransitioningDelegate,ZFPortraitOrientationDelegate>

@property (nonatomic, strong) ZFPresentTransition *transition;
@property (nonatomic, strong) ZFPersentInteractiveTransition *interactiveTransition;
@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@end

@implementation ZFPortraitViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        /*
         When the view controller’s modalPresentationStyle property is UIModalPresentationStyle.custom, UIKit uses the object in this property to facilitate transitions and presentations for the view controller. The transitioning delegate object is a custom object that you provide and that conforms to the UIViewControllerTransitioningDelegate protocol. Its job is to vend the animator objects used to animate this view controller’s view onscreen and an optional presentation controller to provide any additional chrome and animations.
         */
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        /*
         The default value of this property is false.
         When you present a view controller by calling the present(_:animated:completion:) method, status bar appearance control is transferred from the presenting to the presented view controller only if the presented controller's modalPresentationStyle value is UIModalPresentationStyle.fullScreen. By setting this property to true, you specify the presented view controller controls status bar appearance, even though presented non-fullscreen.
         The system ignores this property’s value for a view controller presented fullscreen.
         */
        self.modalPresentationCapturesStatusBarAppearance = YES;
        _statusBarStyle = UIStatusBarStyleLightContent;
        _statusBarAnimation = UIStatusBarAnimationSlide;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.fullScreenAnimation) {
        if (self.orientationWillChange) {
            self.orientationWillChange(YES);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.fullScreenAnimation) {
        self.view.alpha = 1;
        [self.view addSubview:self.contentView];
        self.contentView.frame = [self contentFullScreenRect];
        if (self.orientationDidChanged) {
            self.orientationDidChanged(YES);
        }
    }
    self.fullScreen = YES;
    [self.interactiveTransition updateContentView:self.contentView containerView:self.containerView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.fullScreenAnimation) {
        if (self.orientationWillChange) {
            self.orientationWillChange(NO);
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.fullScreen = NO;
    if (!self.fullScreenAnimation) {
        [self.containerView addSubview:self.contentView];
        self.contentView.frame = self.containerView.bounds;
        if (self.orientationDidChanged) {
            self.orientationDidChanged(NO);
        }
    }
}

#pragma mark - transition delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    [self.transition transitionWithTransitionType:ZFPresentTransitionTypePresent contentView:self.contentView containerView:self.containerView];
    return self.transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self.transition transitionWithTransitionType:ZFPresentTransitionTypeDismiss contentView:self.contentView containerView:self.containerView];
    return self.transition;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.statusBarAnimation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - ZFPortraitOrientationDelegate

- (void)zf_orientationWillChange:(BOOL)isFullScreen {
    if (self.orientationWillChange) {
        self.orientationWillChange(isFullScreen);
    }
}

- (void)zf_orientationDidChanged:(BOOL)isFullScreen {
    if (self.orientationDidChanged) {
        self.orientationDidChanged(isFullScreen);
    }
}

- (void)zf_interationState:(BOOL)isDragging {
    self.transition.interation = isDragging;
}

#pragma mark - getter

- (ZFPresentTransition *)transition {
    if (!_transition) {
        _transition = [[ZFPresentTransition alloc] init];
        _transition.contentFullScreenRect = [self contentFullScreenRect];
        _transition.delagate = self;
    }
    return _transition;
}

- (ZFPersentInteractiveTransition *)interactiveTransition {
    if (!_interactiveTransition) {
        _interactiveTransition = [[ZFPersentInteractiveTransition alloc] init];
        _interactiveTransition.contentFullScreenRect = [self contentFullScreenRect];
        _interactiveTransition.viewController = self;
        _interactiveTransition.delagate = self;
    }
    return _interactiveTransition;;
}

- (void)setDisablePortraitGestureTypes:(ZFDisablePortraitGestureTypes)disablePortraitGestureTypes {
    _disablePortraitGestureTypes = disablePortraitGestureTypes;
    self.interactiveTransition.disablePortraitGestureTypes = disablePortraitGestureTypes;
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    self.transition.contentFullScreenRect = [self contentFullScreenRect];
    self.interactiveTransition.contentFullScreenRect = [self contentFullScreenRect];
    if (!self.fullScreenAnimation && self.isFullScreen) {
        self.contentView.frame = [self contentFullScreenRect];
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    self.transition.fullScreen = fullScreen;
}

- (void)setFullScreenAnimation:(BOOL)fullScreenAnimation {
    _fullScreenAnimation = fullScreenAnimation;
    self.interactiveTransition.fullScreenAnimation = fullScreenAnimation;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    self.transition.duration = duration;
}

// 这里还是 Mode 计算, 最终就是居中显示 Video.
- (CGRect)contentFullScreenRect {
    CGFloat videoWidth = self.presentationSize.width;
    CGFloat videoHeight = self.presentationSize.height;
    if (videoHeight == 0) {
        return CGRectZero;
    }
    CGSize fullScreenScaleSize = CGSizeZero;
    CGFloat screenScale = ZFPlayerScreenWidth/ZFPlayerScreenHeight;
    CGFloat videoScale = videoWidth/videoHeight;
    if (screenScale > videoScale) {
        CGFloat height = ZFPlayerScreenHeight;
        CGFloat width = height * videoScale;
        fullScreenScaleSize = CGSizeMake(width, height);
    } else {
        CGFloat width = ZFPlayerScreenWidth;
        CGFloat height = (CGFloat)(width / videoScale);
        fullScreenScaleSize = CGSizeMake(width, height);
    }
    
    videoWidth = fullScreenScaleSize.width;
    videoHeight = fullScreenScaleSize.height;
    CGRect result = CGRectMake((ZFPlayerScreenWidth - videoWidth) / 2.0, (ZFPlayerScreenHeight - videoHeight) / 2.0, videoWidth, videoHeight);
    return result;
}

@end
