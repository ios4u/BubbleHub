//
//  BHMainViewController.m
//  BubbleHub
//
//  Created by Pietro Rea on 12/3/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHSettings.h"
#import "BHMainViewController.h"
#import "BHNearbyViewController.h"
#import "BHSearchViewController.h"
#import "BHFavoritesViewController.h"
#import "BHSettingsViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

#define kFavoriteRestaurantsArrayKey @"FavoriteRestaurants"
#define kFavoriteRestaurantsIDsKey @"FavoriteRestaurantIDs"

@interface BHMainViewController ()

@property (strong, nonatomic) UITabBarController* tabBarController;
@property (strong, nonatomic) BHNearbyViewController* nearbyViewController;
@property (strong, nonatomic) BHSearchViewController* searchViewController;
@property (strong, nonatomic) BHFavoritesViewController* favoritesViewController;
@property (strong, nonatomic) BHSettingsViewController* settingsViewController;

@end

@implementation BHMainViewController

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
    
    [self setupTabBarViewController];
    
    //Setup storage in NSUserDefaults for favorite resturants
    NSUserDefaults* userDefaults  = [NSUserDefaults standardUserDefaults];
    
    NSArray* favoritesArray = [userDefaults arrayForKey:kFavoriteRestaurantsArrayKey];
    if (!favoritesArray) [userDefaults setObject:[[NSArray alloc] init] forKey:kFavoriteRestaurantsArrayKey];
    
    NSArray* favoriteIDs = [userDefaults stringArrayForKey:kFavoriteRestaurantsIDsKey];
    if (!favoriteIDs) [userDefaults setObject:[[NSArray alloc] init] forKey:kFavoriteRestaurantsIDsKey];
    
    //Turn on AFNetworking network activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    //Default unit of measurement is the mile/feet
    if (![[BHSettings settings] distanceUnit]) {
        [[BHSettings settings] setDistanceUnit:BHDistanceUnitMiles];
    }
    
    
#ifdef SCREENSHOT
    [self prepareForScreenshot];
#endif
}

- (void)setupTabBarViewController{
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    
    self.nearbyViewController = [[BHNearbyViewController alloc] init];
    UINavigationController* nearbyNavigationController = [[UINavigationController alloc] initWithRootViewController:self.nearbyViewController];
    
    self.searchViewController = [[BHSearchViewController alloc] init];
    UINavigationController* searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    
    self.favoritesViewController = [[BHFavoritesViewController alloc] init];
    UINavigationController* favoritesNavigationController = [[UINavigationController alloc] initWithRootViewController:self.favoritesViewController];
    
    self.settingsViewController = [[BHSettingsViewController alloc] init];
    UINavigationController* settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    
    [viewControllers addObject:nearbyNavigationController];
    [viewControllers addObject:searchNavigationController];
    [viewControllers addObject:favoritesNavigationController];
    [viewControllers addObject:settingsNavigationController];
    
    self.nearbyViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Nearby" image:[UIImage imageNamed:@"74-location"] tag:0];
    self.searchViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"06-magnify"] tag:1];
    self.favoritesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:[UIImage imageNamed:@"28-star"] tag:1];
    self.settingsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"20-gear-2"] tag:1];
    
    self.tabBarController.viewControllers = viewControllers;
    self.tabBarController.view.frame = self.view.bounds;
    [self.view addSubview:self.tabBarController.view];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



//Call this method to nil out any dynamic or localized content
- (void)prepareForScreenshot {
    self.nearbyViewController.tabBarItem.title = @"";
    self.searchViewController.tabBarItem.title = @"";
    self.favoritesViewController.tabBarItem.title = @"";
    self.settingsViewController.tabBarItem.title = @"";
}

- (void)updateNearbyViewController {
    [self.nearbyViewController updateData];
}


@end

