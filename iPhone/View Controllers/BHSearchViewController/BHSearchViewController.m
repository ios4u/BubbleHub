//
//  TPSearchViewController.m
//  iPeru
//
//  Created by Pietro Rea on 8/25/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHGetVenueListWebOperation.h"
#import "BHGetVenueListResult.h"
#import "BHSearchViewController.h"
#import "BHDetailViewController.h"
#import "BHVenue.h"
#import "BHSettings.h"
#import "MBProgressHUD.h"

@interface BHSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *restaurantArray;
@property (strong, nonatomic) BHGetVenueListWebOperation* getRestaurantListWebOperation;
@property (strong, nonatomic) UIView* blackOverlayView;

@end

@implementation BHSearchViewController

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
    
    self.title = @"Search";
    
    self.blackOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    self.blackOverlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.restaurantArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"BHRestaurantCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BHRestaurantCell"];
    
    BHVenue* restaurant = [self.restaurantArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", restaurant.address, restaurant.city, restaurant.state, restaurant.postalCode];
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BHDetailViewController* detailViewController = [[BHDetailViewController alloc] initWithNibName:@"BHDetailViewController" bundle:nil];
    detailViewController.restaurant = self.restaurantArray[indexPath.row];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self insertBlackOverlayView];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self removeBlackOverlayView];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    __weak BHSearchViewController* viewController = self;
    
    self.getRestaurantListWebOperation = [[BHGetVenueListWebOperation alloc] init];
    NSString* geocodableString = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.getRestaurantListWebOperation.geocodableString = geocodableString;
    self.getRestaurantListWebOperation.clientID = [[BHSettings settings] clientID];
    self.getRestaurantListWebOperation.clientSecret = [[BHSettings settings] clientSecret];
    
    [self.getRestaurantListWebOperation setSuccessBlock:^(id result) {
        [viewController getRestaurantListOperationSuccess];
    }];
    
    [self.getRestaurantListWebOperation setFailureBlock:^{
        [viewController getRestaurantListOperationFailure];
    }];
    
    [self.getRestaurantListWebOperation startAsynchronous];
}

- (void)getRestaurantListOperationSuccess {
    [self removeBlackOverlayView];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    BHGetVenueListResult* restaurantListResult = self.getRestaurantListWebOperation.result;
    self.restaurantArray = restaurantListResult.restaurantArray;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.restaurantArray.count == 0) {
        [self showNoSearchResultsHUD];
    }

}

- (void)getRestaurantListOperationFailure {
    [self removeBlackOverlayView];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
    [self.restaurantArray  removeAllObjects];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self showNoSearchResultsHUD];
}

- (void)showNoSearchResultsHUD {
    MBProgressHUD* progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = @"No search results";
    [progressHUD show:YES];
    [progressHUD hide:YES afterDelay:1.5];
}

- (void)insertBlackOverlayView {
    [self.view insertSubview:self.blackOverlayView aboveSubview:self.tableView];
}

- (void)removeBlackOverlayView {
    [self.blackOverlayView removeFromSuperview];
}

@end
