//
//  HKLUserProfileController.m
//  Calypso
//
//  Created by Kyle Ju on 2015-07-06.
//  Copyright (c) 2015 TTT. All rights reserved.
//

#import "HKLUserProfileController.h"
#import <ParseOSX/ParseOSX.h>
#import "HKLParseHelper.h"
#import "HKLChatClient.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HKLUserProfileController ()
@property (weak) IBOutlet NSView *mainVIew;

@property (weak) IBOutlet NSImageView *userProfilePhoto;
@property (weak) IBOutlet NSTextField *registrationDate;
@property (weak) IBOutlet NSTextField *university;
@property (weak) IBOutlet NSTextField *emailAddress;
@property (weak) IBOutlet NSTextField *phoneNumber;
@property (weak) IBOutlet NSTextField *chipotleLabel;
@property (weak) IBOutlet NSTextField *status;

@property (weak) IBOutlet NSTextField *lastLaunch;
@property (weak) IBOutlet NSTextField *lastMessageSent;
@property (weak) IBOutlet NSTextField *friendsNumber;
@property (weak) IBOutlet NSTextField *prendingFriendsRequest;
@property (weak) IBOutlet NSTextField *sentMessages;
@property (weak) IBOutlet NSTextField *isTappedAddFriend;
@property (weak) IBOutlet NSTextField *lastCheckIn;
@property (weak) IBOutlet NSTextField *lastMode;
@property (weak) IBOutlet NSTextField *lastPublicSmartChat;
@property (weak) IBOutlet NSTextField *userName;

@property (weak) IBOutlet NSView *userDetailBackgroundView;
@property (weak) IBOutlet NSView *userDetailWhiteBackgroundView;
@property (weak) IBOutlet NSView *profileNoteBackgroundView;
@property (unsafe_unretained) IBOutlet NSTextView *profileNotes;

@property (weak) IBOutlet NSButton *deleteUserButton;
@property (weak) IBOutlet NSButton *saveNotesButton;

@property (strong, nonatomic) PFObject *userObject;
@property (strong, nonatomic) FDataSnapshot *fbSnapshot;




@end

@implementation HKLUserProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(makeKey) withObject:self afterDelay:1];
    [self getFbSnapshotData];
    [self fetchUser];
    
    [self setupUI];
}

- (void)makeKey
{
    [[[self view] window] makeKeyAndOrderFront:self];
}

#pragma mark - setup UI

- (void)setupUI {
    [self.userDetailWhiteBackgroundView setWantsLayer:YES];
    [self.userDetailBackgroundView setWantsLayer:YES];
    [self.profileNoteBackgroundView setWantsLayer:YES];
    [self.saveNotesButton setWantsLayer:YES];
    [self.deleteUserButton setWantsLayer:YES];
    self.userDetailBackgroundView.layer.backgroundColor = [UIColorFromRGB(0xD8D8D8) CGColor];
    self.userDetailWhiteBackgroundView.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    self.profileNoteBackgroundView.layer.backgroundColor = [UIColorFromRGB(0xE3E3E3) CGColor];
    
    self.saveNotesButton.layer.backgroundColor = [UIColorFromRGB(0xE3E3E3) CGColor];
    self.deleteUserButton.layer.backgroundColor = [[NSColor redColor] CGColor];
    
    //Todo: change NSButton text color
}
#pragma mark - populate data

