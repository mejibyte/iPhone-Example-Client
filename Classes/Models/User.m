//
//  User.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "User.h"
#import "CheckIn.h"

@implementation User

@dynamic name;
@synthesize firstName;
@synthesize lastName;
@synthesize hometown;
@synthesize imageURL;
@synthesize checkIns;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super initWithDictionary:dictionary]) {
		self.firstName = [dictionary valueForKey:@"first_name"];
		self.lastName = [dictionary valueForKey:@"last_name"];
		self.hometown = [dictionary valueForKey:@"hometown"];
		self.imageURL = [NSURL URLWithString:[dictionary valueForKey:@"image_url"]];
		
		NSMutableArray * recentCheckIns = [NSMutableArray array];
		for (NSDictionary * checkInDictionary in [dictionary valueForKey:@"last_checkins"]) {
			CheckIn * checkIn = [[CheckIn alloc] initWithDictionary:checkInDictionary];
			checkIn.user = self;
			[recentCheckIns addObject:checkIn];
			[checkIn release];
		}
		
		self.checkIns = [NSArray arrayWithArray:recentCheckIns];
	}
	
	return self;
}

- (void)dealloc {
	[firstName release];
	[lastName release];
	[hometown release];
	[imageURL release];
	[checkIns release];
	[super dealloc];
}

- (NSString *)name {
	return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
