//
//  Patricia.m
//  MyContact2
//
//  Created by VMware Inc. on 6/12/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//


#import "Patricia.h"
#import "StringIndexable.h"

#pragma mark - SectionInfo protocol

@interface PatriciaFetchedResultsSectionInfo : NSObject<NSFetchedResultsSectionInfo>

{
    NSString* _name;
    NSString* _indexTitle;
    NSUInteger _numberOfObjects;
    NSArray* _objects;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSUInteger numberOfObjects;
@property (nonatomic, readwrite) NSArray *objects;
@end

@implementation PatriciaFetchedResultsSectionInfo
@synthesize name = _name;
@synthesize indexTitle = _indexTitle;
@synthesize numberOfObjects = _numberOfObjects;
@synthesize objects =_objects;

-(id) initWithName:(NSString*) name
        andObjects:(NSArray*) objects
{
    if(self =[super init])
    {
        _name = name;
        _indexTitle = name;
        _objects = objects;
        _numberOfObjects = [objects count];
    }
    return self;
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"PFSectionInfo:[%@,%@]",_name,_objects];
}

-(void)setObjects:(NSArray*)objects
{
    _objects = objects;
    _numberOfObjects = [objects count];
}

@end


#pragma mark - Nodes definition
#pragma mark - BaseNode definition

@interface BaseNode : NSObject@end;
@implementation BaseNode @end;

#pragma mark - PatirciaNode definition

@interface PatriciaNode : BaseNode
{
    NSMutableDictionary* _baseDict;
}
@property (retain, nonatomic) NSMutableDictionary* baseDict;
-(BaseNode*) nodeForKey:(NSInteger)key;
-(void) setNodeAtKey: (NSInteger)key 
            withNode:(BaseNode*) node;
@end;

@implementation PatriciaNode

@synthesize baseDict = _baseDict;

-(NSDictionary*)baseDict
{
    if(!_baseDict)
    {
        _baseDict = [NSMutableDictionary
                     dictionaryWithCapacity:__initCapacity];
    }
    return _baseDict;
}

-(void) setNodeAtKey:(NSInteger)key
            withNode:(BaseNode*)node
{
    if(!node)
    {
        [self.baseDict setObject:[NSNull null] forKey:[NSNumber numberWithInt:key]];
    }else{
        [self.baseDict setObject:node forKey:[NSNumber numberWithInt:key]];
    }
}

-(BaseNode*) nodeForKey:(NSInteger)key
{
    BaseNode* node = [self.baseDict objectForKey:[NSNumber numberWithInt: key]];
    if([node isEqual:[NSNull null]])
    {
        node = nil;
    }
    return node;
       
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"PNode[%@]",self.baseDict];
}

-(void)dealloc
{
    _baseDict = nil;
}

@end;

#pragma mark - LeafNode definition

/** The leaf node stores the data */
@interface LeafNode : BaseNode
{
    NSObject* _value;
    NSInteger _valueId;
    LeafNode* _nextSibling;
    NSString* _indexString;
}
@property NSInteger valueId;// The unique id to identify the value if multiple exists.
@property (retain) NSObject* value;
@property (retain) LeafNode* nextSibling;// Used to store the next object with the same Index value
@property (retain) NSString* indexString;
@end;

@implementation LeafNode

@synthesize value = _value;
@synthesize valueId = _valueId;
@synthesize nextSibling = _nextSibling;
@synthesize indexString = _indexString;

-(id)initWithValue:(NSObject*) value 
        andValueId:(NSInteger)valueId
    andIndexString:indexString
{
    if(self = [super init])
    {
        _value = value;
        _valueId = valueId;
        _nextSibling = Nil;
        _indexString = indexString;
    }
    return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"LNode[%@,id:%d, next:%@]",self.value,self.valueId, self.nextSibling];
}

-(void)dealloc
{
    _value = nil;
    _nextSibling = nil;
    _indexString = nil;
}

@end;

#pragma mark - Patricia Tree implementation


@interface Patricia()
{
    PatriciaNode* _root;
}
@property (retain, nonatomic) PatriciaNode* root;

-(NSInteger)getIndexKeyVal:(char)key;

-(void) findAllValuesAtNode:(BaseNode*) root
                  addToArray:(NSMutableArray*) arr;

-(BOOL)insertLeafNodeAtNode:(LeafNode*)oldLeafNode
                       withNewLeaf:(LeafNode*) newLeafNode;

-(void)addUniqueToArray:(NSMutableArray*)arr withValue:(NSObject*)value;

