//
//  BackendController.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/21/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "BackendController.h"
#import "TDSingletonCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Posts.h"
#import "AudioTableCell.h"

@interface BackendController ()
@property (nonatomic) NSDictionary *recordSetting;
@property (nonatomic) NSMutableArray *PostsArray;
@property (nonatomic) NSMutableArray *Replies;
@property (nonatomic) long count;
@property (nonatomic) NSURL *recordurl;
@end

@implementation BackendController

@synthesize NameBox;
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
    _recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    
    
//    NSURL *soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"SF1" ofType:@"mp3"]];
//    
//    SystemSoundID SF1;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &SF1);
//    AudioServicesAddSystemSoundCompletion(SF1, NULL, NULL, finishPlaySoundCallBack, NULL);
//    AudioServicesPlaySystemSound(SF1);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Posts" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    _PostsArray = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager
                                                getManagedObjectContext] executeFetchRequest:fetchRequest error:&error] ];
    
    NSEntityDescription *repliesentity = [NSEntityDescription entityForName:@"Replies" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:repliesentity];
    _Replies = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager getManagedObjectContext] executeFetchRequest:fetchRequest error:&error]];
    
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    if (![self.defaults integerForKey:@"count"]) {
        [self.defaults setInteger:0 forKey:@"count"];
        [self.defaults synchronize];
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
    
    AudioTableCell *cell = (AudioTableCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"AudioTableCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    return cell;
}



- (IBAction)Record:(id)sender {
    
    NSLog(@"record");
    _count = [self.defaults integerForKey:@"count"];
    _recordurl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Record%ld.caf",[[NSBundle mainBundle] resourcePath],_count]];
    
    NSError *error = nil;
    
    self.recorder = [[AVAudioRecorder alloc]initWithURL:_recordurl settings:_recordSetting error:&error];
    
    if (error != nil) {
        NSLog(@"Init recorder error: %@",error);
    }
    else if([self.recorder prepareToRecord]){
        NSLog(@"Prepared successful");
    }
    
    if (!self.recorder.recording) {
        [self.recorder record];
    }
    
    NSLog(@"%@",NameBox.text);
    
}

- (IBAction)Stop:(id)sender {
    NSLog(@"stop");
    if (self.recorder.recording) {
        [self.recorder stop];
    }
    [self.defaults setInteger:_count+1 forKey:@"count"];
    [self.defaults synchronize];
    Posts *newposts = [Posts userWithRawDictionary];
    newposts.authorname = self.NameBox.text;
    newposts.posturl = _recordurl;
    [_PostsArray addObject:newposts];
    NSLog(@"%@\n\n%@",_PostsArray,newposts);
    [TDSingletonCoreDataManager saveContext];
}

void finishPlaySoundCallBack(SystemSoundID sound_id, void *user_data){
    NSLog(@"finish playing");
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    frame.origin.y -=216;
    frame.size.height +=216;
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    frame.origin.y +=216;
    frame.size.height -=216;
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

@end
