//
//  MainView.m
//  iAdder
//
//  Created by Andrew Molloy on 6/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MainView.h"

#ifdef _DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

CGContextRef CreateGrayscaleBitmapContext(CGImageRef inImage)
{
   CGContextRef    context = NULL;
   CGColorSpaceRef colorSpace;
   void *          bitmapData;
   int             bitmapByteCount;
   int             bitmapBytesPerRow;
   
   // Get image width, height. We'll use the entire image.
   size_t pixelsWide = CGImageGetWidth(inImage);
   size_t pixelsHigh = CGImageGetHeight(inImage);
   
   // Declare the number of bytes per row. Each pixel in the bitmap in this
   // example is represented by 4 bytes; 8 bits each of red, green, blue, and
   // alpha.
   bitmapBytesPerRow   = (pixelsWide);
   bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
   
   // Use the generic RGB color space.
   colorSpace = CGColorSpaceCreateDeviceGray();
   if (colorSpace == NULL)
   {
      ALog("Error allocating color space");
      return NULL;
   }
   
   // Allocate memory for image data. This is the destination in memory
   // where any drawing to the bitmap context will be rendered.
   bitmapData = malloc( bitmapByteCount );
   if (bitmapData == NULL) 
   {
      ALog("Memory not allocated!");
      CGColorSpaceRelease( colorSpace );
      return NULL;
   }
   
   context = CGBitmapContextCreate (bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,      // bits per component
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaNone);
   if (context == NULL)
   {
      free (bitmapData);
      ALog("Context not created!");
   }
   
   // Make sure and release colorspace before returning
   CGColorSpaceRelease( colorSpace );
   
   return context;
}

char* GetImagePixelData(CGImageRef inImage)
{
   // Create the bitmap context
   CGContextRef cgctx = CreateGrayscaleBitmapContext(inImage);
   if (cgctx == NULL) 
   { 
      // error creating context
      return NULL;
   }
   
   // Get image width, height. We'll use the entire image.
   size_t w = CGImageGetWidth(inImage);
   size_t h = CGImageGetHeight(inImage);
   CGRect rect = {{0,0},{w,h}}; 
   
   // Draw the image to the bitmap context. Once we draw, the memory 
   // allocated for the context for rendering will then contain the 
   // raw image data in the specified color space.
   CGContextDrawImage(cgctx, rect, inImage); 
   
   // Now we can get a pointer to the image data associated with the bitmap
   // context.
   void *data = CGBitmapContextGetData (cgctx);
   char* outData = malloc( w * h );
   
   if (data != NULL)
   {
      memcpy( outData, data, w * h );
   }
   else
   {
      free( outData );
      outData = NULL;
   }
   
   // When finished, release the context
   CGContextRelease(cgctx); 
   // Free image data memory for the context
   if (data)
   {
      free(data);
   }
   
   return outData;
}

@implementation MainView

@synthesize hundredsDigitView, tensDigitView, onesDigitView, tenthsDigitView, hundredthsDigitView, overlayView;
@synthesize digitZero, digitOne;
@synthesize currencySymbolLabel, decimalSeparatorLabel;
@synthesize buttonDownView;

-(void)updateModeButton
{
   switch ( currentMode )
   {
      case MODE_ADDITION:
         [modeButton setImage:[UIImage imageNamed:@"PlusButton.png"] forState:UIControlStateNormal];
         [modeButton setImage:[UIImage imageNamed:@"PlusButton.png"] forState:UIControlStateHighlighted];
         [overlayView setImage:[UIImage imageNamed:@"AdditionOverlay.png"]];
         break;
         
      case MODE_SUBTRACTION:
         [modeButton setImage:[UIImage imageNamed:@"MinusButton.png"] forState:UIControlStateNormal];
         [modeButton setImage:[UIImage imageNamed:@"MinusButton.png"] forState:UIControlStateHighlighted];
         [overlayView setImage:[UIImage imageNamed:@"SubtractionOverlay.png"]];
         break;
         
      case MODE_ADDITION_AND_SUBTRACTION:
         [modeButton setImage:[UIImage imageNamed:@"PlusAndMinusButton.png"] forState:UIControlStateNormal];
         [modeButton setImage:[UIImage imageNamed:@"PlusAndMinusButton.png"] forState:UIControlStateHighlighted];
         [overlayView setImage:[UIImage imageNamed:@"AdditionAndSubtractionOverlay.png"]];
         break;
         
      default:
         break;
   }
   
   [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)currentMode forKey:@"AdderMode"];
}

