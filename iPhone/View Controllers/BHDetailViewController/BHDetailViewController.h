//
//  TPDetailViewController.h
//  iPeru
//
//  Created by Pietro Rea on 10/29/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHBaseViewController.h"
#import "BHVenue.h"

@interface BHDetailViewController : BHBaseViewController <MKMapViewDelegate>

@property (strong, nonatomic) BHVenue* restaurant;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantTitle;
@property (strong, nonatomic) IBOutlet UILabel *restaurantPhone;
@property (strong, nonatomic) IBOutlet UILabel *restaurantDistance;
@property (strong, nonatomic) IBOutlet UILabel *restaurantAddress1;
@property (strong, nonatomic) IBOutlet UILabel *restaurantAddress2;
@property (strong, nonatomic) IBOutlet UIButton *addToFavoritesButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UIView *phoneNumberView;

- (void)populateData; //call after passing in restaurant object

- (IBAction)addToFavoritesButtonTapped:(id)sender;


@end
