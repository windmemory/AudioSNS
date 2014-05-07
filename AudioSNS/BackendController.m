//
//  BackendController.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/21/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//  This is a backend interface that allows you to add "friends' posts"

#import "BackendController.h"
#import "TDSingletonCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Posts.h"
#import "AudioTableCell.h"
#import "ViewController.h"

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
    
    [self prepareData];
    
    self.soundEffectOnly.on = [self.defaults boolForKey:@"soundonly"];
    
}


//initialize variables used in the controller
- (void)prepareData{
    
    _context = [TDSingletonCoreDataManager getManagedObjectContext];
    
    _recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Posts" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    _PostsArray = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager
                                                   getManagedObjectContext] executeFetchRequest:fetchRequest error:&error] ];
    
    
    NSEntityDescription *repliesentity = [NSEntityDescription entityForName:@"Replies" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:repliesentity];
    _Replies = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager getManagedObjectContext] executeFetchRequest:fetchRequest error:&error]];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
//    [self.defaults setBool:self.soundEffectOnly.on forKey:@"soundonly"];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    ViewController *desinationcontroller = [segue destinationViewController];
//    desinationcontroller.soundOnly = [self.defaults boolForKey:@"soundonly"];
    
    [player stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[TDSingletonCoreDataManager getManagedObjectContext] deleteObject:_PostsArray[indexPath.row]];
        [_PostsArray removeObjectAtIndex:indexPath.row];
        [self.AudioTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
    [TDSingletonCoreDataManager saveContext];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_PostsArray count];
}

- (void) PlayButtonClicked:(UIButton*)sender{
    NSError *error;
    Posts *onepost = _PostsArray[sender.tag];
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:onepost.posturl error:&error];
    [player play];
    NSLog(@"%@",player.url);
    NSLog(@"%@",onepost);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AudioTableCell *cell = (AudioTableCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"AudioTableCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    Posts *oneposts = _PostsArray[indexPath.row];
    cell.Postsname.text = oneposts.authorname;
    cell.AudioFileName.text = [oneposts.posturl absoluteString];
    
    cell.PlayButton.tag = indexPath.row;
    [cell.PlayButton addTarget:self action:@selector(PlayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Recorder and Player



- (IBAction)Record:(id)sender {
    
    _count = [self.defaults integerForKey:@"count"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _recordurl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Record%ld.caf",documentsDirectory, _count]];
    
    
    NSError *error = nil;
    
    self.recorder = [[AVAudioRecorder alloc]initWithURL:_recordurl settings:_recordSetting error:&error];
    
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

- (IBAction)Stop:(id)sender {
    NSLog(@"stop");
    if (self.recorder.recording) {
        [self.recorder stop];
    }
    [self.defaults setInteger:_count+1 forKey:@"count"];
    [self.defaults synchronize];
    Posts *newposts = [Posts GenerateNewPost];
    newposts.authorname = self.NameBox.text;
    newposts.posturl = _recordurl;
    [_PostsArray addObject:newposts];
    
    [TDSingletonCoreDataManager saveContext];
    [self.AudioTable reloadData];
}

- (IBAction)SoundOnlySwitch:(id)sender {
    [self.defaults setBool:self.soundEffectOnly.on forKey:@"soundonly"];
    [self.defaults synchronize];
    
    NSLog(@"%d",[self.defaults boolForKey:@"soundonly"]);
}

void finishPlaySoundCallBack(SystemSoundID sound_id, void *user_data){
    NSLog(@"finish playing");
}

#pragma mark - TextBox

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
