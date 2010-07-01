//
//  CheckIn.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "CheckIn.h"
#import "User.h"
#import "Spot.h"

#import "ISO8601DateFormatter.h"

static ISO8601DateFormatter * _ISO8601DateFormatter;

@implementation CheckIn

@synthesize user;
@synthesize spot;
@synthesize timestamp;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super initWithDictionary:dictionary]) {
		self.user = [[User alloc] initWithDictionary:[dictionary valueForKey:@"user"]];
		self.spot = [[Spot alloc] initWithDictionary:[dictionary valueForKey:@"spot"]];
		
		if (_ISO8601DateFormatter == nil) {
			_ISO8601DateFormatter = [[ISO8601DateFormatter alloc] init];
		}
		
		self.timestamp = [_ISO8601DateFormatter dateFromString:[dictionary valueForKey:@"created_at"]]; 
	}
	
	return self;
}

- (void)dealloc {
	[user release];
	[spot release];
	[timestamp release];
	[super dealloc];
}

@end
