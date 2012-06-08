//
//  Contact.m
//  MyContact2
//
//  Created by Xinkai HE on 6/5/12.
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

static NSString* SORT_BY = @"firstName";
static NSInteger FIRST_LAST_STYLE = 0;
static NSInteger LAST_FIRST_STYLE = 1;


-(NSString*) getDescriptionByStyle:(NSInteger) style
{
    switch (style) {
        case 0:
            
            break;
        case 1:
            
            break;
            
        default:
            break;
    }
}


- (NSString*) contactDisplayName:(NSManagedObject*) object
{
    NSString* firstName = [object valueForKey:@"firstName"];
    NSString* lastName = [object valueForKey:@"lastName"];
    NSString* phone = [object valueForKey:@"phone"];
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
        NSLog(@"Only email available");
        return [object valueForKey:@"email"];
        // assume one of them is not nil
    }
    
    
    if([SORT_BY isEqualToString:@"firstName"])
    {
        result = [result stringByAppendingFormat:@"%@ %@",firstName, lastName];
        NSLog(@"Sort by firstName");
    }else
    {
        result = [result stringByAppendingFormat:@"%@, %@",lastName, firstName];
        NSLog(@"Sort by lastName");
    }
    NSLog(@"Result:%@",result);
    return result;
    // else
    
}

@end