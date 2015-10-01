//
//  HKLChatSearchViewController.m
//  Calypso
//
//  Created by Kyle Ju on 2015-07-14.
//  Copyright (c) 2015 TTT. All rights reserved.
//

#import "HKLChatSearchViewController.h"
#import "HKLChatsViewController.h"
#import "HKLParseHelper.h"
#import "HKLNetworkController.h"
#import <Firebase/Firebase.h>
#import "HKLChatClient.h"
#import <ParseOSX/ParseOSX.h>


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HKLChatSearchViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (strong, nonatomic) NSWindowController * wc;
@property (weak) IBOutlet NSScrollView *chatSearchTableView;
@property (weak) IBOutlet NSTextField *chatSearchTextField;
@property (weak) IBOutlet NSButton *searchByCityButton;
@property (weak) IBOutlet NSButton *searchByNameButton;
@property (weak) IBOutlet NSButton *openChats;

@property (copy, nonatomic) NSMutableArray *chatIds;
@property (nonatomic, strong) NSMutableArray *chatMeta;
@property (nonatomic, strong) NSMutableDictionary *allChatMeta;
@property (nonatomic, strong) NSMutableArray *chatObjects;
@property (strong) IBOutlet NSTableView *chatsTableView;
@property (strong, nonatomic) NSMutableSet *searcheduuids;
@property BOOL ascendBool;


@end

@implementation HKLChatSearchViewController {
    NSArray *_defaultArrayHeader;
    NSArray *_columnIdentifierArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _defaultArrayHeader = @[@"Chat", @"City, State",@"Active Now",@"Messages Today", @"Content"];
    _columnIdentifierArray = @[@"ColumnOne", @"ColumnTwo", @"ColumnThree", @"ColumnFour", @"ColumnFive"];
    self.chatMeta = [[NSMutableArray alloc] init];
    self.allChatMeta = [[NSMutableDictionary alloc] init];
    self.searcheduuids = [[NSMutableSet alloc] init];
    [self setUpUI];
    [self getChats];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
        NSDictionary *dict = [self.chatMeta objectAtIndex:row];
    
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[0]]) {
        [tableColumn.headerCell setStringValue:_defaultArrayHeader[0]];
        
        NSString *name = [dict valueForKey:@"real_name"];
        if (name != nil) {
            cellView.textField.stringValue = name;
        }
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[1]]) {
        [tableColumn.headerCell setStringValue:_defaultArrayHeader[1]];
        
        NSString *name = [dict valueForKey:@"location"];
        if (name != nil) {
            cellView.textField.stringValue = name;
        }
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[2]]) {
        [tableColumn.headerCell setStringValue:_defaultArrayHeader[2]];
        
        NSString *name = [dict valueForKey:@"active_users"];
        if (name != nil) {
            cellView.textField.stringValue = name;
        } else {
            cellView.textField.stringValue = @"";
        }
        
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[3]]) {
        [tableColumn.headerCell setStringValue:_defaultArrayHeader[3]];
        
        
        NSString *name = [dict valueForKey:@"messages_today"];
        if (name != nil) {
            cellView.textField.stringValue = name;
        } else {
            cellView.textField.stringValue = @"";
        }
        
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[4]]) {
        [tableColumn.headerCell setStringValue:_defaultArrayHeader[4]];
        
        
        NSString *name = [dict valueForKey:@"content"];
        if (name != nil) {
            cellView.textField.stringValue = name;
        } else {
            cellView.textField.stringValue = @"";
        }
        
        return cellView;
    }
    
    return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    NSLog(@"Row %ld Pressed", (long)rowIndex);
    
    HKLChatsViewController *chatsViewController = [[HKLChatsViewController alloc] initWithNibName:@"HKLChatsViewController" bundle:nil];
    chatsViewController.chatId = [[self.chatMeta objectAtIndex:rowIndex]valueForKey:@"uuid"];
    
    // WINDOW
    _wc =[[NSWindowController alloc] initWithWindowNibName:@"HKLChatWindowController"];
    [_wc.window.contentView addSubview:chatsViewController.view];
    [_wc.window setTitle:chatsViewController.chatId];
    
    NSRect frame = NSMakeRect(0, 0, 741, 565);
    [_wc.window setContentMinSize:frame.size];
    [_wc.window setContentAspectRatio:frame.size];
    chatsViewController.view.frame = frame;
    
    [_wc showWindow:self];
    [_wc.window makeMainWindow];
    
    return YES;
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)tableColumn {
    
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[0]])
    {
        [self orderTable:@"real_name"];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[1]])
    {
        [self orderTable:@"location"];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[2]])
    {
        [self orderTable:@"active_users"];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[3]])
    {
        [self orderTable:@"messages_today"];
    }
    if( [tableColumn.identifier isEqualToString:_columnIdentifierArray[4]])
    {
        [self orderTable:@"content"];
    }

    return YES;
}

