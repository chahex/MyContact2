//
//  Patricia.m
//  MyContact2
//
//  Created by VMware Inc. on 6/12/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "Patricia.h"
#import "StringIndexable.h"

#pragma mark - Nodes definition

#pragma mark - BaseNode definition

@protocol BaseNode @end;
@interface BaseNode : NSObject<BaseNode> 
@property char keyVal;
@end;

@implementation BaseNode
char _keyVal;
@synthesize keyVal = _keyVal;

-(id)initWithKeyVal : (char)keyVal
{
    if(self = [super init])
    {
        self.keyVal = keyVal;
    }
    return self;
}
@end;

#pragma mark - PatirciaNode definition

@interface PatriciaNode : BaseNode
@property (strong, readwrite) NSMutableArray<BaseNode>* baseArr;
@end;

@implementation PatriciaNode
NSMutableArray<BaseNode> *_baseArr;
@synthesize baseArr = _baseArr;


-(id)initWithKeyVal:(char)keyVal
{
    if(self = [super initWithKeyVal:keyVal])
    {
        self.baseArr = [[NSMutableArray array] initWithCapacity:__initcapacity];
    }
    return self;
}
@end;

#pragma mark - LeafNode definition

/** The leaf node stores the data */
@interface LeafNode : BaseNode
// Used to store the next object with the same Index value
@property LeafNode* nextSibling;
@property NSObject<StringIndexable>* value;
// The unique id to identify the value if multiple exists.
@property NSInteger valueId;
@end;

@implementation LeafNode
{
    LeafNode* _nextSibling;
    NSObject<StringIndexable>* _value;
    NSInteger _valueId;
}
@synthesize nextSibling = _nextSibling;
@synthesize value = _value;
@synthesize valueId = _valueId;

-(id)initWithValue:(NSObject<StringIndexable>*) value 
        andValueId:(NSInteger)valueId
{
    if(self = [super init])
    {
        self.nextSibling = Nil;
        self.value = value;
        self.valueId = valueId;
    }
    return self;
}

@end;


#pragma mark - Patricia Tree implementation

@interface Patricia()
@property PatriciaNode* root;
@end;

@implementation Patricia

-(void)addAllStringIndexables:(NSArray<StringIndexable>*)stringIndexables
{
    NSInteger i = 0;
    for(NSObject<StringIndexable>* indexable in stringIndexables)
    {
        [self addStringIndexable:indexable withValueId:i++];
    }
}

-(void)addStringIndexable:(NSObject<StringIndexable>*) stringIndexable withValueId:(NSInteger) valueId
{

    BaseNode *p = self.root;
    NSString* index = stringIndexable.indexString;
    NSInteger indexLength = [index length];
    for(NSInteger i = 0;i<indexLength;i++)
    {
        NSInteger key = [self toIndexKeyVal:[index characterAtIndex:i]];
        if([p isKindOfClass:[Patricia class]])
        {
             // when reached the end of word, just put it on the first node
            if(i == indexLength-1)
            {
                LeafNode* ln = [((PatriciaNode*)p).baseArr objectAtIndex:0];
                [self addLeafNodeAtNode:&ln WithValue:stringIndexable withValueId:valueId];
                return;
            }
            BaseNode* next = [((PatriciaNode*)p).baseArr objectAtIndex:key];
            // when could added to the leaf directly
            if(!next) 
            {
                [self addLeafNodeAtNode:&next WithValue:stringIndexable withValueId:valueId];
                return;
            }
            
            // when next node is a PatriciaNode
            if([next isKindOfClass:[PatriciaNode class]])
            {
                p = next;
                continue;
            }
            
            // when next node is a leafNode
            if([next isKindOfClass:[LeafNode class]])
            {
                if([((LeafNode*)next).value.indexString isEqualToString:stringIndexable.indexString])
                {
                    [self addLeafNodeAtNode:&next WithValue:stringIndexable withValueId:valueId];
                    return;
                }else {
                    NSString* k_l = ((LeafNode*)next).value.indexString;
                    do{
                        PatriciaNode* nn = [PatriciaNode alloc];
                        [((PatriciaNode*)p).baseArr replaceObjectAtIndex:i withObject:nn];
                        p = nn;
                        ++i;
                        // the strings are like:
                        // new: are
                        // old: area
                        if(i>=indexLength)
                        {
                            // add the new one
                            [self addLeafNodeAtNode:&p WithValue:stringIndexable withValueId:valueId];
                            // add the old one
                            [self addLeafNodeAtNode:[((PatriciaNode*)p).baseArr objectAtIndex:<#(NSUInteger)#> WithValue:<#(NSObject<StringIndexable> *)#> withValueId:<#(NSInteger)#>
                        }
                        key=[self toIndexKeyVal:[index characterAtIndex:i]];
                    }while([k_l characterAtIndex:i]==key);
                    if(i==indexLength-1)
                    {
                        LeafNode* ln2 = [((PatriciaNode*)p).baseArr objectAtIndex:0];
                        [self addLeafNodeAtNode:&ln2 WithValue:stringIndexable withValueId:valueId];
                    }
                    
                    
                }

                
            }
            
            
            
        }
    }
    // set end of word marker to p
}

// This method should only be used to add a leafNode to 
// an existing LeafNode pointer, or a nil place
// so if it is not a leaf node but a patricia node, should take
// a different approach

-(void)addLeafNodeAtNode:(BaseNode**)baseNode
               WithValue:(NSObject<StringIndexable>*) value
             withValueId:(NSInteger)valueId
{
    if(*baseNode){
        LeafNode* p = (LeafNode*)*baseNode;
        // here strictly assume no loop, and no siblings means nil.
        while(p.nextSibling!=Nil)
            p = p.nextSibling;
        *baseNode = p;
    }
    *baseNode = [[LeafNode alloc] initWithValue:value andValueId:valueId];
    return;
}

/**
 * @return the modified key value for the given key, the return value should be used as index in the patricia key,<br> the - should be ignored when processing if followed by number, for Name-1 = Name1, for Name&&1 = Name(cap)1
 */
-(NSInteger)toIndexKeyVal:(char)key
{
    if(__ignoreCase)
    {
        // word character
        if(key<='z' && key>='a')
            return key - 'a' + 1;
        // number character
        if(key<='9' && key>='0')
            return key - '0' +1;
        // just ignore the - when processing
        // if(key=='-')
        //    return 0;
    }
    // otherwise treat as same thing.
    return __initcapacity-1;
}

-(NSObject<StringIndexable>*)removeAtStringIndex:(NSString*)index
                                     withValueId:(NSInteger)valueId
{
    return Nil;
}
-(NSArray<StringIndexable>*) suggestValues:(NSString*)index
{
    return Nil;
}
-(BOOL)isEntry:(NSString*)index
{
    return NO;
}

-(BOOL)testReturn
{
    return YES;
}

@end
