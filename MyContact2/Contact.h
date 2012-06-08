//
//  Contact.h
//  MyContact2
//
//  Created by VMware Inc. on 6/8/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#ifndef variable_const_sort_by
#define variable_const_sort_by

static  NSString* const SORT_BY = @"firstName";

#endif


@interface Contact : NSManagedObject


@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * displayNameInitial;

+ (NSString *)sortKey;

@end
