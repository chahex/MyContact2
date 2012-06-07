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

@end