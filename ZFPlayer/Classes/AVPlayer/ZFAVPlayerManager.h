#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if __has_include(<ZFPlayer/ZFPlayerMediaPlayback.h>)
#import <ZFPlayer/ZFPlayerMediaPlayback.h>
#else
#import "ZFPlayerMediaPlayback.h"
#endif

/*
 这个类, 封装的是对于 AVPlayer 的管理. 所以, 实际上, 是真正的视频播放控制类.
 */

@interface ZFAVPlayerManager : NSObject <ZFPlayerMediaPlayback>

/*
 之前, LocalPlayer 还要自己专门写一个, 实际山, ZFPlayerManager 是可以处理本地视频的.
 AVPlayer 将本地, 远端视频的处理, 是包装到自己的内部的.
 
 An asset that represents media at a local or remote URL.
 
 An asset is a container object for one or more instances of AVAssetTrack that models the uniformly typed tracks of media.
 Audio and video tracks are the most common track types, but assets may also contain supplementary tracks, such as closed captions, subtitles, and timed metadata.
 
 You load the tracks for an asset by asynchronously loading its tracks property. In some cases, you may want to perform operations on a subset of an asset’s tracks rather than on its complete collection. For those situations, an asset provides methods to retrieve subsets of tracks according to particular criteria, such as identifier, media type, or characteristic.
 */
@property (nonatomic, strong, readonly) AVURLAsset *asset;
/*
 这是一个 Asset 的加载过程的体现.
 An object that models the timing and presentation state of an asset that a player object presents.
 // 里面, 会创建一个 Asset 当做是包装格式的对象形式.
 An AVPlayerItem stores a reference to an AVAsset object, which represents the media to be played.
 If you need to access information about the asset before you enqueue it for playback, you can use the methods of the AVAsynchronousKeyValueLoading protocol to load the values you need.
 
 // AssetItem 的各个属性, 是一个异步属性. 会在加载过程中, 根据网络的返回值, 自动添加.
 // 这也是为什么, 这个框架要大量使用 KVO 的原因.
 Alternatively, AVPlayerItem can automatically load the needed asset data for you by passing the desired set of keys to its init(asset:automaticallyLoadedAssetKeys:) initializer. When the player item is ready to play, those asset properties will have been loaded and are ready for use.
 AVPlayerItem is a dynamic object. In addition to its property values that can be changed by you, many of its read-only property values can be changed by the associated AVPlayer during the item’s preparation and playback.
 You can use Key-value observing to observe these state changes as they occur. One of the most important player item properties to observe is its status.
 The status indicates if the item is ready for playback and generally available for use. When you first create a player item, its status has a value of AVPlayerItem.Status.unknown, meaning its media hasn’t been loaded and has not yet been enqueued for playback.
 Associating a player item with an AVPlayer immediately begins enqueuing the item’s media and preparing it for playback, but you need to wait until its status changes to AVPlayerItem.Status.readyToPlay before it’s ready for use. The following code example illustrates how to register and be notified of status changes:
 func prepareToPlay() {
     let url =
     // Create asset to be played
     asset = AVAsset(url: url)
     
     let assetKeys = [
         "playable",
         "hasProtectedContent"
     ]
     // Create a new AVPlayerItem with the asset and an
     // array of asset keys to be automatically loaded
     playerItem = AVPlayerItem(asset: asset,
                               automaticallyLoadedAssetKeys: assetKeys)
     
     // Register as an observer of the player item's status property
     playerItem.addObserver(self,
                            forKeyPath: #keyPath(AVPlayerItem.status),
                            options: [.old, .new],
                            context: &playerItemContext)
     
     // Associate the player item with the player
     player = AVPlayer(playerItem: playerItem)
 }
 The prepareToPlay method registers to observe the player item’s status property using the addObserver(_:forKeyPath:options:context:) method.
 You should call this method before associating the player item with the player to make sure you capture all state changes to the item’s status.
 
 To be notified of changes to the status, you need to implement the observeValue(forKeyPath:of:change:context:) method. This method is invoked whenever the status changes giving you the chance to take some action in response (see example).
 override func observeValue(forKeyPath keyPath: String?,
                            of object: Any?,
                            change: [NSKeyValueChangeKey : Any]?,
                            context: UnsafeMutableRawPointer?) {
     // Only handle observations for the playerItemContext
     guard context == &playerItemContext else {
         super.observeValue(forKeyPath: keyPath,
                            of: object,
                            change: change,
                            context: context)
         return
     }
     
     if keyPath == #keyPath(AVPlayerItem.status) {
         let status: AVPlayerItemStatus
         
         // Get the status change from the change dictionary
         if let statusNumber = change?[.newKey] as? NSNumber {
             status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
         } else {
             status = .unknown
         }
         
         // Switch over the status
         switch status {
         case .readyToPlay:
         // Player item is ready to play.
         case .failed:
         // Player item failed. See error.
         case .unknown:
             // Player item is not yet ready.
         }
     }
 }
 The example retrieves the new status from the change dictionary and switches over its value. If the player item’s status is AVPlayerItem.Status.readyToPlay, then it’s ready for use.
 If a problem was encountered while attempting to load the player item’s media, the status will be AVPlayerItem.Status.failed. You can get the NSError providing the details of the failure by querying the player item’s error property.
 */
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;
/// 视频请求头
@property (nonatomic, strong) NSDictionary *requestHeader;

@property (nonatomic, strong, readonly) AVPlayerLayer *avPlayerLayer;

@end
