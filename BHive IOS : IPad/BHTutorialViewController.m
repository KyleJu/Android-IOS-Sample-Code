//
//  BHTutorialViewController.m
//  BHive
//
//  Created by Vinson Li on 2015-03-16.
//  Copyright (c) 2015 com.tbadigital. All rights reserved.
//

#import "BHTutorialViewController.h"
#import "BHTransparentView.h"
#import "BHTutorialElement.h"
#import "AppDelegate.h"

static const CGFloat margin = 10.f;
#define IS_IPAD   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define DESC_FONT_SIZE ((IS_IPAD)? 20.f:14.f)
#define STATUS_BAR_HEIGHT 20
#define TUTORIALVIEW_BUTTON_HEIGHT 50

@interface BHTutorialViewController ()

@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet BHTransparentView *overlayView;
@property (strong, nonatomic) UILabel *descLabel;


@end

@implementation BHTutorialViewController {
    CGFloat _screenWidth;
    CGFloat _screenHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _screenWidth = MAX(size.width, size.height);
        _screenHeight = MIN(size.width, size.height);
    }
    else {
        _screenWidth = MIN(size.width, size.height);
        _screenHeight = MAX(size.width, size.height);
    }
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, _screenWidth - 2 * margin, 80)];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.font = [UIFont fontWithName:@"SourceSansPro-SemiBold" size:DESC_FONT_SIZE];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.numberOfLines = 0;
    descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:descLabel];
    self.descLabel = descLabel;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.currentIndex = 0;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    if (_currentIndex < self.elements.count) {
        [self loadTutorial];
    }
}

- (void)loadTutorial {
    BHTutorialElement *element = self.elements[_currentIndex];
    self.overlayView.rectsArray = element.rects;
    
    self.descLabel.text = element.desc;
    
    CGRect rect = [element.rects[0] CGRectValue];
    if (CGRectGetMaxX(rect) <= _screenWidth/3) {
        self.descLabel.frame = ({
            CGRect frame = self.descLabel.frame;
            frame.origin.x = CGRectGetMaxX(rect) + margin;
            frame.origin.y = CGRectGetMinY(rect);
            frame.size.width = _screenWidth - CGRectGetMaxX(rect) - 2 * margin;
            frame.size.height = [self calculateLabelHeight:frame.size.width text:self.descLabel.text];
            frame;
        });
    } else if (CGRectGetMinX(rect) >= _screenWidth *2 /3){
        self.descLabel.frame = ({
            CGRect frame = self.descLabel.frame;
            frame.origin.y = CGRectGetMinY(rect);
            frame.size.width = _screenWidth - CGRectGetMinX(rect) - 2 * margin;
            frame.size.height = [self calculateLabelHeight:frame.size.width text:self.descLabel.text];
            frame.origin.x = (CGRectGetMinX(rect) > 2 * frame.size.width)? CGRectGetMinX(rect) - margin - frame.size.width:margin;
            frame;
        });
    } else if (CGRectGetMinY(rect) - STATUS_BAR_HEIGHT > _screenHeight - CGRectGetMaxY(rect) - TUTORIALVIEW_BUTTON_HEIGHT){
        self.descLabel.frame = ({
            CGRect frame = self.descLabel.frame;
            frame.size.height = [self calculateLabelHeight:frame.size.width text:self.descLabel.text];
            frame.origin.y = CGRectGetMinY(rect) - frame.size.height - margin;
            frame;
        });
    } else {
        self.descLabel.frame = ({
            CGRect frame = self.descLabel.frame;
            frame.size.height = [self calculateLabelHeight:frame.size.width text:self.descLabel.text];
            frame.origin.y = CGRectGetMaxY(rect) + margin;
            frame;
        });
    }
    
}

- (IBAction)skipAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BHTutorialEnded" object:nil];
    }];
}

- (IBAction)nextAction:(id)sender {
    if (self.currentIndex < self.elements.count-1) {
        self.currentIndex++;
    }
    else {
        [self dismissViewControllerAnimated:NO completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BHTutorialEnded" object:nil];
        }];
    }
}
#pragma mark - Private Method
- (CGFloat)calculateLabelHeight:(CGFloat)maxWidth text:(NSString *)descText {
    CGRect textRect = [descText boundingRectWithSize:CGSizeMake(maxWidth, 9999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-SemiBold" size:DESC_FONT_SIZE]}
                                        context:nil];
    return textRect.size.height;
}

@end
