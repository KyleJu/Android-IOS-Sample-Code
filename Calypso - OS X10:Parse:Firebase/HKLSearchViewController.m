//
//  HKLSearchViewController.m
//  Calypso
//
//  Created by Jesse Scott on 2015-07-03.
//  Copyright (c) 2015 TTT. All rights reserved.
//

#import "HKLSearchViewController.h"
#import "HKLChatsViewController.h"
#import "HKLParseHelper.h"
#import "HKLUserProfileController.h"
#import "HKLNetworkController.h"
#import <Firebase/Firebase.h>
#import "HKLChatClient.h"


#pragma mark - INTERFACE -

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HKL_LOGGEDIN_USER [[HKLNetworkController sharedController] loggedInUser] //HKLUser


@interface HKLSearchViewController () <NSTableViewDataSource,NSStreamDelegate, NSComboBoxDataSource, NSComboBoxDelegate>
@property (weak) IBOutlet NSTextField *userSearchField;
@property (weak) IBOutlet NSTextField *scatterChatField;

@property (weak) IBOutlet NSComboBox *collegeDropdownField;
@property (weak) IBOutlet NSComboBox *behaviorDropdownField;
@property (weak) IBOutlet NSComboBox *statusDropdownField;
@property (weak) IBOutlet NSTableView *searchTableView;
@property (weak) IBOutlet NSButton *userSearchButton;
@property (weak) IBOutlet NSButton *scatterChatsButton;
@property (weak) IBOutlet NSButton *openChatsButton;
@property (weak) IBOutlet NSButton *openProfileButton;

@property (strong, nonatomic) NSArray *allChatMeta;
@property (strong, nonatomic) PFUser *currentUser;
@property BOOL ascendBool;


@property (strong, nonatomic) NSWindowController * wc;

@property (strong, nonatomic) NSMutableArray *groupChatUsers;
@property (strong, nonatomic) NSMutableArray *scatterChatUsers;
@property (strong, nonatomic) NSMutableArray *userArray;
@property (strong, nonatomic) NSMutableArray *collegeArray;
@property (strong, nonatomic) NSArray *behaviorArray;
@property (strong, nonatomic) NSArray *statusArray;

@property (copy, nonatomic) PFQuery *profileDataQuery;

@end

@implementation HKLSearchViewController {
    NSArray *_arrayOfHeader;
    NSArray *_columnIdentifierArray;
    NSArray *_statusDropDownArray;
}

#pragma mark - LIFECYCLE -

#pragma mark - Lazy Initializtion -

- (NSMutableArray *)scatterChatUsers {
    if (!_scatterChatUsers) {
        _scatterChatUsers = [NSMutableArray array];
    }
    return _scatterChatUsers;
}

- (NSMutableArray *)groupChatUsers {
    if (!_groupChatUsers) {
        _groupChatUsers = [NSMutableArray array];
    }
    return _groupChatUsers;
}

- (NSMutableArray *)collegeArray {
    if (!_collegeArray) {
        _collegeArray = [[NSMutableArray alloc] init];
        [_collegeArray addObject:@"All College"];
        [_collegeArray addObject:@"No College"];
    }
    
    return _collegeArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", NSStringFromClass([self class]));
    self.userArray = [[NSMutableArray alloc] init];
    _arrayOfHeader = @[@"Username", @"College", @"Friends", @"Email", @"Last Message w/me"];
    _columnIdentifierArray = @[@"ColumnOne", @"ColumnTwo", @"ColumnThree", @"ColumnFour", @"ColumnFive"];
    self.behaviorArray = @[@"Last Activity", @"Last Message Sent", @"Profile Data", @"College", @"Friends", @"Friends Requests", @"Chats", @"Add New Friends", @"Checking In", @"Status", @"Tapped Public Smart Chat", @"College Confirmation"];
    _statusDropDownArray = @[@[@"Today", @"3 days", @"7 days", @"30 days", @"Longer"], @[@"Today", @"3 days", @"7 days", @"30 days", @"Longer"], @[@"Full", @"Not Full"], @[@"Added", @"Not Added"], @[@"More han Zero", @"Zero"], @[@"More Than 5", @"Less Than 5"], @[@"More Than 15", @"Less Than 15"], @[@"Have Tapped", @"Have Not Tapped"], @[@"Have Not Checked In", @"Have Checked In"], @[@"Have Set", @"Have Not Set"], @[@"Has Tapped", @"Has Not Tapped"], @[@"Has Added Schoo, But Not Click Email Link"]];
    
    self.currentUser = [PFUser currentUser];
    
    [self setUpUI];
    [self fetchParseUser];
    [self fetchCollege];
    [self getChatMeta];
}


