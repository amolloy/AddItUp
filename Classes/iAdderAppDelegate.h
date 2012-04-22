//
//  iAdderAppDelegate.h
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class MainViewController;

@interface iAdderAppDelegate : NSObject <UIApplicationDelegate> {
   UIWindow *window;
   MainViewController *mainViewController;
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) MainViewController *mainViewController;

@end

