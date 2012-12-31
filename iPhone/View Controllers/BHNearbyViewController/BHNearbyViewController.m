//
//  TPNearbyViewController.m
//  iPeru
//
//  Created by Pietro Rea on 8/25/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BHGetVenueListWebOperation.h"
#import "BHGetVenueListResult.h"
#import "BHNearbyViewController.h"
#import "BHDetailViewController.h"
#import "BHSettings.h"
#import "BHVenue.h"
#import "MBProgressHUD.h"

#define MAP_VIEW_INDEX 0
#define LIST_VIEW_INDEX 1
#define METERS_PER_MILE 1609.34

@interface BHNearbyViewController ()

//container for mapViewContainer and tableView
@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIView* mapContainerView;
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UIButton* userLocationButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSMutableArray* allRestaurants;
@property (strong, nonatomic) NSMutableArray* nearbyRestaurants;
@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) BHGetVenueListWebOperation *getRestaurantListWebOperation;

- (IBAction)segmentedControlTapped:(id)sender;

@end

@implementation BHNearbyViewController

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

    self.title = @"Nearby";
    self.locationManager = [[CLLocationManager alloc] init];
    self.nearbyRestaurants = [[NSMutableArray alloc] init];
    self.allRestaurants = [[NSMutableArray alloc] init];
    
    [self setupMapView];
    [self setupTableView];
    
#ifdef SCREENSHOT
    [self prepareForScreenshot];
#endif
    
}

- (void)setupMapView {
    
    //Container view
    self.mapContainerView.frame = self.centerView.frame;
    [self.view addSubview:self.mapContainerView];
    
    //Map view
    self.mapView.frame = self.mapContainerView.frame;
    [self.mapContainerView addSubview:self.mapView];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation= YES;
    
    
    //User location button
    CGFloat y = self.mapContainerView.frame.size.height - 41;
    self.userLocationButton.frame = CGRectMake(10, y, 31, 31);
    [self.mapContainerView addSubview:self.userLocationButton];
    [self.userLocationButton addTarget:self action:@selector(userLocationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //Refresh button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshButtonTapped)];
}

- (void)setupTableView {
    self.tableView.frame = self.centerView.frame;
    [self.view insertSubview:self.tableView belowSubview:self.mapContainerView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat y = self.mapContainerView.frame.size.height - 50;
    self.userLocationButton.frame = CGRectMake(10, y, 31, 31);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mapView.frame = self.centerView.frame;
    self.tableView.frame = self.centerView.frame;
}

- (void)viewDidUnload
{
    [self setSegmentedControl:nil];
    [self setCenterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)segmentedControlTapped:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == LIST_VIEW_INDEX)
        [self presentTableView];
    else
        [self presentMapView];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearbyRestaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"TPRestaurantCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TPRestaurantCell"];
    
    BHVenue* restaurant = [self.nearbyRestaurants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", restaurant.address, restaurant.city, restaurant.state, restaurant.postalCode];
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BHDetailViewController* detailViewController = [[BHDetailViewController alloc] initWithNibName:@"BHDetailViewController" bundle:nil];
    detailViewController.restaurant = self.nearbyRestaurants[indexPath.row];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - MKMapViewDelegate methods

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
    
    //Set up callout button
    UIButton* calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = calloutButton;
    [calloutButton addTarget:self action:@selector(calloutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews {
    
    //Animate annotationViews dropping from above
    
    for (MKAnnotationView *annotationView in annotationViews) {
        CGRect endFrame = annotationView.frame;
        annotationView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5 animations:^{
            annotationView.frame = endFrame;
        }];
    }
}

#pragma mark - Miscellaneous methods

- (void)presentMapView {

    //Add Refresh button
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)];
    [self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
    
    [UIView transitionFromView:self.tableView
                        toView:self.mapContainerView
                      duration:0.5f
                       options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews)
                    completion:nil];
    
}

- (void)presentTableView {
    
    //Hide refresh button
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    [UIView transitionFromView:self.mapContainerView
                        toView:self.tableView
                      duration:0.5f
                       options:(UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews)
                    completion:^(BOOL finished) {
                        [self.tableView reloadData];
                    }];
    
}

- (void)calloutButtonTapped:(id)sender {
    
    BHDetailViewController* detailViewController = [[BHDetailViewController alloc] initWithNibName:@"BHDetailViewController" bundle:nil];
    detailViewController.restaurant = (BHVenue*)[[self.mapView selectedAnnotations] lastObject];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)getRestaurantListWebOperation:(CLLocationCoordinate2D)coordinates searchRadius:(CLLocationDistance)radius {
    
    self.getRestaurantListWebOperation = [[BHGetVenueListWebOperation alloc] init];
    self.getRestaurantListWebOperation.latitude = [NSNumber numberWithDouble:(double)coordinates.latitude];
    self.getRestaurantListWebOperation.longitude = [NSNumber numberWithDouble:(double)coordinates.longitude];
    self.getRestaurantListWebOperation.clientID = [[BHSettings settings] clientID];
    self.getRestaurantListWebOperation.clientSecret = [[BHSettings settings] clientSecret];
    
    __weak BHNearbyViewController* viewController = self;
    [self.getRestaurantListWebOperation setSuccessBlock:^(id result) {
        [viewController handleInitialRestaurantListResponse];
    }];
    
    [self.getRestaurantListWebOperation startAsynchronous];
}

- (void)refreshRestaurantListWebOperation:(CLLocationCoordinate2D)coordinates searchRadius:(CLLocationDistance)radius {
    
    self.getRestaurantListWebOperation = [[BHGetVenueListWebOperation alloc] init];
    self.getRestaurantListWebOperation.latitude = [NSNumber numberWithDouble:(double)coordinates.latitude];
    self.getRestaurantListWebOperation.longitude = [NSNumber numberWithDouble:(double)coordinates.longitude];
    self.getRestaurantListWebOperation.radius = [NSNumber numberWithDouble:radius];
    self.getRestaurantListWebOperation.clientID = [[BHSettings settings] clientID];
    self.getRestaurantListWebOperation.clientSecret = [[BHSettings settings] clientSecret];
    
    __weak BHNearbyViewController* viewController = self;
    [self.getRestaurantListWebOperation setSuccessBlock:^(id result) {
        [viewController handleRefreshRestaurantListResponse];
    }];
    
    [self.getRestaurantListWebOperation startAsynchronous];
}

- (void)handleInitialRestaurantListResponse {
    
    BHGetVenueListResult* result = (BHGetVenueListResult*) self.getRestaurantListWebOperation.result;
    self.nearbyRestaurants = [result.restaurantArray mutableCopy];
    
    for (BHVenue* restaurant in self.nearbyRestaurants) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ID == %@", restaurant.ID];
        NSArray* filteredArray = [self.allRestaurants filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            [self.mapView addAnnotation:restaurant];
            [self.allRestaurants addObject:restaurant];
        }
    }
    
    MBProgressHUD* progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = [NSString stringWithFormat:@"%i restaurants near you.", self.nearbyRestaurants.count];
    [progressHUD show:YES];
    [progressHUD hide:YES afterDelay:1];
}

- (void)handleRefreshRestaurantListResponse {
    
    BHGetVenueListResult* result = (BHGetVenueListResult*) self.getRestaurantListWebOperation.result;
    
    NSInteger newRestaurantsCount = 0;
    
    for (BHVenue* restaurant in result.restaurantArray) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ID == %@", restaurant.ID];
        NSArray* filteredArray = [self.allRestaurants filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            [self.mapView addAnnotation:restaurant];
            [self.allRestaurants addObject:restaurant];
            newRestaurantsCount++;
        }
    }
    
    MBProgressHUD* progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = [NSString stringWithFormat:@"%i new restaurants in this area.", newRestaurantsCount];
    
    [progressHUD show:YES];
    [progressHUD hide:YES afterDelay:1];
}

