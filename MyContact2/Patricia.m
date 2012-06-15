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
@property NSObject* value;
// The unique id to identify the value if multiple exists.
@property NSInteger valueId;
@property NSString* indexString;
@end;

@implementation LeafNode
{
    LeafNode* _nextSibling;
    NSObject* _value;
    NSInteger _valueId;
    NSString* _indexString;
}
@synthesize nextSibling = _nextSibling;
@synthesize value = _value;
@synthesize valueId = _valueId;
@synthesize indexString = _indexString;

-(id)initWithValue:(NSObject*) value 
        andValueId:(NSInteger)valueId
    andIndexString:indexString
{
    if(self = [super init])
    {
        self.nextSibling = Nil;
        self.value = value;
        self.valueId = valueId;
        self.indexString = indexString;
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

-(void)addStringIndexable:(NSObject<StringIndexable>*) value
              withValueId:(NSInteger) valueId
{
    NSString* index = value.indexString;
    [self addValue:value withIndexString:index andValueId:valueId];
}

// the following methods are added on June 14 to improve flexibility
// on how to index on the object
-(void)addValue:(NSObject*)value 
withIndexSelector:(SEL)indexSel 
     andValueId:(NSInteger)valueId
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString* index = [value performSelector:indexSel];
    #pragma clang diagnostic pop
    [self addValue:value withIndexString:index andValueId:valueId];
}

-(void)addValues:(NSArray*) objArray withIndexSelector:(SEL)indexSel;
{
    NSInteger i = 0;
    for(NSObject* value in objArray)
    {
        [self addValue:value withIndexSelector:indexSel andValueId:i++];
    }
}

-(void)addValue:(NSObject*) value
withIndexString:(NSString*) indexString 
     andValueId:(NSInteger) valueId
{
    if(!__ignoreCase){
        // not supported case sensitivie.
        abort();
    }
    NSString* index = [indexString lowercaseString];
    NSInteger newIndexLength = [index length];
    
    if(!index) {        return;    }
    
    LeafNode* newLeaf = [[LeafNode alloc]initWithValue:value andValueId:valueId andIndexString:indexString];
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
#line 122
        // 
        // meet with slash key, that should be ignored.
        if(newKey==__slashKey)
        {
            if(i==newIndexLength-1)
            {
                newKey = __otherKey;
            }
            else{
                ++i;
                continue;
            }
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
        NSString* oldIndex = [oldLeaf.indexString lowercaseString];
        NSInteger oldIndexLength = [oldIndex length];
        NSInteger oldKey = 0;
        // duplicated indexes
        // NSLog(@"oldi:%@,newi:%@",oldIndex,index);
        if([oldIndex isEqualToString:index])
        {
            [self insertLeafNodeAtNodePointer:&oldLeaf withNewLeaf:newLeaf];
            return;
        }
        
        // since the slash should be ignored, actually need two pointers.
        NSInteger oi = i;
        NSInteger ni = i;
        
        do{
            // NSLog(@"(o:%d:%@:%d)/(n:%d:%@:%d)",oi, oldIndex,oldKey,ni,index,newKey);
            PatriciaNode* tmpNode = [[PatriciaNode alloc] init];
            [p setNodeAtKey:newKey withNode:tmpNode];
            p = tmpNode;
            ++oi;
            ++ni;
            // if the strings are like:
            // new: are
            // old: area
            if(ni>=newIndexLength)
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
                for(;;)
                {
                    newKey = [self getIndexKeyVal:[index characterAtIndex:ni]];
                    // NSLog(@"%@ni:d",ni);
                    if(newKey!=__slashKey)
                    {
                        break;
                    }
                    else
                    {
                        // NSLog(@"slash found in new key.");
                        if(++ni>=newIndexLength)
                        {
                            // NSLog(@"new key set to other key.");
                            newKey = __otherKey;
                            break;
                        }
                    }
                }
                // NSLog(@"new key is:%d after loop.",newKey);
            }
            
            // the strings are like:
            // new: area
            // old: are
            // now, p->are, so put area at p[a], and put are at p[#]
            if(oi>=oldIndexLength)
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
                for(;;)
                {
                    // NSLog(@"%@oi:d",oi);
                    oldKey = [self getIndexKeyVal:[oldIndex characterAtIndex:oi]];;
                    // NSLog(@"oldKey:%d",oldKey);
                    if(oldKey!=__slashKey)
                    {
                        break;
                    }
                    else
                    {
                        if(++oi>=oldIndexLength)
                        {
                            oldKey = __otherKey;
                            break;
                        }
                    }
                }

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

// side effect: the pointer passed in may be pointed to a new LeafNode if it is originally Nil..
// if it is not Nil, the newLeafNode will be attached to the siblings.
// if the value in the old leaf is equal to the value in the new leaf, simpley return without adding it.

-(void)insertLeafNodeAtNodePointer:(LeafNode**)oldLeafPointer
               withNewLeaf:(LeafNode*) newLeafNode
{

    LeafNode* oldLeafNode = *oldLeafPointer;
    if([oldLeafNode.value isEqual:newLeafNode.value]){
        return;
    }
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
 * Notice, the return value should be consistent with the constants defined in the header file.
 * 
 *
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
        return __slashKey;
    // otherwise treat as same thing.
    return __otherKey;
}

-(NSObject*)removeAtStringIndex:(NSString*)index
                                     withValueId:(NSInteger)valueId
{
    return Nil;
}

-(NSArray*) suggestValuesForIndex:(NSString*)index
{
    // go looking for the values there
    // from the root
    // if the node is Patricia Node, iterate through all the sub nodes, should use recursive call?
    // if the node is leaf node, just return its stroe values
    // the returned values should be ordered.
    
    // the order can be guranteed by two ways,
    //      1. simpley iterate the key from __keyLowerBound to __keyUperBound.
    //      2. get all keys from the map, order the keys.
    // as for the interface of 
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:self.size];

    [self suggestValuesForIndex:index
                     withOffset:0 
                        AtPNode:self.root
                     addToArray:arr];
    return [NSArray arrayWithArray: arr];
}

-(void) suggestValuesForIndex:(NSString*)index 
                   withOffset:(NSInteger)offset
                      AtPNode:(PatriciaNode*) root
                   addToArray:(NSMutableArray*)arr
{

    NSInteger indexLength = [index length];
    NSInteger curOffset = offset;
    NSInteger curKey = 0;
    BaseNode* curNode = root;
   
    
    
    for(;curOffset<indexLength;curOffset++)
    {
        if(!curNode)
            return;
        if([curNode isKindOfClass:[PatriciaNode class]])
        {
            curKey = [self getIndexKeyVal:[index characterAtIndex:curOffset]];
            if(curOffset<indexLength-1)
            {
                // special treat on slash key, ignore it
                if(curKey==__slashKey)
                {
                    continue;
                }
                curNode = [((PatriciaNode*)curNode) nodeForKey:curKey];
                continue;
            }else if(curOffset==indexLength-1){
                // curNode is patricia node, and the offset==indexLength-1
                // if not slashKey, just go to 
                if(curKey!=__slashKey)
                {
                    curNode = [((PatriciaNode*)curNode) nodeForKey:curKey];
                }
                if([curNode isKindOfClass:[PatriciaNode class]])
                {
                    [self findAllValuesAtPNode:(PatriciaNode*)curNode addToArray:arr];
                    break;
                }
                // if the 
            }
        }
        
        
        // when is a leafNode, just return the value on it.
        LeafNode* leafNode = (LeafNode*)curNode;
        do{
            [self addUniqueToArray:arr withValue:leafNode.value];
        }while((leafNode = leafNode.nextSibling));
        break;
    }
}

// helper method that only add to the array when the array does not contain the object
-(void)addUniqueToArray:(NSMutableArray*)arr withValue:(NSObject*)value
{
    // guarantee the nil value not inserted into the array.
    if(!value)
        return;
    if(![arr containsObject:value])
    {
        [arr addObject:value];
    }
}

/**The range of this */

-(void) findAllValuesAtPNode:(PatriciaNode*) root
                 addToArray:(NSMutableArray*) arr
{
    if(!root)
        return;
    
    NSInteger start = __keyLowerBound;
    NSInteger end = __keyUpperBound;
    
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
                [self addUniqueToArray:arr withValue:isLeafCurNode.value];
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
/**

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
    NSArray* arr = [NSArray arrayWithObjects:@"a",@"xiao",@"xi-o", @"ab", @"0",@"x@f",@"x-1",@"x-3",@"X$f2",@"x1",@"x-1",@"x-2",@"x2", @"-",@"x-a", nil];
    for(NSString* str in arr)
    {
        idx = [[StrIndexable alloc] initWithName:str];
        [p addValue:idx withIndexSelector:@selector(indexString) andValueId:0];
    }
    NSLog(@"%@",p);
	NSMutableArray* arr2 = [p suggestValuesForIndex:@"xi--"];
    NSLog(@"%@",arr2);
}

int main(int argc, char *argv[]) { testPatricia();}
*/
