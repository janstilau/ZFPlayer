#import <UIKit/UIKit.h>
#import "ZFPlayerConst.h"

@interface ZFPlayerView : UIView

// 真正的, 和 AVPlayerLayer 钩挂的 View/
@property (nonatomic, strong) UIView *playerView;

// 封面图, 因为不播放的时候, 一定会有一个封面图, 所以封装到了内部.
@property (nonatomic, strong, readonly) UIImageView *coverImageView;

/// Determines how the content scales to fit the view.
@property (nonatomic, assign) ZFPlayerScalingMode scalingMode;

/// The video size.
@property (nonatomic, assign) CGSize presentationSize;


@end
