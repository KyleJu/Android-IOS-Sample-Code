//
//  SMShippingAddressListViewController.m
//  ShoeMe
//
//  Created by Kyle Ju on 2015-05-07.
//  Copyright (c) 2015 shoes.com. All rights reserved.
//

#import "SMShippingAddressListViewController.h"
#import "SMShippingAddressListTableViewCell.h"
#import "SMAddShippingAddressTableViewCell.h"

#define SYSTEM_VERSION                              ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS8_OR_ABOVE                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))

static NSString* const SMShippingAddressListTableViewCellIdentifier = @"SMShippingAddressListTableViewCell";
static NSString* const SMAddShippingAddressTableViewCellIdentifier = @"SMAddShippingAddressTableViewCell";

@interface SMShippingAddressListViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UITableView *addressListTableView;
@property (strong, nonatomic) SMShippingAddressListTableViewCell *prototypeCell;
@end

@implementation SMShippingAddressListViewController {
    NSIndexPath *_indexPathClick;
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
        self.navigationRightButtonText = @"Edit";
        self.navigationRightButtonSelector = @selector(editButton);
        _addressArray = [[NSMutableArray alloc] initWithArray: @[@"1503 Marlowe Grove Dr.Sugar Land", @"77347 MD-05 2205 Lower Mall Vancouver, BC Canada", @"Just home", @"Send it to my homie G's house, my homie G is Marco Zuckerbergdelu, a japanese dude hehehehehehehehe heheheheheheheheheheheheheheh",@"What is the single $1.00 charge on my credit card?", @"Have you received my returned item?", @"Something small", @"Some really huge question that will span a bunch of lines, I mean really huge, gigantic even"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    if (!self.addressListTableView) {
        [self setupTableView];
        [self.addressListTableView reloadData];
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = self.addressArray.count;
    return num+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.addressArray.count) {
        SMAddShippingAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SMAddShippingAddressTableViewCellIdentifier];
        return cell;
    }
    SMShippingAddressListTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SMShippingAddressListTableViewCellIdentifier];
    cell.addressLabel.text = self.addressArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IOS8_OR_ABOVE) {
        return UITableViewAutomaticDimension;
    }
    if (!self.prototypeCell) {
        self.prototypeCell = [[NSBundle mainBundle] loadNibNamed:@"SMShippingAddressListTableViewCell" owner:nil options:nil][0];
    }
    self.prototypeCell.addressLabel.text = self.addressArray[indexPath.row];
    [self.prototypeCell setNeedsLayout];
    [self.prototypeCell layoutIfNeeded];
    CGFloat height = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0f;
    if (height < 59.0f) {
        height = 59.0f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (IS_IOS8_OR_ABOVE) {
            [self createAlertController:indexPath];
        } else {
            [self createAlertView:indexPath];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row != self.addressArray.count;
}

- (void)createAlertController:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete"
                                          message:@"Are you sure you want to delete this address?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.addressListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                                   }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.addressArray removeObjectAtIndex:indexPath.row];
                                   [self.addressListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)createAlertView:(NSIndexPath *)indexPath {
    _indexPathClick = indexPath;
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:@"Title"
                            message:@"Message"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            otherButtonTitles:@"Ok",nil];
    [myAlert show];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.addressListTableView reloadRowsAtIndexPaths:@[_indexPathClick] withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [self.addressArray removeObjectAtIndex:_indexPathClick.row];
        [self.addressListTableView deleteRowsAtIndexPaths:@[_indexPathClick] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma  mark - Private Method
- (void)setupTableView {
    self.addressListTableView = [[UITableView alloc] init];
    self.addressListTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressListTableView.delegate = self;
    self.addressListTableView.dataSource = self;
    self.addressListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.addressListTableView registerNib:[UINib nibWithNibName:@"SMShippingAddressListTableViewCell" bundle:nil] forCellReuseIdentifier:SMShippingAddressListTableViewCellIdentifier];
    [self.addressListTableView registerNib:[UINib nibWithNibName:@"SMAddShippingAddressTableViewCell" bundle:nil] forCellReuseIdentifier:SMAddShippingAddressTableViewCellIdentifier];
    self.addressListTableView.estimatedRowHeight = 80.0f;
    [self.contentView addSubview:self.addressListTableView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[addressListTableView]-0-|" options:0 metrics:0 views:@{@"addressListTableView":self.addressListTableView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[addressListTableView]-0-|" options:0 metrics:0 views:@{@"addressListTableView":self.addressListTableView}]];
}

- (void)backButtonDismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editButton {
    
     [self.addressListTableView setEditing:!(self.addressListTableView.isEditing) animated:YES];
}

@end
