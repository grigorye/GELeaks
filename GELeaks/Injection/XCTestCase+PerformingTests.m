//
//  XCTestCase+PerformingTests.m
//  Pods
//
//  Created by Grigorii Entin on 12/24/18.
//

#import "XCTestCase+PerformingTests.h"

@implementation XCTestCase (PerformingTests)

+ (instancetype)nonLeakingTestWithSelector:(SEL)selector;
{
#if 1
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
	invocation.selector = selector;
	
	XCTestCase *test = [[self alloc] initWithInvocation:invocation];
#else
	// –initWithSelector: leaks, -initWithInvocation: doesn't.
	XCTestCase *test = [[self alloc] initWithSelector:selector];
#endif

	return test;
}

@end
