//
//  UIScrollView+WawaHeadRefresh.h
//  R
//
//  Created by macRong on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WawaHeadRefreshView;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, WawaHeadRefreshPosition) {
    WawaHeadRefreshPositionTop,
    WawaHeadRefreshPositionToBack
};


@interface UIScrollView (WawaHeadRefresh)

@property (nonatomic, assign, readonly) BOOL isShowHeadRefresh;
@property (nonatomic, strong, readonly) WawaHeadRefreshView *wawaHeadRefresh;


- (void)wawaHeadRefresh:(dispatch_block_t)actionHandler;
- (void)wawaHeadRefreshWithpostion:(WawaHeadRefreshPosition)position actionHandler:(dispatch_block_t)actionHandler;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface WawaHeadRefreshView: UIView

@property (nonatomic, assign, readonly) BOOL isRefreshing;

- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END

