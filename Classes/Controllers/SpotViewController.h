//
//  SpotViewController.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@class Spot;
@class EGOImageView;

@interface SpotViewController : UITableViewController <CLLocationManagerDelegate> {
	Spot * spot;
	NSArray * checkIns;
		
	IBOutlet UILabel * nameLabel;
	IBOutlet EGOImageView * imageView;
	IBOutlet MKMapView * mapView;
}

@property (nonatomic, retain) Spot * spot;
@property (nonatomic, retain) NSArray * checkIns;

- (id)initWithSpot:(Spot *)someSpot;

@end
