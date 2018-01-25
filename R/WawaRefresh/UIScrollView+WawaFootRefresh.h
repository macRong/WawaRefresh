//
//  UIScrollView+WawaFootRefresh.h
//  R
//
//  Created by 荣守振 on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WawaFootRefreshView;

static const CGFloat   WAWAFOOTVIEWHEIGHT = 64.0f;

typedef NS_ENUM(NSUInteger, WawaFootRefreshPosition) {
    WawaFootRefreshPositionScrollViewBottom,
    WawaFootRefreshPositionContentBottom
};


@interface UIScrollView (WawaFootRefresh)

@property (nonatomic, assign, readonly) BOOL isShowFootRefresh;
@property (nonatomic, strong, readonly) WawaFootRefreshView *wawaFootRefresh;

- (void)wawaFootRefresh:(dispatch_block_t)actionHandler;

@end


#pragma mark -############################# WawaFootRefreshView #################################################

@interface WawaFootRefreshView: UIView

@property (nonatomic) WawaFootRefreshPosition footRefreshPosition;

- (void)stopAnimation;


@end
