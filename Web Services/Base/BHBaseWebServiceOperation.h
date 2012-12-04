//
//  TPBaseWebServiceOperation.h
//  iPeru
//
//  Created by Pietro Rea on 8/26/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHBaseWebServiceOperation : NSOperation


- (void)startAsynchronous;
- (void)setSuccessBlock:(void(^)(id result))successBlock failureBlock:(void(^)(void))failureBlock;

@property (assign, nonatomic) BOOL isFinished;
@property (assign, nonatomic) BOOL isExecuting;
@property (assign, nonatomic) BOOL isCancelled;
@property (strong, nonatomic) id result;
@property (copy, nonatomic) void(^successBlock)(id result);
@property (copy, nonatomic) void(^failureBlock)(void);

- (void)performOperation; // Override in subclass
- (void)performSuccess;
- (void)performFailure;

@end


