#import <UIKit/UIKit.h>
#import "ZFOrientationObserver.h"

typedef NS_ENUM(NSUInteger, ZFPresentTransitionType) {
    ZFPresentTransitionTypePresent,
    ZFPresentTransitionTypeDismiss,
};

@interface ZFPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) id<ZFPortraitOrientationDelegate> delagate;

@property (nonatomic, assign) CGRect contentFullScreenRect;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, assign) BOOL interation;

@property (nonatomic, assign) NSTimeInterval duration;

// 这里设计的不好, 不如在 VC 里面定义两个对象.
- (void)transitionWithTransitionType:(ZFPresentTransitionType)type
                         contentView:(UIView *)contentView
                       containerView:(UIView *)containerView;

@end
