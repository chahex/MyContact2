//
//  Trie.h
//  MyContact2
//
//  Created by VMware Inc. on 6/11/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringIndexable.h"

// This is a trie object.
// 

@interface Trie : NSObject

@property (readonly) BOOL isCaseInsensitive;

-(id)initWithCaseInsensitive:(BOOL)caseInsensitive;

// this method should take an Object conforms
// to the StringIndexable protocol

-(void)addIndexableValue:(id<StringIndexable>)indexable;

-(void)addAllIndexableValues:(NSArray<StringIndexable>*)indexables;

-(NSArray<StringIndexable>*) findAll:(NSString*)index;

-(id<StringIndexable>)removeAtStringIndex:(NSString*)index;

-(BOOL)isEntry:(NSString*)index;

@end