#pragma mark - NSTableViewDelegate -

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        PFObject *object = self.userArray[row];
        if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[0]]) {
            [tableColumn.headerCell setStringValue:_arrayOfHeader[0]];
            cellView.textField.stringValue = object[kParseUserNameKey];
            return cellView;
        }
        if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[1]]) {
            [tableColumn.headerCell setStringValue:_arrayOfHeader[1]];
            PFObject * college = object[kParseUserCollegeKey];
            if (college[kParseCollegeNameKey] != nil) {
                cellView.textField.stringValue = college[kParseCollegeNameKey];
            } else {
                cellView.textField.stringValue = @"";
                
            }
            return cellView;
        }
        if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[2]]) {
            [tableColumn.headerCell setStringValue:_arrayOfHeader[2]];
            if (object[kParseUserFriendCountKey] != nil) {
                cellView.textField.stringValue = object[kParseUserFriendCountKey];
            } else {
                cellView.textField.stringValue = @"";
            }
            return cellView;
        }
        if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[3]]) {
            [tableColumn.headerCell setStringValue:_arrayOfHeader[3]];
            if (object[kParseUserEmailKey] != nil) {
                cellView.textField.stringValue = object[kParseUserEmailKey];
            } else {
                cellView.textField.stringValue = @"";
            }
            return cellView;
        }
        
        if ([tableColumn.identifier isEqualToString:_columnIdentifierArray[4]]) {
            [tableColumn.headerCell setStringValue:_arrayOfHeader[4]];
            
            NSString *lastMessage = object[@"last_message"];
            if (lastMessage != nil) {
                cellView.textField.stringValue = lastMessage;
            }
            
            return cellView;
        }
    return nil;
}


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)tableColumn {
    
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[0]])
    {
        [self orderTable:kParseUserNameKey];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[1]])
    {
        [self orderTable:[NSString stringWithFormat:@"%@.%@", kParseUserCollegeKey, kParseCollegeNameKey]];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[2]])
    {
        [self orderTable:kParseUserFriendCountKey];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[3]])
    {
        [self orderTable:kParseUserEmailKey];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[4]])
    {
        [self orderTable:@"last_message"];
    }
    
    return YES;
}

-(void)orderTable:(NSString *)key {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:self.ascendBool];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.userArray = [NSMutableArray arrayWithArray:[self.userArray sortedArrayUsingDescriptors:sortDescriptors]];
    self.ascendBool = !self.ascendBool;
    [self.searchTableView reloadData];
}



#pragma mark - NSTableViewDataSource -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.userArray.count;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    return YES;
}

#pragma mark - fetchData

- (void)fetchParseUser {
    PFQuery *query = [HKLParseHelper queryForAllUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            [self.userArray removeAllObjects];
            for (int i = 0; i < [array count]; i++) {
                [self.userArray addObject:[array objectAtIndex:i]];
                [self addLastTime:i];
            }
           [self.searchTableView reloadData];
        }
    }];
}

