//
//  WawaRefresh.h
//  R
//
//  Created by macRong on 2018/1/19.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "WawaLoadingView.h"
#import "UIScrollView+WawaHeadRefresh.h"
#import "UIScrollView+WawaFootRefresh.h"


static const CGFloat   WAWALOADINGHEIGHT = 64.0f;



/**
 question:
 
 1.快速滑动处理
 2.Timer, Runloop
 3.💥时 inset设置生硬
 4. iOS11.0+ loading位置不对
 5. 多次创建 销毁对象
 6. kvo 创建标识 和销毁
 7. 来回小滑动 有闪动bug
 
 */
