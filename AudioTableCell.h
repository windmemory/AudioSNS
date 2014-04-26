//
//  AudioTableCell.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/24/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Postsname;
@property (weak, nonatomic) IBOutlet UILabel *AudioFileName;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;



@end
