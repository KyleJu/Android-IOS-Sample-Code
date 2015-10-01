//
//  KUEventsViewController.m
//  kure
//
//  Created by Kyle Ju on 2015-07-20.
//  Copyright (c) 2015 kure. All rights reserved.
//

#import "KUEventsViewController.h"
#import "KUEventTableViewCell.h"
#import "KUEventNameViewController.h"
#import "KUProductNameViewController.h"
#import "KUAPIHelper.h"
#import "KUEvent.h"
#import "KUProduct.h"
#import "KUPromotion.h"
#import <CoreLocation/CoreLocation.h>
#import "KUAppData.h"
#import "KUCategory.h"
#import "KUUIFactory.h"

typedef NS_ENUM(NSInteger, KUEventSortType) {
    KUSortDate,
    KUSortCategory,
    KUSortLatest
};
static NSString * const KUEventTablieViewCellIdentifier = @"KUEventTableViewCell";
@interface KUEventsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *eventTableView;

//data
@property (strong, nonatomic) NSMutableArray *eventArray;

//for category and date
@property (strong, nonatomic) NSMutableArray *sectionArray;
@property (strong, nonatomic) NSMutableDictionary *eventDictionary;

@property (assign, nonatomic) NSInteger sortType;
//location
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation *location;

@end

