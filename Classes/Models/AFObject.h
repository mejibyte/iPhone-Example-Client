//
//  AFObject.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AFObject : NSObject {
	NSURL * url;
}

@property (nonatomic, retain) NSURL * url;
@property (readonly) NSString * identifier;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
