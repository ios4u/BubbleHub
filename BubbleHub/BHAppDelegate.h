//
//  BHAppDelegate.h
//  BubbleHub
//
//  Created by Pietro Rea on 12/3/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BHAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
