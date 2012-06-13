//
//  Patricia.h
//  MyContact2
//
//  Created by VMware Inc. on 6/12/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringIndexable.h"

#ifndef PARTIRCIA_INITIALS
#define PARTRICIA_INITIALS

// a-z, 0-9, with an extra unit at 0 to contain leaf node
// and the last unit represents all the other chars, 
// like +, /, %, ^, except for -
static NSInteger __initcapacity = 38;

static NSInteger __sharpIndex = 0;

static BOOL __ignoreCase = YES;

// only chars within the range of a to z are processed.

static char __beginChar = 'a';
static char __endinChar = 'z';

#endif

@interface Patricia : NSObject

-(void)addAllStringIndexables:(NSArray<StringIndexable>*)stringIndexables;
-(void)addStringIndexable:(NSObject<StringIndexable>*) stringIndexable withValueId:(NSInteger)valueId;
-(NSObject<StringIndexable>*)removeAtStringIndex:(NSString*)index
                 withValueId:(NSInteger)valueId;
-(NSArray<StringIndexable>*) suggestValues:(NSString*)index;
-(BOOL)isEntry:(NSString*)index;

// getters that can be called via dot
// seems like getters are define as non argument methods
// -(BOOL)testReturnOfDotOper; 
// -(void)testNoReturn;

@end
