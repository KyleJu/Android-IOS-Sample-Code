//
//  SLGlasgowScaleViewController.m
//  MPA
//
//  Created by Kyle Ju on 2015-04-13.
//  Copyright (c) 2015 Bruce Adams Laboratory. All rights reserved.
//

#import "SLGlasgowScaleViewController.h"
#import "SLNavTitileVIew.h"
#import "SLGlasgowScaleImageTableViewCell.h"
#import "SLGlasgowScaleOptionTableViewCell.h"

static NSString *const SLGlasgowScaleImageCellIdentifier = @"SLGlasgowScaleImageCellIdentifier";
static NSString *const SLGlasgowScaleOptionCellIdentifier = @"SLGlasgowScaleOptionCellIdentifier";
#define EXTRA_CELL_NUM 2

@interface SLGlasgowScaleViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *inputArray;
@property (strong, nonatomic) NSString *tableViewTitle;
@property (strong, nonatomic) NSIndexPath *cellNumSelected;
//gradeScale type
//  0 - 4grades
//  1 - 5grades
//  2 - 6grades
@property (assign, nonatomic) NSInteger gradeScaleType;
@property (assign, nonatomic) NSInteger pageNumber;
@property (strong, nonatomic) UIButton *footerNextButton;
@property (strong, nonatomic) UIButton *footerBackButton;
@end

@implementation SLGlasgowScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationController.navigationBar.translucent = NO;
    
    //set default value
    self.cellNumSelected = [NSIndexPath indexPathForRow:2 inSection:0];
    self.pageNumber = 0;
    
    //Nav title
    SLNavTitileVIew *navTitle = [[SLNavTitileVIew alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    navTitle.mainTitle = @"Glasgow Scale";
    navTitle.subTitle = @"Vincent Vegas";
    navTitle.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = navTitle;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SLGlasgowScaleImageTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SLGlasgowScaleImageCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SLGlasgowScaleOptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SLGlasgowScaleOptionCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //input array
    self.inputArray = [[NSArray alloc] initWithObjects:@"Make no movements (No motor response)", @"Extension to painful stimuli (Decerebate: rigid/abnormal extensor posture)",@"Flexion to painful stimuli (Decorticate: arms inward on chest, hands - clenched fists, legs extended feet inward", @"Withdrawal from pain", @"Localizes to pain", @"Obeys commands", nil];
    self.tableViewTitle = @"Glasgow Scale";
    self.gradeScaleType = 0;
}

- (void)viewDidLayoutSubviews {
    self.tableView.tableFooterView = [self configureFooterView];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inputArray.count + EXTRA_CELL_NUM;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        }
        cell.textLabel.text = self.tableViewTitle;
        cell.textLabel.font = [UIFont fontWithName:@"SourceSansPro-Bold" size:20];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }else if (indexPath.row == 1) {
        cell = (SLGlasgowScaleImageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:SLGlasgowScaleImageCellIdentifier];
        [(SLGlasgowScaleImageTableViewCell*)cell configureCell:self.gradeScaleType];
        return cell;
    }else {
        cell = (SLGlasgowScaleOptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:SLGlasgowScaleOptionCellIdentifier];
        [(SLGlasgowScaleOptionTableViewCell*)cell configureCell:indexPath.row - 1 content:self.inputArray[indexPath.row - EXTRA_CELL_NUM]];
        
        return cell;
    }
    return  nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize maximumQuestionLabelSize = CGSizeMake(self.tableView.frame.size.width, 9999);
    
    if (indexPath.row == 0) {
        return 40.0f;
    }
    else if (indexPath.row == 1) {
        return 120.0f;
    }else {
        NSString *str = [self.inputArray objectAtIndex:indexPath.row - EXTRA_CELL_NUM];
        CGRect textRect = [str boundingRectWithSize:maximumQuestionLabelSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Regular" size:15]}
                                             context:nil];
        return textRect.size.height + 30.0f;
    }
    
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 2) {
        SLGlasgowScaleOptionTableViewCell *cell = (SLGlasgowScaleOptionTableViewCell *)[tableView cellForRowAtIndexPath:self.cellNumSelected];
        cell.checkOffImageView.image = [UIImage imageNamed:@"check_off"];
        cell = (SLGlasgowScaleOptionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.checkOffImageView.image = [UIImage imageNamed:@"check_green_on"];
        self.cellNumSelected = indexPath;

    }
    
}

#pragma mark - Private Method

- (UIView *)configureFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 80)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    self.footerNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.footerNextButton setImage:[UIImage imageNamed:@"glasgow_btn_next"] forState:UIControlStateNormal];
    [self.footerNextButton sizeToFit];
    [self.footerNextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.pageNumber == 0){
        self.footerNextButton.center = footerView.center;
        [footerView addSubview:self.footerNextButton];
    } else if (self.pageNumber == 1){
        self.footerBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.footerBackButton setImage:[UIImage imageNamed:@"glasgow_btn_previous"] forState:UIControlStateNormal];
        [self.footerBackButton sizeToFit];
        [self.footerBackButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        CGPoint centerPoint = footerView.center;
        self.footerBackButton.center = CGPointMake(centerPoint.x - self.footerBackButton.frame.size.width/2 - 5, centerPoint.y);
        self.footerNextButton.center = CGPointMake(centerPoint.x + self.footerBackButton.frame.size.width/2 + 5, centerPoint.y);
        [footerView addSubview:self.footerNextButton];
        [footerView addSubview:self.footerBackButton];
    } else {
        self.footerNextButton.center = footerView.center;
        [self.footerNextButton setImage:[UIImage imageNamed:@"glasgow_btn_done"] forState:UIControlStateNormal];
        [footerView addSubview:self.footerNextButton];
    }
    
    return footerView;
}

#pragma mark - button action
- (void)nextButtonPressed {
    //TODO:
    // self.inputArray should be changed too *******
    if (self.pageNumber < 2){
        self.pageNumber ++;
        self.gradeScaleType ++;
        [self.tableView reloadData];
        self.tableView.tableFooterView = [self configureFooterView];
    } else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)backButtonPressed {
    if (self.pageNumber > 0) {
        self.pageNumber --;
        self.gradeScaleType --;
        [self.tableView reloadData];
        self.tableView.tableFooterView = [self configureFooterView];
    }
}





@end
