//
//  BHSettings.h
//  BubbleHub
//
//  Created by Pietro Rea on 12/4/2012.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BHDistanceUnitMiles,
    BHDistanceUnitKilometers
} BHDistanceUnit;

@interface BHSettings : NSObject

@property (readonly, nonatomic) NSString* clientID;
@property (readonly, nonatomic) NSString* clientSecret;
@property (assign, nonatomic) BHDistanceUnit distanceUnit;

+ (id)settings;

@end
