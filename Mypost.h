//
//  Mypost.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/30/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Replies;

@interface Mypost : NSManagedObject

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) Replies *relationship;


+ (instancetype)GenerateMyPost;
@end
