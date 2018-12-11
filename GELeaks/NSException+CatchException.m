//
//  NSException+CatchException.m
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//

#import "NSException+CatchException.h"

@implementation NSException (CatchException)

+ (NSException *)catchException:(void (^)(void))block;
{
    @try {
        block();
    } @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

@end
