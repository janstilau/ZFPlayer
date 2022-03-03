#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFPlayerBackgroundState) {
    ZFPlayerBackgroundStateForeground,  // Enter the foreground from the background.
    ZFPlayerBackgroundStateBackground,  // From the foreground to the background.
};

/*
 视频播放的时候, 需要监听各种设备的事件, 其中有很多是通过通知的方式监听的.
 这是一个工具类, 进行各种通知的注册, 然后暴露接口, 进行回调.
 */

@interface ZFPlayerNotification : NSObject

@property (nonatomic, readonly) ZFPlayerBackgroundState backgroundState;

@property (nonatomic, copy, nullable) void(^willResignActive)(ZFPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(ZFPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(ZFPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(ZFPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(ZFPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^volumeChanged)(float volume);

@property (nonatomic, copy, nullable) void(^audioInterruptionCallback)(AVAudioSessionInterruptionType interruptionType);

/*
 在开始播放的时候, 进行了通知的开始监听.
 */
- (void)addNotification;

/*
 在停止 stop 的时候, 进行了通知的结束监听.
 */
- (void)removeNotification;

@end

NS_ASSUME_NONNULL_END
