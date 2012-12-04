//
//  TPRestaurant.m
//  iPeru
//
//  Created by Pietro Rea on 8/27/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHVenue.h"
#import <CoreLocation/CoreLocation.h>

#define kRestaurantIDKey @"ID"
#define kRestaurantNameKey @"Name"
#define kRestaurantPhoneKey @"Phone"
#define kRestaurantAddressKey @"Address"
#define kRestaurantCrossStreetKey @"CrossStreet"
#define kRestaurantPostalCodeKey @"PostalCode"
#define kRestaurantCityKey @"City"
#define kRestaurantStateKey @"State"
#define kRestaurantCountryKey @"Country"
#define kRestaurantLatitudeKey @"Latitude"
#define kRestaurantLongitudeKey @"Longitude"
#define kRestaurantDistanceKey @"Distance"

@implementation BHVenue

#pragma mark - MKAnnotation protocol methods

- (NSString*)title {
    return self.name;
}

- (NSString*)subtitle {
    return self.address;
}

- (CLLocationCoordinate2D)coordinate {

    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    return location;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        self.ID = [aDecoder decodeObjectForKey:kRestaurantIDKey];
        self.name = [aDecoder decodeObjectForKey:kRestaurantNameKey];
        self.phone = [aDecoder decodeObjectForKey:kRestaurantPhoneKey];
        self.address = [aDecoder decodeObjectForKey:kRestaurantAddressKey];
        self.crossStreet = [aDecoder decodeObjectForKey:kRestaurantCrossStreetKey];
        self.postalCode = [aDecoder decodeObjectForKey:kRestaurantPostalCodeKey];
        self.city = [aDecoder decodeObjectForKey:kRestaurantCityKey];
        self.state = [aDecoder decodeObjectForKey:kRestaurantStateKey];
        self.country = [aDecoder decodeObjectForKey:kRestaurantCountryKey];
        self.latitude = [aDecoder decodeObjectForKey:kRestaurantLatitudeKey];
        self.longitude = [aDecoder decodeObjectForKey:kRestaurantLongitudeKey];
        self.distance = [aDecoder decodeObjectForKey:kRestaurantDistanceKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:kRestaurantIDKey];
    [aCoder encodeObject:self.name forKey:kRestaurantNameKey];
    [aCoder encodeObject:self.phone forKey:kRestaurantPhoneKey];
    [aCoder encodeObject:self.address forKey:kRestaurantAddressKey];
    [aCoder encodeObject:self.crossStreet forKey:kRestaurantCrossStreetKey];
    [aCoder encodeObject:self.postalCode forKey:kRestaurantPostalCodeKey];
    [aCoder encodeObject:self.city forKey:kRestaurantCityKey];
    [aCoder encodeObject:self.state forKey:kRestaurantStateKey];
    [aCoder encodeObject:self.country forKey:kRestaurantCountryKey];
    [aCoder encodeObject:self.latitude forKey:kRestaurantLatitudeKey];
    [aCoder encodeObject:self.longitude forKey:kRestaurantLongitudeKey];
    [aCoder encodeObject:self.distance forKey:kRestaurantDistanceKey];
}

@end
