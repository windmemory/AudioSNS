//
//  Posts.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/24/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "Posts.h"
#import "Replies.h"
#import "TDSingletonCoreDataManager.h"

@implementation Posts

@dynamic authorname;
@dynamic posturl;
@dynamic postofreply;

+ (instancetype)userWithRawDictionary
{
    NSManagedObjectContext *context = [TDSingletonCoreDataManager getManagedObjectContext];
    Posts *posts = [NSEntityDescription insertNewObjectForEntityForName:@"Posts"
                                                 inManagedObjectContext:context];
    return posts;
}

@end
