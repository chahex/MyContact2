//
//  PatriciaFetchedResultController.m
//  MyContact2
//
//  Created by VMware Inc. on 6/18/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "PatriciaFetchedResultController.h"
#import "Patricia.h"
#import "Contact.h"

@interface PatriciaFetchedResultController()
-(void) prepareFetchedResults;
@end

@implementation PatriciaFetchedResultController

-(void) prepareFetchedResults
{
    Patricia* p = [[Patricia alloc] init];
    [p addValues:super.fetchedObjects withIndexSelector:@selector(displayName)];
    NSMutableArray* myLocalSections = nil;
    NSMutableArray* myLocalIndexTitles = nil;
    _myFetchedObjects = [p findAllValuesWithResultsSectionInfos:&myLocalSections andHeaderTitles:&myLocalIndexTitles];
    _mySections = myLocalSections;
    _mySectionIndexTitles = myLocalIndexTitles;
}

-(BOOL)performFetch:(NSError *__autoreleasing *)error
{
    BOOL flag = [super performFetch:error];
    if(flag)
    {
        [self prepareFetchedResults];
    }
    return flag;
}

-(NSArray*) fetchedObjects
{
    return _myFetchedObjects;
}

-(NSArray*) sectionIndexTitles
{
    return _mySectionIndexTitles;
}

-(NSArray*) sections
{
    return _mySections;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id<NSFetchedResultsSectionInfo> section = [_mySections objectAtIndex:indexPath.section];
    return [section.objects objectAtIndex:indexPath.row];
}

/* Returns the indexPath of a given object.
 */
-(NSIndexPath *)indexPathForObject:(id)object
{
    return [[NSIndexPath alloc] initWithIndex:[_myFetchedObjects indexOfObject:object]];
}

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName
{
    return sectionName;
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex
{
    return sectionIndex;
}

@end