-(void)orderTable:(NSString *)key {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:self.ascendBool];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.chatMeta = [NSMutableArray arrayWithArray:[self.chatMeta sortedArrayUsingDescriptors:sortDescriptors]];
    self.ascendBool = !self.ascendBool;
    [self.chatsTableView reloadData];
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    //NSLog(@"%lu", (unsigned long)[self.chatMeta count]);
    return [self.chatMeta count];
}

#pragma mark  - UI -

- (void)setUpUI {
    [self.searchByCityButton setWantsLayer:YES];
    self.searchByCityButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
    [self.searchByNameButton setWantsLayer:YES];
    self.searchByNameButton.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];
    [self.openChats setWantsLayer:YES];
    self.openChats.layer.backgroundColor = [UIColorFromRGB(0x00ECC4) CGColor];

}

#pragma mark  - ACTIONS -


- (IBAction)CityChatSearchAction:(id)sender {
    //chat search
    if (self.chatSearchTextField.stringValue != nil && ![self.chatSearchTextField.stringValue isEqualToString:@""]) {
        //search by city
        //[self getChatsUUID:kParseCustomVenueAddressKey uuidKey:kParseCustomVenueUUIDKey queryFetched:[HKLParseHelper queryForCustomVenue]];
        [self getChatsUUID:kParseHighSchoolCityKey uuidKey:kParseHighSchoolUUIDKey queryFetched:[HKLParseHelper queryForAllHighSchools]];
        [self getChatsUUID:kParseCollegeCityKey uuidKey:kParseCollegeUUIDKey queryFetched:[HKLParseHelper queryForAllColleges]];
        [self getChatsUUID:kParseModeGeoNameKey uuidKey:kParseModeGeoUUIDKey queryFetched:[HKLParseHelper queryForAllModes]];
        [self getChatsUUID:kParseVenueAddressKey uuidKey:kParseVenueUUIDKey queryFetched:[HKLParseHelper queryForAllVenues]];
        [self getChatsUUID:kParseSpecialChatLocationAddressKey uuidKey:kParseSpecialChatLocationUUIDKey queryFetched:[HKLParseHelper queryForAllSpecailChatLocations]];
    }
    
}
- (IBAction)nameChatsSearchAction:(id)sender {
    //search by name
     [self.chatMeta removeAllObjects];
    [self.searcheduuids removeAllObjects];
    if (self.chatSearchTextField.stringValue != nil && ![self.chatSearchTextField.stringValue isEqualToString:@""]) {
        //[self getChatsUUID:kParseCustomVenueName uuidKey:kParseCustomVenueUUIDKey queryFetched:[HKLParseHelper queryForCustomVenue]];
        [self getChatsUUID:kParseHighSchoolNameKey uuidKey:kParseHighSchoolUUIDKey queryFetched:[HKLParseHelper queryForAllHighSchools]];
        [self getChatsUUID:kParseCollegeNameKey uuidKey:kParseCollegeUUIDKey queryFetched:[HKLParseHelper queryForAllColleges]];
        [self getChatsUUID:kParseModeGeoNameKey uuidKey:kParseModeGeoUUIDKey queryFetched:[HKLParseHelper queryForAllModes]];
        [self getChatsUUID:kParseVenueNameKey uuidKey:kParseVenueUUIDKey queryFetched:[HKLParseHelper queryForAllVenues]];
        [self getChatsUUID:kParseSpecialChatNameKey uuidKey:kParseSpecialChatLocationUUIDKey queryFetched:[HKLParseHelper queryForAllSpecailChatLocations]];
    }
}

