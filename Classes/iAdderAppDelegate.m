//
//  iAdderAppDelegate.m
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright Andy Molloy 2013. All rights reserved.
//

#import "iAdderAppDelegate.h"
#import "AddItUpViewControllerViewController.h"
#import "ThemeMenuViewController.h"
#import "MainView.h"
#import "MFSideMenu.h"

@interface iAdderAppDelegate ()
@property (nonatomic, strong) MFSideMenu* themeMenu;
@property (nonatomic, strong) AddItUpViewControllerViewController* mainViewController;
@end

@implementation iAdderAppDelegate

@synthesize window = _window;

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.mainViewController = [[AddItUpViewControllerViewController alloc] initWithNibName:@"AddItUpViewControllerViewController" bundle:nil];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
	[navigationController setNavigationBarHidden:YES animated:NO];
	
	ThemeMenuViewController* themeViewController = [[ThemeMenuViewController alloc] initWithNibName:@"ThemeMenuViewController" bundle:nil];
	
	self.themeMenu = [MFSideMenu menuWithNavigationController:navigationController
										   sideMenuController:themeViewController];
	
	self.window.rootViewController = navigationController;
	[self.window makeKeyAndVisible];
	
	return YES;
}

-(void)applicationDidBecomeActive:(UIApplication*)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	MainView* mainView = (MainView*)self.mainViewController.view;
	[mainView updateCurrentMode];
}

@end
