//
//  KUEventNameViewController.m
//  kure
//
//  Created by Kyle Ju on 2015-07-20.
//  Copyright (c) 2015 kure. All rights reserved.
//

#import "KUEventNameViewController.h"
#import <UIImageView+AFNetworking.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "KUStoreLocationMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "KUUIFactory.h"
#import "KUAppData.h"
#import "KUStore.h"
#import "KUStoreLocationsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface KUEventNameViewController () <MFMailComposeViewControllerDelegate,EKEventEditViewDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *addressOneButton;
@property (weak, nonatomic) IBOutlet UIButton *addressTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *pinterestButon;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabe;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *calenderButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceCalender;
@property (weak, nonatomic) IBOutlet UILabel *promotionLabel;
@property (nonatomic,retain)UIDocumentInteractionController *docFile;
@property (weak, nonatomic) IBOutlet UIView *contactInfoView;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailLabel;

@property (nonatomic, strong) NSMutableArray *allStoreLocations;


@end

@implementation KUEventNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allStoreLocations = [[NSMutableArray alloc] init];
    [self findAllLocations];
    [self removeBackText];
    [self setUpUI];
}

- (IBAction)addressButtonAction:(id)sender {
    if (sender == self.addressTwoButton) {
        if (self.eventNameType == KUEventNameDetail) {
            KUStoreLocationMapViewController *mapView = [[KUStoreLocationMapViewController alloc] init];
            //Todo: pass in the kuevent
            mapView.event = self.event;
            [self.navigationController pushViewController:mapView animated:YES];
        } else {
            //promotion
            KUStoreLocationsViewController *controller = [[KUStoreLocationsViewController alloc] init];
            controller.storeType = KUStorePromotionView;
            controller.stores = self.allStoreLocations;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}
- (IBAction)addToCalenderAction:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    //assign weak self
    __weak KUEventNameViewController *weakSelf = self;
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
        if (!granted) {
            // alertview to see "access not granted"
            return; }
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        event.title = self.event.name;
        event.startDate = self.event.startsOn;
        event.endDate = self.event.endsOn;
        event.URL = self.event.webUrl;
        event.location = self.addressTwoButton.titleLabel.text;
        event.notes = self.event.desc;
        EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
        controller.eventStore = eventStore;
        controller.event = event;
        controller.editViewDelegate = self;
        [weakSelf presentViewController:controller animated:YES completion:nil];
    }];

}
- (IBAction)phoneNumAction:(id)sender {
    [self callStore];
}

- (IBAction)emailAction:(id)sender {
    [self sendEmail];
}

- (IBAction)shareOnAction:(UIButton *)sender {
    sender.enabled = NO;
    if (self.eventNameType == KUEventNameDetail) {
        NSArray *array = [self.event.desc componentsSeparatedByString:@"."];
        if (sender == self.facebookButton) {
            [KUUIFactory postOnFacebook:self facbeookUrl:self.event.shareableUrl];
        }
        if (sender == self.twitterButton) {
            NSString *text;
            if (self.event.shareableUrl != nil) {
                text = [NSString stringWithFormat:@"%@\n%@", self.event.shareableUrl, array[0]];
            } else {
                text = [NSString stringWithFormat:@"%@", array[0]];
            }

            [KUUIFactory postOnTwitterWithText:text image:self.mainImageView.image url:nil controller:self];
        }
        if (sender == self.pinterestButon) {
            // not doing for now
        }
        if (sender == self.instagramButton) {
            NSString *text = [NSString stringWithFormat:@"%@\n%@", self.event.shareableUrl, array[0]];
            [self postOnInstagram:self.mainImageView.image text:text];
        }
    } else {
        NSArray *array = [self.promotion.desc componentsSeparatedByString:@"."];
        if (sender == self.facebookButton) {
            [KUUIFactory postOnFacebook:self facbeookUrl:self.promotion.shareableUrl];
        }
        if (sender == self.twitterButton) {
            NSString *text;
            if (self.promotion.shareableUrl != nil) {
               text = [NSString stringWithFormat:@"%@\n%@", self.promotion.shareableUrl, array[0]];
            } else {
                text = [NSString stringWithFormat:@"%@", array[0]];
            }
            [KUUIFactory postOnTwitterWithText:text image:self.mainImageView.image url:nil controller:self];
        }
        if (sender == self.pinterestButon) {
            // NOT DOING FOR NOW
        }
        if (sender == self.instagramButton) {
            NSString *text = [NSString stringWithFormat:@"%@\n%@", self.promotion.shareableUrl, array[0]];
            [self postOnInstagram:self.mainImageView.image text:text];
        }
        
    }
    sender.enabled = YES;
    
}

#pragma mark - Setup