#pragma mark - FireQueryForChats
- (void)getChatsUUID:(NSString *)locationKey uuidKey:(NSString *)uuid queryFetched:(PFQuery *)query{
   
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *uuidArray = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                if (object[locationKey] != nil) {
                    if (([object[locationKey] rangeOfString:self.chatSearchTextField.stringValue options:NSCaseInsensitiveSearch].location != NSNotFound) ) {
                        [self.chatObjects addObject:object];
                        [uuidArray addObject:object[uuid]];
                        
                    }
                }
            }
            [self getChatsInFireBase:uuidArray];
            [self.chatsTableView reloadData];
        }
    }];
    
}


#pragma mark - queryForFireBase
- (void)getChatsInFireBase:(NSMutableArray *)uuidArray {
    [self.chatIds addObjectsFromArray:uuidArray];
    // TODO: fetch chats and refresh the table
    
    
    for (NSString *currentId in uuidArray) {
        [self getDataFromParseHelperOne:[HKLParseHelper queryForAllHighSchools] idValue:currentId];
        [self getDataFromParseHelperOne:[HKLParseHelper queryForAllColleges] idValue:currentId];
        [self getDataFromParseHelperTwo:[HKLParseHelper queryForAllSpecailChatLocations] idValue:currentId];
        [self getDataFromParseHelperTwo:[HKLParseHelper queryForAllVenues] idValue:currentId];
        [self getDataFromParseHelperThree:[HKLParseHelper queryForAllModes] idValue:currentId];
    }
}



- (void)getChats {
    
    Firebase *chatMetaRef = [HKLChatClient chatsRef];
    [chatMetaRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            self.allChatMeta = snapshot.value;
            [self.chatsTableView reloadData];
        }
    }];
  
}


#pragma mark - fetch data from parse

- (void)getDataFromParseHelperOne:(PFQuery *)query idValue:(NSString *)string_id {
    [query whereKey:@"uuid" equalTo:string_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0) {
            NSArray *name = [objects valueForKey:@"name"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[name objectAtIndex:0] forKey:@"real_name"];
            
            NSArray *uuid = [objects valueForKey:@"uuid"];
            [dict setValue:[uuid objectAtIndex:0] forKey:@"uuid"];
            
            NSDictionary *serverData = [objects valueForKey:@"serverData"];
            NSArray *city = [serverData valueForKey:@"city"];
            NSArray *state = [serverData valueForKey:@"state"];
            if ([city count] > 0 && [state count] > 0) {
                NSString *location = [NSString stringWithFormat:@"%@, %@", [city objectAtIndex:0], [state objectAtIndex:0]];
                [dict setValue:location forKey:@"location"];
                
            }
            
            NSDictionary *singleChat = [self.allChatMeta valueForKey:[dict valueForKey:@"uuid"]];
            if (singleChat != nil) {
                
                int messagesToday = [self getMessagesToday:[dict valueForKey:@"uuid"]];
                [dict setValue:[NSString stringWithFormat:@"%d", messagesToday] forKey:@"messages_today"];
            }
            
            NSArray *messagesArray = [[self.allChatMeta valueForKey:[uuid objectAtIndex:0]] valueForKey:@"messages"];
            if (messagesArray != nil) {
                [dict setValue:@"Yes" forKey:@"content"];
            }
                                       
            
            [[HKLNetworkController sharedController] retrieveVenueUsers:[uuid objectAtIndex:0] success:^(NSArray *users) {
                [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[users count]] forKey:@"active_users"];
                if (![self.searcheduuids containsObject:[uuid objectAtIndex:0]]) {
                    [self.searcheduuids addObject:[uuid objectAtIndex:0]];
                    [self.chatMeta addObject:dict];
                    [self.chatsTableView reloadData];
                }
               
            } failure:^(NSError *error) {
                //ERROR MESSAGE
                NSLog(@"Couldn't load users");
//                [self.chatMeta addObject:dict];
//                [self.chatsTableView reloadData];
            }];
            
            
        }
    }];
}