-(void) suggestValuesForIndex:(NSString*)index 
                   withOffset:(NSInteger)offset
                      AtPNode:(PatriciaNode*) root
                   addToArray:(NSMutableArray*)arr;

-(void)clearPatriciaNode:(PatriciaNode*)pNode;

-(void)clearLeafNode:(LeafNode*)lNode;

@end;

@implementation Patricia
@synthesize size = _size;
@synthesize root = _root;

-(void)dealloc
{
    _root = nil;
}

-(id) init
{
    if(self = [super init])
    {
        _root = nil;
        _size = 0;
    }
    return self;
}

-(PatriciaNode*)root
{
    if(!_root)
    {
        _root = [[PatriciaNode alloc] init];
    }
    return _root;
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
    NSString* index = [indexString uppercaseString];
    NSInteger newIndexLength = [index length];
    
    if(!index) {        return;    }
    
    LeafNode* newLeaf = [[LeafNode alloc]initWithValue:value andValueId:valueId andIndexString:indexString];
    PatriciaNode *p = self.root;
    
    for(NSInteger i = 0;;)
    {

        // when reached the end of word, just put it on the first node
        if(i == newIndexLength)
        {
            LeafNode* oldLeaf = (LeafNode*)[p nodeForKey:__sharpKey];
            // the oldLeaf pointer's value may be changed if it is nil.
            [self insertLeafNodeAtNode:oldLeaf withNewLeaf:newLeaf];
            [p setNodeAtKey:__sharpKey withNode:oldLeaf];
            // if no exceptions, the value is due to be inserted.
            ++self.size;
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
            // if no exceptions, the value is due to be inserted.
            ++self.size;
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
        NSString* oldIndex = [oldLeaf.indexString uppercaseString];
        NSInteger oldIndexLength = [oldIndex length];
        NSInteger oldKey = 0;
        // duplicated indexes
        // NSLog(@"oldi:%@,newi:%@",oldIndex,index);
        if([oldIndex isEqualToString:index])
        {
            if([self insertLeafNodeAtNode:oldLeaf withNewLeaf:newLeaf])
            {
                ++self.size;
            }
            return;
        }
        
        // since the slash should be ignored, actually need two pointers.
        NSInteger oi = i;
        NSInteger ni = i;
        
        do{
           //  NSLog(@"(o:%d:%@:%d)/(n:%d:%@:%d)",oi, oldIndex,oldKey,ni,index,newKey);
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
        // like h-1 is old and h1 is new....
        if(oi>=oldIndexLength&&ni>=newIndexLength)
        {
            break;
        }
        }while(oldKey == newKey);
        
        // the 3rd situation, strings should be like:
        // new: aret*
        // old: aref*
        // p->are, so put aret at p[t], and put aref at p[f]
        // i is pointing to t/f
        
        [p setNodeAtKey:newKey withNode:newLeaf];
        [p setNodeAtKey:oldKey withNode:oldLeaf];
        // if no exceptions, the value is due to be inserted.
        ++self.size;
        return;
    }
    // set end of word marker to p
}

-(BOOL)insertLeafNodeAtNode:(LeafNode*)oldLeafNode 
                       withNewLeaf:(LeafNode*) newLeafNode
{

    if([oldLeafNode.value isEqual:newLeafNode.value]){
        return NO;
    }
    
    // here strictly assume no loop, and no siblings means nil.
    while(oldLeafNode.nextSibling!=Nil)
        oldLeafNode = oldLeafNode.nextSibling;
    oldLeafNode.nextSibling = newLeafNode;
    return YES;
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
    if(key<='Z' && key>='A')
        return key - 'A' + 1 + 10;
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

    // lower case not supported.
    if(!__ignoreCase)
        abort();
    index = [index uppercaseString];
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
                    [self findAllValuesAtNode:curNode addToArray:arr];
                    break;
                }
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

-(void) findAllValuesAtNode:(BaseNode*) root
                 addToArray:(NSMutableArray*) arr
{
    if(!root)
        return;
    if([root isKindOfClass:[LeafNode class]])
    {
        // when it is a leaf node.
        LeafNode* isLeafCurNode = (LeafNode*)root;
        do{
            // NSLog(@"%@",isLeafCurNode);
            [self addUniqueToArray:arr withValue:isLeafCurNode.value];
        }while((isLeafCurNode = isLeafCurNode.nextSibling));
    }else if([root isKindOfClass:[PatriciaNode class]]){
        // when it is a patricia node 
        NSInteger start = __keyLowerBound;
        NSInteger end = __keyUpperBound;
        PatriciaNode* isPatriciaNode = (PatriciaNode*)root;
        for(NSInteger i = start;i<=end;i++)
        {
            [self findAllValuesAtNode:[isPatriciaNode nodeForKey:i] addToArray:arr];
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

-(void)clearLeafNode:(LeafNode*)lNode
{
    LeafNode* curNode = lNode;
    while(curNode)
    {
        LeafNode* temp = curNode.nextSibling;
        curNode.nextSibling = nil;
        curNode.value = nil;
        curNode.indexString = nil;
        curNode = temp;
    }
}

-(void)clearPatriciaNode:(PatriciaNode*)pNode
{
    NSInteger begin = __keyLowerBound;
    NSInteger end = __keyUpperBound + 1;
    for(NSInteger i = begin ; i <= end ; i++)
    {
        BaseNode* childNode = [pNode nodeForKey:i];
        if([childNode isKindOfClass:[PatriciaNode class]])
        {
            [self clearPatriciaNode:(PatriciaNode*)childNode];
        }
        else if([childNode isKindOfClass:[LeafNode class]])
        {
            [self clearLeafNode:(LeafNode*)childNode];
        }
    }
}



-(void)clear
{
    _size = 0;
    [self clearPatriciaNode:self.root];
}

-(NSArray*) findAllValues
{
    NSMutableArray* marr = [[NSMutableArray alloc] initWithCapacity:self.size];
    [self findAllValuesAtNode:self.root addToArray:marr];
    return [NSArray arrayWithArray:marr];
}


// the section header is the initial of the index
// this method is designed to work only with displayNameInitial
-(NSArray*) findAllValuesWithResultsSectionInfos:(NSMutableArray **)sectionInfos andHeaderTitles:(NSMutableArray **)headerTitles
{
    NSInteger begin = __keyLowerBound;
    NSInteger end = __keyUpperBound;
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:_size];
    NSMutableArray* sectInfos = [NSMutableArray arrayWithCapacity:27];
    NSMutableArray* hdrTitls = [NSMutableArray arrayWithCapacity:27];
    //used to store the values with the sharp key
    NSMutableArray* sharpObjects = [NSMutableArray arrayWithCapacity:10];

    for(NSInteger i = begin ; i <= end ; i++)
    {
        BaseNode* childNode = [self.root nodeForKey:i];
        if(childNode==nil)
            continue;
        
        char ch = 0;
        NSMutableArray* objects;
        PatriciaFetchedResultsSectionInfo *sectInfo;

        
        if(i<11||i>=37)
        {
            ch = 'Z'+1;
            objects = sharpObjects;
            [self findAllValuesAtNode:childNode addToArray:objects];
            
        }else{
            ch = i-11+'A';
            sectInfo = [[PatriciaFetchedResultsSectionInfo alloc] initWithName:[NSString stringWithFormat:@"%c",ch] andObjects:nil];
            objects = [NSMutableArray arrayWithCapacity:10];
            [self findAllValuesAtNode:childNode addToArray:objects];
            if([objects count]){
                [hdrTitls addObject:[NSString stringWithFormat:@"%c",ch]];
            }
            [results addObjectsFromArray:objects];
            sectInfo.objects = [NSArray arrayWithArray:objects];
            [sectInfos addObject:sectInfo];
        }   
    }
    if([sharpObjects count]){
        [results addObjectsFromArray:sharpObjects];
        PatriciaFetchedResultsSectionInfo* sharpSectionInfo = [[PatriciaFetchedResultsSectionInfo alloc] initWithName:@"#" andObjects:[NSArray arrayWithArray:sharpObjects]];
        [sectInfos addObject:sharpSectionInfo];
        [hdrTitls addObject:@"#"];
    }
    
    *sectionInfos = sectInfos;
    *headerTitles = hdrTitls;
    return [NSArray arrayWithArray:results];
}

@end

/*

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
	NSArray* arr2 = [p suggestValuesForIndex:@"xi--"];
    NSLog(@"%@",arr2);
    // size may not be same with the 
    NSLog(@"%@",p.findAllValues);
    NSLog(@"%ld:%d:%lu",p.size,p.findAllValues.count==p.size,[p.findAllValues count]);
    NSMutableArray* infoArr = nil;
    NSArray* results = [p findAllValuesWithResultsSectionInfos:&infoArr];
    NSLog(@"results again:%@",results);
    NSLog(@"infos:%@",infoArr);

}

int main(int argc, char *argv[]) { testPatricia();}
*/
