//
//  A.m
//  R
//
//  Created by 荣守振 on 2018/1/20.
//  Copyright © 2018年 Shengshui. All rights reserved.
//

#import "A.h"

@interface A ()
<
UITableViewDataSource,
UITableViewDelegate
>
{
    UIRefreshControl *_refresh;

}

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation A

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor redColor];

    _refresh = [[UIRefreshControl alloc]initWithFrame:CGRectMake(20, 20, 50, 50)];
    [_refresh addTarget:self action:@selector(reloadAction) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refresh];
    
    self.title = @"For iOS 6 & later";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Using NSAttributed String"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,5)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,12)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(19,6)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldItalicMT" size:15.0] range:NSMakeRange(0, 5)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] range:NSMakeRange(6, 12)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:15.0] range:NSMakeRange(19, 6)];
    _refresh.attributedTitle = str;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refresh endRefreshing];
    });
    
    // Wawa
    __weak typeof(self)weakSelf = self;
    [self.tableView wawaFootRefresh:^{
        typeof(weakSelf)Sself = weakSelf;
        [Sself foot];
    }];
}

- (void)foot
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.wawaFootRefresh endRefreshing];
    });
}

- (void)reloadAction
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refresh endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *defaultCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MP_search_defaultCell"];
    defaultCell.backgroundColor = [UIColor purpleColor];
    
    return defaultCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    A *a = [[A alloc]init];
    [self.navigationController pushViewController:a animated:YES];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
