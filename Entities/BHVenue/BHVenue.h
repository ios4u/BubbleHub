//
//  TPRestaurant.h
//  iPeru
//
//  Created by Pietro Rea on 8/27/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BHVenue : NSObject <MKAnnotation, NSCoding>

@property (strong, nonatomic) NSString* ID;
@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* crossStreet;
@property (strong, nonatomic) NSString* postalCode;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* state;
@property (strong, nonatomic) NSString* country;

@property (strong, nonatomic) NSNumber* latitude;
@property (strong, nonatomic) NSNumber* longitude;
@property (strong, nonatomic) NSNumber* distance; //measured in meters

#pragma mark - MKAnnotation protocol

@property (nonatomic, readonly, copy) NSString* subtitle;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
