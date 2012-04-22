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

@interface iAdderAppDelegate ()
@property (nonatomic, strong) AddItUpViewControllerViewController* viewController;
@end

@implementation iAdderAppDelegate

@synthesize viewController = _viewController;
@synthesize window = _window;

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   // Override point for customization after application launch.
   self.viewController = [[AddItUpViewControllerViewController alloc] initWithNibName:@"AddItUpViewControllerViewController" bundle:nil];
   self.window.rootViewController = self.viewController;
   [self.window makeKeyAndVisible];
   return YES;
}

-(void)applicationDidBecomeActive:(UIApplication*)application
{
   MainView* mainView = (MainView*)self.viewController.view;
   [mainView updateCurrentMode];
}

@end
