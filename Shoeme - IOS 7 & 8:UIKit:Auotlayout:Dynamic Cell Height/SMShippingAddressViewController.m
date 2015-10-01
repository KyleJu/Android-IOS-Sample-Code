//
//  SMShippingAddressViewController.m
//  ShoeMe
//
//  Created by Kyle Ju on 2015-04-29.
//  Copyright (c) 2015 shoes.com. All rights reserved.
//

#import "SMShippingAddressViewController.h"
#import "SMShippingAddressFieldTableViewCell.h"
#import "SMShippingStatesTableViewCell.h"
#import "SMShippingAddressSliderTableViewCell.h"
#import "SMCusPickerView.h"
#import "SMShippingAddressListViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *const SMShippingAddressFieldTableViewCellIdentifier = @"SMShippingAddressFieldTableViewCell";
static NSString *const SMShippingStatesTableViewCellIdentifier = @"SMShippingStatesTableViewCell";
static NSString *const SMShippingAddressSliderTableViewCellIdentifier = @"SMShippingAddressSliderTableViewCell";

@interface SMShippingAddressViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CusPickerViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UITableView *shippingAddressTableView;
@property (copy, nonatomic) NSString *shippingStreet;
@property (copy, nonatomic) NSString *shippingApartment;
@property (copy, nonatomic) NSString *shippingCity;
@property (copy, nonatomic) NSString *shippingStates;
@property (strong, nonatomic) UITextField *statesTextField;
@property (copy, nonatomic) NSString *shippingZipCode;
@property (strong, nonatomic) UISwitch *defaultAddressSwitch;
@property (strong, nonatomic) UISwitch *POBoxSwtich;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIGestureRecognizer *tapper;


@end

@implementation SMShippingAddressViewController {
    CGRect _ZipCodeTextFieldFrame;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showSeparator = YES;
        self.showDismissArrow = NO;
        self.showNavigationBar = YES;
        
        self.navigationTitle = @"Shipping Address";
        self.navigationLeftButtonImage = [UIImage imageNamed:@"back_btn"];
        self.navigationLeftButtonSelector = @selector(backButtonDismiss);
        
        //set the default pickview choice
        _shippingStates = @"Alabama";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tapper = [[UITapGestureRecognizer alloc]
                   initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapper];
}

- (void)viewDidLayoutSubviews {
    if (!self.shippingAddressTableView){
        [self setupTableView];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.footerView){
            [self setupFooterView];
        }
        self.shippingAddressTableView.tableFooterView = self.footerView;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath >=0 && indexPath.row <=2) {
        SMShippingAddressFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SMShippingAddressFieldTableViewCellIdentifier];
        switch (indexPath.row) {
            case SMShippingAddressStreet:
                [cell configureCell:@"Street" subText:@"(US States, Territories and Military Address only)" textFieldTag:indexPath.row ];
                break;
            case SMShippingAddressApartment:
                [cell configureCell:@"Apartment, suite#, company, c/o, etc." subText:@"(optional)" textFieldTag:indexPath.row];
                break;
            case SMShippingAddressCity:
                [cell configureCell:@"City" subText:@"" textFieldTag:indexPath.row];
                break;
            default:
                break;
        }
        cell.addressContentTextfield.delegate = self;
        return cell;
    }
    
    if (indexPath.row == 3) {
        SMShippingStatesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SMShippingStatesTableViewCellIdentifier];
        self.statesTextField = cell.statesTextField;
        cell.zipCodeTextField.delegate = self;
        cell.statesTextField.delegate = self;
        [cell configureCell:indexPath.row];
        return cell;
    }
    
    if (indexPath.row == 4 || indexPath.row == 5) {
        SMShippingAddressSliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SMShippingAddressSliderTableViewCellIdentifier];
        switch (indexPath.row - 3) {
            case SMShippingAddressSetDefaultSwtichCell:
                [cell configureCell:@"Set this address as default"];
                self.defaultAddressSwitch = cell.addressSwitch;
                break;
            case SMShippingAddressSetPOBoxSwtichCell:
                [cell configureCell:@"This address is a P.O. box"];
                self.POBoxSwtich = cell.addressSwitch;
                break;
            default:
                break;
        }
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 100.0f;
    }
    if (indexPath.row == 4 || indexPath.row == 5){
        return 55.0f;
    }
    return 80.0f;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == SMShippingAddressStates) {
        [[self view] endEditing:YES];
        [self initPickerView];
        return NO;
    }
    _ZipCodeTextFieldFrame = [self.shippingAddressTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(textField.tag == SMShippingAddressZipCode? 3:textField.tag) inSection:0]].frame;
        _ZipCodeTextFieldFrame = [self.shippingAddressTableView convertRect:_ZipCodeTextFieldFrame toView:self.view];
        [self enableKeyboardFrameDidChangeNotification];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case SMShippingAddressStreet:
            self.shippingStreet = textField.text;
            break;
        case SMShippingAddressApartment:
            self.shippingApartment = textField.text;
            break;
        case SMShippingAddressCity:
            self.shippingCity = textField.text;
            break;
        case SMShippingAddressZipCode:
            self.shippingZipCode = textField.text;
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
        [textField resignFirstResponder];
    else
        [view becomeFirstResponder];
    
    //[self disableKeyboardFrameDidChangeNotification];
    return YES;
}

