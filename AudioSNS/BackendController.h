//
//  BackendController.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/21/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BackendController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)Record:(id)sender;
- (IBAction)Stop:(id)sender;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UITableView *AudioTable;


@end
