
#import <UIKit/UIKit.h>
@class ZFLandscapeViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ZFLandscapeViewControllerDelegate <NSObject>

- (BOOL)ls_shouldAutorotate;
- (void)ls_willRotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)ls_didRotateFromOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)ls_targetRect;

@end

@interface ZFLandscapeViewController : UIViewController

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak, nullable) id<ZFLandscapeViewControllerDelegate> delegate;

@property (nonatomic, readonly) BOOL isFullscreen;

@property (nonatomic, getter=isRotating) BOOL rotating;

@property (nonatomic, assign) BOOL disableAnimations;

@property (nonatomic, assign) BOOL statusBarHidden;
/// default is  UIStatusBarStyleLightContent.
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
/// defalut is UIStatusBarAnimationSlide.
@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimation;

@property (nonatomic, copy) void(^rotatingCompleted)(void);

@end

NS_ASSUME_NONNULL_END