#pragma mark - Notification
- (void)enableKeyboardFrameDidChangeNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)disableKeyboardFrameDidChangeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - keyboardFrameDidChange
- (void) keyboardFrameDidChange:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    if (keyboardFrame.origin.y == self.view.bounds.size.height) {
        [self.shippingAddressTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        if (CGRectGetMaxY(_ZipCodeTextFieldFrame) > keyboardFrame.origin.y) {
            CGFloat offsetY = keyboardFrame.size.height - (self.view.frame.size.height - CGRectGetMaxY(_ZipCodeTextFieldFrame));
            [self.shippingAddressTableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        }
    }
}

#pragma mark - SortByChoicePickerViewDelegate
- (void)cusPickerViewDoneBtnClickedWithChoice:(NSString *)choice {
    if (choice) {
        self.statesTextField.text = choice;
        self.shippingStates = choice;
    } else {
        self.statesTextField.text = self.shippingStates;
    }
}

#pragma mark - Private Mehthod

- (void)initPickerView {
    //initiate the pickview
    NSArray *americanStates = [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil];
    SMCusPickerView *statesPickerView = [[SMCusPickerView alloc] initWithFrame:self.view.bounds withChoices:americanStates withCurrentChoice:self.shippingStates];
    statesPickerView.delegate = self;
    [self.view addSubview:statesPickerView];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)nextButtonPressed {
    NSLog(@"%@, %@, %@", self.shippingStates, self.shippingZipCode, self.shippingStreet);
    [self.navigationController pushViewController:[[SMShippingAddressListViewController alloc] init] animated:YES];

}

- (void)backButtonDismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTableView {
    self.shippingAddressTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.shippingAddressTableView.translatesAutoresizingMaskIntoConstraints = NO;
    //set up tableView
    self.shippingAddressTableView.delegate = self;
    self.shippingAddressTableView.dataSource = self;
    self.shippingAddressTableView.allowsSelection = NO;
    self.shippingAddressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.shippingAddressTableView registerNib:[UINib nibWithNibName:@"SMShippingAddressFieldTableViewCell" bundle:nil] forCellReuseIdentifier:SMShippingAddressFieldTableViewCellIdentifier];
    [self.shippingAddressTableView registerNib:[UINib nibWithNibName:@"SMShippingStatesTableViewCell" bundle:nil] forCellReuseIdentifier:SMShippingStatesTableViewCellIdentifier];
    [self.shippingAddressTableView registerNib:[UINib nibWithNibName:@"SMShippingAddressSliderTableViewCell" bundle:nil] forCellReuseIdentifier:SMShippingAddressSliderTableViewCellIdentifier];
    //add subview
    [self.contentView addSubview:self.shippingAddressTableView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[shippingAddressView]-0-|" options:0 metrics:0 views:@{@"shippingAddressView":self.shippingAddressTableView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[shippingAddressView]-0-|" options:0 metrics:0 views:@{@"shippingAddressView":self.shippingAddressTableView}]];
}

- (void)setupFooterView {
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.shippingAddressTableView.frame.size.width, 65.0f)];
    self.footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    nextButton.backgroundColor = UIColorFromRGB(0x37bbe0);
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17];
    nextButton.tintColor = [UIColor whiteColor];
    nextButton.frame = CGRectMake(10.0f, 10.0f, self.footerView.frame.size.width - 20.0f, 45.0f);
    [self.footerView addSubview:nextButton];
}
- (void)dealloc {
    [self disableKeyboardFrameDidChangeNotification];
}

@end
