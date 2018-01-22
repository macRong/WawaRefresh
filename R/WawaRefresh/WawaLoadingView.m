//
//  WawaLoadingView.m
//  R
//
//  Created by macRong on 2018/1/13.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "WawaLoadingView.h"

#define WawaRadians(x) (M_PI * (x) / 180.0)


#pragma mark -######################## WawaWeakProxy ################################################

@interface WawaWeakProxy:NSProxy

@property (nonatomic, weak) id obj;

+ (instancetype)invokeProxyTarget:(id)target;

@end


@implementation WawaWeakProxy


+ (id)invokeProxyTarget:(id)target
{
    WawaWeakProxy *proxy = [WawaWeakProxy alloc];
    proxy.obj = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [self.obj methodSignatureForSelector:aSelector];
    
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.obj];
}

@end



#pragma mark -######################## WawaLoadingView ################################################

id _Nullable wawa_getValidObjectFromArray(NSArray *_Nullable array, NSInteger index)
{
    if ([array isKindOfClass:[NSArray class]] && index < array.count)
    {
        return array[index];
    }
    
    return nil;
}

static const CGFloat  WAWA_CIRCLE_ANGLE = 360.0f/WAWALOADINCOUNT;

@interface WawaLoadingView()
{
    CGFloat _circle_radius;
    CGFloat _center_XY;
    CGFloat _line_Width;
    CGFloat _preValue;
    
    NSInteger _loadIndex; // ?
    NSTimer   *_timer; // ?
    
    BOOL _isGraphicsFinish;
    BOOL _headLoading;
}

@property (nonatomic, strong) NSMutableArray *startmArray;
@property (nonatomic, strong) NSMutableArray *endmArray;
@property (nonatomic, strong) NSMutableArray *colorsmArray;
@property (nonatomic, strong) NSMutableArray *beforehandColorsmArray;
@property (nonatomic, strong) NSMutableSet  *tempmSet;

@end



@implementation WawaLoadingView

- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initVariable];
        self.opaque = NO;
    }
    
    return self;
}

- (void)initVariable
{
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    
    _circle_radius = (w/2 - 2)/2;
    _center_XY  = w > h ? h/2 : w/2;
    _line_Width = w > h ? h/15.0f : w/15.0f;
    
    _preValue = CGFLOAT_MIN;
    _headLoading = NO;
    [self transformHorizontal];
}

- (void)startAnimating
{
    NSLog(@"aaaaaaaaaaaa >>>>>>>>");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.07f
                                                  target:[WawaWeakProxy invokeProxyTarget:self]
                                                selector:@selector(repeatAnimation)
                                                userInfo:nil
                                                 repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)repeatAnimation
{
    NSLog(@"__%s",__PRETTY_FUNCTION__);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self transformView];
    });

    if (!_isGraphicsFinish)
    {
        if (![NSThread isMainThread])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNeedsDisplay];
            });
        }
        else
        {
            [self setNeedsDisplay];
        }
    }

    if (_loadIndex < WAWALOADINCOUNT)
    {
        _loadIndex++;
    }
    else
    {
        _isGraphicsFinish = YES;
        _loadIndex = 0;
    }
}


#pragma mark - Out

- (void)setLoaingValue:(CGFloat)value
{
    if (_headLoading)
    {
        return;
    }
    
    if (_preValue == CGFLOAT_MIN)
    {
        _preValue = value;
    }
    
    BOOL clockwise = [self clockwise:value];
    _preValue = value;

    if (clockwise)
    {
        [self setWiseLoading:value];
    }
    else
    {
        [self setNoWiseLoading:value];
    }
    
//    NSLog(@"_____ preValue =%f,value=%f, clockwise=%d",_preValue,roundf(value),clockwise);
}

- (void)reset
{
    [self initVariable];
    [self clear];
}

- (void)stopAnimation
{
    if (_timer)
    {
        [self reset];

        NSLog(@"❌❌❌");
        [_timer invalidate];
        _timer = nil;
    }
}


#pragma mark - Private

