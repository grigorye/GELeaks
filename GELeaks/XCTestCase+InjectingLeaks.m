//
//  XCTestCase+LeaksInjector.m
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

#import <XCTest/XCTest.h>
#import <GELeaks/GELeaks-Swift.h>

@implementation XCTestCase (InjectingLeaks)

+ (void)load {
	[self injectLeaks];
}

@end
