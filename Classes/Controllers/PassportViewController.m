//
//  PassportViewController.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/07/01.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "PassportViewController.h"
#import "SpotViewController.h"

#import "User.h"
#import "CheckIn.h"
#import "Spot.h"

#import "EGOHTTPRequest.h"

#import "AFImageLoadingCell.h"
#import "EGOImageView.h"

#import "GowallaAPI.h"

@interface PassportViewController ()
- (void)updateContent;
@end

static NSDateFormatter * _dateFormatter;

@implementation PassportViewController

@synthesize user;
@synthesize checkIns;

- (id)initWithGowallaUser:(User *)someUser {
	if (self = [super initWithNibName:@"PassportView" bundle:nil]) {
		self.user = someUser;
	}
	
	return self;
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.user.name;
	
	self.tableView.rowHeight = 60.0f;
	
	[self updateContent];
	
	[[GowallaAPI requestForPath:[self.user.url path]
					 parameters:nil 
					   delegate:self 
					   selector:@selector(userRequestDidFinish:)] startAsynchronous];
	
	[[GowallaAPI requestForPath:[[self.user.url path] stringByAppendingPathComponent:@"events"]
					 parameters:nil 
					   delegate:self 
					   selector:@selector(checkInsRequestDidFinish:)] startAsynchronous];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	nameLabel = nil;
	hometownLabel = nil;
	imageView = nil;
}

- (void)updateContent {
	nameLabel.text = self.user.name;
	hometownLabel.text = self.user.hometown;
	[imageView setImageURL:self.user.imageURL];
}

#pragma mark -
#pragma mark EGOHTTPRequest

- (void)userRequestDidFinish:(EGOHTTPRequest *)request {	
	NSLog(@"requestDidFinish: %@", request.responseString);
	NSDictionary * response = [NSDictionary dictionaryWithJSONData:request.responseData 
															 error:nil];
	
	if (request.responseStatusCode == 200) {
		self.user = [[User alloc] initWithDictionary:response];
		self.checkIns = self.user.checkIns;
		[self updateContent];
		[self.tableView reloadData];
	}
}

- (void)checkInsRequestDidFinish:(EGOHTTPRequest *)request {	
	NSLog(@"requestDidFinish: %@", request.responseString);
	NSDictionary * response = [NSDictionary dictionaryWithJSONData:request.responseData 
															 error:nil];
	
	if (request.responseStatusCode == 200) {
		NSMutableArray * mutableCheckins = [NSArray array];
		for (NSDictionary * dictionary in [response valueForKey:@"activity"]) {
			CheckIn * checkIn = [[CheckIn alloc] initWithDictionary:dictionary];
			[mutableCheckins addObject:checkIn];
			[checkIn release];
		}
		
		self.checkIns = [NSArray arrayWithArray:mutableCheckins];
		[self.tableView reloadData];
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
	
	[cell setImageURL:checkIn.spot.imageURL];
	cell.textLabel.text = checkIn.spot.name;
	cell.detailTextLabel.text = [_dateFormatter stringFromDate:checkIn.timestamp];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckIn * checkIn = [self.checkIns objectAtIndex:indexPath.row];
	SpotViewController * viewController = [[[SpotViewController alloc] initWithSpot:checkIn.spot] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}


@end

