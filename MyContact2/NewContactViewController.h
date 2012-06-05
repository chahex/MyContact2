//
//  NewContactViewController.h
//  MyContact2
//
//  Created by Xinkai HE on 6/4/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface NewContactViewController : UIViewController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

- (IBAction)doneEditing:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *done;
@end