//
//  AFObject.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "AFObject.h"

@implementation AFObject

@synthesize url;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.url = [NSURL URLWithString:[dictionary valueForKey:@"url"] 
						  relativeToURL:[NSURL URLWithString:@"http://api.gowalla.com"]];
	}
					
	return self;
}

- (void)dealloc {
	[url release];
	[super dealloc];
}

- (NSString *)identifier {
	return [self.url lastPathComponent];
}

- (NSUInteger)hash {
	return [self.url hash];
}

- (BOOL)isEqual:(id)object {
	return [self isKindOfClass:[object class]] && [self hash] == [object hash];
}

@end