- (void)setWiseLoading:(CGFloat)value
{
    if ([self.tempmSet containsObject:@(roundf(value))])
    {
        [self.tempmSet removeObject:@(roundf(value))];
        
        // 定义宏来////// ????
        if (_startmArray && _startmArray.count > 0)
        {
            [self.startmArray removeLastObject];
        }
        
        if (_endmArray && _endmArray.count > 0)
        {
            [self.endmArray removeLastObject];
        }
        
        if (_colorsmArray && _colorsmArray.count > 0)
        {
            [self.colorsmArray removeLastObject];
        }
        
        [self setNeedsDisplay];
    }
}

- (void)setNoWiseLoading:(CGFloat)value
{
    if (roundf(value) > WAWALOADINCOUNT || [self.tempmSet containsObject:@(roundf(value))])
    {
        return;
    }

    if(roundf(value) == WAWALOADINCOUNT && self.tempmSet.count >= WAWALOADINCOUNT)
    {
        // 爆炸
        [self bombLoading];
        return;
    }
    
    [self.tempmSet addObject:@(roundf(value))];
    
    // 初始值
    [self setCirclePoint:roundf(value)];
    [self setDefaultColor];
    
    [self setNeedsDisplay];
}

- (void)bombLoading
{
    if (!_headLoading)
    {
        _headLoading = YES;

        if (self.loadingBlock)
        {
            self.loadingBlock();
        }
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.5 options:0 animations:^{
            self.transform =  CGAffineTransformScale(self.transform, 1.15f, 1.15f);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self beforehandColor];
                [self setNeedsDisplay];
            });
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.7f animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI_2*2.3);
                self.transform =  CGAffineTransformScale(self.transform, 1.11f, 1.11f);
                }];
            });
     
        } completion:^(BOOL finished) {
            [self bombFinish];
        }];
        
    }
}

- (void)bombFinish
{
    NSLog(@"--%s__",__PRETTY_FUNCTION__);
    [self startAnimating];
    [UIView animateWithDuration:4.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI_2*8.3);
    }];
}

- (void)beforehandColor
{
    NSMutableArray *arr = @[].mutableCopy;
    for (int i = WAWALOADINCOUNT; i > 0 ; i --)
    {
        CGFloat color = i/10.0f >0.95 ? 0.95f : i/10.0f;
        color = color < 0.4f ? 0.4f : color;
        
        NSLog(@"color == %f",color);
        
        struct WaWa_Colors colors = {1-color ,1-color ,1-color};
        NSValue *colors_value = [NSValue valueWithBytes:&colors objCType:@encode(struct WaWa_Colors)];
        [arr addObject:colors_value];
    }
    
    [self.colorsmArray removeAllObjects];
    self.colorsmArray = arr.mutableCopy;
}

- (BOOL)clockwise:(CGFloat)value
{
    if (_preValue > value)
    {
        return YES;
    }

    return NO;
}

- (void)setCirclePoint:(CGFloat)value
{
//    NSLog(@"--%s__",__PRETTY_FUNCTION__);

    CGPoint start_point = [self pointWithCenter:CGPointMake(_center_XY, _center_XY) angle:value*WAWA_CIRCLE_ANGLE radius:_circle_radius+0.5];
    CGPoint end_point   = [self pointWithCenter:CGPointMake(_center_XY, _center_XY) angle:value*WAWA_CIRCLE_ANGLE radius:_circle_radius*2];
   
//    if (_startmArray && ![self.startmArray containsObject:NSStringFromCGPoint(start_point)])
    {
        [self.startmArray addObject:NSStringFromCGPoint(start_point)];
    }
    
//    if (_endmArray && ![self.endmArray containsObject:NSStringFromCGPoint(start_point)])
    {
        [self.endmArray addObject:NSStringFromCGPoint(end_point)];
    }
}

- (void)setDefaultColor
{
//    NSLog(@"--%s__",__PRETTY_FUNCTION__);

    struct WaWa_Colors colors = {0.3 ,0.3 ,0.3};
    NSValue *colors_value = [NSValue valueWithBytes:&colors objCType:@encode(struct WaWa_Colors)];
    [self.colorsmArray addObject:colors_value];
}

