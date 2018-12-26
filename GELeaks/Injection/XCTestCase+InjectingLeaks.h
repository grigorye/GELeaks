//
//  XCTestCase+LeaksInjector.m
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

#import <XCTest/XCTest.h>

@interface XCTestCase (InjectingLeaks)

+ (void)injectDefaultTestSuite;
+ (void)injectWaitForExpectations;

@end

@interface XCTestSuite (InjectingLeaks)

+ (void)injectTestSuiteForTestCaseWithName;

@end
