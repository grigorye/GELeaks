//
//  XCTestCase+LeaksInjector.m
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

#import <XCTest/XCTest.h>
#import <GELeaks/GELeaks-Swift.h>
#import <objc/runtime.h>

@implementation XCTestCase (InjectingLeaks)

+ (void)load {
	[self injectLeaks];
}

@end

@implementation XCTestSuite (InjectingLeaks)

+ (void)load {
	[self injectLeaks];
}

+ (void)injectTestSuiteForTestCaseWithName;
{
	Method oldMethod = class_getClassMethod(self, @selector(testSuiteForTestCaseWithName:));
	Method newMethod = class_getClassMethod(self, @selector(leaksEnabledTestSuiteForTestCaseWithName:));
	method_exchangeImplementations(oldMethod, newMethod);
}

@end
