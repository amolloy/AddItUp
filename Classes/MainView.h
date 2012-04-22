//
//  MainView.h
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

typedef enum {
   MODE_ADDITION,
   MODE_SUBTRACTION,
   MODE_ADDITION_AND_SUBTRACTION
} AdderModes;

@interface MainView : UIView {
}

-(IBAction)resetButtonPressed:(UIButton*)button;
-(void)updateCurrentMode;

@end