@implementation KUEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sortType = KUSortDate;
    if (self.displayType == KUListEvents) {
        [self locationServiceSetup];
    }
    [self fetchData];
    [self removeBackText];
    [self setUpNavBar];
    [self setUpTableViwe];
    [self setUpSegmentedControll];
    [self setUpBadges];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displayType == KUListEvents) {
        if (self.sortType == KUSortLatest) {
            return 1;
        } else {
            return self.sectionArray.count;
        }
    } else {
            return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    view.tintColor = UICOLOR_FROM_RGB(0x32323A);
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    header.textLabel.font = [UIFont fontWithName:@"Roboto-Thin" size:16.0f];
    
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(0, header.frame.size.height, header.frame.size.width, 1);
    topLine.backgroundColor = [UIColor whiteColor].CGColor;
    [header.layer addSublayer:topLine];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.displayType == KUListEvents) {
        if (self.sortType == KUSortLatest) {
            return nil;
        } else {
            return self.sectionArray[section];
        }
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.displayType == KUListEvents) {
        if (self.sortType == KUSortLatest) {
            return self.eventArray.count;
        } else {
            NSArray *array = [self.eventDictionary objectForKey:self.sectionArray[section]];
            return array.count;
        }
    } else {
            return self.eventArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KUEventTableViewCell * cell = [self.eventTableView dequeueReusableCellWithIdentifier:KUEventTablieViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (self.displayType) {
        case KUListEvents: {
            KUEvent * event;
            if (self.sortType == KUSortLatest) {
                event = self.eventArray[indexPath.row];
            } else {
                NSArray *array = [self.eventDictionary objectForKey:self.sectionArray[indexPath.section]];
                event = array[indexPath.row];
            }
            double distance = [self getDistance:[event.address.longitude doubleValue] latitude:[event.address.latitude doubleValue]];
            [cell configureCell:event.imageUrl eventTitle:event.name location:[event.address cityStateZip] distance:[NSString stringWithFormat:@"%i%@", (int)distance, @"km"]];
        }
            break;
        case KUListProducts:{
            KUProductResult *product = self.eventArray[indexPath.row];
            [cell configureCell:product.imageUrl eventTitle:product.title location:nil distance:nil];
            
        }
            break;
        case KUListPromotions:{
            KUPromotionResult *promotion = self.eventArray[indexPath.row];
            [cell configureCell:promotion.imageUrl eventTitle:promotion.title location:nil distance:nil];
        }
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark - UITableView Delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.displayType == KUListEvents) {
        if (self.sortType == KUSortLatest) {
            return 0;
        } else {
            return 44.0f;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.displayType) {
        case KUListEvents:{
            KUEventNameViewController *controlller = [[KUEventNameViewController alloc] init];
            controlller.eventNameType = KUEventNameDetail;
            KUEvent * event;
            if (self.sortType == KUSortLatest) {
                event = self.eventArray[indexPath.row];
            } else {
                NSArray *array = [self.eventDictionary objectForKey:self.sectionArray[indexPath.section]];
                event = array[indexPath.row];
            }
            controlller.event = event;
            [self.navigationController pushViewController:controlller animated:YES];
            break;
        }
        case KUListProducts: {
            KUProductNameViewController *controlller = [[KUProductNameViewController alloc] init];
            controlller.product = self.eventArray[indexPath.row];
            [self.navigationController pushViewController:controlller animated:YES];
            break;
        }
        case KUListPromotions: {
            KUEventNameViewController *controlller = [[KUEventNameViewController alloc] init];
            controlller.eventNameType = KUPromotionsNameDetail;
            controlller.promotion = self.eventArray[indexPath.row];
            [self.navigationController pushViewController:controlller animated:YES];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.f;
}

- (IBAction)swtichEventsOrder:(id)sender {
    if (self.displayType == KUListEvents) {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:{
                [self sortBasedOnDate];
            }
                break;
            case 1:{
                [self sortBasedOnCategory];
            }
                break;
            case 2: {
                [self sortBasedOnLatest];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Setup

- (void)removeBackText {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)setUpBadges {
    switch (self.displayType) {
        case KUListEvents:
            [[KUAppData sharedCache] cacheEventsBadgeCount:0];
            break;
        case KUListProducts:
            [[KUAppData sharedCache] cacheProductsBadgeCount:0];
            break;
        case KUListPromotions:
            [[KUAppData sharedCache] cachePromotionsBadgeCount:0];
            break;
        default:
            break;
    }
}

- (void)setUpNavBar {
    switch (self.displayType) {
        case KUListEvents:
            self.title = @"Events";
            break;
        case KUListProducts:
            self.title = @"Products";
            break;
        case KUListPromotions:
            self.title = @"Promotions";
            break;
        default:
            break;
    }
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)setUpTableViwe {
    //tableview
    self.eventTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.eventTableView registerNib:[UINib nibWithNibName:@"KUEventTableViewCell" bundle:nil] forCellReuseIdentifier:KUEventTablieViewCellIdentifier];
    self.eventTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setUpSegmentedControll {
    if (self.displayType != KUListEvents){
        [self.segmentedControl removeFromSuperview];
    }
    else {
        if (self.notification) {
            self.segmentedControl.selectedSegmentIndex = 2;
        }
    }
}

#pragma mark - fetch Data
- (void)fetchData {
    switch (self.displayType) {
        case KUListEvents: {
            self.eventArray = [[[KUAppData sharedCache] getEvents] mutableCopy];
                if (self.notification) {
                    [self sortBasedOnLatest];
                }
                else {
                    [self sortBasedOnDate];
                }
        }
            break;
        case KUListProducts: {
            self.eventArray = [[[KUAppData sharedCache] getProductResult] mutableCopy];
            [self sortBasedOnDate];
        }
            break;
        case KUListPromotions: {
            self.eventArray = [[[KUAppData sharedCache] getPromotionResult] mutableCopy];
            [self sortBasedOnDate];
        }
            break;
        default:
            break;
    }
}
#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = [locations lastObject];
    [self.eventTableView reloadData];
}
#pragma mark - location
- (void)locationServiceSetup {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        // Will open an confirm dialog to get user's approval
        [self.locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager startUpdatingLocation]; //Will update location immediately
    }
}

#pragma mark - distance Helper
- (double)getDistance:(CLLocationDegrees)longitude latitude:(CLLocationDegrees)lat {
    if (self.location != nil) {
        CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:lat longitude:longitude];
        CLLocationDistance distance = [self.location distanceFromLocation:regionLocation];
        return distance/1000.0f;
    } else {
        return 0.0f;
    }
}



- (void)sortBasedOnCategory {
    NSMutableDictionary *eventDic = [[NSMutableDictionary alloc ] init];
    NSArray *eventType = [[KUAppData sharedCache] getAllCategories];
    for (int i = 0; i < eventType.count; i++) {
        KUCategory * category = eventType[i];
        if (category.type == 1) continue;
        for (int k =0; k < self.eventArray.count; k ++) {
            KUEvent *event = self.eventArray[k];
            for (int x = 0; x < event.categoryIds.count; x++) {
                if ([[event.categoryIds[x] stringValue] isEqualToString:category.id]) {
                    if ([eventDic objectForKey:category.name] != nil) {
                        NSMutableArray *array = [[eventDic objectForKey:category.name] mutableCopy];
                        [array addObject:event];
                        [eventDic setObject:array forKey:category.name];
                    } else {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        [array addObject:event];
                        [eventDic setObject:array forKey:category.name];
                    }
                }
            }
        }
        
    }
    self.sectionArray = [[[eventDic allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] mutableCopy];
    self.eventDictionary = eventDic;
    self.sortType = KUSortCategory;
    
    [self.eventTableView reloadData];
    
}

- (void)sortBasedOnDate {
    self.sortType = KUSortDate;
    if (self.displayType != KUListEvents) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedOn" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.eventArray = [NSMutableArray arrayWithArray:[self.eventArray sortedArrayUsingDescriptors:sortDescriptors]];
        [self.eventTableView reloadData];
    } else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startsOn" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *eventArray = [self.eventArray sortedArrayUsingDescriptors:sortDescriptors];
        NSMutableArray *keyArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *eventDic = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < eventArray.count; i ++) {
            KUEvent * event = eventArray[i];
            NSString *key = [NSDateFormatter localizedStringFromDate:event.startsOn
                                           dateStyle:NSDateFormatterLongStyle
                                           timeStyle:NSDateFormatterNoStyle];
            if ([eventDic objectForKey:key] != nil) {
                NSMutableArray *eventInDate = [eventDic objectForKey:key];
                [eventInDate addObject:event];
//                [eventDic setObject:eventInDate forKey:key];
            } else {
                NSMutableArray *eventArray = [[NSMutableArray alloc] init];
                [eventArray addObject:event];
                [eventDic setObject:eventArray forKey:key];
                [keyArray addObject:key];
            }
        }
        self.sectionArray = keyArray;
        self.eventDictionary = eventDic;
        [self.eventTableView reloadData];
    }
}

- (void)sortBasedOnLatest {
    self.sortType = KUSortLatest;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedOn" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.eventArray = [NSMutableArray arrayWithArray:[self.eventArray sortedArrayUsingDescriptors:sortDescriptors]];
    [self.eventTableView reloadData];
}

@end
