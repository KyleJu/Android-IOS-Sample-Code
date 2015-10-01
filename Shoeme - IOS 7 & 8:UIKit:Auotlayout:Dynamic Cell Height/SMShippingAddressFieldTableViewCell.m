//
//  SMShippingAddressFieldTableViewCell.m
//  ShoeMe
//
//  Created by Kyle Ju on 2015-04-29.
//  Copyright (c) 2015 shoes.com. All rights reserved.
//

#import "SMShippingAddressFieldTableViewCell.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SMShippingAddressFieldTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *addressContetLabel;
@property (strong, nonatomic) NSDictionary *mainTextAttrs;
@property (strong, nonatomic) NSDictionary *subTextAttrs;

@end

@implementation SMShippingAddressFieldTableViewCell

- (void)awakeFromNib {
    UIColor *mainTextColor = [UIColor blackColor];
    UIColor *subTextColor = UIColorFromRGB(0x9b9a9b);
    self.mainTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:mainTextColor, NSForegroundColorAttributeName, nil];
    self.subTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:subTextColor, NSForegroundColorAttributeName, nil];
    self.addressContentTextfield.layer.borderWidth = 1.0f;
    self.addressContentTextfield.layer.masksToBounds = YES;
    self.addressContentTextfield.layer.borderColor = [UIColorFromRGB(0x969696) CGColor];
    self.addressContentTextfield.returnKeyType = UIReturnKeyNext;
    
    //add 10px padding on the left for place holder
    UIImageView *paddingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.addressContentTextfield.leftView = paddingView;
    self.addressContentTextfield.leftViewMode = UITextFieldViewModeAlways;
    
}

- (void)configureCell:(NSString *)mainText subText:(NSString *)subtext textFieldTag:(NSInteger)tag {
    NSMutableAttributedString *mainTextAttString =[[NSMutableAttributedString alloc] initWithString:mainText attributes:self.mainTextAttrs];
    NSMutableAttributedString *subTextAttString = [[NSMutableAttributedString alloc] initWithString:subtext attributes:self.subTextAttrs];
    [mainTextAttString appendAttributedString:subTextAttString];
    self.addressContetLabel.attributedText = mainTextAttString;
    self.addressContentTextfield.tag = tag;
}

@end
