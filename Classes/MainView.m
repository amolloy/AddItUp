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

@interface MainView ()

@property (nonatomic, strong) IBOutlet UIView*             hundredsDigitView;
@property (nonatomic, strong) IBOutlet UIView*             tensDigitView;
@property (nonatomic, strong) IBOutlet UIView*             onesDigitView;
@property (nonatomic, strong) IBOutlet UIView*             tenthsDigitView;
@property (nonatomic, strong) IBOutlet UIView*             hundredthsDigitView;
@property (nonatomic, strong) IBOutlet UIImageView*        overlayView;
@property (nonatomic, strong) IBOutlet UIImageView*        buttonDownView;

@property (nonatomic, strong) IBOutlet UIView*             digitZero;
@property (nonatomic, strong) IBOutlet UIView*             digitOne;

@property (nonatomic, strong) IBOutlet UILabel*            currencySymbolLabel;
@property (nonatomic, strong) IBOutlet UILabel*            decimalSeparatorLabel;

@property (nonatomic, assign) NSInteger            currentValue;

@property (nonatomic, assign) SystemSoundID        clickDownSound;
@property (nonatomic, assign) SystemSoundID        clickUpSound;
@property (nonatomic, assign) SystemSoundID        clickCancelSound;

@property (nonatomic, assign) SystemSoundID        clickDownSubtractSound;
@property (nonatomic, assign) SystemSoundID        clickUpSubtractSound;
@property (nonatomic, assign) SystemSoundID        clickCancelSubtractSound;

@property (nonatomic, assign) char*                buttonAreasImage;
@property (nonatomic, assign) CGSize               buttonAreasImageSize;

@property (nonatomic, assign) int                  currentButtonPressed;

@property (nonatomic, assign) CGFloat              numberWheelsStartY;
@property (nonatomic, assign) CGFloat              numberWheelsNumberHeight;

@property (nonatomic, assign) BOOL                 ignoringTouches;

@property (nonatomic, assign) AdderModes           currentMode;
@end

@implementation MainView

@synthesize hundredsDigitView = _hundredsDigitView;
@synthesize tensDigitView = _tensDigitView;
@synthesize onesDigitView = _onesDigitView;
@synthesize tenthsDigitView = _tenthsDigitView;
@synthesize hundredthsDigitView = _hundredthsDigitView;
@synthesize overlayView = _overlayView;
@synthesize digitZero = _digitZero;
@synthesize digitOne = _digitOne;
@synthesize currencySymbolLabel = _currencySymbolLabel;
@synthesize decimalSeparatorLabel = _decimalSeparatorLabel;
@synthesize buttonDownView = _buttonDownView;
@synthesize currentValue = _currentValue;
@synthesize clickDownSound = _clickDownSound;
@synthesize clickUpSound = _clickUpSound;
@synthesize clickCancelSound = _clickCancelSound;
@synthesize clickDownSubtractSound = _clickDownSubtractSound;
@synthesize clickUpSubtractSound = _clickUpSubtractSound;
@synthesize clickCancelSubtractSound = _clickCancelSubtractSound;
@synthesize buttonAreasImage = _buttonAreasImage;
@synthesize buttonAreasImageSize = _buttonAreasImageSize;
@synthesize currentButtonPressed = _currentButtonPressed;
@synthesize numberWheelsStartY = _numberWheelsStartY;
@synthesize numberWheelsNumberHeight = _numberWheelsNumberHeight;
@synthesize ignoringTouches = _ignoringTouches;
@synthesize currentMode = _currentMode;

-(BOOL)canBecomeFirstResponder 
{
   return YES;
}

-(int)getButtonForX:(NSInteger)x Y:(NSInteger)y
{
   int i = self.buttonAreasImageSize.width * y + x;
   
   int button = self.buttonAreasImage[i];
   
   switch ( self.currentMode )
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
      CGFloat newY = self.numberWheelsStartY;
      UIView* view = (__bridge UIView*)context;
      view.center = CGPointMake( view.center.x, newY );    
   }
}

