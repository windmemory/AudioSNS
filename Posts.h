//
//  Posts.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/23/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Posts : NSManagedObject

@property (nonatomic, retain) NSString * authorname;
@property (nonatomic, retain) NSString * posturl;

@end
