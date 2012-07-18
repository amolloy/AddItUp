//
//  ASMButtonDownView.m
//  AddItUp
//
//  Created by The Molloys on 7/18/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMButtonDownView.h"

@interface ASMButtonDownView ()
-(UIImage*)buttonDownImageForButton:(int)button;
@end

@implementation ASMButtonDownView

@synthesize adderMode = _adderMode;
@synthesize downButton = _downButton;

-(void)setAdderMode:(AdderModes)adderMode
{
   _adderMode = adderMode;
   [self setNeedsDisplay];
}

-(void)setDownButton:(NSInteger)downButton
{
   _downButton = downButton;
   [self setNeedsDisplay];
}

-(UIImage*)buttonDownImageForButton:(int)button
{
   NSString* imageName = [NSString stringWithFormat:@"PButton%dDown.png", button];
   return [UIImage imageNamed:imageName];
}

-(void)drawRect:(CGRect)rect
{
   if (-1 != self.downButton)
   {
      CGRect drawRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
      
      if ( MODE_ADDITION_AND_SUBTRACTION == self.adderMode )
      {
         UIImage* buttonImage = [self buttonDownImageForButton:self.downButton];
         [buttonImage drawInRect:drawRect];
      }
      else
      {
         NSInteger button = self.downButton;
         
         if ( MODE_SUBTRACTION == self.adderMode )
         {
            button-= 4;
         }
         
         UIImage* buttonImage = [self buttonDownImageForButton:button];
         [buttonImage drawInRect:drawRect];
         buttonImage = [self buttonDownImageForButton:button + 4];
         [buttonImage drawInRect:drawRect];
      }
   }
}

@end
