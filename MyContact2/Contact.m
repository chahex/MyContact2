//
//  Contact.m
//  MyContact2
//
//  Created by VMware Inc. on 6/8/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@dynamic company;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic phone;
@dynamic timeStamp;
@dynamic displayName;
@dynamic displayNameInitial;


-(NSString*)displayName

{
    [self willAccessValueForKey:@"displayName"];
    NSString* firstName = [self valueForKey:@"firstName"];
    NSString* lastName = [self valueForKey:@"lastName"];
    NSString* phone = [self valueForKey:@"phone"];
    NSString* email = [self valueForKey:@"email"];
    NSString* company = [self valueForKey:@"company"];
    NSString* result = @"";

    NSLog(@"[fn=%@,ln=%@,phone=%@]",firstName,lastName,phone);
    
    // If no firstName and lastName given, return phone number
    // Works for nil too.
    if(![firstName length] && ![lastName length])
    {
        if([phone length]){
            NSLog(@"Only phone number not nil.");
            return phone;
        }
        if([email length]){
            NSLog(@"Only email available");
            return [self valueForKey:@"email"];
        }
        NSLog(@"return company");
        return company;
        // assume one of them is not nil
    }
    
    if([SORT_BY isEqualToString:@"firstName"])
    {
        result = [result stringByAppendingFormat:@"%@ %@",firstName, lastName];
    }else
    {
        result = [result stringByAppendingFormat:@"%@, %@",lastName, firstName];
    }
    NSLog(@"Sort by %@",SORT_BY);
    NSLog(@"Result:%@",result);
    [self didAccessValueForKey:@"displayName"];
    return result;
    // else
    
}

-(NSString*)displayNameInitial
{
    [self willAccessValueForKey:@"displayNameInitial"];
    NSString* result = [[self displayName] substringToIndex:1];
    [self didAccessValueForKey:@"displayNameInitial"];
    return result;
}

@end
