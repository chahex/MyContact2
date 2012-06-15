//
//  DetailViewController.m
//  MyContact2
//
//  Created by Xinkai HE on 6/3/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize navigationBar = _navigationBar;
@synthesize detailItem = _detailItem;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize companyField = _companyField;
@synthesize phoneField = _phoneField;
@synthesize emailField = _emailField;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{   
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSManagedObject* mObject = self.detailItem;
        self.firstNameField.text = [mObject valueForKey:@"firstName"];
        self.lastNameField.text = [mObject valueForKey:@"lastName"];
        self.companyField.text = [mObject valueForKey:@"company"];
        self.phoneField.text = [mObject valueForKey:@"phone"];
        self.emailField.text = [mObject valueForKey:@"email"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setCompanyField:nil];
    [self setPhoneField:nil];
    [self setEmailField:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)deleteContact:(id)sender {
    
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *editedManagedObject = (NSManagedObject*)self.detailItem;
    [context deleteObject:editedManagedObject];
    NSLog(@"Deletion complete.");
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)saveContact:(id)sender {
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject* editedManagedObject = self.detailItem;
    [editedManagedObject setValue:self.firstNameField.text forKey:@"firstName"];
    [editedManagedObject setValue:self.lastNameField.text forKey:@"lastName"];
    [editedManagedObject setValue:self.companyField.text forKey:@"company"];
    [editedManagedObject setValue:self.phoneField.text forKey:@"phone"];
    [editedManagedObject setValue:self.emailField.text forKey:@"email"];
    NSError *error = nil;
    if(![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"Save complete:%@",self.detailItem);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