- (void)setColor
{
    NSLog(@"--%s__",__PRETTY_FUNCTION__);
    //   CGFloat r = 0xF800 >> 8;
    //   CGFloat g = 0x07E0 >> 3;
    //   CGFloat b = 0x001F <<  3;
    
//    CGFloat color = 0;
    CGFloat color = _loadIndex/10.0f >0.95 ? 0.95f : _loadIndex/10.0f;
     color = color < 0.3f ? 0.3f : color;
    
    NSLog(@"color == %f",color);
    
    struct WaWa_Colors colors = {color ,color ,color};
    NSValue *colors_value = [NSValue valueWithBytes:&colors objCType:@encode(struct WaWa_Colors)];
    [self.colorsmArray addObject:colors_value];
}


- (void)transformHorizontal
{
    [UIView animateWithDuration:.02 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.transform = CGAffineTransformScale(self.transform, 1.0, -1.0);
    }];
}

- (void)transformView
{
    [UIView animateWithDuration:.02 animations:^{
        self.transform = CGAffineTransformMakeRotation(WawaRadians(_loadIndex*WAWA_CIRCLE_ANGLE));
    }];
}

- (void)transformIdentitWithRestore:(BOOL)restore
{
    if (restore)
    {
        [UIView animateWithDuration:0.5f animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }
    else
    {
        [UIView animateWithDuration:.5f animations:^{
            CGAffineTransform newTransform = CGAffineTransformScale(self.transform, 1.06, 1.06);
            self.transform = newTransform;
        }];
    }
}

- (void)clear
{
    if ([_startmArray isKindOfClass:[NSMutableArray class]])
    {
        [_startmArray removeAllObjects];
    }
    
    if ([_endmArray isKindOfClass:[NSMutableArray class]])
    {
        [_endmArray removeAllObjects];
    }
    
    if ([_colorsmArray isKindOfClass:[NSMutableArray class]])
    {
        [_colorsmArray removeAllObjects];
    }
    
    if ([_beforehandColorsmArray isKindOfClass:[NSMutableArray class]])
    {
        [_beforehandColorsmArray removeAllObjects];
    }
    
    if ([_tempmSet isKindOfClass:[NSMutableSet class]])
    {
        [_tempmSet removeAllObjects];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for (int i =0 ; i < self.startmArray.count; i ++)
    {
        CGPoint start_point =  CGPointFromString(wawa_getValidObjectFromArray(self.startmArray, i));
        CGPoint end_point = CGPointFromString(wawa_getValidObjectFromArray(self.endmArray, i));
        
        CGContextMoveToPoint(ctx, start_point.x, start_point.y);
        CGContextAddLineToPoint(ctx,end_point.x, end_point.y);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, _line_Width);
        
        WaWa_Colors colors;
        NSValue *customValue = wawa_getValidObjectFromArray(self.colorsmArray, i);
        [customValue getValue:&colors];
        CGContextSetRGBStrokeColor(ctx,colors.r,colors.g,colors.b,1.0);
        CGContextStrokePath(ctx);
    }

//    CGContextRelease(ctx);
}

- (CGPoint)pointWithCenter:(CGPoint)center  angle:(CGFloat)aAngle radius:(CGFloat)aRadius
{
    CGFloat x = aRadius*cosf(WawaRadians(aAngle));
    CGFloat y = aRadius*sinf(WawaRadians(aAngle));
    
    return CGPointMake(center.x+x, center.y-y);
}


#pragma mark - Setter/Getter

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self setNeedsDisplay];
}

- (NSMutableArray *)startmArray
{
    if (!_startmArray)
    {
        _startmArray = @[].mutableCopy;
    }
    
    return _startmArray;
}

- (NSMutableArray *)endmArray
{
    if (!_endmArray)
    {
        _endmArray = @[].mutableCopy;
    }
    
    return _endmArray;
}

- (NSMutableArray *)colorsmArray
{
    if (!_colorsmArray)
    {
        _colorsmArray = @[].mutableCopy;
    }
    
    return _colorsmArray;
}

- (NSMutableArray *)beforehandColorsmArray
{
    if (!_beforehandColorsmArray)
    {
        _beforehandColorsmArray = @[].mutableCopy;
    }
    
    return _beforehandColorsmArray;
}

- (NSMutableSet *)tempmSet
{
    if(!_tempmSet)
    {
        _tempmSet = [NSMutableSet set];
    }
    
    return _tempmSet;
}

@end
