//
//  MasterViewController.h
//  MyContact2
//
//  Created by Xinkai HE on 6/3/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "Patricia.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) Patricia* contactPatricia;
@property (strong, nonatomic) NSArray* searchResults;


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