-(void)rollView:(UIView*)view fromDigit:(NSInteger)fromDigit toDigit:(NSInteger)toDigit full:(BOOL)full direction:(int)dir
{
   CGFloat newY;
   
   if ( full )
   {
      newY = self.numberWheelsStartY - ( toDigit * self.numberWheelsNumberHeight );
   }
   else
   {
      if ( toDigit != fromDigit )
      {
         float fract = 0.35f;
         newY = self.numberWheelsStartY - ( fromDigit * self.numberWheelsNumberHeight ) + dir * ( self.numberWheelsNumberHeight * fract );
      }
      else
      {
         return; // don't even do anything in this case
      }
   }
   
   [UIView beginAnimations:@"rollNumberWheel" context:(__bridge void*)view];
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
         newY = self.numberWheelsStartY - ( 10 * self.numberWheelsNumberHeight );
         CGPoint newCenter = CGPointMake( view.center.x, newY );
         view.center = newCenter;
      }
      else
      {
         newY = self.numberWheelsStartY - ( 0 * self.numberWheelsNumberHeight );
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
   [self rollView:self.hundredthsDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:self.tenthsDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:self.onesDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:self.tensDigitView fromDigit:od toDigit:nd full:full direction:dir];
   
   oldWork/= 10;
   od = oldWork % 10;
   work/= 10;
   nd = work % 10;
   [self rollView:self.hundredsDigitView fromDigit:od toDigit:nd full:full direction:dir];
}

-(void)updateCurrentMode
{
   self.currentMode = (AdderModes)[[NSUserDefaults standardUserDefaults] integerForKey:@"AdderMode"];
   
   UIImage* overlayImage = nil;
   switch ( self.currentMode )
   {
      case MODE_ADDITION:
         overlayImage = [UIImage imageNamed:@"AdditionOverlay.png"];
         break;
         
      case MODE_SUBTRACTION:
         overlayImage = [UIImage imageNamed:@"SubtractionOverlay.png"];
         break;
         
      case MODE_ADDITION_AND_SUBTRACTION:
         overlayImage = [UIImage imageNamed:@"AdditionAndSubtractionOverlay.png"];
         break;
         
      default:
         break;
   }
   
   [self.overlayView setImage:overlayImage];
}

-(void)awakeFromNib
{
   [self updateCurrentMode];
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
      
      // Get the main bundle for the app
      CFBundleRef mainBundle;
      mainBundle = CFBundleGetMainBundle ();
      
      SystemSoundID ssid;

      CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                         CFSTR("ClickDown"),
                                                         CFSTR ("aiff"),
                                                         NULL
                                                         );
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickDownSound = ssid;
      CFRelease(soundFileURLRef);
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickUp"),
                                                CFSTR ("aiff"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickUpSound = ssid;
      CFRelease(soundFileURLRef);
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickCancel"),
                                                CFSTR ("aiff"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickCancelSound = ssid;
      CFRelease(soundFileURLRef);
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickUpSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickUpSubtractSound = ssid;
      CFRelease(soundFileURLRef);
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickDownSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickDownSubtractSound = ssid;
      CFRelease(soundFileURLRef);
      
      soundFileURLRef = CFBundleCopyResourceURL(mainBundle,
                                                CFSTR("ClickCancelSubtract"),
                                                CFSTR ("wav"),
                                                NULL
                                                );
      
      AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
      self.clickCancelSubtractSound = ssid;
      CFRelease(soundFileURLRef);
      
      UIImage* buttonAreas = [UIImage imageNamed:@"PortraitViewButtonAreas.png"];
      
      self.buttonAreasImage = GetImagePixelData( buttonAreas.CGImage );
      self.buttonAreasImageSize = buttonAreas.size;   
      
      self.multipleTouchEnabled = NO;
      
      [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(setupLabels) userInfo:nil repeats:NO];
      
      self.ignoringTouches = YES;
   }
   
   return self;
}

-(void)playSound:(SystemSoundID)soundId
{
   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SoundOn"])
   {
      AudioServicesPlaySystemSound( soundId );
   }
}

