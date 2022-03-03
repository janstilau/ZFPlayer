//
//  ZFAppDelegate.m
//  ZFPlayer
//
//  Created by renzifeng on 05/23/2018.
//  Copyright (c) 2018 renzifeng. All rights reserved.
//

#import "ZFAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)setAllowOrentitaionRotation:(BOOL)allowOrentitaionRotation {
    _allowOrentitaionRotation = allowOrentitaionRotation;
}

/*
 
 */

/*
 This method returns the total set of interface orientations supported by the app.
 When determining whether to rotate a particular view controller, the orientations returned by this method are intersected with the orientations supported by the root view controller or topmost presented view controller.
 The app and view controller must agree before the rotation is allowed.
 If you do not implement this method, the app uses the values in the UIInterfaceOrientation key of the app’s Info.plist as the default interface orientations.
 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    NSLog(@"从 Delegate 获取 支持的 InterfaceOrientation");
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
    if (self.allowOrentitaionRotation) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

/*
 UIViewController: supportedInterfaceOrientations
 
 This property returns a bit mask that specifies which orientations the view controller supports. For more information, see UIInterfaceOrientationMask.
 When the device orientation changes, the system calls this method on the root view controller or the topmost modal view controller that fills the window. If the view controller supports the new orientation, the system rotates the window and the view controller.
 The system only calls this method if the view controller's shouldAutorotate method returns true.
 
 Override this method to declare which orientations the view controller supports. The default value is all for the iPad idiom and allButUpsideDown for the iPhone idiom. The value you return must not be 0.
 To determine whether to rotate, the system compares the view controller's supported orientations with the app's supported orientations — as determined by the Info.plist file or the app delegate's application(_:supportedInterfaceOrientationsFor:) method — and the device's supported orientations.
 Note
 All iPadOS devices support the portraitUpsideDown orientation. It’s best practice to enable it for the iPad idiom. iOS devices without a Home button, such as iPhone 12, don’t support this orientation. You should disable it entirely for the iPhone idiom.
 */

/*
 UIViewController: preferredInterfaceOrientationForPresentation
 
 The system calls this method when presenting the view controller full screen. When your view controller supports two or more orientations but the content appears best in one of those orientations, override this method and return the preferred orientation.
 If your view controller implements this method, your view controller’s view is shown in the preferred orientation (although it can later be rotated to another supported rotation). If you do not implement this method, the system presents the view controller using the current orientation of the status bar.
 */

@end
