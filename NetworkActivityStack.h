//
//  NetworkActivityStack.h
//
//  Created by Shane Arney on 11/14/12.
//  Copyright (c) 2012 Shane Arney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRANetworkActivityStack : NSObject

+ (SRANetworkActivityStack*) defaultStack;

- (void) pushActivityContextWithName:(NSString*)contextName;
- (void) pushActivityContextWithName:(NSString*)contextName withActivityWithName:(NSString *)activityName;
- (void) removeActivityContextWithName:(NSString*)contextName;

- (void) startActivityWithName:(NSString*)activityName inContext:(NSString*)contextName;
- (void) stopActivityWithName:(NSString*)activityName inContext:(NSString*)contextName;

@end
