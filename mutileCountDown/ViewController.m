//
//  ViewController.m
//  mutileCountDown
//
//  Created by tangwei on 16/8/22.
//  Copyright © 2016年 tangwei. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"//上拉刷新，下拉加载

// 当前屏幕 width
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

// 当前屏幕 height
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define totalTime   900

#define timeStep   7

#define pageSize  15

@interface ViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property  (nonatomic, strong) UITableView           *tableView;
@property  (nonatomic, strong) NSMutableArray        *arrayData;
@property (nonatomic, strong)  dispatch_source_t     timer;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int size;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self init_data];
    [self init_ui];
    [self setupRefresh];
    [self timePrompt];
}

- (void) dealloc
{
    if ( _timer != nil ) {
        dispatch_source_cancel(_timer);
    }
}

- (void) init_data
{
    self.index = 0;
    self.size  = pageSize;
    
    self.arrayData = [[NSMutableArray alloc] initWithCapacity:0];
    //NSString *total = @"900";
    for (int i = self.index; i < self.size; i ++) {
        [self.arrayData addObject:[NSString stringWithFormat:@"%d", totalTime - i * timeStep]];
    }
}

- (void) init_ui
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.scrollEnabled = YES;
    [self.view addSubview:_tableView];
}

- (void) setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self init_data];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.index += pageSize;
        self.size += pageSize;
        
        for (int i = self.index; i < self.size; i ++) {
            
            int time = totalTime - i * timeStep;
            if ( time < 0 ) {
                time = 0;
            }
            
            [self.arrayData addObject:[NSString stringWithFormat:@"%d", time]];
        }
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
    
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
        label.textColor = [UIColor darkTextColor];
        label.font = [UIFont systemFontOfSize:16.0];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        [label setTag:1000];
        [cell addSubview:label];


    }

    UILabel *label = (UILabel*)[cell viewWithTag:1000];
    int second = [[self.arrayData objectAtIndex:[indexPath row]] intValue];
    label.text = [self getLeftTime:second];
    
    return cell;
}

- (NSString*) getLeftTime:(int) _second
{
    NSInteger hour = _second / 3600;
    NSInteger miniute = ( _second - hour * 3600 ) / 60;
    NSInteger second = _second - hour * 3600 - miniute * 60;
    
    NSString *time = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)hour, (long)miniute, (long)second];
    
    return time;
}

- (void)timePrompt{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshTime];
        });
    });
    dispatch_resume(_timer);
}

- (void) refreshTime
{
    for (int i = 0; i < self.arrayData.count; i ++) {
        int time = [[self.arrayData objectAtIndex:i] intValue];
        time --;
        if ( time < 0 ) {
            time = 0;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.arrayData replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", time]];
        
        if ( cell ) {
            
            UILabel *label = (UILabel*)[cell viewWithTag:1000];
            if ( label) {
                label.text = [self getLeftTime:time];
            }

        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
