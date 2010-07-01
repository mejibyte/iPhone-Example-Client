//
//  SpotsViewController.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SpotsViewController : UITableViewController <CLLocationManagerDelegate> {
	NSArray * spots;
	CLLocationManager * locationManager;
}

@property (nonatomic, retain) NSArray * spots;
@property (nonatomic, retain) CLLocationManager * locationManager;

@end
