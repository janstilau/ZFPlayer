//
//  ZFSpeedLoadingView.m
//  Pods-ZFPlayer_Example
//
//  Created by 紫枫 on 2018/6/27.
//

#import "ZFSpeedLoadingView.h"
#import "ZFNetworkSpeedMonitor.h"
#import "UIView+ZFFrame.h"

@interface ZFSpeedLoadingView ()

@property (nonatomic, strong) ZFNetworkSpeedMonitor *speedMonitor;

@end

@implementation ZFSpeedLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.userInteractionEnabled = NO;
    [self addSubview:self.loadingView];
    [self addSubview:self.speedTextLabel];
    [self.speedMonitor startNetworkSpeedMonitor];
    // speedMonitor 其实应该提供一个回调. 现在来看, 一个 LoadingView 对应一个网络监控.
    // 如果是多 Tab 情况, 整个 App 内会有多个 ZFSpeedLoadingView. 整个时候, 就会多次发出 Noti.
    // 从目前来看, 没有 LoadingView 没有暴露停止监听的接口.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkSpeedChanged:) name:ZFDownloadNetworkSpeedNotificationKey object:nil];
}

- (void)dealloc {
    [self.speedMonitor stopNetworkSpeedMonitor];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZFDownloadNetworkSpeedNotificationKey object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.zf_width;
    CGFloat min_view_h = self.zf_height;
    
    min_w = 44;
    min_h = min_w;
    min_x = (min_view_w - min_w) / 2;
    min_y = (min_view_h - min_h) / 2 - 10;
    self.loadingView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = self.loadingView.zf_bottom+5;
    min_w = min_view_w;
    min_h = 20;
    self.speedTextLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

- (void)networkSpeedChanged:(NSNotification *)sender {
    NSString *downloadSpped = [sender.userInfo objectForKey:ZFNetworkSpeedNotificationKey];
    self.speedTextLabel.text = downloadSpped;
}

- (void)startAnimating {
    [self.loadingView startAnimating];
    self.hidden = NO;
}

- (void)stopAnimating {
//    [self.loadingView stopAnimating];
//    self.hidden = YES;
}

- (UILabel *)speedTextLabel {
    if (!_speedTextLabel) {
        _speedTextLabel = [UILabel new];
        _speedTextLabel.textColor = [UIColor whiteColor];
        _speedTextLabel.font = [UIFont systemFontOfSize:12.0];
        _speedTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _speedTextLabel;
}

- (ZFNetworkSpeedMonitor *)speedMonitor {
    if (!_speedMonitor) {
        _speedMonitor = [[ZFNetworkSpeedMonitor alloc] init];
    }
    return _speedMonitor;
}

- (ZFLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[ZFLoadingView alloc] init];
        _loadingView.lineWidth = 0.8;
        _loadingView.duration = 1;
        _loadingView.hidesWhenStopped = YES;
    }
    return _loadingView;
}

@end
