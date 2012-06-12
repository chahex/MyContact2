//
//  Trie.m
//  MyContact2
//
//  Created by VMware Inc. on 6/11/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "Trie.h"
#import "StringIndexable.h"

#pragma mark - Node definition

@interface Node :NSObject

// Should these be storng or not stong?

@property (strong,readwrite) Node* firstChild;
@property (strong,readwrite) Node* nextSibling;
@property (strong, readwrite) id<StringIndexable> value;
@property (readwrite) char indexVal;

-(id)initWithIndexVal:(char)indexVal;

@end;

@implementation Node

Node* _firstChild;
Node* _nextSibling;
char _indexVal;
id<StringIndexable> _value;


@synthesize firstChild = _firstChild;
@synthesize nextSibling = _nextSibling;
@synthesize value = _value;
@synthesize indexVal = _indexVal;

-(id)initWithIndexVal:(char)indexVal
{
    if(self=[super init])
    {
        self.indexVal = indexVal;
    }
    return self;
}
@end;



#pragma mark - Trie implementation


@interface Trie()
@property (readwrite) BOOL isCaseInsensitive;
@property (readwrite, strong) Node* root;
@end;


@implementation Trie

BOOL _isCaseInsensitive;
Node* _root;

@synthesize root = _root;
@synthesize isCaseInsensitive=_isCaseInsensitive;

// init with case sensitive by default
-(id)init
{
    return [self initWithCaseSensitivity:NO];
}

-(id)initWithCaseSensitivity:(BOOL)isCaseInsensitive
{
    if(self = [super init])
    {
        self.isCaseInsensitive = isCaseInsensitive;
    }
    return self;
}


-(void)addIndexableValue:(id<StringIndexable>)indexable
{
    NSString* index = [indexable indexString];
    if(self.isCaseInsensitive)
    {
        index = [index lowercaseString];
    }
    char ch = [index characterAtIndex:0];
    // if 
    if(!self.root)
    {
        self.root = [[Node alloc] initWithIndexVal:ch];
    }
}

-(void)addAllIndexableValues:(NSArray<StringIndexable>*)indexables
{
    
}

-(NSArray<StringIndexable>*) findAll:(NSString*)index
{
    
}

-(id<StringIndexable>)removeAtStringIndex:(NSString*)index
{
    
}

-(BOOL)isEntry:(NSString*)index
{
    
}

@end
