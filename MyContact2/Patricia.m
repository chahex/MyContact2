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
@end;
@implementation BaseNode
@end;

#pragma mark - PatirciaNode definition

@interface PatriciaNode : BaseNode

@property NSMutableDictionary* baseDict;

-(BaseNode*) nodeForKey:(NSInteger)key;
-(void) setNodeAtKey: (NSInteger)key 
            withNode:(BaseNode*) node;
@end;

@implementation PatriciaNode
NSMutableDictionary* _baseDict;
@synthesize baseDict = _baseDict;

-(id)init
{
	if(self = [super init])
	{
        self.baseDict = [NSMutableDictionary dictionaryWithCapacity:__initCapacity];
    }
	return self;
}

-(BaseNode*) nodeForKey:(NSInteger)key
{
    return [self.baseDict objectForKey:[NSNumber numberWithInt: key]];
}

-(void) setNodeAtKey:(NSInteger)key
            withNode:(BaseNode*)node
{
    [self.baseDict setObject:node forKey:[NSNumber numberWithInt:key]];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"PNode[%@]",self.baseDict];
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

-(NSString*) description
{
	return [NSString stringWithFormat:@"LNode[%@,id:%d, next:%@]",self.value,self.valueId, self.nextSibling];
}

@end;


#pragma mark - Patricia Tree implementation

@interface Patricia()
@property (retain) PatriciaNode* root;
@end;

@implementation Patricia

PatriciaNode* _root;
NSInteger _size;

@synthesize size = _size;
@synthesize root = _root;

-(id) init
{
	if(self = [super init])
	{
		self.root = [[PatriciaNode alloc] init];
	}
	return self;
}

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
    if(!__ignoreCase){
        // not supported case sensitivie.
        abort();
    }
    NSString* index = [stringIndexable.indexString lowercaseString];
    NSInteger newIndexLength = [index length];
    
    if(!index) {        return;    }
    
    LeafNode* newLeaf = [[LeafNode alloc]initWithValue:stringIndexable andValueId:valueId];
    PatriciaNode *p = self.root;
    
    // if no exceptions, the value is due to be inserted.
    ++self.size;
    
    for(NSInteger i = 0;;)
    {
        // when reached the end of word, just put it on the first node
        if(i == newIndexLength)
        {
            LeafNode* oldLeaf = (LeafNode*)[p nodeForKey:__sharpKey];
            // the oldLeaf pointer's value may be changed if it is nil.
            [self insertLeafNodeAtNodePointer:&oldLeaf withNewLeaf:newLeaf];
            [p setNodeAtKey:__sharpKey withNode:oldLeaf];
            return;
        }
        NSInteger newKey = [self getIndexKeyVal:[index characterAtIndex:i]];
        
        // meet with key that should be ignored, like -
        if(newKey==__sharpKey)
        {
            ++i;
            continue;
        }
        
        BaseNode* next = [p nodeForKey:newKey];
        // when next is NSNull, could add the leaf directly
        if(next == Nil)
        {
            [p setNodeAtKey:newKey withNode:newLeaf];
            return;
        }
        
        // when next node is a PatriciaNode
        if([next isKindOfClass:[PatriciaNode class]])
        {
            p = (PatriciaNode*)next;
            ++i;
            continue;
        }
        
        // when next node is a leafNode
        LeafNode* oldLeaf = (LeafNode*) next;
        // if indexes not duplicated
        NSString* oldIndex = [oldLeaf.value.indexString lowercaseString];
        NSInteger oldIndexLength = [oldIndex length];
        NSInteger oldKey = 0;
        // duplicated indexes
        // NSLog(@"oldi:%@,newi:%@",oldIndex,index);
        if([oldIndex isEqualToString:index])
        {
            [self insertLeafNodeAtNodePointer:&oldLeaf withNewLeaf:newLeaf];
            return;
        }
        
        do{
            PatriciaNode* tmpNode = [[PatriciaNode alloc] init];
            [p setNodeAtKey:newKey withNode:tmpNode];
            p = tmpNode;
            ++i;
            // if the strings are like:
            // new: are
            // old: area
            if(i>=newIndexLength)
            {
                /*
                // add the new one
                [p.baseArr replaceObjectAtIndex:__sharpIndex withObject:newLeaf];
                // add the old one
                [p.baseArr replaceObjectAtIndex:oldKey withObject:oldLeaf];
                return;
                 */
                newKey = __sharpKey;
            }else{
                newKey = [self getIndexKeyVal:[index characterAtIndex:i]];
            }
            
            // the strings are like:
            // new: area
            // old: are
            // now, p->are, so put area at p[a], and put are at p[#]
            if(i>=oldIndexLength)
            {
                /*
                // add the new one
                [p.baseArr replaceObjectAtIndex:newKey withObject:newLeaf];
                // add the old one
                [p.baseArr replaceObjectAtIndex:__sharpIndex withObject:oldLeaf
                 ];
                 */
                oldKey = __sharpKey;
            }else {
                oldKey = newKey = [self getIndexKeyVal:[oldIndex characterAtIndex:i]];
            }
            
        }while(oldKey == newKey);
        
        // the 3rd situation, strings should be like:
        // new: aret*
        // old: aref*
        // p->are, so put aret at p[t], and put aref at p[f]
        // i is pointing to t/f
        
        [p setNodeAtKey:newKey withNode:newLeaf];
        [p setNodeAtKey:oldKey withNode:oldLeaf];
        return;
    }
    // set end of word marker to p
}

