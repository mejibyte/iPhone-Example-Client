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
@end

static NSDateFormatter * _dateFormatter;

static EGOHTTPRequest * spotRequest;
static EGOHTTPFormRequest * checkInRequest;

@implementation SpotViewController

@synthesize spot;
@synthesize checkIns;

- (id)initWithSpot:(Spot *)someSpot {
	if (self = [super initWithNibName:@"SpotView" bundle:nil]) {
		self.spot = someSpot;
	}
	
	return self;
}

- (void)dealloc {	
	[spot release];
	[super dealloc];
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
}

- (void)viewDidUnload {
	[super viewDidUnload];
	nameLabel = nil;
	imageView = nil;
	mapView = nil;
}

- (void)updateContent {
	nameLabel.text = self.spot.name;
	[imageView setImageURL:self.spot.imageURL];
	
	[mapView addAnnotation:self.spot];
	[mapView setRegion:MKCoordinateRegionMakeWithDistance(self.spot.coordinate, 1000, 1000) animated:YES];
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
			CheckIn * checkIn = [[CheckIn alloc] initWithDictionary:response];
			NSString * html = [response valueForKey:@"detail_html"];
			
			CheckInSuccessViewController * viewController = [[[CheckInSuccessViewController alloc] initWithCheckIn:checkIn 
																										detailHTML:html] autorelease];
			UINavigationController * modalNavigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
			
			[self.navigationController presentModalViewController:modalNavigationController animated:YES];
		}
	} else {
		[[[[UIAlertView alloc] initWithTitle:[response valueForKey:@"title"] 
									 message:[response valueForKey:@"message"] 
									delegate:nil 
						   cancelButtonTitle:NSLocalizedString(@"OK", nil) 
						   otherButtonTitles:nil] autorelease] show];
	}	
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

