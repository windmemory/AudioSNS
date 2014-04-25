//
//  Replies.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/24/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Posts;

@interface Replies : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) id messageurl;
@property (nonatomic, retain) id postsurl;
@property (nonatomic, retain) Posts *replyofpost;

@end
