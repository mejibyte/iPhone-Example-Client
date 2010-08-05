//
//  SpotViewController.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "SpotViewController.h"
#import "CheckInSuccessViewController.h"
#import "PassportViewController.h"

#import "Spot.h"
#import "User.h"
#import "CheckIn.h"

#import "EGOHTTPRequest.h"
#import "EGOHTTPFormRequest.h"

#import "AFImageLoadingCell.h"

#import "CLLocationManager+AFExtensions.h"
#import "NSData+Base64.h"
#import "GowallaAPI.h"

@interface SpotViewController () 
- (void)updateContent;
- (void)handleCheckInState;
@end

static NSDateFormatter * _dateFormatter;

static EGOHTTPRequest * spotRequest;
static EGOHTTPFormRequest * checkInRequest;

@implementation SpotViewController

@synthesize spot;
@synthesize checkIns;
@synthesize locationManager;

- (id)initWithSpot:(Spot *)someSpot {
	if (self = [super initWithNibName:@"SpotView" bundle:nil]) {
		self.spot = someSpot;
		
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		self.locationManager.distanceFilter = 80.0;
	}
	
	return self;
}

- (void)dealloc {
	self.locationManager.delegate = nil;
	
	[spot release];
	[locationManager release];
	[super dealloc];
}

- (void)handleCheckInState {
	if ([Spot canCheckInAtSpot:self.spot fromLocation:self.locationManager.location]) {
		[checkInButton setTitle:NSLocalizedString(@"Check In", nil) 
					   forState:UIControlStateNormal];
		checkInButton.enabled = YES;
	} else {
		[checkInButton setTitle:[self.locationManager distanceAndDirectionTo:self.spot.location] 
					   forState:UIControlStateDisabled];
		checkInButton.enabled = NO;
	}
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = self.spot.name;
	
	self.tableView.rowHeight = 60.0f;
	
	mapView.layer.cornerRadius = 8.0f;
	mapView.layer.borderWidth = 1.0f;
	mapView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	
	[self updateContent];
	
	spotRequest = [GowallaAPI requestForPath:[self.spot.url path] 
								  parameters:nil 
									delegate:self 
									selector:@selector(requestDidFinish:)];
	
	[spotRequest startAsynchronous];
	
	[self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	nameLabel = nil;
	imageView = nil;
	mapView = nil;
	[self.locationManager stopUpdatingLocation];
}

- (void)updateContent {
	nameLabel.text = self.spot.name;
	[imageView setImageURL:self.spot.imageURL];
	
	checkInButton.titleLabel.numberOfLines = 2;
	checkInButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	
	[mapView addAnnotation:self.spot];
	[mapView setRegion:MKCoordinateRegionMakeWithDistance(self.spot.coordinate, 1000, 1000) animated:YES];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)checkIn:(id)sender {
	[checkInButton setEnabled:NO];
	
	CLLocation * currentLocation = self.locationManager.location;
	CLLocationAccuracy accuracy = currentLocation.horizontalAccuracy;
	CLLocationDegrees latitude = currentLocation.coordinate.latitude;
	CLLocationDegrees longitude = currentLocation.coordinate.longitude;

	NSString * URLString = [@"https://api.gowalla.com/checkins.json" stringByAppendingFormat:@"?oauth_token=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kGowallaBasicOAuthAccessTokenPreferenceKey]];
	
	checkInRequest = [[EGOHTTPFormRequest alloc] initWithURL:[NSURL URLWithString:URLString]
													delegate:self];
	[checkInRequest setDidFailSelector:@selector(requestDidFinish:)];
	
	[checkInRequest setPostValue:self.spot.identifier 
						  forKey:@"spot_id"];
	[checkInRequest setPostValue:[[NSNumber numberWithDouble:latitude] stringValue]
						  forKey:@"lat"];
	[checkInRequest setPostValue:[[NSNumber numberWithDouble:longitude] stringValue]
						  forKey:@"lng"];
	[checkInRequest setPostValue:[[NSNumber numberWithDouble:accuracy] stringValue]
						  forKey:@"accuracy"];
	
	
	[checkInRequest startSynchronous];
}

#pragma mark -
#pragma mark EGOHTTPRequest

- (void)requestDidFinish:(EGOHTTPRequest *)request {	
	NSLog(@"requestDidFinish: %@", request.responseString);
	NSDictionary * response = [NSDictionary dictionaryWithJSONData:request.responseData 
															 error:nil];
	
	if (request.responseStatusCode == 200) {
		if ([request isEqual:spotRequest]) {
			self.spot = [[Spot alloc] initWithDictionary:response];
			self.checkIns = self.spot.checkIns;
			
			[self.tableView reloadData];			
		} else if ([request isEqual:checkInRequest]) {
			CheckIn * checkIn = [[[CheckIn alloc] initWithDictionary:response] autorelease];
			NSString * html = [response valueForKey:@"detail_html"];
			
			CheckInSuccessViewController * viewController = [[[CheckInSuccessViewController alloc] initWithCheckIn:checkIn 
																										detailHTML:html] autorelease];
			UINavigationController * modalNavigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
			
			[self.navigationController presentModalViewController:modalNavigationController animated:YES];
		}
	} else {
		[[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
									 message:request.responseString
									delegate:nil 
						   cancelButtonTitle:NSLocalizedString(@"OK", nil) 
						   otherButtonTitles:nil] autorelease] show];
	}
	
	[self handleCheckInState];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation 
{
	NSLog(@"locationManager:didUpdateToLocation:fromLocation:");
	[self handleCheckInState];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.checkIns count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([self.checkIns count] > 0) {
		return NSLocalizedString(@"Recent Check-Ins", nil);
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"Cell";
    
    AFImageLoadingCell * cell = (AFImageLoadingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[AFImageLoadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
										  reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (_dateFormatter == nil) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDoesRelativeDateFormatting:YES];
		[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[_dateFormatter setLocale:[NSLocale currentLocale]];
	}
	
	CheckIn * checkIn = [self.checkIns objectAtIndex:indexPath.row];
	
	[cell setImageURL:checkIn.user.imageURL];
	cell.textLabel.text = checkIn.user.name;
	cell.detailTextLabel.text = [_dateFormatter stringFromDate:checkIn.timestamp];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckIn * checkIn = [self.checkIns objectAtIndex:indexPath.row];
	PassportViewController * viewController = [[[PassportViewController alloc] initWithGowallaUser:checkIn.user] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
