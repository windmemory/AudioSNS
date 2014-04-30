//
//  Replies.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/30/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "Replies.h"
#import "Posts.h"
#import "TDSingletonCoreDataManager.h"

@implementation Replies

@dynamic author;
@dynamic messageurl;
@dynamic postsurl;
@dynamic replyofpost;
@dynamic replytomypost;

+ (instancetype)GenerateNewReply
{
    NSManagedObjectContext *context = [TDSingletonCoreDataManager getManagedObjectContext];
    Replies *reply = [NSEntityDescription insertNewObjectForEntityForName:@"Replies"
                                                 inManagedObjectContext:context];
    return reply;
}

@end
