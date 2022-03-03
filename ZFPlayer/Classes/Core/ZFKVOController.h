#import <Foundation/Foundation.h>

/*
 真实的监听操作, 还是写到了 target 的内部.
 这个类, 主要可以用来管理监听者的关系.
 可以在必要的时候, 清空所有的监听关系. 
 */

@interface ZFKVOController : NSObject

- (instancetype)initWithTarget:(NSObject *)target;

- (void)safelyAddObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  options:(NSKeyValueObservingOptions)options
                  context:(void *)context;
- (void)safelyRemoveObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath;

- (void)safelyRemoveAllObservers;

@end
