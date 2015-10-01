//
//  SLGlasgowScaleResultViewController.m
//  MPA
//
//  Created by Kyle Ju on 2015-04-14.
//  Copyright (c) 2015 Bruce Adams Laboratory. All rights reserved.
//

#import "SLGlasgowScaleResultViewController.h"
#import "SLNavTitileVIew.h"
#import "SLGlasgowScaleScoreTableViewCell.h"
#import "SLGlasgowScaleResultImageTableViewCell.h"

static NSString *const SLGlasgowScaleScoreTableViewCellIdentifier = @"SLGlasgowScaleScoreTableViewCell";
static NSString *const SLGlasgowScaleResultImageTableViewCellIdentifier = @"SLGlasgowScaleResultImageTableViewCell";
@interface SLGlasgowScaleResultViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 0 for minor injury
// 1 for moderate injury
// 2 for servere injury
@property (assign, nonatomic) NSInteger injuryType;
@property (strong, nonatomic) NSArray *inputArray;
@property (strong, nonatomic) NSString *lastRecord;

@end

@implementation SLGlasgowScaleResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    //init data
    self.injuryType = 2;
    self.inputArray = [[NSArray alloc] initWithObjects:@"Vegas, Vincent, SAVeV - 001", @"GCS 12 = E4 V4 M4; Jan 1, 2015; 10:30 AM",nil];
    self.lastRecord = @"GCS 14 = E4 V4 M4; Jan 20, 2014; 10:30 AM";
    
 
    //Nav title
    SLNavTitileVIew *navTitle = [[SLNavTitileVIew alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    navTitle.mainTitle = @"Glasgow SCale Result";
    navTitle.subTitle = @"VeV001";
    navTitle.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = navTitle;
    
    //Nav bar item
    UIBarButtonItem *mailIconBarItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"email_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(mailIconButton:)];
    self.navigationItem.rightBarButtonItem = mailIconBarItem;
    
    //Register nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SLGlasgowScaleScoreTableViewCell" bundle:nil] forCellReuseIdentifier:SLGlasgowScaleScoreTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SLGlasgowScaleResultImageTableViewCell" bundle:nil] forCellReuseIdentifier:SLGlasgowScaleResultImageTableViewCellIdentifier];

}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        }
        cell.textLabel.text = @"Results:";
        cell.textLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:20];
    }
    
    if (indexPath.row == 1) {
        cell = (SLGlasgowScaleScoreTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:SLGlasgowScaleScoreTableViewCellIdentifier];
        [(SLGlasgowScaleScoreTableViewCell*)cell configureCell:self.injuryType scoreInfo:self.inputArray[0] scoreTime:self.inputArray[1]];
    }
    if (indexPath.row == 2) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SubtitleCeLL"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SubtitleCeLL"];
        }
        cell.detailTextLabel.text = self.lastRecord;
        cell.textLabel.text = @"PRIOR SCORE:";
        cell.textLabel.font = [UIFont fontWithName:@"SourceSansPro-Bold" size:15];
        cell.detailTextLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:15];
    }
    
    if (indexPath.row == 3) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:SLGlasgowScaleResultImageTableViewCellIdentifier];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    switch (indexPath.row) {
        case 0:
            height = 44.0f;
            break;
        case 1:
            (self.injuryType == 0)? (height = 110.0f):(height = 135.0f);
            break;
        case 2:
            height = 45.0f;
            break;
        case 3:
            height = 205.0f;
            break;
        default:
            height = 44.0f;
            break;
    }
    return  height;
}

- (void)mailIconButton:(id)sender {
    NSLog(@"MailIconButton is being pressed");
}

@end
