//
//  SpotsViewController.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "SpotsViewController.h"
#import "SpotViewController.h"

#import "Spot.h"

#import "GowallaAPI.h"

#import "AFImageLoadingCell.h"

#import "CLLocationManager+AFExtensions.h"


@implementation SpotsViewController

@synthesize spots;
@synthesize locationManager;

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.spots = [NSArray array];
		
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		self.locationManager.distanceFilter = 80.0;
	}
	
	return self;
}

- (void)dealloc {
	self.locationManager.delegate = nil;

	[spots release];
	[locationManager release];
    [super dealloc];
}


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Spots", nil);
	
	self.tableView.rowHeight = 60.0f;	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[EGOHTTPRequest cancelRequestsForDelegate:self];
	[self.locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark EGOHTTPRequest

- (void)requestDidFinish:(EGOHTTPRequest *)request {
	NSLog(@"requestDidFinish:");
	
	if (request.responseStatusCode == 200) {
		NSDictionary * response = [NSDictionary dictionaryWithJSONData:request.responseData 
																   error:nil];
		NSMutableSet * someSpots = [NSMutableSet set];
		for (NSDictionary * dictionary in [response valueForKey:@"spots"]) {
			Spot * spot = [[Spot alloc] initWithDictionary:dictionary];
			[someSpots addObject:spot];
			[spot release];
		}
		
		self.spots = [[someSpots allObjects] sortedArrayUsingComparator:^(id a, id b) {
			CLLocation * currentLocation = self.locationManager.location;
			CLLocationDistance distanceToA = [currentLocation distanceFromLocation:[a location]];
			CLLocationDistance distanceToB = [currentLocation distanceFromLocation:[b location]];
			if (distanceToA < distanceToB) {
				return NSOrderedAscending;
			} else if (distanceToA > distanceToB) {
				return NSOrderedDescending;
			} else {
				return NSOrderedSame;
			}
		}];
		
		[self.tableView reloadData];
	} else {
		NSLog(@"requestDidFail: %@", request.error);
	}
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation 
{
	NSLog(@"locationManager:didUpdateToLocation:fromLocation:");
	
	CLLocationDegrees latitude = newLocation.coordinate.latitude;
	CLLocationDegrees longitude = newLocation.coordinate.longitude;
	
	NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
	[parameters setValue:[NSString stringWithFormat:@"%+.9f", latitude] 
				  forKey:@"lat"];
	[parameters setValue:[NSString stringWithFormat:@"%+.9f", longitude] 
				  forKey:@"lng"];
	
	[[GowallaAPI requestForPath:@"spots" 
					 parameters:parameters 
					   delegate:self 
					   selector:@selector(requestDidFinish:)] startAsynchronous];
}

#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.spots count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"Cell";
    
    AFImageLoadingCell * cell = (AFImageLoadingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[AFImageLoadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
										  reuseIdentifier:CellIdentifier] autorelease];
    }
	
	Spot * spot = [self.spots objectAtIndex:indexPath.row];
	
	[cell setImageURL:spot.imageURL];
	cell.textLabel.text = spot.name;
	cell.detailTextLabel.text = [self.locationManager distanceAndDirectionTo:spot.location];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SpotViewController * viewController = [[[SpotViewController alloc] initWithSpot:[self.spots objectAtIndex:indexPath.row]] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end

