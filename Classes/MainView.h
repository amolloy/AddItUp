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
   UIView*              hundredsDigitView;
   UIView*              tensDigitView;
   UIView*              onesDigitView;
   UIView*              tenthsDigitView;
   UIView*              hundredthsDigitView;
   UIImageView*         overlayView;
   UIImageView*         buttonDownView;
   
   UILabel*             currencySymbolLabel;
   UILabel*             decimalSeparatorLabel;
   
   NSInteger            currentValue;
   
   BOOL                 sound;
   
   IBOutlet UIButton*   soundButton;
   IBOutlet UIButton*   modeButton;
   
   SystemSoundID        clickDownSound;
   SystemSoundID        clickUpSound;
   SystemSoundID        clickCancelSound;
   
   SystemSoundID        clickDownSubtractSound;
   SystemSoundID        clickUpSubtractSound;
   SystemSoundID        clickCancelSubtractSound;
   
   char*                buttonAreasImage;
   CGSize               buttonAreasImageSize;
   
   int                  currentButtonPressed;
   
   CGFloat              numberWheelsStartY;
   CGFloat              numberWheelsNumberHeight;
   
   UIView*              digitZero;
   UIView*              digitOne; // These are used to measure the distance between our numbers
   
   BOOL                 ignoringTouches;
   
   AdderModes           currentMode;
}

-(IBAction)resetButtonPressed:(UIButton*)button;
-(IBAction)toggleSound:(UIButton*)button;
-(IBAction)toggleMode:(UIButton*)button;

@property (nonatomic, retain) IBOutlet UIView* hundredsDigitView;
@property (nonatomic, retain) IBOutlet UIView* tensDigitView;
@property (nonatomic, retain) IBOutlet UIView* onesDigitView;
@property (nonatomic, retain) IBOutlet UIView* tenthsDigitView;
@property (nonatomic, retain) IBOutlet UIView* hundredthsDigitView;
@property (nonatomic, retain) IBOutlet UIImageView* overlayView;
@property (nonatomic, retain) IBOutlet UIImageView* buttonDownView;

@property (nonatomic, retain) IBOutlet UIView* digitZero;
@property (nonatomic, retain) IBOutlet UIView* digitOne;

@property (nonatomic, retain) IBOutlet UILabel* currencySymbolLabel;
@property (nonatomic, retain) IBOutlet UILabel* decimalSeparatorLabel;

@end
