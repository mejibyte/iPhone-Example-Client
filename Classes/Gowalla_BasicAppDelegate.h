//
//  Gowalla_BasicAppDelegate.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright Mattt Thompson 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AuthenticationViewController;

@interface Gowalla_BasicAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow * window;
    UINavigationController * navigationController;
	AuthenticationViewController * authenticationViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UINavigationController * navigationController;
@property (nonatomic, retain) AuthenticationViewController * authenticationViewController;

@end

