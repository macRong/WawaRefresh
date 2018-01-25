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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];

    self.view.backgroundColor = [UIColor brownColor];
    
    [self.tableView wawaHeadRefresh:^{
        
        [self ok];
    }];
    
    [self.tableView wawaFootRefresh:^{
       
        [self foot];
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"bbbbbb %@",self.tableView.wawaHeadRefresh);
        [self.tableView.wawaHeadRefresh stopAnimation];
    });
    
    
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

- (void)ok
{
    NSLog(@"💥");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL s = self.tableView.wawaHeadRefresh.isLoading;
        [self.tableView.wawaHeadRefresh stopAnimation];
    });
}

- (void)foot
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *defaultCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MP_search_defaultCell"];
//    defaultCell.backgroundColor = [UIColor purpleColor];
    defaultCell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
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