-(int)getButtonForX:(NSInteger)x Y:(NSInteger)y
{
   int i = buttonAreasImageSize.width * y + x;
   
   int button = buttonAreasImage[i];
   
   switch ( currentMode )
   {
      case MODE_ADDITION:
         if ( button > 4 )
         {
            button-= 4;
         }
         break;
      case MODE_SUBTRACTION:
         if ( button > 0 && button <= 4 )
         {
            button+= 4;
         }
         break;
      case MODE_ADDITION_AND_SUBTRACTION:
         // do nothing
         break;
      default:
         break;
   }
   
   if ( button < 1 || button > 8 )
   {
      button = -1;
   }
   
   return button;
}

-(void)rollAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
   if ( [finished boolValue] == YES )
   {
      CGFloat newY = numberWheelsStartY;
      UIView* view = (UIView*)context;
      view.center = CGPointMake( view.center.x, newY );    
   }
}

-(void)rollView:(UIView*)view fromDigit:(NSInteger)fromDigit toDigit:(NSInteger)toDigit full:(BOOL)full direction:(int)dir
{
   CGFloat newY;
   
   if ( full )
   {
      newY = numberWheelsStartY - ( toDigit * numberWheelsNumberHeight );
   }
   else
   {
      if ( toDigit != fromDigit )
      {
         float fract = 0.35f;
         newY = numberWheelsStartY - ( fromDigit * numberWheelsNumberHeight ) + dir * ( numberWheelsNumberHeight * fract );
      }
      else
      {
         return; // don't even do anything in this case
      }
   }
   
   [UIView beginAnimations:@"rollNumberWheel" context:view];
   [UIView setAnimationBeginsFromCurrentState:YES];
   [UIView setAnimationDuration:0.1f];
   
   if ( full && ( ( fromDigit == 9 && toDigit == 0 ) || ( fromDigit == 1 && toDigit == 0 ) ) )
   {
      // We were on 9, we need to scroll to the zero that's after it, then switch without animating to
      // the 0 at the top.
      [UIView setAnimationDidStopSelector:@selector(rollAnimationDidStop:finished:context:)];
      [UIView setAnimationDelegate:self];
      
      if ( fromDigit == 9 && toDigit == 0 )
      {
         newY = numberWheelsStartY - ( 10 * numberWheelsNumberHeight );
         CGPoint newCenter = CGPointMake( view.center.x, newY );
         view.center = newCenter;
      }
      else
      {
         newY = numberWheelsStartY - ( 0 * numberWheelsNumberHeight );
         CGPoint newCenter = CGPointMake( view.center.x, newY );
         view.center = newCenter;
      }
   }
   else
   {
      CGPoint newCenter = CGPointMake( view.center.x, newY );
      
      view.center = newCenter;
   }
   
   [UIView commitAnimations];
}

-(void)updateLabelsForValue:(NSInteger)value full:(BOOL)full
{
   NSInteger work = value;
   NSInteger oldWork = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastValue"];
   
   int dir = ( work > oldWork ) ? -1 : 1;
   
   if ( work < 0 )
   {
      work = 100000 + work;
   }
   
   work%= 100000;
   
   NSInteger od = oldWork % 10;
   NSInteger nd = work % 10;
   [self rollView:hundredthsDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:tenthsDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:onesDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:tensDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:hundredsDigitView fromDigit:od toDigit:nd full:full direction:dir];
}

