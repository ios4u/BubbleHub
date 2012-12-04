//
//  TPNearbyViewController.h
//  iPeru
//
//  Created by Pietro Rea on 8/25/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHBaseViewController.h"
#import <MapKit/MapKit.h>

@interface BHNearbyViewController : BHBaseViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

- (void)updateData;              //Called by TPMainViewController

@end