-(void)addLastTime:(int)pos {
    
    PFObject *object = self.userArray[pos];
    if (![self.currentUser.username isEqualToString:object[kParseUserNameKey]]) {
        for (int i = 0; i < [self.allChatMeta count]; i++) {
            NSDictionary *attendees = [[self.allChatMeta objectAtIndex:i] valueForKey:@"attendees"];
            if([object[kParseUserNameKey] isEqualToString:@"supertramp"]) {
                NSLog(@"");
            }
            
            if (attendees != nil && [attendees count] == 2) {
                NSSet *attendess = [NSSet setWithArray:[attendees allValues]];
                if ([attendess containsObject:self.currentUser.username] && [attendess containsObject:object[kParseUserNameKey]]) {
                    
                    double time = [[[[self.allChatMeta objectAtIndex:i] valueForKey:@"last_message"] valueForKey:@"timestamp"] doubleValue] / 1000;
                    if (time == 0) {
                        [[self.userArray objectAtIndex:pos] setValue:@"" forKey:@"last_message"];
                    } else {
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
                        NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
                        [df_local setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
                        [df_local setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
                        
                        [[self.userArray objectAtIndex:pos] setValue:[df_local stringFromDate:date] forKey:@"last_message"];
                    }
                    return;
                } else {
                    [[self.userArray objectAtIndex:pos] setValue:@"" forKey:@"last_message"];
                }
            }
        }
    } else {
        [[self.userArray objectAtIndex:pos] setValue:@"You" forKey:@"last_message"];
    }
    
}

- (void)fetchCollege {
    PFQuery *query = [HKLParseHelper queryForAllColleges];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            for (PFObject *college in array) {
                [self.collegeArray addObject:college[kParseCollegeNameKey]];
            }
        }
    }];
    [self.collegeDropdownField reloadData];
}

#pragma mark - private Method

- (void)setUpUI {
    [self.userSearchButton setWantsLayer:YES];
    self.userSearchButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
    [self.openChatsButton setWantsLayer:YES];
    self.openChatsButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
    [self.scatterChatsButton setWantsLayer:YES];
    self.scatterChatsButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
    [self.openProfileButton setWantsLayer:YES];
    self.openProfileButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
}

#pragma mark - NSComboBoxDataSource
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if (aComboBox == self.collegeDropdownField) {
        return self.collegeArray.count;
    }
    if (aComboBox == self.behaviorDropdownField) {
        return self.behaviorArray.count;
    }
    if (aComboBox == self.statusDropdownField) {
        return self.statusArray.count;
    }
    return 0;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (aComboBox == self.collegeDropdownField) {
        return [self.collegeArray objectAtIndex:index];
    }
    if (aComboBox == self.behaviorDropdownField) {
        return [self.behaviorArray objectAtIndex:index];
    }
    if (aComboBox == self.statusDropdownField) {
        return [self.statusArray objectAtIndex:index];
    }
    return nil;
}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
    NSComboBox *box = (NSComboBox*)[notification object];
    if (box == self.behaviorDropdownField) {
        [self performSelector:@selector(readComboValue:) withObject:[notification object] afterDelay:0];
    }
}

- (void)readComboValue:(id)object {
    if (self.behaviorDropdownField.stringValue != nil && ![self.behaviorDropdownField.stringValue isEqualToString:@""]) {
        NSInteger index = [self.behaviorArray indexOfObject:[(NSComboBox *)object stringValue]];
        self.statusArray = _statusDropDownArray[index];
        [self.statusDropdownField reloadData];
    }
}

