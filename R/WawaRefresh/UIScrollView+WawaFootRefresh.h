//
//  UIScrollView+WawaFootRefresh.h
//  R
//
//  Created by 荣守振 on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (WawaFootRefresh)

- (void)wawaFootRefresh:(dispatch_block_t)actionHandler;

@end
