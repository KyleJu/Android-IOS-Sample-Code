//
//  DJNotificationViewController.m
//  DayJam
//
//  Created by Vinson Li on 2015-03-04.
//  Copyright (c) 2015 DayJam. All rights reserved.
//

#import "DJNotificationViewController.h"
#import "DJAPIClient.h"
#import "DJProfileViewController.h"
#import "DJNotificationTableViewCell.h"
#import "DJUser.h"
#import <UIActionSheet+Blocks.h>
#import "DJEverything.h"
#import "DJDetailViewController.h"

static NSString * const dJNotificationTableViewCell = @"DJNotificationTableViewCell";

@interface DJNotificationViewController () <UITableViewDataSource, UITableViewDelegate, DJNotificationTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *notificationsArray;

@end

@implementation DJNotificationViewController

#pragma mark - LIFECYCLE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navBarDayJamIcon"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DJNotificationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:dJNotificationTableViewCell];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    self.tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    [self.tableView setBackgroundColor:kOffWhiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPlayerNotification" object:self];
}

#pragma mark - API

- (void)getNotifications {
    [[DJAPIClient sharedClient] getNotificationsWithSuccess:^(NSArray *notifications) {
        self.notificationsArray = notifications;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView setSeparatorColor:kDarkColor];
        [self.tableView reloadData];
    }];
}

#pragma mark - ACTIONS

- (void)refreshTable {
    [self.refreshControl beginRefreshing];
    [self getNotifications];
    [self.refreshControl endRefreshing];
}

#pragma - DELEGATE

- (void)didTapOnProfile:(DJUser *)user {
    DJProfileViewController *vc = [[DJProfileViewController alloc] init];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapOnMedia:(DJFeed *)feed {
    DJDetailViewController *vc = [DJDetailViewController sharedInstance];
    [[DJDetailViewController sharedInstance] resetUIWithFeed:feed];
    vc.view.frame = [UIScreen mainScreen].bounds;
    vc.hidePresenterNav = NO;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    vc.view.alpha = 0.0f;
    [UIView animateWithDuration:0.4 animations:^{
        vc.view.alpha = 1.0f;
    }];
}

- (void)didTapOnFollowButton:(DJUser *)user buttonClicked:(UIButton *)button {
    __weak DJUser *weakUser = user;
    
    if (user.following.boolValue) {
        [UIActionSheet showInView:self.view
                        withTitle:nil
                cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:@"Unfollow"
                otherButtonTitles:nil
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex != actionSheet.cancelButtonIndex) {
                                 [[DJAPIClient sharedClient] unfollowUser:user success:^(DJUser *user) {
                                     weakUser.following = @(NO);
                                     button.selected = NO;
                                 }];
                             }
                         }];
    }
    else {
     [[DJAPIClient sharedClient] followUser:user success:^(DJUser *user) {
         weakUser.following = @(YES);
         button.selected = YES;
     }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notificationsArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    DJNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dJNotificationTableViewCell];
    cell.delegate = self;
    cell.separatorInset = UIEdgeInsetsZero;
    [cell configureCell:self.notificationsArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DJProfileViewController *vc = [[DJProfileViewController alloc] init];
    vc.user = ((DJNotification *)self.notificationsArray[indexPath.row]).actor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DJNotification *notification = self.notificationsArray[indexPath.row];
    if ([notification.message_type isEqualToString:@"comment"]){
        return 80.0;
    }else{
        return 64.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

@end
