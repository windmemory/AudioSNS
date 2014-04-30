//
//  Mypost.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/30/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "Mypost.h"
#import "Replies.h"
#import "TDSingletonCoreDataManager.h"

@implementation Mypost

@dynamic url;
@dynamic relationship;

+ (instancetype)GenerateMyPost
{
    NSManagedObjectContext *context = [TDSingletonCoreDataManager getManagedObjectContext];
    Mypost *posts = [NSEntityDescription insertNewObjectForEntityForName:@"MyPosts"
                                                 inManagedObjectContext:context];
    return posts;
}

@end
