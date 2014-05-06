//
//  MypostController.h
//  AudioSNS
//
//  Created by Gao Yuan on 5/5/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MypostController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) AVAudioPlayer *player;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSUserDefaults *defaults;


@property (strong, nonatomic) IBOutlet UITableView *mypostTable;
@property (strong, nonatomic) IBOutlet UITextField *nameBox;
- (IBAction)startRecord:(id)sender;
- (IBAction)stopRecord:(id)sender;

@end
