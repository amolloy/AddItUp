//
//  iAdderAppDelegate.m
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iAdderAppDelegate.h"
#import "MainViewController.h"

@implementation iAdderAppDelegate

@synthesize window;
@synthesize mainViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}



@end
