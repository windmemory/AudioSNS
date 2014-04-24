//
//  BackendController.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/21/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "BackendController.h"

@interface BackendController ()
@end

@implementation BackendController

@synthesize recorder;
@synthesize player;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record.caf",[[NSBundle mainBundle] resourcePath]]];
    
    NSURL *soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"SF1" ofType:@"mp3"]];
    
    SystemSoundID SF1;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &SF1);
    AudioServicesAddSystemSoundCompletion(SF1, NULL, NULL, finishPlaySoundCallBack, NULL);
    AudioServicesPlaySystemSound(SF1);
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    
    if (error != nil) {
        NSLog(@"Init recorder error: %@",error);
    }
    else if([self.recorder prepareToRecord]){
        NSLog(@"Prepared successful");
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}



- (IBAction)Record:(id)sender {
    
    NSLog(@"record");
    
    if (!self.recorder.recording) {
        [self.recorder record];
    }
    
}

- (IBAction)Stop:(id)sender {
    NSLog(@"stop");
    if (self.recorder.recording) {
        [self.recorder stop];
    }
    
}

void finishPlaySoundCallBack(SystemSoundID sound_id, void *user_data){
    NSLog(@"finish playing");
}



@end
