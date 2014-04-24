//
//  Replies.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/23/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Replies : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * postsurl;
@property (nonatomic, retain) NSString * messageurl;

@end