- (IBAction)userSearchAction:(id)sender {
    //user search
    PFQuery *query = [HKLParseHelper queryForAllUser];
    if (self.userSearchField.stringValue != nil && ![self.userSearchField.stringValue isEqualToString:@""]) {
        [query whereKey:kParseUserNameKey equalTo:self.userSearchField.stringValue];
    }
    if (self.collegeDropdownField.stringValue != nil && ![self.collegeDropdownField.stringValue isEqualToString:@""]) {
        if ([self.collegeDropdownField.stringValue isEqualToString:self.collegeArray[0]]) {
            [query whereKeyExists:kParseUserCollegeKey];
        } else if ([self.collegeDropdownField.stringValue isEqualToString:self.collegeArray[1]]) {
            [query whereKeyDoesNotExist:kParseUserCollegeKey];
        } else {
            PFQuery *innerQuery = [HKLParseHelper queryForAllColleges];
            [innerQuery whereKey:kParseCollegeNameKey equalTo:self.collegeDropdownField.stringValue];
            [query whereKey:kParseUserCollegeKey matchesQuery:innerQuery];
        }
    }
    
    if (self.behaviorDropdownField.stringValue != nil && ![self.behaviorDropdownField.stringValue isEqualToString:@""]&& self.statusDropdownField.stringValue != nil && ![self.statusDropdownField.stringValue isEqualToString:@""]) {
        if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[0]]) {
            //Last activity (Today, 3 days, 7 days, 30 days, longer)
            NSDate *currentDate = [NSDate date];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                //Today
                NSDate *now = [NSDate date];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
                [components setHour:00];
                NSDate *targetDate = [calendar dateFromComponents:components];
                [query whereKey:@"updatedAt" greaterThanOrEqualTo: targetDate];
            } else if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[1]]) {
                //3 days
                [dateComponents setDay:-3];
                NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
                [query whereKey:@"updatedAt" greaterThanOrEqualTo:targetDate];
            } else if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[2]]) {
               // 7 days
                [dateComponents setDay:-7];
                NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
                [query whereKey:@"updatedAt" greaterThanOrEqualTo:targetDate];
            } else if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[3]]) {
                // 30 days
                [dateComponents setDay:-30];
                NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
                [query whereKey:@"updatedAt" greaterThanOrEqualTo:targetDate];
            } else {
                //longer
                [dateComponents setDay:-30];
                NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
                [query whereKey:@"updatedAt" lessThanOrEqualTo:targetDate];
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[1]]) {
            // Last message sent (Today, 3 days, 7 days, 30 days, longer)     - FireBase
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[2]]) {
            //Profile Data (Full, not Full)
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                [query whereKeyExists:kParseUserAvatarImageKey];
                [query whereKeyExists:kParseUserFullNameKey];
                [query whereKey:kParseUserFullNameKey notEqualTo:@""];
            } else {
                //not full
                [self fetchProfileDataNotFull:query];
                return;
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[3]]) {
            //College (Added, non added)
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                [query whereKeyExists:kParseUserCollegeKey];
            } else {
                [query whereKeyDoesNotExist:kParseUserCollegeKey];
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[4]]) {
            //Friends (more than zero, zero)
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                //more than zero
                [query whereKey:kParseUserFriendCountKey greaterThan:@0];
            } else {
                //zero
                [query whereKey:kParseUserFriendCountKey equalTo:@0];
                [query whereKeyDoesNotExist:kParseUserFriendCountKey ];
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[5]]) {
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                //more than zero
                [self findPendingFriendsUser:query sign:true];
            } else {
                //zero
                [self findPendingFriendsUser:query sign:false];
            }

            return;
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[6]]) {
            //chats (more than 5, less than 5) -
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {

                [self fetchChatsAndPeople:query sign:YES];
            } else {

                [self fetchChatsAndPeople:query sign:NO];
            }
            return;
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[7]]) {
            //add new friends (have tapped, have not tapped)
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[8]]) {
            //checking in have not checked in/ have checked in)
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                [query whereKeyDoesNotExist:kParseUserLastCheckinTime];
            } else {
                [query whereKeyExists:kParseUserLastCheckinTime];
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[9]]) {
            //status (have set/ have not set)
            if ([self.statusDropdownField.stringValue isEqualToString:self.statusArray[0]]) {
                //set
                [query whereKey:kParseUserModeKey notEqualTo:@""];
                [query whereKeyExists:kParseUserModeKey];
            } else {
                [query whereKey:kParseUserModeKey equalTo:@""];
                [query whereKeyDoesNotExist:kParseUserModeKey];
            }
        } else if ([self.behaviorDropdownField.stringValue isEqualToString:self.behaviorArray[10]]) {
            //Tapped public smart chat (has tapped/ has not tapped)
        } else {
            //College Confirmation (Has added school ,but not clicked email link)
            [query whereKey:kParseUserEmailVerifiedKey equalTo:[NSNumber numberWithBool:NO]];
        }

    }
    [self findUsers:query];

}

#pragma mark - ACTIONS -

- (IBAction)scatterChatAction:(id)sender {
    NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
    if (self.searchTableView.numberOfSelectedRows >= 1) {
        NSIndexSet *indexes = self.searchTableView.selectedRowIndexes;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            PFUser *parseUser = [self.userArray objectAtIndex:idx];
            HKLUser *huckleUser = [HKLParseHelper updatedUserFromParseUser:parseUser inRealm:nil];
            [selectedObjects addObject:huckleUser];
        }];
        [self startScatterChat:selectedObjects];
    }
}


