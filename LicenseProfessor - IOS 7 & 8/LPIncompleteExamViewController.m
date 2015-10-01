//
//  LPIncompleteExamViewController.m
//  licenseProfessorMockUp
//
//  Created by Kyle Ju on 2015-06-11.
//  Copyright (c) 2015 Kenny Park. All rights reserved.
//

#import "LPIncompleteExamViewController.h"
#import "LPNavTitleView.h"
#import "AppData.h"
#import "Exam.h"
#import "LPFetchHelper.h"
#import "LPModeSelectionViewController.h"

static NSString *const LPIncompleteExamTableViewCellIdentifier = @"LPIncompleteExamTableViewCell";
@interface LPIncompleteExamViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) LPNavTitleView * navTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *incompleteExamArray;
@property (strong, nonatomic) LPModeSelectionViewController* modeController;
@end

@implementation LPIncompleteExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.modeController = (LPModeSelectionViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"Mode"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.incompleteExamArray = [[AppData shareInstance] retrieveAllExamTitleInProgress];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.navTitle) {
        [self setUpNavTitle];
    }
    self.navigationController.navigationBar.topItem.titleView = self.navTitle;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.incompleteExamArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:LPIncompleteExamTableViewCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LPIncompleteExamTableViewCellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    //get ride of margin
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    //textLabel
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0f];
    NSString *mainTitle = self.incompleteExamArray[indexPath.row];;
    cell.textLabel.text = mainTitle;
    //detailed textLabel
    cell.detailTextLabel.text = [[AppData shareInstance] retrieveExamInProgressSubtitle:mainTitle];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:11.0f];
    
    // color changes
    cell.detailTextLabel.textColor = UIColorFromRGB(COLOR1);
    return cell;
}


#pragma  mark - UIDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //animation for background color when the cell is being selected
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds] ;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.949 green:0.922 blue:0.78 alpha:1];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedTitle = self.incompleteExamArray[indexPath.row];
    Exam *selectedExam = [LPFetchHelper incompleteExamFetcher:selectedTitle];
    //*******
    NSArray *unsortedArray = [selectedExam.questions allObjects];
    NSSortDescriptor *questionIDSort  = [[NSSortDescriptor alloc] initWithKey:@"questionID" ascending:YES];
    NSMutableArray *sortArrayQuestion = [NSMutableArray arrayWithArray:[unsortedArray sortedArrayUsingDescriptors:@[questionIDSort]]];
    self.modeController.fetchedQuestions = sortArrayQuestion;
    self.modeController.isSavedProgess = YES;
    [self presentViewController:self.modeController animated:YES completion:NULL];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *cacheKey = [[AppData shareInstance] createCacheKeyForExams:self.incompleteExamArray[indexPath.row]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:cacheKey];
        [[AppData shareInstance] removeExamTitleInProgress:self.incompleteExamArray[indexPath.row]];
        [self.incompleteExamArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

#pragma mark - set up Nav Title

- (void)setUpNavTitle {
    LPNavTitleView *navTitle = [[LPNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    navTitle.mainTitle = @"Incomplete Exams";
    navTitle.subTitle = @"License Professor";
    self.navTitle = navTitle;
}
@end
