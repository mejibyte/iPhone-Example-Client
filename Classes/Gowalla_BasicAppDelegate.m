//
//  Gowalla_BasicAppDelegate.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright Mattt Thompson 2010. All rights reserved.
//

#import "Gowalla_BasicAppDelegate.h"

#import "AuthenticationViewController.h"

#import "EGOHTTPFormRequest.h"
#import "URLParser.h"

@implementation Gowalla_BasicAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize authenticationViewController;

#pragma mark -
#pragma mark Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	NSString * OAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:kGowallaBasicOAuthAccessTokenPreferenceKey];
	NSDate * OAuthTokenExpirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kGowallaBasicOAuthTokenExpirationPreferenceKey];
	if (OAuthToken == nil || [OAuthTokenExpirationDate compare:[NSDate date]] == NSOrderedAscending) {
		authenticationViewController = [[[AuthenticationViewController alloc] initWithNibName:@"AuthenticationView" bundle:nil] autorelease];
		[navigationController presentModalViewController:authenticationViewController 
												animated:YES];	
	}
	
    return YES;
}

#pragma mark -
#pragma mark OAuth

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {	
	NSLog(@"application:handleOpenURL: %@", url);
	URLParser * parser = [[[URLParser alloc] initWithURLString:[url absoluteString]] autorelease];
	NSString * code = [parser valueForVariable:@"code"];
	
	NSURL * OAuthTokenURL = [NSURL URLWithString:@"https://api.gowalla.com/api/oauth/token"];
	EGOHTTPFormRequest * request = [[[EGOHTTPFormRequest alloc] initWithURL:OAuthTokenURL delegate:self] autorelease];
	[request setPostValue:@"authorization_code" 
				   forKey:@"grant_type"];
	[request setPostValue:kGowallaAPIKey
				   forKey:@"client_id"];
	[request setPostValue:kGowallaAPISecret
				   forKey:@"client_secret"];
	[request setPostValue:code 
				   forKey:@"code"];
	[request setPostValue:kGowallaRedirectURI
				   forKey:@"redirect_uri"];
	[request setPostValue:@"read-write" 
				   forKey:@"scope"];
	
	[request setDidFinishSelector:@selector(applicationDidAuthorizeWithRequest:)];
	[request startSynchronous];
	
	return YES;
}
 
- (void)applicationDidAuthorizeWithRequest:(EGOHTTPFormRequest *)request {
	NSLog(@"applicationDidAuthorizeWithRequest: %@", request.responseString);
	NSDictionary * response = [NSDictionary dictionaryWithJSONData:[request responseData] error:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[response valueForKey:@"access_token"] 
											  forKey:kGowallaBasicOAuthAccessTokenPreferenceKey];
	[[NSUserDefaults standardUserDefaults] setObject:[response valueForKey:@"refresh_token"] 
											  forKey:kGowallaBasicOAuthRefreshTokenPreferenceKey];
	
	NSDate * expirationDate = [NSDate dateWithTimeIntervalSinceNow:[[response valueForKey:@"expires_in"] doubleValue]];
	[[NSUserDefaults standardUserDefaults] setObject:expirationDate 
											  forKey:kGowallaBasicOAuthTokenExpirationPreferenceKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Refresh access token if it is expired
	if ([expirationDate compare:[NSDate date]] == NSOrderedAscending) {
		NSURL * OAuthTokenURL = [NSURL URLWithString:@"https://api.gowalla.com/api/oauth/token"];
		EGOHTTPFormRequest * request = [[[EGOHTTPFormRequest alloc] initWithURL:OAuthTokenURL delegate:self] autorelease];
		[request setPostValue:@"refresh_token" 
					   forKey:@"grant_type"];
		[request setPostValue:kGowallaAPIKey
					   forKey:@"client_id"];
		[request setPostValue:kGowallaAPISecret
					   forKey:@"client_secret"];
		[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:kGowallaBasicOAuthRefreshTokenPreferenceKey]
					   forKey:@"refresh_token"];
		[request setPostValue:kGowallaRedirectURI
					   forKey:@"redirect_uri"];
		
		[request setDidFinishSelector:@selector(applicationDidAuthorizeWithRequest:)];
		[request startSynchronous];
	} else {
		[authenticationViewController dismissModalViewControllerAnimated:YES];
	}	
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

}

- (void)dealloc {
	[navigationController release];
	[window release];
	[authenticationViewController release];
	[super dealloc];
}

@end

