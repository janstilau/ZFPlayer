#import "ZFLandscapeViewController.h"

@interface ZFLandscapeViewController ()

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@end

@implementation ZFLandscapeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentOrientation = UIInterfaceOrientationPortrait;
        _statusBarStyle = UIStatusBarStyleLightContent;
        _statusBarAnimation = UIStatusBarAnimationSlide;
    }
    return self;
}

/*
 size
 The new size for the container’s view.

 coordinator
 The transition coordinator object managing the size change. You can use this object to animate your changes or get information about the transition that is in progress.

 Discussion
 UIKit calls this method before changing the size of a presented view controller’s view. You can override this method in your own objects and use it to perform additional tasks related to the size change. For example, a container view controller might use this method to override the traits of its embedded child view controllers. Use the provided coordinator object to animate any changes you make.

 If you override this method in your custom view controllers, always call super at some point in your implementation so that UIKit can forward the size change message appropriately. View controllers forward the size change message to their views and child view controllers. Presentation controllers forward the size change to their presented view controller.
 */
/*
 [self interfaceOrientation:targetOrientation]; 会直接调用到这里. 
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    
    self.rotating = YES;
    UIInterfaceOrientation newOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    UIInterfaceOrientation oldOrientation = _currentOrientation;
    if (UIInterfaceOrientationIsLandscape(newOrientation)) {
        // 在这, 进行了 View 的转移工作.
        if (self.contentView.superview != self.view) {
            [self.view addSubview:self.contentView];
        }
    }
    
    if (oldOrientation == UIInterfaceOrientationPortrait) {
        // ls_targetRect 是原来的数值.
        self.contentView.frame = [self.delegate ls_targetRect];
        [self.contentView layoutIfNeeded];
    }
    self.currentOrientation = newOrientation;
    
    [self.delegate ls_willRotateToOrientation:self.currentOrientation];
    
    BOOL isFullscreen = size.width > size.height;
    if (self.disableAnimations) {
        [CATransaction begin];
        // Sets whether actions triggered as a result of property changes made within this transaction group are suppressed.
        // 这样, 任何关键帧属性变化, 都不引起数据变化.
        [CATransaction setDisableActions:YES];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (isFullscreen) {
            self.contentView.frame = CGRectMake(0, 0, size.width, size.height);
        } else {
            self.contentView.frame = [self.delegate ls_targetRect];
        }
        [self.contentView layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (self.disableAnimations) {
            [CATransaction commit];
        }
        [self.delegate ls_didRotateFromOrientation:self.currentOrientation];
        if (!isFullscreen) {
            self.contentView.frame = self.containerView.bounds;
            [self.contentView layoutIfNeeded];
        }
        self.disableAnimations = NO;
        self.rotating = NO;
    }];
}

- (BOOL)isFullscreen {
    return UIInterfaceOrientationIsLandscape(_currentOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return [self.delegate ls_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        return YES;
    }
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

- (void)setRotating:(BOOL)rotating {
    _rotating = rotating;
    if (!rotating && self.rotatingCompleted) {
        self.rotatingCompleted();
    }
}

@end

