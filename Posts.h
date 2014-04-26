//
//  Posts.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/24/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Replies;

@interface Posts : NSManagedObject

@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSURL *posturl;
@property (nonatomic, retain) NSSet *postofreply;
@end

@interface Posts (CoreDataGeneratedAccessors)

- (void)addPostofreplyObject:(Replies *)value;
- (void)removePostofreplyObject:(Replies *)value;
- (void)addPostofreply:(NSSet *)values;
- (void)removePostofreply:(NSSet *)values;
+ (instancetype)userWithRawDictionary;

@end
