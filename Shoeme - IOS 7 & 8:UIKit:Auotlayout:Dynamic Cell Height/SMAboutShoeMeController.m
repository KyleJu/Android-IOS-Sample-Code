//
//  SMAboutShoeMeController.m
//  ShoeMe
//
//  Created by Kyle Ju on 2015-04-24.
//  Copyright (c) 2015 shoes.com. All rights reserved.
//

#import "SMAboutShoeMeController.h"

#import "SMAboutShoeMeView.h"

@interface SMAboutShoeMeController ()

@property (nonatomic, strong) SMAboutShoeMeView* aboutShoeMeView;

@end

@implementation SMAboutShoeMeController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.showSeparator = NO;
        self.showDismissArrow = NO;
        self.showNavigationBar = YES;
        
        self.navigationTitle = @"About SHOES.COM";
        self.navigationLeftButtonImage = [UIImage imageNamed:@"back_btn"];
        self.navigationLeftButtonSelector = @selector(backButtonDismiss);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.aboutShoeMeView = [[SMAboutShoeMeView alloc] init];
    self.aboutShoeMeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.aboutShoeMeView];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[aboutShoeMeView]-0-|" options:0 metrics:0 views:@{@"aboutShoeMeView":self.aboutShoeMeView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[aboutShoeMeView]-0-|" options:0 metrics:0 views:@{@"aboutShoeMeView":self.aboutShoeMeView}]];
}

- (void)backButtonDismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
