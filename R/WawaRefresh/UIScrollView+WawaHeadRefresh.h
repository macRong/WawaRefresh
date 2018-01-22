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
    WawaHeadRefreshPositionToBack /** 在scrollView下面（比如：scrollView展示不是全频模式） */
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


/**
 question:
 
 1.快速滑动处理
 2.Timer
 3.💥时 inset设置生硬
 
 
 */