- (void)removeBackText {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)setUpUI {
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    switch (self.eventNameType) {
        case KUEventNameDetail:{
            self.title = self.event.name;
            self.promotionLabel.hidden = YES;
            [self.mainImageView setImageWithURL:self.event.imageUrl];
            self.eventNameLabe.text = self.event.name;
            self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.event.startsOn
                                           dateStyle:NSDateFormatterLongStyle
                                           timeStyle:NSDateFormatterNoStyle];
            self.descLabel.text = self.event.desc;
            if (self.event.phone.length != 0) {
                [self.phoneNumLabel setTitle:self.event.phone forState:UIControlStateNormal];
            } else {
                [self.phoneNumLabel setTitle:@"Not Available" forState:UIControlStateNormal];
                self.phoneNumLabel.enabled = NO;
            }
            if (self.event.email.length != 0) {
                [self.emailLabel setTitle:self.event.email forState:UIControlStateNormal];
            } else {
                [self.emailLabel setTitle:@"Not Available" forState:UIControlStateNormal];
                self.emailLabel.enabled = NO;
            }
            [self.addressTwoButton setTitle: [self.event.address cityStateZip] forState:UIControlStateNormal];

        }
            break;
        case KUPromotionsNameDetail: {
            self.title = self.promotion.title;
            //label
            [self.contactInfoView removeFromSuperview];
            self.calenderButton.enabled = NO;
            self.calenderButton.hidden = YES;
            self.calenderButton.alpha = 0.0f;
            self.verticalSpaceCalender.constant = 0.0f;
            self.eventNameLabe.text = self.promotion.title;
            self.dateLabel.text = [NSString stringWithFormat:@"%@%@",@"Expires on ",[NSDateFormatter localizedStringFromDate:self.promotion.displayUntil dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle]];
            self.descLabel.text = self.promotion.desc;
            [self.addressTwoButton setTitle: @"See Available Stores" forState:UIControlStateNormal];
            if (self.promotion.couponCode) {
                self.promotionLabel.text = self.promotion.couponCode;
                if ([KUUIFactory qrCodeImageFrom:self.promotion.couponCode]) {
                    self.mainImageView.image = [KUUIFactory qrCodeImageFrom:self.promotion.couponCode];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - filter locations

- (void)findAllLocations {
    if (self.eventNameType == KUPromotionsNameDetail) {
        NSArray *allStores = [[KUAppData sharedCache] getAllStores];
        if (self.promotion.storeIds) {
            for (NSNumber *num in self.promotion.storeIds) {
                for (int k = 0 ; k < allStores.count; k ++) {
                    KUStore *store = allStores[k];
                    if ([num integerValue] == store.id) {
                        [self.allStoreLocations addObject:store];
                    }
                }
            }
        } else {
            // all store locations
            self.allStoreLocations = [[[KUAppData sharedCache] getAllStores] mutableCopy];
        }
    }
}

#pragma mark - instagram
- (void)postOnInstagram:(UIImage *)image text:(NSString *)tx {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        // shared image here ****************
        NSData* imageData = UIImagePNGRepresentation(image);
        NSString* imagePath = [self documentDirectoryWithSubpath:@"image.igo"];
        [imageData writeToFile:imagePath atomically:NO];
        NSURL* fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"file://%@",imagePath]];
        
        self.docFile = [self setupControllerWithURL:fileURL usingDelegate:self];
        self.docFile.annotation = [NSDictionary dictionaryWithObject: tx
                                                              forKey:@"InstagramCaption"];
        self.docFile.UTI = @"com.instagram.photo";
        
        // OPEN THE HOOK
        [self.docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Instagram Account"
                                                            message:@"Please Install Instagram"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

}
#pragma mark -- UIDocumentInteractionController delegate

- (UIDocumentInteractionController *) setupControllerWithURL:(NSURL*)fileURL
                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}

- (NSString*) documentDirectoryWithSubpath:(NSString*)subpath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count <= 0)
        return nil;
    
    NSString* dirPath = [paths objectAtIndex:0];
    if (subpath)
        dirPath = [dirPath stringByAppendingFormat:@"/%@", subpath];
    
    return dirPath;
}


#pragma mark - call store
- (void)callStore {
    NSString *phoneNum = self.event.phone;
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:phoneNum];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Invalid phone number" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil, nil] show];
    }
}

- (BOOL)isValidatePhoneNumber:(NSString *)phoneNumber {
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumber];
}
- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        //create the MFMailComposeViewController
        MFMailComposeViewController *composerVC = [[MFMailComposeViewController alloc] init];
        composerVC.mailComposeDelegate = self;
        [composerVC setToRecipients:@[self.event.email]];
        [composerVC setSubject:@"the subject"];
        [composerVC setMessageBody:@"the message body" isHTML:NO];
        composerVC.modalPresentationStyle = UIModalPresentationFormSheet;
        if (composerVC) {
            [self presentViewController:composerVC animated:YES completion:nil];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your device doesn't support the composer sheet" delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles: nil] show];
    }
}
#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:@"Send mail failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"CLOSE" otherButtonTitles:nil, nil] show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // close the Mail Interface
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - EKEventDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