- (IBAction)groupChatAction:(id)sender {
    NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
    if (self.searchTableView.numberOfSelectedRows >= 1) {
        NSIndexSet *indexes = self.searchTableView.selectedRowIndexes;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            PFUser *parseUser = [self.userArray objectAtIndex:idx];
            HKLUser *huckleUser = [HKLParseHelper updatedUserFromParseUser:parseUser inRealm:nil];
            [selectedObjects addObject:huckleUser];
        }];
        [self startGroupChat:selectedObjects];
    }
}

- (IBAction)openProfileAction:(id)sender {
    if (self.searchTableView.numberOfSelectedRows == 1) {
            HKLUserProfileController *userProfileController = [[HKLUserProfileController alloc] initWithNibName:@"HKLUserProfileController" bundle:nil];
            PFObject *object = self.userArray[self.searchTableView.selectedRow];
            userProfileController.objectId = object.objectId;
        
            // WINDOW
            _wc =[[NSWindowController alloc] initWithWindowNibName:@"HKLProfileWindowController"];
            [_wc.window.contentView addSubview:userProfileController.view];
            [_wc.window setTitle:userProfileController.objectId];
        
            NSRect frame = NSMakeRect(0, 0, 700, 700);
            [_wc.window setContentMinSize:frame.size];
            [_wc.window setContentAspectRatio:frame.size];
            userProfileController.view.frame = frame;
        
            [_wc.window makeMainWindow];
            [_wc showWindow:self];
    }
    else {
        NSLog(@"You can only open 1 Profile at a time.");
    }
}

#pragma mark - Private Method -

- (void)startGroupChat:(NSMutableArray *)users {
    [self.groupChatUsers addObjectsFromArray:users];
    
    NSMutableArray *usernames = [NSMutableArray array];
    for (HKLUser *user in self.groupChatUsers) {
        [usernames addObject:user.username];
    }
    [usernames sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
        return [name1 compare:name2];
    }];
    
    [HKLChatClient groupChatIdForPeople:users continueBlock:^(NSString *chatId) {
        [HKLChatClient addChatPlaceholderIfNeededWithKind:HKLChatKindGroup chatId:chatId forUsers:[users arrayByAddingObject:HKL_LOGGEDIN_USER] groupName:nil];
        [self openGroupChatWithChatId:chatId];
    }];

    
}

- (void)openGroupChatWithChatId:(NSString *)id {
    HKLChatsViewController *chatsViewController = [[HKLChatsViewController alloc] initWithNibName:@"HKLChatsViewController" bundle:nil];
    chatsViewController.chatId = id;
    
    _wc =[[NSWindowController alloc] initWithWindowNibName:@"HKLChatWindowController"];
    [_wc.window.contentView addSubview:chatsViewController.view];
    [_wc.window setTitle:chatsViewController.chatId];
    
    NSRect frame = NSMakeRect(0, 0, 741, 565);
    [_wc.window setContentMinSize:frame.size];
    [_wc.window setContentAspectRatio:frame.size];
    chatsViewController.view.frame = frame;
    
    [_wc showWindow:self];
}

- (void)startScatterChat:(NSMutableArray *)users {
    
    [self.scatterChatUsers addObjectsFromArray:users];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Send"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"ScatterChat"];
    [alert setInformativeText:@"Send the same message to multiple friends. Each individual message will be in your chats."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] keyWindow] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self completeScatterChat];
        }
    }];
}

- (void)completeScatterChat {
    NSString *text = self.scatterChatField.stringValue;
    if (text.length == 0) {
        // Nothing to do, no message.
        return;
    }
    NSRange range = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (range.location != NSNotFound && range.length == text.length) {
        // Nothing to do, blank string.
        return;
    }

    for (HKLUser *user in self.scatterChatUsers) {
        NSArray *userIds = @[ HKL_LOGGEDIN_USER.guid, user.guid ];
        NSString *chatId = [self compositeChatId:userIds];
        
        [HKLChatClient addChatPlaceholderIfNeededWithKind:HKLChatKindDirect chatId:chatId forUsers:@[ HKL_LOGGEDIN_USER, user ] groupName:nil];
        [HKLChatClient sendMessage:text
                            fromId:HKL_LOGGEDIN_USER.guid
                      fromUsername:HKL_LOGGEDIN_USER.username
                            chatId:chatId
                  sendNotification:YES];
    }

    self.scatterChatUsers = nil;
}

