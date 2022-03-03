#import "ZFOrientationObserver.h"
#import "ZFLandscapeWindow.h"
#import "ZFPortraitViewController.h"
#import "ZFPlayerConst.h"
#import <objc/runtime.h>

@interface UIWindow (CurrentViewController)

/*!
 @method currentViewController
 @return Returns the topViewController in stack of topMostController.
 */
+ (UIViewController*)zf_currentViewController;

@end

@implementation UIWindow (CurrentViewController)

+ (UIViewController*)zf_currentViewController; {
    __block UIWindow *window;
    if (@available(iOS 13, *)) {
        [[UIApplication sharedApplication].connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull scene, BOOL * _Nonnull scenesStop) {
            if ([scene isKindOfClass: [UIWindowScene class]]) {
                UIWindowScene * windowScene = (UIWindowScene *)scene;
                [windowScene.windows enumerateObjectsUsingBlock:^(UIWindow * _Nonnull windowTemp, NSUInteger idx, BOOL * _Nonnull windowStop) {
                    if (windowTemp.isKeyWindow) {
                        window = windowTemp;
                        *windowStop = YES;
                        *scenesStop = YES;
                    }
                }];
            }
        }];
    } else {
        window = [[UIApplication sharedApplication].delegate window];
    }
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController *)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

@end

@interface ZFOrientationObserver () <ZFLandscapeViewControllerDelegate>

@property (nonatomic, weak) ZFPlayerView *view; // 真正的, 播放器视图.

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, strong) UIView *cell;

@property (nonatomic, assign) NSInteger playerViewTag;

@property (nonatomic, assign) ZFRotateType rotateType;

@property (nonatomic, strong) UIWindow *previousKeyWindow;

@property (nonatomic, strong) ZFLandscapeWindow *window;

@property (nonatomic, readonly, getter=isRotating) BOOL rotating;

@property (nonatomic, strong) ZFPortraitViewController *portraitViewController;

/// current device orientation observer is activie.
@property (nonatomic, assign) BOOL activeDeviceObserver;

/// Force Rotaion, default NO.
@property (nonatomic, assign) BOOL forceRotaion;

@property (nonatomic, strong) UIView *snapshot;

@end

@implementation ZFOrientationObserver
@synthesize presentationSize = _presentationSize;

- (instancetype)init {
    self = [super init];
    if (self) {
        _fullScreenMode = ZFFullScreenModeLandscape;
        _supportInterfaceOrientation = ZFInterfaceOrientationMaskAllButUpsideDown;
        _allowOrientationRotation = YES;
        _rotateType = ZFRotateTypeNormal;
        _currentOrientation = UIInterfaceOrientationPortrait;
        _portraitFullScreenMode = ZFPortraitFullScreenModeScaleToFill;
        _disablePortraitGestureTypes = ZFDisablePortraitGestureTypesAll;
    }
    return self;
}

- (void)updateRotateView:(ZFPlayerView *)rotateView
           containerView:(UIView *)containerView {
    self.rotateType = ZFRotateTypeNormal;
    self.view = rotateView;
    self.containerView = containerView;
}

- (void)updateRotateView:(ZFPlayerView *)rotateView rotateViewAtCell:(UIView *)cell playerViewTag:(NSInteger)playerViewTag {
    self.rotateType = ZFRotateTypeCell;
    self.view = rotateView;
    self.cell = cell;
    self.playerViewTag = playerViewTag;
}

- (void)dealloc {
    [self removeDeviceOrientationObserver];
}

