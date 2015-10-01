//
//  DJNotificationFollowingTableViewCell.m
//  DayJam
//
//  Created by Kyle Ju on 2015-03-27.
//  Copyright (c) 2015 DayJam. All rights reserved.
//

#import "DJNotificationTableViewCell.h"
#import "DJEverything.h"
#import "DJUser.h"
#import "DJMedia.h"
#import <UIImageView+AFNetworking.h>
#import "DJFeed.h"

@interface DJNotificationTableViewCell() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) DJUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *notificationIcon;
@property (strong, nonatomic) NSDictionary * nameAttrs;
@property (strong, nonatomic) NSDictionary * actionAttrs;

@end

@implementation DJNotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    //font style
    self.userNameLabel.font = DEFAULT_BOLDFONT(12);
    
    //color
    self.userNameLabel.textColor = kBrightColor;
    self.descriptionLabel.textColor = kDarkColor;
    
    // attributed string
    UIFont *nameFont = [UIFont italicSystemFontOfSize:12];
    UIColor *nameColor = kDarkColor;
    UIFont *actionFont = [UIFont systemFontOfSize:12];
    UIColor *actionColor = [UIColor grayColor];
    NSDictionary *nameAttrs = [NSDictionary dictionaryWithObjectsAndKeys:nameFont,NSFontAttributeName, nameColor, NSForegroundColorAttributeName, nil];
    NSDictionary *actionAttrs = [NSDictionary dictionaryWithObjectsAndKeys:actionFont, NSFontAttributeName, actionColor, NSForegroundColorAttributeName, nil];
    self.nameAttrs= nameAttrs;
    self.actionAttrs = actionAttrs;
    
    //Set up UITapGestureRecognizers
    UITapGestureRecognizer *tapOnUser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnUser:)];
    [self.userImageView addGestureRecognizer:tapOnUser];
    self.userImageView.userInteractionEnabled = YES;
    tapOnUser.delegate = self;
    
    UITapGestureRecognizer *tapOnMedia = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnMedia:)];
    [self.pictureImageView addGestureRecognizer:tapOnMedia];
    self.pictureImageView.userInteractionEnabled = YES;
    tapOnMedia.delegate = self;
    
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCell:(DJNotification *)notification {
    self.notification = notification;
    self.user = notification.actor;
    
    NSMutableAttributedString *descriptionNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@", notification.actor.username] attributes:self.nameAttrs];
    NSMutableAttributedString *descriptionActionString;

    // Username
    self.userNameLabel.text = notification.actor.username;
    
    // Thumbnail
    [self.userImageView setImageWithURL:notification.actor.small_avatar_url placeholderImage:[UIImage imageNamed:@"profilePictureDefault"]];
    
    NSString * type = notification.message_type;
    if ([type isEqualToString:@"follow"]){
        self.pictureImageView.hidden = YES;
        self.followButton.hidden = NO;
        
        if ([notification.actor.following intValue] == 0) {
            [self.followButton setSelected:NO];
            
        } else {
            [self.followButton setSelected:YES];
        }
        self.notificationIcon.image = [UIImage imageNamed:@"NotificationFollowIcon"];
        descriptionActionString = [[NSMutableAttributedString alloc] initWithString:@" started following you" attributes:self.actionAttrs];
    }
    else {
        self.pictureImageView.hidden = NO;
        self.followButton.hidden = YES;
        [self.pictureImageView setImageWithURL:notification.media.thumbnail_url];
        
        if ([type isEqualToString:@"like"]){
            self.notificationIcon.image = [UIImage imageNamed:@"NotificationLikeIcon"];
            descriptionActionString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" liked your %@", notification.media.type] attributes:self.actionAttrs];
        }
        else if ([type isEqualToString:@"comment"] || [type isEqualToString:@"comment_update"]){
            self.notificationIcon.image = [UIImage imageNamed:@"NotificationCommentIcon"];
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.descriptionLabel.frame.origin.x, CGRectGetMaxY(self.descriptionLabel.frame) - 2 , self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height)];
            commentLabel.text = notification.comment;
            commentLabel.font = [UIFont italicSystemFontOfSize:12];
            [self addSubview:commentLabel];
            
            descriptionActionString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" left a comment on your %@", notification.media.type] attributes:self.actionAttrs];
        }
        else if ([type isEqualToString:@"comment_upvote"]){
            self.notificationIcon.image = [UIImage imageNamed:@"NotificationCommentIcon"];
            UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.descriptionLabel.frame.origin.x, CGRectGetMaxY(self.descriptionLabel.frame) - 2 , self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height)];
            commentLabel.text = notification.comment;
            commentLabel.font = [UIFont italicSystemFontOfSize:12];
            [self addSubview:commentLabel];
            
            descriptionActionString = [[NSMutableAttributedString alloc] initWithString:@" upvoted your comment" attributes:self.actionAttrs];
        }
        else if ([type isEqualToString:@"rejam"]){
            self.notificationIcon.image = [UIImage imageNamed:@"NotificationRejamIcon"];
            descriptionActionString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" rejammed your %@", notification.media.type] attributes:self.actionAttrs];
        }
        else{
            descriptionActionString = [[NSMutableAttributedString alloc] initWithString:@" nothing" attributes:self.actionAttrs];
            NSLog(@"The notificationType is not follow, like, comment or rejam");
        }
    }
    
    [descriptionNameString appendAttributedString:descriptionActionString];
    [self.descriptionLabel setAttributedText:descriptionNameString];
    
}

#pragma mark - TAP

- (void)handleSingleTapOnUser:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(didTapOnProfile:)]) {
        [self.delegate didTapOnProfile:self.user];
    }
}

- (void)handleSingleTapOnMedia:(UITapGestureRecognizer *)recognizer {
    DJFeed *feed = [[DJFeed alloc] initWithUser:self.user withMedia:self.notification.media];
    if (self.notification.media != nil) {
        if ([self.delegate respondsToSelector:@selector(didTapOnMedia:)]) {
            [self.delegate didTapOnMedia:feed];
        }
    }
}

- (IBAction)followUser:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapOnFollowButton:buttonClicked:)]) {
        [self.delegate didTapOnFollowButton:self.user buttonClicked:sender];
    }
}

@end