- (NSString *)compositeChatId:(NSArray *)userIds {
    NSArray *sortedIds = [userIds sortedArrayUsingComparator:^NSComparisonResult(NSString *guid1, NSString *guid2) {
        return [guid1 compare:guid2];
    }];
    
    return [sortedIds componentsJoinedByString:@"-"];
}

- (void)findUsers:(PFQuery*)query {
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.userArray removeAllObjects];
            for (int i = 0; i < [objects count]; i++) {
                [self.userArray addObject:[objects objectAtIndex:i]];
                [self addLastTime:i];
            }
            [self.searchTableView reloadData];
        }
    }];
}

- (void)findPendingFriendsUser:(PFQuery *)query sign:(BOOL)isBigger {
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.userArray removeAllObjects];
            for (PFObject *object in objects) {
                [self getPendingFriendsCount:object sign:isBigger];
            }
        }
    }];
}

- (void)getPendingFriendsCount:(PFObject *)object sign:(BOOL)isBigger {
    
    PFQuery *query = [HKLParseHelper queryForFriendCount];
    [query whereKey:@"receiver" equalTo:object];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSInteger count = 0;
            for (PFObject *object in objects) {
                if (object[kParseFriendshipAcceptedAtKey] == nil) {
                    count++;
                }
            }
            if (isBigger) {
                if (count >= 5) {
                    [self.userArray addObject:object];
                    [self addLastTime:(int)[self.userArray count] -1];
                    [self.searchTableView reloadData];
                }
            } else {
                if (count < 5) {
                    [self.userArray addObject:object];
                    [self addLastTime:(int)[self.userArray count] -1];
                    [self.searchTableView reloadData];
                }
            }
        }
    }];
}

- (void)fetchProfileDataNotFull:(PFQuery *)query {
    self.profileDataQuery = query;
    [self.userArray removeAllObjects];
    NSMutableArray *allObjectId = [[NSMutableArray alloc] init];
    [query whereKeyExists:kParseUserAvatarImageKey];
    [query whereKeyExists:kParseUserFullNameKey];
    [query whereKey:kParseUserFullNameKey notEqualTo:@""];
    [query findObjectsInBackgroundWithBlock:^(NSArray *data, NSError *error) {
              if (!error) {
                  for (PFObject *object in data) {
                      [allObjectId addObject:object.objectId];
                  }
                  [self.profileDataQuery whereKey:@"objectId" notContainedIn:allObjectId];
                  [self findUsers:self.profileDataQuery];
              }
    }];
}

-(void)getChatMeta {
    
    Firebase *chats = [HKLChatClient chatMetasRef];
    [chats observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            
            self.allChatMeta = [snapshot.value allValues];
            [self.searchTableView reloadData];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
}

                 - (void)fetchChatsAndPeople: (PFQuery *)query sign:(BOOL)isBigger {
    Firebase *chatsRef = [HKLChatClient chatsRef];
    [chatsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            Firebase *peopleRef = [HKLChatClient peopleRef];
            [peopleRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *peopleSnapshot) {
                if ([snapshot exists]) {
                    NSMutableArray *userMessageIds = [[NSMutableArray alloc] init];
                    NSArray *userIds = [peopleSnapshot.value allKeys];
                    for (NSString *userId in userIds) {
                        int count = 0;
                        NSDictionary *ids = [[peopleSnapshot.value valueForKey:userId] valueForKey:@"chats"];
                        NSArray *values = [ids allKeys];
                        for (NSString *chatId in values) {
                            NSDictionary *allMessages = [[snapshot.value valueForKey:chatId] valueForKey:@"messages"];
                            NSArray *keys = [allMessages allKeys];
                            for (NSString *key in keys) {
                                NSString *senduuid = [[allMessages valueForKey:key] valueForKey:@"sender_uuid"];
                                if ([senduuid isEqualToString:userId]) {
                                    count++;
                                }
                            }
                        }
                        if (isBigger) {
                            if (count >= 15) {
                                [userMessageIds addObject:userId];
                            }
                        } else {
                            if (count < 15) {
                                [userMessageIds addObject:userId];
                            }
                        }
                    }
                    [query whereKey:@"objectId" containedIn:userMessageIds];
                    [self findUsers:query];
                }
            }];
            
        }
    }];
}

@end