-(void)setupSoundButton
{
   if ( sound ) 
   {
      [soundButton setImage:[UIImage imageNamed:@"SoundOnButton.png"] forState:UIControlStateNormal];
      [soundButton setImage:[UIImage imageNamed:@"SoundOnButton.png"] forState:UIControlStateHighlighted];
   }
   else
   {
      [soundButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateNormal];
      [soundButton setImage:[UIImage imageNamed:@"SoundOff.png"] forState:UIControlStateHighlighted];
   }
}

-(id)initWithCoder:(NSCoder*)encoder
{
   if ( (self = [super initWithCoder:encoder]) ) 
   {
      [[NSUserDefaults standardUserDefaults] registerDefaults:
       [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:0], @"LastValue",
        [NSNumber numberWithBool:YES], @"SoundOn",
        [NSNumber numberWithInteger:(int)MODE_ADDITION], @"AdderMode",
        nil]];
      
      currentMode = (AdderModes)[[NSUserDefaults standardUserDefaults] integerForKey:@"AdderMode"];
      
      // Get the main bundle for the app
      CFBundleRef mainBundle;
      mainBundle = CFBundleGetMainBundle ();
      
      CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                         CFSTR("ClickDown"),
                                                         CFSTR ("aiff"),
                                                         NULL
                                                         );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickDownSound
                                       );
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickUp"),
                                                CFSTR ("aiff"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickUpSound
                                       );
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickCancel"),
                                                CFSTR ("aiff"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickCancelSound
                                       );

      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickUpSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickUpSubtractSound
                                       );
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickDownSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickDownSubtractSound
                                       );
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickCancelSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef,
                                       &clickCancelSubtractSound
                                       );
      
      
      UIImage* buttonAreas = [UIImage imageNamed:@"PortraitViewButtonAreas.png"];
      
      buttonAreasImage = GetImagePixelData( buttonAreas.CGImage );
      buttonAreasImageSize = buttonAreas.size;   
      
      self.multipleTouchEnabled = NO;
      
      [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(setupLabels) userInfo:nil repeats:NO];
      
      ignoringTouches = YES;
   }
   
   return self;
}

-(void)playSound:(SystemSoundID)soundId
{
   if ( sound )
   {
      AudioServicesPlaySystemSound( soundId );
   }
}

-(void)setupLabels
{
   numberWheelsStartY = hundredsDigitView.center.y;
   
   numberWheelsNumberHeight = digitOne.center.y - digitZero.center.y;
   
   currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastValue"];
   sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundOn"];
   [self updateLabelsForValue:currentValue full:YES];
   [self setupSoundButton];
   [self updateModeButton];
   
   NSLocale* locale = [NSLocale autoupdatingCurrentLocale];
   
   NSString* ls = [locale objectForKey:NSLocaleDecimalSeparator];
   [decimalSeparatorLabel setText:ls];
   
   ls =  [locale objectForKey:NSLocaleCurrencySymbol];
   [currencySymbolLabel setText:ls];
   
   currentButtonPressed = -1;
   
   ignoringTouches = NO;

   buttonDownView.hidden = YES;
}

-(IBAction)toggleSound:(UIButton*)button
{
   sound = !sound;
   
   [self setupSoundButton];
   
   [[NSUserDefaults standardUserDefaults] setBool:sound forKey:@"SoundOn"];
}

-(IBAction)toggleMode:(UIButton*)button
{
   if ( currentMode == MODE_ADDITION )
   {
      currentMode = MODE_SUBTRACTION;
   }
   else if ( currentMode == MODE_SUBTRACTION )
   {
      currentMode = MODE_ADDITION_AND_SUBTRACTION;
   }
   else
   {
      currentMode = MODE_ADDITION;
   }
   
   [self updateModeButton];
}

-(IBAction)resetButtonPressed:(UIButton*)button
{
   currentValue = 0;
   [self updateLabelsForValue:currentValue full:YES];
   
   [[NSUserDefaults standardUserDefaults] setInteger:currentValue forKey:@"LastValue"];
}

