//
//  UIScrollView+WawaHeadRefresh.h
//  R
//
//  Created by macRong on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WawaHeadRefreshView;

typedef NS_ENUM(NSUInteger, WawaHeadRefreshPosition) {
    WawaHeadRefreshPositionTop,
    WawaHeadRefreshPositionToBack
};

@interface UIScrollView (WawaHeadRefresh)

@property (nonatomic, getter=isShowHeadRefresh) BOOL showHeadRefresh;
@property (nonatomic, strong, readonly) WawaHeadRefreshView *wawaHeadRefresh;


- (void)wawaHeadRefresh:(dispatch_block_t)actionHandler;
- (void)wawaHeadRefreshWithpostion:(WawaHeadRefreshPosition)position actionHandler:(dispatch_block_t)actionHandler;

@end



@interface WawaHeadRefreshView: UIView

- (void)stopAnimation;

@end



