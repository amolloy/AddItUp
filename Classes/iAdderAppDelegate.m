//
//  iAdderAppDelegate.m
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iAdderAppDelegate.h"
#import "AddItUpViewControllerViewController.h"
#import "MainView.h"
#import "TestFlight.h"

@interface iAdderAppDelegate ()
@property (nonatomic, strong) AddItUpViewControllerViewController* viewController;
@end

@implementation iAdderAppDelegate

@synthesize viewController = _viewController;
@synthesize window = _window;

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   [TestFlight takeOff:@"a65c700e4d0ed6cb4c72b5e44cfe2a66_ODMzNzIyMDEyLTA0LTIyIDA5OjA2OjA1LjY4MDIxMA"];
   
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   // Override point for customization after application launch.
   self.viewController = [[AddItUpViewControllerViewController alloc] initWithNibName:@"AddItUpViewControllerViewController" bundle:nil];
   self.window.rootViewController = self.viewController;
   [self.window makeKeyAndVisible];
   return YES;
}

-(void)applicationDidBecomeActive:(UIApplication*)application
{
   [[NSUserDefaults standardUserDefaults] synchronize];
   MainView* mainView = (MainView*)self.viewController.view;
   [mainView updateCurrentMode];
}

@end
