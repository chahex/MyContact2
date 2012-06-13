//
//  MyContact2Tests.m
//  MyContact2Tests
//
//  Created by Xinkai HE on 6/3/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import "MyContact2Tests.h"

@implementation MyContact2Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    // STFail(@"Unit tests are not implemented yet in MyContact2Tests");
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:3];
    // arr = [arr initWithCapacity:3];
    
    STAssertEquals(3, [arr count], @"count is not 3");
}

@end
