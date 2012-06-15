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

static NSInteger const __initCapacity = 38;

static NSInteger const __sharpKey = 0;

static NSInteger const __slashKey = -1;

static NSInteger const __otherKey = 37;

static NSInteger const __keyLowerBound = 0;

static NSInteger const __keyUpperBound = 37;

static BOOL const __ignoreCase = YES;

#endif

@interface Patricia : NSObject

@property NSInteger size;

-(void)addAllStringIndexables:(NSArray<StringIndexable>*)stringIndexables;

-(void)addStringIndexable:(NSObject<StringIndexable>*) value 
              withValueId:(NSInteger)valueId;

-(void)addValue:(NSObject*) value
withIndexString:(NSString*) indexString 
     andValueId:(NSInteger) valueId;

-(void)addValue:(NSObject*) object
withIndexSelector:(SEL)indexSel
andValueId:(NSInteger)valueId;

-(void)addValues:(NSArray*) objArray
withIndexSelector:(SEL)indexSel;

-(NSObject<StringIndexable>*)removeAtStringIndex:(NSString*)index 
                                     withValueId:(NSInteger)valueId;

-(NSArray<StringIndexable>*) suggestValuesForIndex:(NSString*)index;

-(BOOL)isEntry:(NSString*)index;

// getters that can be called via dot
// seems like getters are define as non argument methods
// -(BOOL)testReturnOfDotOper; 
// -(void)testNoReturn;

@end
