//
//  User.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "AFObject.h"


@interface User : AFObject {
	NSString * firstName;
	NSString * lastName;
	NSString * hometown;
	NSURL * imageURL;
	
	NSArray * checkIns;
}

@property (readonly) NSString * name;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * hometown;
@property (nonatomic, retain) NSURL * imageURL;

@property (nonatomic, retain) NSArray * checkIns;

@end
