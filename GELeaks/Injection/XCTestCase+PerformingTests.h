//
//  XCTestCase+PerformingTests.h
//  Pods
//
//  Created by Grigorii Entin on 12/24/18.
//

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (PerformingTests)

+ (instancetype)nonLeakingTestWithSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
