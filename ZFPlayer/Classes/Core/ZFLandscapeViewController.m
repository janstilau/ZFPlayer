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

// 实际上, 整个动画, 都是在 Landscape 上进行的. 
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"viewWillTransitionToSize 触发了");
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    
    self.rotating = YES;
    UIInterfaceOrientation newOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    UIInterfaceOrientation oldOrientation = _currentOrientation;
    if (UIInterfaceOrientationIsLandscape(newOrientation)) {
        // 如果新方向是横屏, 则进行 ContentView 的添加工作.
        if (self.contentView.superview != self.view) {
            [self.view addSubview:self.contentView];
        }
    }
    
    if (oldOrientation == UIInterfaceOrientationPortrait) {
        // 如果, 原有的方向是竖屏, 则将 contentView
        self.contentView.frame = [self.delegate ls_targetRect];
        [self.contentView layoutIfNeeded];
    }
    // 在这里, 进行了当前方向的改变.
    self.currentOrientation = newOrientation;
    
    [self.delegate ls_willRotateToOrientation:self.currentOrientation];
    
    // 根据目标尺寸, 来判断是要进入全屏, 还是退出全屏.
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
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:4 animations:^{
//                if (isFullscreen) {
//                    self.contentView.frame = CGRectMake(0, 0, size.width, size.height);
//                } else {
//                    self.contentView.frame = [self.delegate ls_targetRect];
//                }
//                [self.contentView layoutIfNeeded];
//            }];
//        });
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        if (self.disableAnimations) {
            [CATransaction commit];
        }
        [self.delegate ls_didRotateFromOrientation:self.currentOrientation];
        if (!isFullscreen) {
            // containerView 仅仅在这里被使用了.
            // 目的就是进行进行 ContentView 的动画操作.
            self.contentView.frame = self.containerView.bounds;
            [self.contentView layoutIfNeeded];
        }
       
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:4 animations:^{
//                if (!isFullscreen) {
//                    // containerView 仅仅在这里被使用了.
//                    // 目的就是进行进行 ContentView 的动画操作.
//                    self.contentView.frame = self.containerView.bounds;
//                    [self.contentView layoutIfNeeded];
//                }
//            }];
//        });
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

// 这里有点问题. 这个方法会经常性的触发. 把逻辑放到这里来, 很混乱.
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

