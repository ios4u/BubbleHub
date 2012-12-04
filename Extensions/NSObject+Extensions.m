//
//  NSObject+Extensions.m
//  iPeru
//
//  Created by Pietro Rea on 8/28/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)

- (NSObject *)valueOrNil {
    if ([self isKindOfClass:[NSNull class]])
        return nil;
    else
        return self;
}

@end
