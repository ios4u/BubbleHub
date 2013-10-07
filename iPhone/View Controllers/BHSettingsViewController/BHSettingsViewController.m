//
//  TPSettingsViewController.m
//  iPeru
//
//  Created by Pietro Rea on 8/25/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHSettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import "BHSettings.h"

//Note: Add version 1.0 at the bottom

@interface BHSettingsViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray* section1Array;
@property (strong, nonatomic) NSArray* section2Array;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation BHSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self formatViews];
    
    self.title = @"Settings";
    self.section1Array = @[@"Miles", @"Kilometers"];
    self.section2Array = @[@"Feedback", @"Tell a friend"];
    
    //Add version at the bottom of settings tab
    self.tableView.tableFooterView = self.versionLabel;
    NSString* versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionLabel.text = [self.versionLabel.text stringByAppendingFormat:@" Version %@", versionString];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setBackgroundImageView:nil];
    [self setVersionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return self.section1Array.count;
    else
        return self.section2Array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TPSettingsCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TPSettingsCell"];
    
    //"Miles"
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = self.section1Array[indexPath.row];
        if ([[BHSettings settings] distanceUnit] == BHDistanceUnitMiles) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    //"Kilometers"
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.textLabel.text = self.section1Array[indexPath.row];
        if ([[BHSettings settings] distanceUnit] == BHDistanceUnitKilometers) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
        
    //"Feedback", "Tell a Friend"
    if (indexPath.section == 1) {
        cell.textLabel.text = self.section2Array[indexPath.row];
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString* sectionTitle;
    
    if (section == 0) {
        sectionTitle = @"Units";
    }
    else {
        sectionTitle = @"Share";
    }
    
    return sectionTitle;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        //"Miles"
        if (indexPath.row == 0) {
            UITableViewCell* milesCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            milesCell.accessoryType= UITableViewCellAccessoryCheckmark;
            UITableViewCell* kmCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            kmCell.accessoryType = UITableViewCellAccessoryNone;
            [[BHSettings settings] setDistanceUnit:BHDistanceUnitMiles];
        }
        
        //"Kilometers"
        if (indexPath.row == 1) {
            UITableViewCell* milesCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            milesCell.accessoryType= UITableViewCellAccessoryNone;
            UITableViewCell* kmCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            kmCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[BHSettings settings] setDistanceUnit:BHDistanceUnitKilometers];
        }
    }
    
    
    if (indexPath.section == 1) {
        
        //"Feedback"
        if (indexPath.row == 0) {
            [self feedbackTapped];
        }
        
        //"Tell a friend"
        if (indexPath.row == 1) {
            [self tellAFriendTapped];
        }
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Miscellaneous

- (void)feedbackTapped {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:@[@"pietrorea@gmail.com"]];
        [mailViewController setSubject:@"iPeru: Feedback"];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        [self cannotSendMailAlert];
    }
}

- (void)tellAFriendTapped {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Peruvian Restaurant Finder"];
        NSString* mailBody = @"Check out this app called iPeru. It is a simple way of finding Peruvian restaurants and it goes right in your pocket.";
        [mailViewController setMessageBody:mailBody isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        [self cannotSendMailAlert];
    }
}

- (void)cannotSendMailAlert {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Cannot send e-mail"
                                                        message:@"At least one e-mail account must be enabled in Mail."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)formatViews {
    self.backgroundImageView.image = [[UIImage imageNamed:@"straws"] resizableImageWithCapInsets:UIEdgeInsetsZero];
}

@end