-(void)dealloc 
{
   free( buttonAreasImage );
   
   AudioServicesDisposeSystemSoundID(clickDownSound);
   AudioServicesDisposeSystemSoundID(clickUpSound);
   AudioServicesDisposeSystemSoundID(clickCancelSound);
   AudioServicesDisposeSystemSoundID(clickDownSubtractSound);
   AudioServicesDisposeSystemSoundID(clickUpSubtractSound);
   AudioServicesDisposeSystemSoundID(clickCancelSubtractSound);
   
   [super dealloc];
}

-(void)ignoreTouchesForTimeInterval:(NSTimeInterval)ti
{
   ignoringTouches = YES;
   [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(stopIgnoringTouches) userInfo:nil repeats:NO];
}

-(void)stopIgnoringTouches
{
   ignoringTouches = NO;
}

-(void)cancelButtonPress
{
   if ( currentButtonPressed > 0 && currentButtonPressed <= 4 )
   {
      [self playSound:clickCancelSound];
   }
   else if ( currentButtonPressed > 4 && currentButtonPressed <= 8 )
   {
      [self playSound:clickCancelSubtractSound];
   }
   
   currentButtonPressed = -1;
   
   [self updateLabelsForValue:currentValue full:YES];
   
   buttonDownView.hidden = YES;
}

-(UIImage*)buttonDownImageForButton:(int)button
{
   NSString* imageName = nil;
   
   if ( currentMode == MODE_ADDITION_AND_SUBTRACTION )
   {
      imageName = [NSString stringWithFormat:@"PButton%dDown.png", button];
   }
   else
   {
      if ( currentMode == MODE_SUBTRACTION )
      {
         button-= 4;
      }

      int but2 = button + 4;
      
      imageName = [NSString stringWithFormat:@"PButton%da%dDown.png", button, but2];
   }
   
   return [UIImage imageNamed:imageName];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
   UITouch* touch = [touches anyObject];
   CGPoint loc = [touch locationInView:self];
   
   int button = [self getButtonForX:loc.x Y:loc.y];
   
   currentButtonPressed = button;
   
   if ( currentButtonPressed != -1 )
   {
      NSInteger newVal;
      
      if ( currentButtonPressed <= 4 )
      {
         newVal = currentValue + pow( 10, currentButtonPressed - 1 );
         [self playSound:clickDownSound];
      }
      else
      {
         newVal = currentValue - pow( 10, currentButtonPressed - 5 );
         [self playSound:clickDownSubtractSound];
      }
      
      [self updateLabelsForValue:newVal full:NO];
      
      [buttonDownView setImage:[self buttonDownImageForButton:currentButtonPressed]];
      buttonDownView.hidden = NO;
   }
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
   UITouch* touch = [touches anyObject];
   CGPoint loc = [touch locationInView:self];
   
   int button = [self getButtonForX:loc.x Y:loc.y];
   
   if ( currentButtonPressed != button )
   {
      [self cancelButtonPress];
   }
}

-(void)touchesCanceled 
{
   [self cancelButtonPress];
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
   UITouch* touch = [touches anyObject];
   CGPoint loc = [touch locationInView:self];
   
   int button = [self getButtonForX:loc.x Y:loc.y];
   
   if ( button == currentButtonPressed && button != -1 )
   {
      if ( currentButtonPressed <= 4 )
      {
         currentValue+= pow( 10, currentButtonPressed - 1 );
         [self playSound:clickUpSound];
      }
      else
      {
         currentValue-= pow( 10, currentButtonPressed - 5 );
         [self playSound:clickUpSubtractSound];
      }
      
      [self updateLabelsForValue:currentValue full:YES];
      
      if ( currentValue < 0 )
      {
         currentValue = 100000 + currentValue;
      }
      
      currentValue%= 100000;
      [[NSUserDefaults standardUserDefaults] setInteger:currentValue forKey:@"LastValue"];
      
      [self ignoreTouchesForTimeInterval:0.11f];
   }
   
   currentButtonPressed = -1;

   buttonDownView.hidden = YES;
}

@end
