//
//  NSException+CatchException.h
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (CatchException)

+ (NSException * _Nullable)catchException:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