- (void)userLocationButtonTapped {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

//Call this method to nil out any dynamic or localized content
- (void)prepareForScreenshot {
    
    self.title = @"";
    self.tabBarItem.title = @"";
    self.mapView.hidden = YES;
    self.tableView.hidden = YES;
    self.userLocationButton.hidden = YES;
    
    [self.segmentedControl setTitle:@"" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"" forSegmentAtIndex:1];
}

- (void)refreshButtonTapped {
    [self refreshRestaurantListWebOperation:self.mapView.centerCoordinate searchRadius:[self distanceFromMapCenter]];
}

- (CLLocationDistance)distanceFromMapCenter { //returns meters from the side of the map to the center of the map
    
    MKMapRect mapRect = self.mapView.visibleMapRect;
    
    double pointX = mapRect.origin.x;
    double pointY = mapRect.origin.y + (mapRect.size.height / 2);
    MKMapPoint borderPoint = MKMapPointMake(pointX, pointY);
    MKMapPoint centerPoint = MKMapPointForCoordinate(self.mapView.centerCoordinate);
    
    return MKMetersBetweenMapPoints(borderPoint, centerPoint);
}

- (void)updateData {
    
    CLLocationCoordinate2D userCoordinate = self.locationManager.location.coordinate;
    
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(userCoordinate, 10 * METERS_PER_MILE, 10 * METERS_PER_MILE);
    [self.mapView setRegion:coordinateRegion animated:YES];
    
    [self getRestaurantListWebOperation:userCoordinate searchRadius:[self distanceFromMapCenter]];
}

@end