- (void)addDeviceOrientationObserver {
    if (self.allowOrientationRotation) {
        self.activeDeviceObserver = YES;
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)removeDeviceOrientationObserver {
    self.activeDeviceObserver = NO;
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange {
    if (self.fullScreenMode == ZFFullScreenModePortrait || !self.allowOrientationRotation) return;
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        return;
    }
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    
    // Determine that if the current direction is the same as the direction you want to rotate, do nothing
    // 实际上, 私有方法也会触发这里的监听, 这里做一个拦截. 否则就递归了.
    if (currentOrientation == _currentOrientation) return;
    _currentOrientation = currentOrientation;
    if (_currentOrientation == UIInterfaceOrientationPortraitUpsideDown) return;
    
    switch (currentOrientation) {
        case UIInterfaceOrientationPortrait: {
            if ([self _isSupportedPortrait]) {
                [self rotateToOrientation:UIInterfaceOrientationPortrait animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if ([self _isSupportedLandscapeLeft]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if ([self _isSupportedLandscapeRight]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - public

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self rotateToOrientation:orientation animated:animated completion:nil];
}

// 该函数入口, 可能是用户点击了全屏播放按钮, 强制进行了 Landscape 的 Deivce 变化.
// 也可能是设备的重力方向变化.
- (void)rotateToOrientation:(UIInterfaceOrientation)targetOrientation
                   animated:(BOOL)animated
                 completion:(void(^)(void))completion {
    if (self.fullScreenMode == ZFFullScreenModePortrait) return;
    // _currentOrientation 并不是实际的设备的朝向, 而是自己记录的朝向.
    _currentOrientation = targetOrientation;
    self.forceRotaion = YES;
    
    if (UIInterfaceOrientationIsLandscape(targetOrientation)) {
        if (!self.fullScreen) {
            
            // 这里, 是进行 landscapeViewController 的配置工作.
            UIView *containerView = nil;
            if (self.rotateType == ZFRotateTypeCell) {
                containerView = [self.cell viewWithTag:self.playerViewTag];
            } else {
                containerView = self.containerView;
            }
            
            if (!self.window) {
                self.window = [ZFLandscapeWindow new];
                self.window.landscapeViewController.delegate = self;
                if (@available(iOS 9.0, *)) {
                    [self.window.rootViewController loadViewIfNeeded];
                } else {
                    [self.window.rootViewController view];
                }
            }
            
            self.window.landscapeViewController.contentView = self.view;
            self.window.landscapeViewController.containerView = self.containerView;
            self.fullScreen = YES;
        }
        if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
    } else {
        self.fullScreen = NO;
    }
    
    self.window.landscapeViewController.disableAnimations = !animated;
    @zf_weakify(self)
    self.window.landscapeViewController.rotatingCompleted = ^{
        @zf_strongify(self)
        self.forceRotaion = NO;
        if (completion) completion();
    };
    
    [self interfaceOrientation:UIInterfaceOrientationUnknown];
    [self interfaceOrientation:targetOrientation];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    [self enterPortraitFullScreen:fullScreen animated:animated completion:nil];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void(^ __nullable)(void))completion {
    self.fullScreen = fullScreen;
    if (fullScreen) {
        self.portraitViewController.contentView = self.view;
        self.portraitViewController.containerView = self.containerView;
        self.portraitViewController.duration = self.duration;
        if (self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleAspectFit) {
            self.portraitViewController.presentationSize = self.presentationSize;
        } else if (self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleToFill) {
            self.portraitViewController.presentationSize = CGSizeMake(ZFPlayerScreenWidth, ZFPlayerScreenHeight);
        }
        self.portraitViewController.fullScreenAnimation = animated;
        [[UIWindow zf_currentViewController] presentViewController:self.portraitViewController animated:animated completion:^{
            if (completion) completion();
        }];
    } else {
        self.portraitViewController.fullScreenAnimation = animated;
        [self.portraitViewController dismissViewControllerAnimated:animated completion:^{
            if (completion) completion();
        }];
    }
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    [self enterFullScreen:fullScreen animated:animated completion:nil];
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        [self enterPortraitFullScreen:fullScreen animated:animated completion:completion];
    } else {
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        orientation = fullScreen? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        [self rotateToOrientation:orientation animated:animated completion:completion];
    }
}

#pragma mark - private

/// is support portrait
- (BOOL)_isSupportedPortrait {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait;
}

/// is support landscapeLeft
- (BOOL)_isSupportedLandscapeLeft {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeLeft;
}

/// is support landscapeRight
- (BOOL)_isSupportedLandscapeRight {
    return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)_isSupported:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait;
        case UIInterfaceOrientationLandscapeLeft:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return self.supportInterfaceOrientation & ZFInterfaceOrientationMaskLandscapeRight;
        default:
            return NO;
    }
    return NO;
}

- (void)showLandscapeWindow:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        if (keyWindow != self.window && self.previousKeyWindow != keyWindow) {
            self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
        }
        // 当, 横屏的时候, 让自己的全屏 Window 进行展示.
        if (!self.window.isKeyWindow) {
            self.window.hidden = NO;
            [self.window makeKeyAndVisible];
        }
    }
}

- (void)showPortraitWindow:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait && !self.window.hidden) {
        UIView *containerView = nil;
        if (self.rotateType == ZFRotateTypeCell) {
            containerView = [self.cell viewWithTag:self.playerViewTag];
        } else {
            containerView = self.containerView;
        }
        [self performSelector:@selector(relocateContentViewToContainerView:) onThread:NSThread.mainThread withObject:containerView waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        [self performSelector:@selector(showOriginKeyWindow:) onThread:NSThread.mainThread withObject:self.snapshot waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    }
}

// 在全屏动画之前, 截屏当前的 PlayerView, 然后存放到当前的 ContainerView 上.
// 在 LandscapeVC 上, 仅仅做 contentView 的 superView 的切换.
- (void)cachePlayerViewSnapshot {
    UIView *containerView = nil;
    if (self.rotateType == ZFRotateTypeCell) {
        containerView = [self.cell viewWithTag:self.playerViewTag];
    } else {
        containerView = self.containerView;
    }
    self.snapshot = [self.view.playerView snapshotViewAfterScreenUpdates:NO];
    self.snapshot.frame = containerView.bounds;
    [containerView addSubview:self.snapshot];
}

- (void)relocateContentViewToContainerView:(UIView *)containerView {
    [containerView addSubview:self.view];
    self.view.frame = containerView.bounds;
    [self.view layoutIfNeeded];
}

- (void)showOriginKeyWindow:(UIView *)snapshot {
    if (snapshot) { [snapshot removeFromSuperview]; }
    UIWindow *previousKeyWindow = self.previousKeyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    [previousKeyWindow makeKeyAndVisible];
    self.previousKeyWindow = nil;
    self.window.hidden = YES; // 将自己的 Window 进行隐藏.
}

#pragma mark - ZFLandscapeViewControllerDelegate

// 这里是不太好的一个试下. 在一个 Get 方法里面, 产生了副作用.
// LandscapeVC, 检测到了 DeviceChange, 然后调用 shouldAutoRate. 到达这里.
// 然后进行了 Window 的切换.
- (BOOL)ls_shouldAutorotate {
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        return NO;
    }
    
    UIInterfaceOrientation currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (![self _isSupported:currentOrientation]) {
        return NO;
    }
    
    if (self.forceRotaion) {
        [self showLandscapeWindow:currentOrientation];
        return YES;
    }
    
    if (!self.activeDeviceObserver) {
        return NO;
    }
    
    [self showLandscapeWindow:currentOrientation];
    return YES;
}

