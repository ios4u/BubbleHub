//
//  TPFavoritesViewController.m
//  iPeru
//
//  Created by Pietro Rea on 8/25/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHFavoritesViewController.h"
#import "BHDetailViewController.h"
#import "MBProgressHUD.h"

#define kFavoriteRestaurantsArrayKey @"FavoriteRestaurants"
#define kFavoriteRestaurantsIDsKey @"FavoriteRestaurantIDs"

@interface BHFavoritesViewController ()

@property (strong, nonatomic) MBProgressHUD* progressHUD;
@property (strong, nonatomic) NSMutableArray* favoritesArray;
@property (strong, nonatomic) NSMutableArray* favoriteIDsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BHFavoritesViewController

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
    
    self.title = @"Favorites";
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(editButtonTapped)];
    
    editButton.possibleTitles = [[NSSet alloc] initWithArray:@[@"Edit", @"Cancel"]];
    
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Recreate array of favorite TPRestaurants
    self.favoritesArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* encodedRestaurants = [userDefaults objectForKey:kFavoriteRestaurantsArrayKey];
    
    for (NSData* encodedRestaurant in encodedRestaurants) {
        BHVenue* restaurant = (BHVenue*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedRestaurant];
        [self.favoritesArray addObject:restaurant];
    }
    
    //Recreate array of favorite restaurant IDs
    self.favoriteIDsArray = [[userDefaults objectForKey:kFavoriteRestaurantsIDsKey] mutableCopy];
    [self.tableView reloadData];
    
    //Handle the case where there are no saved restaurants
    [self checkNoFavoritesSaved];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNoFavoritesHUD];
    if (self.tableView.editing) [self.tableView setEditing:NO animated:NO];
}

- (void)viewDidUnload
{
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
    return self.favoritesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TPRestaurantCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TPRestaurantCell"];
    
    BHVenue* restaurant = [self.favoritesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", restaurant.address, restaurant.city, restaurant.state, restaurant.postalCode];
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete from data model
        [self removeRestaurantAtIndexPath:indexPath];
        
        //Delete table view cell
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BHDetailViewController* detailViewController = [[BHDetailViewController alloc] initWithNibName:@"BHDetailViewController" bundle:nil];
    detailViewController.restaurant = self.favoritesArray[indexPath.row];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Miscellanous methods

- (void)editButtonTapped {
    
    //Start editing
    if (!self.tableView.editing) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Cancel"];
        [self.tableView setEditing:YES animated:YES];
    }
    //Stop editing
    else {
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.tableView setEditing:NO animated:YES];
    }
    
}

- (void)removeRestaurantAtIndexPath:(NSIndexPath*)indexPath {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BHVenue* restaurant = self.favoritesArray[indexPath.row];
    
    //Remove restaurant from local favorites array
    [self.favoritesArray removeObject:restaurant];
    
    //Remove restaurant from NSUserDefaults favorites array
    NSMutableArray* encodedRestaurants = [[NSMutableArray alloc] init];
    for (BHVenue* restaurant in self.favoritesArray) {
        NSData* encodedRestaurant = [NSKeyedArchiver archivedDataWithRootObject:restaurant];
        [encodedRestaurants insertObject:encodedRestaurant atIndex:0];
    }
    
    [userDefaults setObject:encodedRestaurants forKey:kFavoriteRestaurantsArrayKey];
    
    //Remove restaurant from local favorite IDs array
    [self.favoriteIDsArray removeObject:restaurant.ID];
    
    //Check the case of no more saved restaurants
    [self checkNoFavoritesSaved];
    
    //Remove restaurant from NSUserDefaults favorite IDs array
    [userDefaults setObject:self.favoriteIDsArray forKey:kFavoriteRestaurantsIDsKey];
    
    if (self.favoriteIDsArray.count == 0) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.tableView setEditing:NO animated:YES];
    }
    
    [userDefaults synchronize];
}

- (void)checkNoFavoritesSaved {
    if (self.favoriteIDsArray.count == 0) {
        [self showNoFavoritesHUD];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        [self hideNoFavoritesHUD];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)showNoFavoritesHUD {
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHUD];
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = @"No saved restaurants";
    [self.progressHUD show:YES];
}

- (void)hideNoFavoritesHUD {
    [self.progressHUD hide:YES];
}


@end
