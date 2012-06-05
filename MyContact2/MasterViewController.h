//
//  MasterViewController.h
//  MyContact2
//
//  Created by Xinkai HE on 6/3/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
