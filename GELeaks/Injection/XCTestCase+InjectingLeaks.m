//
//  XCTestCase+LeaksInjector.m
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

#import "GELeaks-Swift.h"
#import <JRSwizzle/JRSwizzle.h>
#import <XCTest/XCTest.h>

@implementation XCTestCase (InjectingLeaks)

+ (void)load {
	[self injectLeaks];
}

+ (void)injectDefaultTestSuite;
{
	NSError *error;
	BOOL succeeded = [self jr_swizzleClassMethod:@selector(defaultTestSuite) withClassMethod:@selector(leaksEnabledDefaultTestSuite) error:&error];
	if (!succeeded) {
		NSAssert(NO, @"%@", error);
		abort();
	}
}

+ (void)injectWaitForExpectations;
{
	NSError *error;
	
	BOOL succeeded = [self jr_swizzleMethod:@selector(waitForExpectations:timeout:) withMethod:@selector(leaksEnabledWaitForExpectations:timeout:) error:&error];
	if (!succeeded) {
		NSAssert(NO, @"%@", error);
		abort();
	}
}

@end

@implementation XCTestSuite (InjectingLeaks)

+ (void)load {
	[self injectLeaks];
}

+ (void)injectTestSuiteForTestCaseWithName;
{
	NSError *error;
	BOOL succeeded = [self jr_swizzleClassMethod:@selector(testSuiteForTestCaseWithName:) withClassMethod:@selector(leaksEnabledTestSuiteForTestCaseWithName:) error:&error];
	if (!succeeded) {
		NSAssert(NO, @"%@", error);
		abort();
	}
}

@end
