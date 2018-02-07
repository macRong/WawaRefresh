//
//  ViewController.m
//  R
//
//  Created by macRong on 2018/1/11.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "ViewController.h"
#import "WawaLoadingView.h"
#import "A.h"

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    WawaLoadingView *_rView;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *rows;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];

    self.view.backgroundColor = [UIColor purpleColor];
    [self initVar];
    
    
    __weak typeof(self)weakSelf = self;
    [self.tableView wawaHeadRefresh:^{
        typeof(weakSelf)Sself = weakSelf;
        [Sself ok];
    }];
    
    [self.tableView wawaFootRefresh:^{
        typeof(weakSelf)Sself = weakSelf;
        [Sself foot];
    }];
    
    self.tableView.wawaFootRefresh.backgroundColor = [UIColor redColor];
    
//    self.tableView.wawaFootRefresh.distanceBottom = 264.0f;
    
    self.title = @"For iOS 6 & later";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Wawa loading..."];
//    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,5)];
//    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,12)];
//    [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(19,6)];
//    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldItalicMT" size:15.0] range:NSMakeRange(0, 5)];
//    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] range:NSMakeRange(6, 12)];
//    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:15.0] range:NSMakeRange(19, 6)];
//    self.tableView.wawaFootRefresh.attributedTitle = str;

    UIView *fot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 110.0f)];
                                                         fot.backgroundColor = [UIColor purpleColor];
                                                         self.tableView.tableFooterView = fot;
    
    
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    indicator.frame = CGRectMake(0, 0, 190, 190);
//    indicator.center = CGPointMake(self.view.frame.size.width * 0.5,self.view.frame.size.height * 0.5+100);
//    indicator.transform = CGAffineTransformMakeScale(2.5f, 2.5f) ;
//    [indicator startAnimating];
//    [self.view addSubview:indicator];
//
    
//    _rView = [[WawaLoadingView alloc]initWithFrame:CGRectMake(120, 78,28.0f, 28.0f)];
//    [self.view addSubview:_rView];
}

- (void)initVar
{
    self.rows = @[].mutableCopy;
    
    for (int i = 0; i <8; i++)
    {
        [self.rows addObject:[NSDate dateWithTimeIntervalSinceNow:-(i*30)]];
    }
}

- (void)ok
{
    NSLog(@"💥");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL s = self.tableView.wawaHeadRefresh.isAnimation;
        NSLog(@"s = %d",s);
        [self.tableView.wawaHeadRefresh stopAnimation];
    });
}

- (void)foot
{
    [self insertRowAtBottom];
}

- (void)insertRowAtBottom
{
    // ????
    if (self.rows.count == 13)
    {
//        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .1f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [weakSelf.tableView beginUpdates];
  
        for (int i= 0; i < 1; i ++)
        {
            [weakSelf.rows addObject:[weakSelf.rows.lastObject dateByAddingTimeInterval:-60]];
        }

        [self.tableView reloadData];
        
//        [weakSelf.rows addObject:[weakSelf.rows.lastObject dateByAddingTimeInterval:-60]];
//        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.rows.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
//        [weakSelf.tableView endUpdates];
        
        [self.tableView.wawaFootRefresh stopAnimating];
//        [self.tableView.wawaFootRefresh noData:@"暂无数据"];
    });
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView.wawaFootRefresh startAnimating];
//    });
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *defaultCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Wawa_defaultCell"];

    NSDate *date = [self.rows objectAtIndex:indexPath.row];
    NSString *formatterStr = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    defaultCell.textLabel.text =  [NSString stringWithFormat:@"【%ld】 %@",(long)indexPath.row,formatterStr];
    
    return defaultCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    A *a = [[A alloc]init];
    [self.navigationController pushViewController:a animated:YES];
}

CGFloat PreValue = CGFLOAT_MIN;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat value = scrollView.contentOffset.y;
    if (PreValue == CGFLOAT_MIN)
    {
        PreValue = value;
    }
    
    CGFloat currentHeight = fabs(PreValue - value);

    [_rView setLoaingValue:currentHeight*12/WAWALOADINGHEIGHT];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.backgroundColor = [UIColor blueColor]; // ?
    }
    
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
