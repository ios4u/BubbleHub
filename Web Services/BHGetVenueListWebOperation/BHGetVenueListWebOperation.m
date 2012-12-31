//
//  TPGetRestaurantListWebOperation.m
//  iPeru
//
//  Created by Pietro Rea on 8/26/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHGetVenueListWebOperation.h"
#import "BHGetVenueListResult.h"
#import "AFNetworking.h"
#import "BHSettings.h"
#import "NSObject+Extensions.h"

@interface BHGetVenueListWebOperation ()

@property (strong, nonatomic) AFJSONRequestOperation* httpOperation;

@end

@implementation BHGetVenueListWebOperation 

- (void)performOperation {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString* baseString = @"https://api.foursquare.com/v2/venues/explore?";
    NSString* queryString = [@"bubble tea" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* urlString;
    
    if (self.latitude && self.latitude) {
        urlString = [baseString stringByAppendingFormat:@"ll=%f,%f&client_id=%@&client_secret=%@&query=%@&v=%@", [self.latitude doubleValue], [self.longitude doubleValue], self.clientID, self.clientSecret, queryString, dateString];
    }
    else if (self.geocodableString) {
        urlString = [baseString stringByAppendingFormat:@"near=%@&client_id=%@&client_secret=%@&query=%@&v=%@", self.geocodableString, self.clientID, self.clientSecret, queryString, dateString];
    }
    
    if (self.radius) {
        urlString = [urlString stringByAppendingFormat:@"&radius=%d", [self.radius intValue]];
    }
    
    debugLog(urlString);
    
    __weak BHGetVenueListWebOperation* webOperation = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    self.httpOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [webOperation parseJson:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [webOperation performFailure];
    }];
    [self.httpOperation start];
}

- (void)parseJson:(NSDictionary*)jsonDict {
    
    NSDictionary* responseDictionary = [jsonDict[@"response"] valueOrNil];
    NSArray* groupsArray = [responseDictionary[@"groups"] valueOrNil];
    NSDictionary* groupDictionary = [[groupsArray lastObject] valueOrNil];
    NSArray* itemsArray = [groupDictionary[@"items"] valueOrNil];
    
    
    BHGetVenueListResult* result = [[BHGetVenueListResult alloc] init];
    result.restaurantArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* itemDictionary in itemsArray) {
        
        NSDictionary* venueDictionary = [itemDictionary[@"venue"] valueOrNil];
        
        BHVenue* venue = [[BHVenue alloc] init];
        venue.name = [venueDictionary[@"name"] valueOrNil];
        venue.ID = [venueDictionary[@"id"] valueOrNil];
        
        NSDictionary* contactDictionary = [venueDictionary[@"contact"] valueOrNil];
        venue.phone = [contactDictionary[@"formattedPhone"] valueOrNil];
        
        NSDictionary* locationDictionary = [venueDictionary[@"location"] valueOrNil];
        venue.address = [locationDictionary[@"address"] valueOrNil];
        venue.crossStreet = [locationDictionary[@"crossStreet"] valueOrNil];
        venue.longitude = [locationDictionary[@"lng"] valueOrNil];
        venue.latitude = [locationDictionary[@"lat"] valueOrNil];
        venue.distance = [locationDictionary[@"distance"] valueOrNil];
        venue.city = [locationDictionary[@"city"] valueOrNil];
        venue.postalCode = [locationDictionary[@"postalCode"] valueOrNil];
        venue.state = [locationDictionary[@"state"] valueOrNil];
        venue.country = [locationDictionary[@"country"] valueOrNil];
        
        //Only include restaurants that have at least a street address
        
        if (venue.address) {
            [result.restaurantArray addObject:venue];
        }
    }
    
    self.result = result;
    [self performSuccess];
}

- (void)cancel {
    [self.httpOperation cancel];
    [super cancel];
}

@end