// This method should only be used to add a leafNode to 
// an existing LeafNode pointer, or a nil place
// so if it is not a leaf node but a patricia node, should take
// a different approach

-(void)addLeafNodeAtNode:(BaseNode**)baseNode
               withValue:(NSObject<StringIndexable>*) value
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

// side effect: the pointer passed in may be pointed to a new LeafNode if it is originally Nil..
// if it is not Nil, the newLeafNode will be attached to the siblings.

-(void)insertLeafNodeAtNodePointer:(LeafNode**)oldLeafPointer
               withNewLeaf:(LeafNode*) newLeafNode
{

    LeafNode* oldLeafNode = *oldLeafPointer;
    if(oldLeafNode == Nil)
    {
        *oldLeafPointer = newLeafNode;
        return;
    }
    // here strictly assume no loop, and no siblings means nil.
    while(oldLeafNode.nextSibling!=Nil)
        oldLeafNode = oldLeafNode.nextSibling;
    oldLeafNode.nextSibling = newLeafNode;
    return;
}

/**
 * @return the modified key value for the given key, the return value should be used as index in the patricia key,<br> the - should be ignored when processing if followed by number, for Name-1 = Name1, for Name&&1 = Name(cap)1
 */
-(NSInteger)getIndexKeyVal:(char)key
{

    // word character
    if(key<='z' && key>='a')
        return key - 'a' + 1 + 10;
    // number character
    if(key<='9' && key>='0')
        return key - '0' + 1;
    // just ignore the - when processing
    if(key=='-')
        return __sharpKey;
    // otherwise treat as same thing.
    return __initCapacity-1;
}

-(NSObject<StringIndexable>*)removeAtStringIndex:(NSString*)index
                                     withValueId:(NSInteger)valueId
{
    return Nil;
}

-(NSArray<StringIndexable>*) suggestValuesForIndex:(NSString*)index
{
    // go looking for the values there
    // from the root
    // if the node is Patricia Node, iterate through all the sub nodes, should use recursive call?
    // if the node is leaf node, just return its stroe values
    // the returned values should be ordered.
    
    // the order can be guranteed by two ways,
    //      1. simpley iterate the key from 0 to __initCapacity-1.
    //      2. get all keys from the map, order the keys.
    // as for the interface of 
    NSMutableArray<StringIndexable>* arr = [NSMutableArray arrayWithCapacity:self.size];

    [self suggestValuesForIndex:index
                     withOffset:0 
                        AtPNode:self.root
                     addToArray:arr];
    return arr;
}

