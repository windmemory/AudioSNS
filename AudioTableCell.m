//
//  AudioTableCell.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/24/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "AudioTableCell.h"
#import <AVFoundation/AVFoundation.h>
@implementation AudioTableCell

@synthesize PlayButton;
@synthesize Postsname;
@synthesize AudioFileName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