- (void)ls_willRotateToOrientation:(UIInterfaceOrientation)orientation {
    self.fullScreen = UIInterfaceOrientationIsLandscape(orientation);
    if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
    // 截屏
    if (!self.isFullScreen) {
        [self cachePlayerViewSnapshot];
    }
}

// 当, 旋转完毕之后, 会执行该方法, 把 contentView 从 Landscape 上摘出来, 到原来的 container 上
- (void)ls_didRotateFromOrientation:(UIInterfaceOrientation)orientation {
    if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
    if (!self.isFullScreen) {
        [self showPortraitWindow:UIInterfaceOrientationPortrait];
    }
}

- (CGRect)ls_targetRect {
    UIView *containerView = nil;
    if (self.rotateType == ZFRotateTypeCell) {
        containerView = [self.cell viewWithTag:self.playerViewTag];
    } else {
        containerView = self.containerView;
    }
    CGRect targetRect = [containerView convertRect:containerView.bounds toView:containerView.window];
    return targetRect;
}

#pragma mark - getter

- (ZFPortraitViewController *)portraitViewController {
    if (!_portraitViewController) {
        @zf_weakify(self)
        _portraitViewController = [[ZFPortraitViewController alloc] init];
        if (@available(iOS 9.0, *)) {
            [_portraitViewController loadViewIfNeeded];
        } else {
            [_portraitViewController view];
        }
        _portraitViewController.orientationWillChange = ^(BOOL isFullScreen) {
            @zf_strongify(self)
            self.fullScreen = isFullScreen;
            if (self.orientationWillChange) self.orientationWillChange(self, isFullScreen);
        };
        _portraitViewController.orientationDidChanged = ^(BOOL isFullScreen) {
            @zf_strongify(self)
            self.fullScreen = isFullScreen;
            if (self.orientationDidChanged) self.orientationDidChanged(self, isFullScreen);
        };
    }
    return _portraitViewController;
}

