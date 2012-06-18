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

// define the default size of the section info
static NSInteger const SECTION_INFO_SIZE = 27;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) Patricia* contactPatricia;
@property (strong, nonatomic) NSArray* searchResults;
@property (strong, nonatomic) NSArray* sectionInfos;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
