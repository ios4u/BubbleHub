//
//  TPGetRestaurantListWebOperation.h
//  iPeru
//
//  Created by Pietro Rea on 8/26/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHBaseWebServiceOperation.h"

@interface BHGetVenueListWebOperation : BHBaseWebServiceOperation

@property (strong, nonatomic) NSNumber* latitude;         //Required if geocodableString is not provided
@property (strong, nonatomic) NSNumber* longitude;        //Required if geocodableString is not provided

@property (strong, nonatomic) NSString* geocodableString; //Required if latitude & longitude not provided

@property (strong, nonatomic) NSString* clientID;
@property (strong, nonatomic) NSString* clientSecret;
@property (strong, nonatomic) NSString* categoryID;
@property (strong, nonatomic) NSNumber* radius;           // Radius of search in meters (optional)

@end
