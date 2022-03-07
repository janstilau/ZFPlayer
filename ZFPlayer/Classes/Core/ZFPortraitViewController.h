#import <UIKit/UIKit.h>
#import "ZFOrientationObserver.h"

NS_ASSUME_NONNULL_BEGIN

/*
 Portrait 的全屏, 就是使用一个 Present VC 里达到效果.
 将视频播放的 View, 添加到这个 VC 上. 
 */
@interface ZFPortraitViewController : UIViewController

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(BOOL isFullScreen);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(BOOL isFullScreen);

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) BOOL statusBarHidden;

/// default is  UIStatusBarStyleLightContent.
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
/// defalut is UIStatusBarAnimationSlide.
@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimation;

/// default is ZFDisablePortraitGestureTypesNone.
@property (nonatomic, assign) ZFDisablePortraitGestureTypes disablePortraitGestureTypes;

@property (nonatomic, assign) CGSize presentationSize;

@property (nonatomic, assign) BOOL fullScreenAnimation;

@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
