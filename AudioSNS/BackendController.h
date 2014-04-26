//
//  BackendController.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/21/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "TDSingletonCoreDataManager.h"

@class Posts;

@interface BackendController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
- (IBAction)Record:(id)sender;
- (IBAction)Stop:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext *context;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UITableView *AudioTable;
@property (nonatomic) NSUserDefaults *defaults;
@property (weak, nonatomic) IBOutlet UITextField *NameBox;


@end