- (void)getDataFromParseHelperTwo:(PFQuery *)query idValue:(NSString *)string_id {
    [query whereKey:@"uuid" equalTo:string_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray *special = [objects valueForKey:@"address"];
            NSArray *uuid = [objects valueForKey:@"uuid"];
            [dict setValue:[uuid objectAtIndex:0] forKey:@"uuid"];
            //NSLog(@"Speical Chat Found: %@", special);
            if ([special count] > 0) {
                NSArray *specialName = [objects valueForKey:@"name"];
                [dict setValue:[specialName objectAtIndex:0]  forKey:@"real_name"];
                [dict setValue:[special objectAtIndex:0]  forKey:@"location"];
            }
            
            NSDictionary *singleChat = [self.allChatMeta valueForKey:[dict valueForKey:@"uuid"]];
            if (singleChat != nil) {
                int messagesToday = [self getMessagesToday:[dict valueForKey:@"uuid"]];
                [dict setValue:[NSString stringWithFormat:@"%d", messagesToday] forKey:@"messages_today"];
            }
            
            NSArray *messagesArray = [[self.allChatMeta valueForKey:[uuid objectAtIndex:0]] valueForKey:@"messages"];
            if (messagesArray != nil) {
                [dict setValue:@"Yes" forKey:@"content"];
            }
            
            [[HKLNetworkController sharedController] retrieveVenueUsers:[uuid objectAtIndex:0] success:^(NSArray *users) {
                [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[users count]] forKey:@"active_users"];
                if (![self.searcheduuids containsObject:[uuid objectAtIndex:0]]) {
                    [self.searcheduuids addObject:[uuid objectAtIndex:0]];
                    [self.chatMeta addObject:dict];
                    [self.chatsTableView reloadData];
                }
            } failure:^(NSError *error) {
                //ERROR MESSAGE
                NSLog(@"Couldn't load users");
//                [self.chatMeta addObject:dict];
//                [self.chatsTableView reloadData];
            }];
        }
    }];
}

- (void)getDataFromParseHelperThree:(PFQuery *)query idValue:(NSString *)string_id {
    NSMutableArray *stringArray = (NSMutableArray*)[string_id componentsSeparatedByString:@"_"];
    NSMutableString *modeString = [[NSMutableString alloc] init];
    if ([stringArray count] > 1) {
        modeString = [stringArray lastObject];
        [stringArray removeLastObject];
    }
    NSString *parseVenueId = [stringArray componentsJoinedByString:@"_"];
    [query whereKey:@"uuid" equalTo:parseVenueId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] > 0) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray *mode = [objects valueForKey:@"name"];
            //NSLog(@"Mode Found: %@", mode);
                
            NSArray *uuid = [objects valueForKey:@"uuid"];
            [dict setValue:[uuid objectAtIndex:0] forKey:@"uuid"];
            [dict setValue:[mode objectAtIndex:0]  forKey:@"location"];
            [dict setValue:[NSString stringWithFormat:@"%@ %@",[mode objectAtIndex:0], modeString] forKey:@"real_name"];
            
            NSDictionary *singleChat = [self.allChatMeta valueForKey:[dict valueForKey:@"uuid"]];
            if (singleChat != nil) {

                int messagesToday = [self getMessagesToday:[dict valueForKey:@"uuid"]];
                [dict setValue:[NSString stringWithFormat:@"%d", messagesToday] forKey:@"messages_today"];
            }
            
            NSArray *messagesArray = [[self.allChatMeta valueForKey:string_id] valueForKey:@"messages"];
            if (messagesArray != nil) {
                [dict setValue:@"Yes" forKey:@"content"];
            }
            
            [[HKLNetworkController sharedController] retrieveVenueUsers:[uuid objectAtIndex:0] success:^(NSArray *users) {
                [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[users count]] forKey:@"active_users"];
                if (![self.searcheduuids containsObject:[uuid objectAtIndex:0]]) {
                    [self.searcheduuids addObject:[uuid objectAtIndex:0]];
                    [self.chatMeta addObject:dict];
                    [self.chatsTableView reloadData];
                }
            } failure:^(NSError *error) {
                //ERROR MESSAGE
                NSLog(@"Couldn't load users");
//                [self.chatMeta addObject:dict];
//                [self.chatsTableView reloadData];
            }];
        }
    }];
    
}

-(int)getMessagesToday:(NSString *)uuid {
    
    NSArray *messagesArray = [[[self.allChatMeta valueForKey:uuid] valueForKey:@"messages"] allValues];
    
    int messagesToday = 0;
    for (int i = 0; i < [messagesArray count]; i++) {
        double timeStamp = ceil([[[messagesArray objectAtIndex:i] valueForKey:@"timestamp"] doubleValue] / 1000);
        double nowEpochSeconds = ceil([[NSDate date] timeIntervalSince1970]);
        nowEpochSeconds -= 86400;
        
        if (timeStamp > nowEpochSeconds) {
            messagesToday++;
        }
        
    }
    return messagesToday;
}



@end