-(void) suggestValuesForIndex:(NSString*)index 
                   withOffset:(NSInteger)offset
                      AtPNode:(PatriciaNode*) root
                   addToArray:(NSMutableArray<StringIndexable>*)arr
{

    NSInteger indexLength = [index length];
    NSInteger curOffset = offset;
    NSInteger curKey = [self getIndexKeyVal:[index characterAtIndex:curOffset]];
    BaseNode* curNode = [root nodeForKey:curKey];
    
    for(;curOffset<indexLength;)
    {

        if(!curNode)
            return;
        if([curNode isKindOfClass:[PatriciaNode class]])
        {
            if(offset<indexLength-1)
            {
                curKey = [self getIndexKeyVal:[index characterAtIndex:++curOffset]];
                curNode = [((PatriciaNode*)curNode) nodeForKey:curKey];
                continue;
            }else{
                // curNode is patricia node, and the offset==indexLength-1
                [self findAllValuesAtPNode:(PatriciaNode*)curNode addToArray:arr];
                break;
            }
        }
        
        // when is a leafNode, just return the value on it.
        LeafNode* leafNode = (LeafNode*)curNode;
        do{
            [arr addObject:leafNode.value];
        }while((leafNode = leafNode.nextSibling));
        break;
    }
}

-(void) findAllValuesAtPNode:(PatriciaNode*) root
                 addToArray:(NSMutableArray<StringIndexable>*) arr
{
    NSInteger start = 0;
    NSInteger end = __initCapacity - 1;
    
    for(NSInteger i = start;i<=end;i++)
    {
        BaseNode* curNode = [root nodeForKey:i];
		if(!curNode)
			continue;
        if([curNode isKindOfClass:[LeafNode class]])
        {
            // when it is a leaf node.
            LeafNode* isLeafCurNode = (LeafNode*)curNode;
            do{
                [arr addObject:isLeafCurNode.value];
            }while((isLeafCurNode = isLeafCurNode.nextSibling)!=Nil);
        }else{
            // when it is a patricia node 
            [self findAllValuesAtPNode:(PatriciaNode*)curNode addToArray:arr];
        }
    }
}


-(BOOL)isEntry:(NSString*)index
{
    return NO;
}

-(BOOL)testReturn
{
    return YES;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"[root:%@]",self.root];
}

@end


# pragma mark - Test Part:

@interface StrIndexable : NSObject<StringIndexable>
@property (retain) NSString* name;
@end;

@implementation StrIndexable
NSString* _name;
@synthesize name = _name;
-(id)initWithName:(NSString*) name
{
	if(self = [super init])
	{
		self.name = name;
	}
	return self;
}

-(NSString*) indexString{
	return self.name;
}

-(NSString*) description 
{
	return self.name;
}

@end;

/*
void testPatricia(){
    StrIndexable* idx = [[StrIndexable alloc] initWithName:@"x"];
	NSLog(@"idx:%@",idx);
	Patricia* p = [[Patricia alloc] init];
	[p addStringIndexable:idx withValueId:0];
	[p addStringIndexable:idx withValueId:0];
	idx = [[StrIndexable alloc] initWithName:@"Xd"];
	[p addStringIndexable:idx withValueId:0];
	idx = [[StrIndexable alloc] initWithName:@"Xm"];
    [p addStringIndexable:idx withValueId:0];
    [p addStringIndexable:idx withValueId:0];
    NSArray* arr = [NSArray arrayWithObjects:@"a", @"ab", @"0",@"x@f",@"X$f2",@"x1", @"-", nil];
    for(NSString* str in arr)
    {
        idx = [[StrIndexable alloc] initWithName:str];
        [p addStringIndexable:idx withValueId:0];
    }
    NSLog(@"%@",p);
	NSMutableArray<StringIndexable>* arr2 = [p suggestValuesForIndex:@"x"];
    NSLog(@"%@",arr2);
}

int main(int argc, char *argv[]) { testPatricia();}
 */
