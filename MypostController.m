//
//  MypostController.m
//  AudioSNS
//
//  Created by Gao Yuan on 5/5/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "MypostController.h"
#import "TDSingletonCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Mypost.h"
#import "Replies.h"


@interface MypostController ()
@property (nonatomic) NSDictionary *recordSetting;
@property (nonatomic) NSMutableArray *myPostArray;
@property (nonatomic) NSMutableArray *repliesArray;
@property (nonatomic) long count;
@property (nonatomic) NSURL *recordURL;
@property (nonatomic) long selectedPostNumber;
@end

@implementation MypostController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self prepareData];
    
    // Do any additional setup after loading the view.
}

- (void)prepareData{
    
    _context = [TDSingletonCoreDataManager getManagedObjectContext];
    
    _recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mypost" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    _myPostArray = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager
                                                   getManagedObjectContext] executeFetchRequest:fetchRequest error:&error] ];
    
    
    NSEntityDescription *repliesentity = [NSEntityDescription entityForName:@"Replies" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:repliesentity];
    _repliesArray = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager getManagedObjectContext] executeFetchRequest:fetchRequest error:&error]];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    //    [self.defaults setBool:self.soundEffectOnly.on forKey:@"soundonly"];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedPostNumber = indexPath.row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Mypost *mypost = _myPostArray[indexPath.row];
    
    cell.textLabel.text = [[NSString stringWithFormat:@"%@",mypost.url] substringFromIndex:79];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_myPostArray count];
}


- (IBAction)startRecord:(id)sender {
    _count = [self.defaults integerForKey:@"replyCount"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _recordURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Reply%ld.caf",documentsDirectory, _count]];
    
    
    NSError *error = nil;
    
    self.recorder = [[AVAudioRecorder alloc]initWithURL:_recordURL settings:_recordSetting error:&error];
    
    if (error != nil) {
        NSLog(@"Init recorder error: %@",error);
    }
    else if([self.recorder prepareToRecord]){
        NSLog(@"Prepared successful");
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
        [self.recorder prepareToRecord];
        [self.recorder record];
    }
}

- (IBAction)stopRecord:(id)sender {
    NSLog(@"stop");
    if (self.recorder.recording) {
        [self.recorder stop];
    }
    [self.defaults setInteger:_count+1 forKey:@"replyCount"];
    [self.defaults synchronize];
    Replies *newreply = [Replies GenerateNewReply];
    newreply.author = self.nameBox.text;
    newreply.messageurl = _recordURL;
    Mypost *myTargetPost = _myPostArray[_selectedPostNumber];
    myTargetPost.relationship = newreply;
    
    [_repliesArray addObject:newreply];
    
    [TDSingletonCoreDataManager saveContext];
    [self.mypostTable reloadData];
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