#pragma mark - setter

- (void)setLockedScreen:(BOOL)lockedScreen {
    _lockedScreen = lockedScreen;
    if (lockedScreen) {
        [self removeDeviceOrientationObserver];
    } else {
        [self addDeviceOrientationObserver];
    }
}

- (UIView *)fullScreenContainerView {
    if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        return self.window.landscapeViewController.view;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        return self.portraitViewController.view;
    }
    return nil;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)setFullScreenStatusBarHidden:(BOOL)fullScreenStatusBarHidden {
    _fullScreenStatusBarHidden = fullScreenStatusBarHidden;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarHidden = fullScreenStatusBarHidden;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarHidden = fullScreenStatusBarHidden;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setFullScreenStatusBarStyle:(UIStatusBarStyle)fullScreenStatusBarStyle {
    _fullScreenStatusBarStyle = fullScreenStatusBarStyle;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarStyle = fullScreenStatusBarStyle;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarStyle = fullScreenStatusBarStyle;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setFullScreenStatusBarAnimation:(UIStatusBarAnimation)fullScreenStatusBarAnimation {
    _fullScreenStatusBarAnimation = fullScreenStatusBarAnimation;
    if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.statusBarAnimation = fullScreenStatusBarAnimation;
        [self.portraitViewController setNeedsStatusBarAppearanceUpdate];
    } else if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.statusBarAnimation = fullScreenStatusBarAnimation;
        [self.window.landscapeViewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setDisablePortraitGestureTypes:(ZFDisablePortraitGestureTypes)disablePortraitGestureTypes {
    _disablePortraitGestureTypes = disablePortraitGestureTypes;
    self.portraitViewController.disablePortraitGestureTypes = disablePortraitGestureTypes;
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if (self.fullScreenMode == ZFFullScreenModePortrait && self.portraitFullScreenMode == ZFPortraitFullScreenModeScaleAspectFit) {
        self.portraitViewController.presentationSize = presentationSize;
    }
}

- (void)setView:(ZFPlayerView *)view {
    if (view == _view) {
        return;
    }
    _view = view;
    if (self.fullScreenMode == ZFFullScreenModeLandscape && self.window) {
        self.window.landscapeViewController.contentView = view;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.contentView = view;
    }
}

- (void)setContainerView:(UIView *)containerView {
    if (containerView == _containerView) {
        return;
    }
    _containerView = containerView;
    if (self.fullScreenMode == ZFFullScreenModeLandscape) {
        self.window.landscapeViewController.containerView = containerView;
    } else if (self.fullScreenMode == ZFFullScreenModePortrait) {
        self.portraitViewController.containerView = containerView;
    }
}

- (void)setAllowOrientationRotation:(BOOL)allowOrientationRotation {
    _allowOrientationRotation = allowOrientationRotation;
    if (allowOrientationRotation) {
        [self addDeviceOrientationObserver];
    } else {
        [self removeDeviceOrientationObserver];
    }
}

@end
