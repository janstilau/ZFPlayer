#import "ZFLandscapeWindow.h"

@implementation ZFLandscapeWindow

@dynamic rootViewController;

// 没有背景色.
- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelNormal;
        _landscapeViewController = [[ZFLandscapeViewController alloc] init];
        self.rootViewController = _landscapeViewController;
        if (@available(iOS 13.0, *)) {
            if (self.windowScene == nil) {
                self.windowScene = UIApplication.sharedApplication.keyWindow.windowScene;
            }
        }
        self.hidden = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    static CGRect bounds;
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        NSLog(@"Saved Bounds %@", NSStringFromCGRect(bounds));
        NSLog(@"Current Bounds %@", NSStringFromCGRect(self.bounds));
        UIView *superview = self;
        if (@available(iOS 13.0, *)) {
            superview = self.subviews.firstObject;
        }
        [UIView performWithoutAnimation:^{
            for (UIView *view in superview.subviews) {
                if (view != self.rootViewController.view && [view isMemberOfClass:UIView.class]) {
                    view.backgroundColor = UIColor.clearColor;
                    for (UIView *subview in view.subviews) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
            }
        }];
    }
    // 在这里, 会将 RootView 的 View 完全和 Window 进行贴合.
    bounds = self.bounds;
    self.rootViewController.view.frame = bounds;
}

@end
