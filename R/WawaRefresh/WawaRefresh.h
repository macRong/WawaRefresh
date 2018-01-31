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
 
 1.快速滑动处理，offset不准
 2.Timer, Runloop
 3.💥时 inset设置生硬
 4. iOS11.0+ loading位置不对
 5. 多次创建 销毁对象
 6. kvo 创建标识销毁
 7. 来回滑动时 wawaLoading有闪动bug
 8. 在下拉loading中，符合上拉条件是否要执行？
 9. Inset 各种情况测试
 10. 下拉大幅度， 松开会导致上拉时间 加判断
 11. 全局设置， 一旦设置全局有效（没有重置情况下） 单利config
 12. 上拉提示‘暂无数据’， 再下拉处理自动除去‘暂无数据’状态
 13. 满足distanceBottom时， foot下滑动，不应响应加载更多
 
 
 */
