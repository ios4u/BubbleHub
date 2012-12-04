//
//  TPBaseWebServiceOperation.m
//  iPeru
//
//  Created by Pietro Rea on 8/26/12.
//  Copyright (c) 2012 Pietro Rea. All rights reserved.
//

#import "BHBaseWebServiceOperation.h"

#define operation_timeout 90

@interface  BHBaseWebServiceOperation()

@property (strong, nonatomic) NSDate* startTime;
@property (strong, nonatomic) NSDate* endTime;

@end

@implementation BHBaseWebServiceOperation


static NSOperationQueue* sharedQueue = nil;
+ (NSOperationQueue*)sharedQueue {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
        sharedQueue.maxConcurrentOperationCount = 10;
    });
    
    return sharedQueue;
}

- (void)startAsynchronous {
    [[BHBaseWebServiceOperation sharedQueue] addOperation:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - NSOperation Overrides

- (void)start {
    if (self.isCancelled) {
        self.isExecuting = NO;
        self.isFinished = YES;
        return;
    }
    
    self.startTime = [NSDate date];
    debugLog(@"%@ - Start %@", self, self.startTime);
    
    self.isFinished = NO;
    self.isExecuting = YES;
    
    [self performOperation];
    
    // Operation timeout - kill the operation if it takes too long
    [NSTimer scheduledTimerWithTimeInterval:operation_timeout
                                     target:self
                                   selector:@selector(cancel)
                                   userInfo:nil
                                    repeats:NO];
}

#pragma mark - NSOperation base implementation

- (void)setIsFinished:(BOOL)isFinished {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setIsExecuting:(BOOL)isExecuting {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsCancelled:(BOOL)isCancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _isCancelled = isCancelled;
    [self didChangeValueForKey:@"isCancelled"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark - Overrides

- (void)performOperation {
    // Override
}

- (void)performSuccess {
    self.endTime = [NSDate date];
    debugLog(@"%@ completed in %f seconds", self, [self.endTime timeIntervalSinceDate:self.startTime]);
    
    if (self.successBlock && !self.isCancelled) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.successBlock(self.result);
        });
    }
    
    self.isExecuting = NO;
    self.isFinished = YES;
    debugLog(@"%@ - Finished, Success", self);
}

- (void)performFailure {
    if (self.failureBlock) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.failureBlock();
        });
    }
    
    self.isExecuting = NO;
    self.isFinished = YES;
    debugLog(@"%@ - Finished, Failure", self);
}

- (void)setCompletionBlock:(void (^)(void))block {
    [NSException raise:@"Invalid method" format:@"Please use setSuccessBlock: instead"];
}

#pragma mark - Other

- (void)cancel {
    debugLog(@"Cancelling web operation %@", NSStringFromClass([self class]));
    
    self.isCancelled = YES;
    
    // Unfortunately, NSOperation will throw an error if isFinished is set before start is called.
    if (self.isExecuting) {
        self.isFinished = YES;
    }
    
    self.isExecuting = NO;
}

#pragma mark - Property Overrides

- (void)setSuccessBlock:(void(^)(id result))successBlock failureBlock:(void(^)(void))failureBlock {
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
}

#pragma mark - Memory Management

- (void)dealloc {
    debugLog(@"%@ - dealloc", self);
}

@end
