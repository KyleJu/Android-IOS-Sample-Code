//
//  LPNewExamTableViewController.m
//  licenseProfessorMockUp
//
//  Created by Kyle Ju on 2015-01-30.
//  Copyright (c) 2015 Kenny Park. All rights reserved.
//

#import "LPNewExamTableViewController.h"
#import "LPModeSelectionViewController.h"
#import "LPTableViewCellExamTab.h"
#import "LPNavTitleView.h"


@interface LPNewExamTableViewController () <OCBorghettiViewDelegate>
@property (strong, nonatomic) NSMutableArray *arrayOfTitles;
@property (strong, nonatomic) NSMutableArray *sectionTitles;
@property (strong, nonatomic) Exam *theSelectedExam;

@property (strong, nonatomic) OCBorghettiView *accordion;

@property (strong, nonatomic) LPModeSelectionViewController* modeController;
@property (strong, nonatomic) LPNavTitleView *navTitle;
@end

@implementation LPNewExamTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //initialized he NSMutableArray and get it from parsing
    self.arrayOfTitles = [[NSMutableArray alloc] init];
    
    self.title = @"Exams";
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.modeController = (LPModeSelectionViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"Mode"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.navTitle) {
        [self setUpNavTitle];
    }
    self.navigationController.navigationBar.topItem.titleView = self.navTitle;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.sectionTitles = [[NSMutableArray alloc] initWithObjects:@"General", @"Definition", @"Math", nil];
    NSString *stateOfUser = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STATE];
    
    if ([LPFetchHelper isStateSpecificExist]){
        NSString *stateTitle = [stateOfUser stringByAppendingString:@" Specific Exam"];
        [self.sectionTitles addObject:stateTitle];
    }
    
    NSArray *specificExamTitleArray = @[@"ASI", @"AMP", @"PSI"];
    switch ([LPFetchHelper specialExamType]) {
        case 1:
            [self.sectionTitles addObject:specificExamTitleArray[0]];
            break;
        case 2:
            [self.sectionTitles addObject:specificExamTitleArray[1]];
            break;
        case 3:
            [self.sectionTitles addObject:specificExamTitleArray[2]];
            break;
            
        default:
            break;
    }
    for (NSString *eachString in self.sectionTitles){
        NSMutableArray *eachExamArray = [LPFetchHelper examFetchHelper:eachString];
        [self.arrayOfTitles addObject:eachExamArray];
    }
    if (self.accordion != nil) {
        [self.accordion removeFromSuperview];
        self.accordion = nil;
    }
        [self setupAccordion];
}

- (void)setupAccordion
{
    self.accordion = [[OCBorghettiView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 114)];
    self.accordion.headerHeight = 50;
    self.accordion.delegate = self;
    self.accordion.headerFont = [UIFont fontWithName:@"Avenir" size:16];
    
    self.accordion.headerBorderColor = [UIColor clearColor];
    self.accordion.headerColor = UIColorFromRGB(COLOR1);
    [self.view addSubview:self.accordion];
    
    
    for (int i= 0; i <self.sectionTitles.count; i++){
        // Section 1

        NSString *sectionTitle = ({
            NSArray *eachExamArray = self.arrayOfTitles[i];
            NSInteger examCount = [eachExamArray count];
            NSString *mainTitle = [NSString stringWithFormat:@"%@%@%li%@", self.sectionTitles[i],@" (", (long)examCount, @")"];
            mainTitle;
        });
        UITableView *eachSection = [[UITableView alloc] init];
        eachSection.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [eachSection setTag:i];
        [eachSection setDelegate:self];
        [eachSection setDataSource:self];
        [self.accordion addSectionWithTitle:sectionTitle
                                    andView:eachSection];
        
        [eachSection registerNib:[UINib nibWithNibName:@"LPTableViewCellExamTab" bundle:nil] forCellReuseIdentifier:@"ExamDetail"];
    }
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *eachExamArray = self.arrayOfTitles[tableView.tag];
    return [eachExamArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LPTableViewCellExamTab *cell = [tableView dequeueReusableCellWithIdentifier:@"ExamDetail"];
    
    if (cell == nil)
        cell = [[LPTableViewCellExamTab alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExamDetail"];
    
    
    //margin
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    //separator
    tableView.separatorColor = UIColorFromRGB(COLOR2);
    [tableView setSeparatorInset:UIEdgeInsetsZero];

    
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0f];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    Exam *eachExam = self.arrayOfTitles[tableView.tag][indexPath.row];
    cell.textLabel.text = eachExam.title;
    
    // cell titel
    cell.quantityDisplay.text = [NSString stringWithFormat:@"%lu", (unsigned long)eachExam.questions.count];
    cell.quantityDisplay.textColor = UIColorFromRGB(COLOR2);
    
    //style
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //animation for background color when the cell is being selected
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds] ;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.949 green:0.922 blue:0.78 alpha:1];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.theSelectedExam = self.arrayOfTitles[tableView.tag][indexPath.row];
    
    //*******
    NSArray *unsortedArray = [self.theSelectedExam.questions allObjects];
    NSSortDescriptor *questionIDSort  = [[NSSortDescriptor alloc] initWithKey:@"questionID" ascending:YES];
    NSMutableArray *sortArrayQuestion = [NSMutableArray arrayWithArray:[unsortedArray sortedArrayUsingDescriptors:@[questionIDSort]]];
    self.modeController.fetchedQuestions = sortArrayQuestion;
    self.modeController.isSavedProgess = YES;
    [self presentViewController:self.modeController animated:YES completion:NULL];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - set up Nav Title 

- (void)setUpNavTitle {
    LPNavTitleView *navTitle = [[LPNavTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    navTitle.mainTitle = @"Exams";
    navTitle.subTitle = @"License Professor";
    self.navTitle = navTitle;
}

- (BOOL)accordion:(OCBorghettiView *)accordion
 shouldSelectView:(UIView *)view
        withTitle:(NSString *)title {
    return !(title == self.sectionTitles[self.accordion.activeSection]);
}

@end
