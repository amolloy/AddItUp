//
//  AddItUpViewControllerViewController.m
//  AddItUp
//
//  Created by Andy Molloy on 4/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "AddItUpViewControllerViewController.h"

@interface AddItUpViewControllerViewController ()

@end

@implementation AddItUpViewControllerViewController

-(id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) 
   {
      // Custom initialization
   }
   return self;
}

-(void)viewDidLoad
{
   [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
   [self.view becomeFirstResponder];
}

-(void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
