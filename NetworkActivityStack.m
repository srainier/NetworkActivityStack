//
//  NetworkActivityStack.m
//
//  Created by Shane Arney on 11/14/12.
//  Copyright (c) 2012 Shane Arney. All rights reserved.
//

#import "NetworkActivityStack.h"

@interface SRANetworkActivityStack () {
  NSMutableArray* stack_;
}

- (NSUInteger) indexOfContextWithName:(NSString*)contextName;
- (void) refreshNetworkActivityIndicator;

@end

@interface SRANetworkActivityContext : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSMutableSet* activities;

@end

@implementation SRANetworkActivityContext

- (id) initWithName:(NSString*)name {
  self = [super init];
  if (nil != self) {
    _name = name;
    _activities = [[NSMutableSet alloc] init];
  }
  return self;
}

@end

@implementation SRANetworkActivityStack

- (id) init {
  self = [super init];
  if (nil != self) {
    stack_ = [[NSMutableArray alloc] init];
  }
  return self;
}

+ (SRANetworkActivityStack*) defaultStack {
  static dispatch_once_t onceToken;
  static SRANetworkActivityStack* networkActivityStack = nil;
  dispatch_once(&onceToken, ^{
    networkActivityStack = [[SRANetworkActivityStack alloc] init];
  });
  return networkActivityStack;
}

- (void) pushActivityContextWithName:(NSString*)contextName {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (NSNotFound == [self indexOfContextWithName:contextName]) {
      SRANetworkActivityContext* context = [[SRANetworkActivityContext alloc] initWithName:contextName];
      [stack_ addObject:context];
    }
    
    [self refreshNetworkActivityIndicator];
  });
}

- (void) pushActivityContextWithName:(NSString*)contextName withActivityWithName:(NSString *)activityName {
  [self pushActivityContextWithName:contextName];
  [self startActivityWithName:activityName inContext:contextName];
}

- (void) removeActivityContextWithName:(NSString*)contextName {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSUInteger contextIndex = [self indexOfContextWithName:contextName];
    if (NSNotFound != contextIndex) {
      [stack_ removeObjectAtIndex:contextIndex];
    }
    
    [self refreshNetworkActivityIndicator];
  });
}

- (void) startActivityWithName:(NSString*)activityName inContext:(NSString*)contextName {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSUInteger contextIndex = [self indexOfContextWithName:contextName];
    if (NSNotFound != contextIndex) {
      SRANetworkActivityContext* context = [stack_ objectAtIndex:contextIndex];
      [context.activities addObject:activityName];
    }
    
    [self refreshNetworkActivityIndicator];
  });
}

- (void) stopActivityWithName:(NSString*)activityName inContext:(NSString*)contextName {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSUInteger contextIndex = [self indexOfContextWithName:contextName];
    if (NSNotFound != contextIndex) {
      SRANetworkActivityContext* context = [stack_ objectAtIndex:contextIndex];
      [context.activities removeObject:activityName];
    }
    
    [self refreshNetworkActivityIndicator];
  });
}

//
// Helpers
//

- (NSUInteger) indexOfContextWithName:(NSString*)contextName {
  return [stack_ indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return [contextName isEqualToString:[obj name]];
  }];
}

- (void) refreshNetworkActivityIndicator {
  if (0 < stack_.count) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(0 < [[[stack_ lastObject] activities] count])];
  } else {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }
}

@end