- (void)populateData {
    PFObject *file = [self.userObject objectForKey:kParseUserAvatarImageKey];
    PFFile *image = [file objectForKey:kParseUserPhotoImageFileKey];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.userProfilePhoto.image = [[NSImage alloc] initWithData:data];
        }
    }];
    self.userName.stringValue = [self checkStringHerlp:self.userObject[kParseUserNameKey]];
    self.university.stringValue = [self checkStringHerlp:self.userObject[kParseUserCollegeKey][kParseCollegeNameKey]];
    self.registrationDate.stringValue = [self checkStringHerlp:self.userObject.createdAt];
    self.emailAddress.stringValue = [self checkStringHerlp:self.userObject[kParseUserEmailKey]];
    // phone numbers should not be shown
    self.phoneNumber.stringValue = [self checkStringHerlp:self.userObject[@"phone"]];
    self.chipotleLabel.stringValue = [self checkStringHerlp:self.userObject[kParseUserLastVenue][kParseVenueNameKey]];
    self.status.stringValue = [self checkStringHerlp:self.userObject[kParseUserModeKey]];
    
    
    //last message - firebase
    self.friendsNumber.stringValue = [self checkStringHerlp:self.userObject[kParseUserFriendCountKey]];
    self.lastLaunch.stringValue = self.userObject.updatedAt;
    self.lastCheckIn.stringValue = [self checkStringHerlp:self.userObject[kParseUserLastCheckinTime]];
    self.lastMode.stringValue = [self checkStringHerlp:self.userObject[kParseUserModeTimeKey]];
    //last public smart chat - firebase
    
    //notes
    self.profileNotes.string = self.userObject[kParseUserNotesKey];
    
}

- (void)updateFriendCounts:(NSInteger)count {
    self.prendingFriendsRequest.stringValue = [NSString stringWithFormat: @"%ld", (long)count];
}

#pragma mark - buttons
- (IBAction)saveNotes:(id)sender {
    NSLog(@"saved button pressed");
    [self.userObject setObject:self.profileNotes.string forKey:kParseUserNotesKey];
    [self.userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!succeeded) {
            
        }
    }];
}

- (IBAction)deleteUser:(id)sender {
    NSDictionary *params = @{@"objectId":self.objectId};
    [PFCloud callFunctionInBackground:@"deleteUser"
                       withParameters:params
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Cloud Code says: %@", result);
                                        [[[self view] window] close];
                                    }
                                    else {
                                        NSLog(@"Cloud Code Error: %@", [error localizedDescription]);
                                    }
                                }];
}

#pragma mark - retrieve User Object
- (void)fetchUser {
    PFQuery * query = [HKLParseHelper queryForUserProfile];
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *userObject, NSError *error) {
        self.userObject = userObject;
//        [self getLastLaunchTime];
        [self getPendingFriendsCount];
        [self populateData];
    }];
}

- (void)getPendingFriendsCount {

    PFQuery *query = [HKLParseHelper queryForFriendCount];
    [query whereKey:@"receiver" equalTo:self.userObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSInteger count = 0;
            for (PFObject *object in objects) {
                if (object[kParseFriendshipAcceptedAtKey] == nil) {
                    count++;
                }
            }
            [self updateFriendCounts:count];
        }
    }];
}

#pragma mark - Data Helper

- (NSString *)checkStringHerlp:(NSString *)string {
    if (string != nil) {
        return string;
    } else {
        return @"nil";
    }
}

#pragma mark - get Messages from Firebase

- (void)getFbSnapshotData {
    Firebase *chatsRef = [HKLChatClient chatsRef];
    [chatsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            self.fbSnapshot = snapshot;
            [self numOfMessagesSent];
        }
    }];
}

- (void)numOfMessagesSent {
    Firebase *chats = [[HKLChatClient peopleRef] childByAppendingPath:[NSString stringWithFormat:@"%@/chats", self.objectId]];
    [chats observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            int count = 0;
            NSArray *values = [snapshot.value allKeys];
            for (NSString *chatId in values) {
                NSDictionary *allMessages = [[self.fbSnapshot.value valueForKey:chatId] valueForKey:@"messages"];
                NSArray *keys = [allMessages allKeys];
                for (NSString *key in keys) {
                    NSString *senduuid = [[allMessages valueForKey:key] valueForKey:@"sender_uuid"];
                    if ([senduuid isEqualToString:self.objectId]) {
                        count++;
                    }
                }
                //        }
            }
            self.sentMessages.stringValue = [NSString stringWithFormat:@"%d",count];
        }
    }];

}
@end