-(void)setupLabels
{
   self.numberWheelsStartY = self.hundredsDigitView.center.y;
   
   self.numberWheelsNumberHeight = self.digitOne.center.y - self.digitZero.center.y;
   
   self.currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastValue"];
   [self updateLabelsForValue:self.currentValue full:YES];
   
   NSLocale* locale = [NSLocale autoupdatingCurrentLocale];
   
   NSString* ls = [locale objectForKey:NSLocaleDecimalSeparator];
   [self.decimalSeparatorLabel setText:ls];
   
   ls =  [locale objectForKey:NSLocaleCurrencySymbol];
   [self.currencySymbolLabel setText:ls];
   
   self.currentButtonPressed = -1;
   
   self.ignoringTouches = NO;
   
   self.buttonDownView.hidden = YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event
{
   if (UIEventSubtypeMotionShake == event.subtype)
   {
      self.currentValue = 0;
      [self updateLabelsForValue:self.currentValue full:YES];
      
      [[NSUserDefaults standardUserDefaults] setInteger:self.currentValue forKey:@"LastValue"];
   }
}

-(void)dealloc 
{
   free(self.buttonAreasImage);
   
   AudioServicesDisposeSystemSoundID(self.clickDownSound);
   AudioServicesDisposeSystemSoundID(self.clickUpSound);
   AudioServicesDisposeSystemSoundID(self.clickCancelSound);
   AudioServicesDisposeSystemSoundID(self.clickDownSubtractSound);
   AudioServicesDisposeSystemSoundID(self.clickUpSubtractSound);
   AudioServicesDisposeSystemSoundID(self.clickCancelSubtractSound);
   
}

-(void)ignoreTouchesForTimeInterval:(NSTimeInterval)ti
{
   self.ignoringTouches = YES;
   [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(stopIgnoringTouches) userInfo:nil repeats:NO];
}

-(void)stopIgnoringTouches
{
   self.ignoringTouches = NO;
}

-(void)cancelButtonPress
{
   if ( self.currentButtonPressed > 0 && self.currentButtonPressed <= 4 )
   {
      [self playSound:self.clickCancelSound];
   }
   else if ( self.currentButtonPressed > 4 && self.currentButtonPressed <= 8 )
   {
      [self playSound:self.clickCancelSubtractSound];
   }
   
   self.currentButtonPressed = -1;
   
   [self updateLabelsForValue:self.currentValue full:YES];
   
   self.buttonDownView.hidden = YES;
}

-(UIImage*)buttonDownImageForButton:(int)button
{
   NSString* imageName = nil;
   
   if ( self.currentMode == MODE_ADDITION_AND_SUBTRACTION )
   {
      imageName = [NSString stringWithFormat:@"PButton%dDown.png", button];
   }
   else
   {
      if ( self.currentMode == MODE_SUBTRACTION )
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
   
   self.currentButtonPressed = button;
   
   if ( self.currentButtonPressed != -1 )
   {
      NSInteger newVal;
      
      if ( self.currentButtonPressed <= 4 )
      {
         newVal = self.currentValue + pow( 10, self.currentButtonPressed - 1 );
         [self playSound:self.clickDownSound];
      }
      else
      {
         newVal = self.currentValue - pow( 10, self.currentButtonPressed - 5 );
         [self playSound:self.clickDownSubtractSound];
      }
      
      [self updateLabelsForValue:newVal full:NO];
      
      [self.buttonDownView setImage:[self buttonDownImageForButton:self.currentButtonPressed]];
      self.buttonDownView.hidden = NO;
   }
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
   UITouch* touch = [touches anyObject];
   CGPoint loc = [touch locationInView:self];
   
   int button = [self getButtonForX:loc.x Y:loc.y];
   
   if ( self.currentButtonPressed != button )
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
   
   if ( button == self.currentButtonPressed && button != -1 )
   {
      if ( self.currentButtonPressed <= 4 )
      {
         self.currentValue+= pow( 10, self.currentButtonPressed - 1 );
         [self playSound:self.clickUpSound];
      }
      else
      {
         self.currentValue-= pow( 10, self.currentButtonPressed - 5 );
         [self playSound:self.clickUpSubtractSound];
      }
      
      [self updateLabelsForValue:self.currentValue full:YES];
      
      if ( self.currentValue < 0 )
      {
         self.currentValue = 100000 + self.currentValue;
      }
      
      self.currentValue%= 100000;
      [[NSUserDefaults standardUserDefaults] setInteger:self.currentValue forKey:@"LastValue"];
      
      [self ignoreTouchesForTimeInterval:0.11f];
   }
   
   self.currentButtonPressed = -1;
   
   self.buttonDownView.hidden = YES;
}

@end
