//
//  TPDetailViewController.m
//  iPeru
//
//  Created by Pietro Rea on 10/29/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHSettings.h"
#import "BHDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

#define kMetersPerMile 1609.34
#define kFavoriteRestaurantsArrayKey @"FavoriteRestaurants"
#define kFavoriteRestaurantsIDsKey @"FavoriteRestaurantIDs"

@interface BHDetailViewController ()

@end

@implementation BHDetailViewController

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
    
    [self.scrollView addSubview:self.containerView];
    self.scrollView.contentSize = self.containerView.frame.size;
    
    [self formatViews];
    [self populateData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setRestaurantTitle:nil];
    [self setRestaurantDistance:nil];
    [self setMapView:nil];
    [self setRestaurantAddress1:nil];
    [self setRestaurantAddress2:nil];
    [self setRestaurantPhone:nil];
    [self setAddToFavoritesButton:nil];
    [self setBackgroundImageView:nil];
    [self setContainerView:nil];
    [self setScrollView:nil];
    [self setAddressView:nil];
    [self setPhoneNumberView:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapKitDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    //Return default blue dot for user's location
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    NSString* identifier = @"Restaurant";
    MKPinAnnotationView* annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    else {
        annotationView.annotation = annotation;
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

#pragma mark - Miscellaneous methods

- (void)populateData{
    
    NSInteger distanceMeters = [self.restaurant.distance integerValue];
    double distanceMiles = distanceMeters/kMetersPerMile;
    double distanceKilometers = distanceMeters/1000.0;
    
    self.restaurantTitle.text = self.restaurant.title;
    
    if ([[BHSettings settings] distanceUnit] == BHDistanceUnitMiles) {
        self.restaurantDistance.text = [NSString stringWithFormat:@"%.2f miles", distanceMiles];
    }
    else {
        self.restaurantDistance.text = [NSString stringWithFormat:@"%.2f km", distanceKilometers];
    }
    
    self.restaurantPhone.text = self.restaurant.phone;
    NSString* phone = self.restaurantPhone.text;
    if (!phone || [phone isEqualToString:@""]) {
        self.restaurantPhone.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16];
        self.restaurantPhone.text = @"Phone not available";
    }

    self.restaurantAddress1.text = self.restaurant.address;
    self.restaurantAddress2.text = [NSString stringWithFormat:@"%@, %@ %@", self.restaurant.city, self.restaurant.state, self.restaurant.postalCode];
    
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(self.restaurant.coordinate, 0.2 * kMetersPerMile, 0.2 * kMetersPerMile);
    [self.mapView setRegion:coordinateRegion animated:YES];
    [self.mapView addAnnotation:self.restaurant];
    
    if ([self isRestaurantInFavorites:self.restaurant]) {
        self.addToFavoritesButton.enabled = NO;
    }
    
}

- (IBAction)addToFavoritesButtonTapped:(id)sender {
    
    if ([self isRestaurantInFavorites:self.restaurant]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Duplicate"
                                                            message:[NSString stringWithFormat:@"\"%@\" is already in your favorites", self.restaurant.name]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
    else {
        
        [self saveRestaurant:self.restaurant];
        
        MBProgressHUD* progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:progressHUD];
        
        // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        progressHUD.mode = MBProgressHUDModeCustomView;
        progressHUD.labelText = @"Saved";
        
        [progressHUD show:YES];
        [progressHUD hide:YES afterDelay:1];
        
        self.addToFavoritesButton.enabled = NO;
    }
    
}

- (BOOL)isRestaurantInFavorites:(BHVenue*)restaurant {
    
    BOOL isFavorite = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* favoriteIDsArray = [userDefaults stringArrayForKey:kFavoriteRestaurantsIDsKey];
    
    if ([favoriteIDsArray containsObject:self.restaurant.ID])
        isFavorite = YES;
    
    return isFavorite;
}

- (void)saveRestaurant:(BHVenue*)restaurant {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Save to Favorites Array
    NSArray* favoritesArray = [userDefaults arrayForKey:kFavoriteRestaurantsArrayKey];
    NSMutableArray* favoritesMutableArray = [favoritesArray mutableCopy];
    NSData* encodedRestaurant = [NSKeyedArchiver archivedDataWithRootObject:self.restaurant];
    [favoritesMutableArray insertObject:encodedRestaurant atIndex:0];
    [userDefaults setObject:favoritesMutableArray forKey:kFavoriteRestaurantsArrayKey];
    
    //Save to Favorite IDs Array
    NSArray* favoriteIDsArray = [userDefaults stringArrayForKey:kFavoriteRestaurantsIDsKey];
    NSMutableArray* favoriteIDsMutableArray = [favoriteIDsArray mutableCopy];
    [favoriteIDsMutableArray insertObject:self.restaurant.ID atIndex:0];
    [userDefaults setObject:favoriteIDsMutableArray forKey:kFavoriteRestaurantsIDsKey];
    
    [userDefaults synchronize];
}

- (void)formatViews {
    
    //Map View
    self.mapView.layer.cornerRadius = 10.0f;
    self.mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.5f;
//    self.mapView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.mapView.layer.shadowOpacity = 1.0f;
//    self.mapView.layer.shadowRadius = 3.0;
//    self.mapView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    
    //Address View
    self.addressView.layer.cornerRadius = 10.0f;
    self.addressView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addressView.layer.borderWidth = 1.5f;
    
    //Phone Number View
    self.phoneNumberView.layer.cornerRadius = 10.0f;
    self.phoneNumberView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneNumberView.layer.borderWidth = 1.5f;
    
    //Background Image
    self.backgroundImageView.image = [[UIImage imageNamed:@"straws"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    
    //Favorite button
    UIImage* resizableImage = [[UIImage imageNamed:@"tanButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 7, 5, 7)];
    UIImage* resizableImageHighlight = [[UIImage imageNamed:@"tanButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 7, 5, 7)];
    [self.addToFavoritesButton setBackgroundImage:resizableImage forState:UIControlStateNormal];
    [self.addToFavoritesButton setBackgroundImage:resizableImageHighlight forState:UIControlStateHighlighted];
}

@end
