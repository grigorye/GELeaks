//
//  LeaksSwizzledTestCaseInjector.m
//  LeaksTests
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCTestCase (LeaksSwizzledTestCaseInjectorForwarding)

+ (void)swizzleInvokeTest;
+ (void)swizzleLeaksFromInitialize;

@end

@implementation XCTestCase (LeaksSwizzledTestCaseInjector)

+ (void)load {
    //[XCTestCase swizzleInvokeTest];
}

+ (void)initialize {
    [super initialize];
    //[XCTestCase swizzleLeaksFromInitialize];
}

@end
