//
//  DummyObjCTests.m
//  Pods
//
//  Created by Grigorii Entin on 12/25/18.
//

#import <XCTest/XCTest.h>

@interface DummyObjCProperty : NSObject
@end

@interface DummyObjCTests : XCTestCase

@property (strong, nonatomic) DummyObjCProperty *dummyProperty;
@end

@implementation DummyObjCTests

- (instancetype)init;
{
	return [super init];
}

- (instancetype)initWithSelector:(SEL)selector;
{
	return [super initWithSelector:selector];
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation;
{
	return [super initWithInvocation:invocation];
}

- (void)dealloc;
{}

- (void)testDummy;
{
	self.dummyProperty = [DummyObjCProperty new];
}

@end

@implementation DummyObjCProperty

- (instancetype)init
{
	return [super init];
}

- (void)dealloc;
{}

@end
