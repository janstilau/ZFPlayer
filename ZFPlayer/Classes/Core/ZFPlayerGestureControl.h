
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFPlayerGestureType) {
    ZFPlayerGestureTypeUnknown,
    ZFPlayerGestureTypeSingleTap,
    ZFPlayerGestureTypeDoubleTap,
    ZFPlayerGestureTypePan,
    ZFPlayerGestureTypePinch
};

typedef NS_ENUM(NSUInteger, ZFPanDirection) {
    ZFPanDirectionUnknown,
    ZFPanDirectionV,
    ZFPanDirectionH,
};

typedef NS_ENUM(NSUInteger, ZFPanLocation) {
    ZFPanLocationUnknown,
    ZFPanLocationLeft,
    ZFPanLocationRight,
};

typedef NS_ENUM(NSUInteger, ZFPanMovingDirection) {
    ZFPanMovingDirectionUnkown,
    ZFPanMovingDirectionTop,
    ZFPanMovingDirectionLeft,
    ZFPanMovingDirectionBottom,
    ZFPanMovingDirectionRight,
};

/// This enumeration lists some of the gesture types that the player has by default.
typedef NS_OPTIONS(NSUInteger, ZFPlayerDisableGestureTypes) {
    ZFPlayerDisableGestureTypesNone         = 0,
    ZFPlayerDisableGestureTypesSingleTap    = 1 << 0,
    ZFPlayerDisableGestureTypesDoubleTap    = 1 << 1,
    ZFPlayerDisableGestureTypesPan          = 1 << 2,
    ZFPlayerDisableGestureTypesPinch        = 1 << 3,
    ZFPlayerDisableGestureTypesAll          = (ZFPlayerDisableGestureTypesSingleTap | ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch)
};

/// This enumeration lists some of the pan gesture moving direction that the player not support.
typedef NS_OPTIONS(NSUInteger, ZFPlayerDisablePanMovingDirection) {
    ZFPlayerDisablePanMovingDirectionNone         = 0,       /// Not disable pan moving direction.
    ZFPlayerDisablePanMovingDirectionVertical     = 1 << 0,  /// Disable pan moving vertical direction.
    ZFPlayerDisablePanMovingDirectionHorizontal   = 1 << 1,  /// Disable pan moving horizontal direction.
    ZFPlayerDisablePanMovingDirectionAll          = (ZFPlayerDisablePanMovingDirectionVertical | ZFPlayerDisablePanMovingDirectionHorizontal)  /// Disable pan moving all direction.
};


// 给一个 View, 配置 Gesture 的过程太复杂了. 并且是可以复用的.
// 直接使用一个工具类, 
@interface ZFPlayerGestureControl : NSObject

/// Gesture condition callback.
@property (nonatomic, copy, nullable) BOOL(^triggerCondition)(ZFPlayerGestureControl *control, ZFPlayerGestureType type, UIGestureRecognizer *gesture, UITouch *touch);

/// Single tap gesture callback.
@property (nonatomic, copy, nullable) void(^singleTapped)(ZFPlayerGestureControl *control);

/// Double tap gesture callback.
@property (nonatomic, copy, nullable) void(^doubleTapped)(ZFPlayerGestureControl *control);

/// Begin pan gesture callback.
@property (nonatomic, copy, nullable) void(^beganPan)(ZFPlayerGestureControl *control, ZFPanDirection direction, ZFPanLocation location);

/// Pan gesture changing callback.
@property (nonatomic, copy, nullable) void(^changedPan)(ZFPlayerGestureControl *control, ZFPanDirection direction, ZFPanLocation location, CGPoint velocity);

/// End the Pan gesture callback.
@property (nonatomic, copy, nullable) void(^endedPan)(ZFPlayerGestureControl *control, ZFPanDirection direction, ZFPanLocation location);

/// Pinch gesture callback.
@property (nonatomic, copy, nullable) void(^pinched)(ZFPlayerGestureControl *control, float scale);

/// The single tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;

/// The double tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

/// The pan tap gesture.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

/// The pinch tap gesture.
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGR;

/// The pan gesture direction.
@property (nonatomic, readonly) ZFPanDirection panDirection;

/// The pan location.
@property (nonatomic, readonly) ZFPanLocation panLocation;

/// The moving drection.
@property (nonatomic, readonly) ZFPanMovingDirection panMovingDirection;

/// The gesture types that the player not support.
@property (nonatomic) ZFPlayerDisableGestureTypes disableTypes;

/// The pan gesture moving direction that the player not support.
@property (nonatomic) ZFPlayerDisablePanMovingDirection disablePanMovingDirection;

/**
 Add  all gestures(singleTap、doubleTap、panGR、pinchGR) to the view.
 */
- (void)addGestureToView:(UIView *)view;

/**
 Remove all gestures(singleTap、doubleTap、panGR、pinchGR) form the view.
 */
- (void)removeGestureToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
