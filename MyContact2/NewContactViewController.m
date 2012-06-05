//
//  NewContactViewController.m
//  MyContact2
//
//  Created by Xinkai HE on 6/4/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "NewContactViewController.h"
#import "AppDelegate.h"

@implementation NewContactViewController
@synthesize done;


@synthesize managedObjectContext = __managedObjectContext;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize companyField = _companyField;
@synthesize phoneField = _phoneField;
@synthesize emailField = _emailField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setDone:nil];
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setCompanyField:nil];
    [self setPhoneField:nil];
    [self setEmailField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Create new contact

- (void)insertNewObject
{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    // First insert, then update. 
    // The insertion == create object.
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
    
    /*  // Iterate through the dictionary
    NSString* name = [entity name];
    NSDictionary* dict = [entity propertiesByName];
    for(id key in dict)
    {
        NSLog(@"%@:key=%@,val=%@",name, key,[dict objectForKey:key]);
    }
    */
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:self.firstNameField.text forKey:@"firstName"];
    [newManagedObject setValue:self.lastNameField.text forKey:@"lastName"];
    [newManagedObject setValue:self.companyField.text forKey:@"company"];
    [newManagedObject setValue:self.phoneField.text forKey:@"phone"];
    [newManagedObject setValue:self.emailField.text forKey:@"email"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"Insertion complete:%@",newManagedObject);
}

- (IBAction)doneEditing:(id)sender {
    NSLog(@"doneEditing..");
    [self insertNewObject];
    NSLog(@"doneInsertion..");
    [self.navigationController popViewControllerAnimated:YES];  
}

-(NSManagedObjectContext*)managedObjectContext
{
    if(__managedObjectContext==nil)
    {
        __managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return __managedObjectContext;
    
}




@end
