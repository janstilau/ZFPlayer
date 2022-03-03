#import <UIKit/UIKit.h>
#import "ZFPlayerConst.h"

@interface ZFPlayerView : UIView

/// player content view.
@property (nonatomic, strong) UIView *playerView;

/// Determines how the content scales to fit the view.
@property (nonatomic, assign) ZFPlayerScalingMode scalingMode;

/// The video size.
@property (nonatomic, assign) CGSize presentationSize;

/// The cover for playerView.
@property (nonatomic, strong, readonly) UIImageView *coverImageView;

@end
