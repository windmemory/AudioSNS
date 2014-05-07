//
//  ViewController.m
//  AudioSNS
//
//  Created by Gao Yuan on 4/4/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <OpenEars/FliteController.h>
#import <OpenEars/OpenEarsLogging.h>
#import <FBShimmering.h>
#import <FBShimmeringView.h>
#import <FBShimmeringLayer.h>
#import <CoreData/CoreData.h>
#import "TDSingletonCoreDataManager.h"
#import "Posts.h"
#import "Mypost.h"
#import "Replies.h"
#define interval 10

typedef enum{
    none,
    isStart,
    isSpeakingNameofPost,
    isSpeakingGeneralInstruction,
    Commenting,
    Sharing,
    Newposting,
    confirmComment,
    confirmShare,
    confirmPost,
    Choosemode,
    messageSystem,
    finishMessage,
    
    WrongCommend = 1 <<20,
}Status;

@interface ViewController ()

@property (nonatomic) NSTimer *SilenceTimer;
@property (nonatomic) int NumberofPostisPlaying;
@property (nonatomic) int numberOfMypost;
@property (nonatomic) Status status;
@property (nonatomic) UILabel *StatusLabel;
@property (nonatomic) FBShimmeringView *shimmeringView;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) SystemSoundID sf1;
@property (nonatomic) SystemSoundID sf2;
@property (nonatomic) SystemSoundID sf3;
@property (nonatomic) SystemSoundID sf4;
@property (nonatomic) SystemSoundID sf5;
@property (nonatomic) SystemSoundID sf6;
@end

@implementation ViewController

@synthesize fliteController;
@synthesize slt;
@synthesize openEarsEventsObserver;
@synthesize pocketphinxController;
@synthesize pathToDynamicallyGeneratedDictionary;
@synthesize pathToDynamicallyGeneratedLanguageModel;

static double level[interval];
static double totallevel;
static int iteration;
static BOOL flag;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.StopButton.hidden = YES;
    self.StartButton.hidden = YES;
    _NumberofPostisPlaying = 0;
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [self initialFunctions];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    [self.fliteController say:[NSString stringWithFormat:@"Welcome to Voice based SNS, press START button to start"] withVoice:self.slt];
    self.StartButton.hidden = NO;
    
    _status = none;
    
}
- (void) initialFunctions{
    //--------------------------Register Sound Effect in the system--------------------------------------
    
    NSURL *soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf1" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf1);
    soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf2" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf2);
    soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf3" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf3);
    soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf4" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf4);
    soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf5" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf5);
    soundurl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"sf6" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundurl, &_sf6);
    
    //--------------------------Generate Language Model----------------------------------------------------
    
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSArray *words = [NSArray arrayWithObjects:@"COMMENT", @"SHARE", @"CONFIRM", @"CANCEL", @"NEW", @"MAKE",@"POST",@"QUIT",@"WANT",@"REPLY",@"REDO", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	
    if([err code] == noErr) {
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    self.pathToDynamicallyGeneratedLanguageModel = lmPath;
    self.pathToDynamicallyGeneratedDictionary = dicPath;
}

- (void) initialdata{
    
//------------------------------initialize core data-----------------------------------------------
    NSError *dataerror;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Posts" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:entity];
    _PostsArray = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager
                                                   getManagedObjectContext] executeFetchRequest:fetchRequest error:&dataerror] ];
    
    
    NSEntityDescription *repliesentity = [NSEntityDescription entityForName:@"Replies" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:repliesentity];
    _Replies = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager getManagedObjectContext] executeFetchRequest:fetchRequest error:&dataerror]];
    
    NSEntityDescription *mypostentity = [NSEntityDescription entityForName:@"Mypost" inManagedObjectContext:[TDSingletonCoreDataManager getManagedObjectContext]];
    [fetchRequest setEntity:mypostentity];
    _myposts = [NSMutableArray arrayWithArray:[[TDSingletonCoreDataManager getManagedObjectContext] executeFetchRequest:fetchRequest error:&dataerror]];
    NSLog(@"%@\n\n\n%@\n\n\n%@",_myposts,_PostsArray,_Replies);


}

- (void)viewDidAppear:(BOOL)animated{
    [self initialdata];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self StopSystem];
}



- (IBAction)SystemStart:(id)sender{
    
    self.StopButton.hidden = NO;
    self.Title.hidden = YES;
    self.StartButton.hidden = YES;
    if (_shimmeringView == nil) {
        [self initializashimmeringview];
    }else{
        _shimmeringView.hidden = NO;
        _StatusLabel.hidden = NO;
    }
    
    if ([self.fliteController speechInProgress]) {
        [self.fliteController interruptTalking];
    }
    [self startlistening];
    [self chooseMode];

}

-(void) chooseMode{
    _status = isStart;
    [self.fliteController say:@"Do you want to listen" withVoice:slt];
}

- (IBAction)SystemStop:(id)sender {
    self.StopButton.hidden = YES;
    self.Title.hidden = NO;
    self.StartButton.hidden = NO;
    _StatusLabel.hidden = YES;
    _shimmeringView.hidden = YES;
    [self StopSystem];
}


- (void) StopSystem{
    if ([self.audioplayer isPlaying]) {
        [self.audioplayer stop];
    }
    if ([self.audiorecorder isRecording]) {
        [self.audiorecorder stop];
    }
    if ([self.fliteController speechInProgress]) {
        [self.fliteController interruptTalking];
    }
    if ([self.pocketphinxController isListening]) {
        [self.pocketphinxController stopListening];
    }
    if (_SilenceTimer) {
        [_SilenceTimer invalidate];
    }
    _status = isStart;
    
}


- (FliteController *)fliteController{
    if (fliteController == nil) {
        fliteController = [[FliteController alloc] init];
    }
    return fliteController;
}

- (Slt*)slt{
    if (slt == nil) {
        slt = [[Slt alloc]init];
    }
    return slt;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver{
    if (openEarsEventsObserver == nil) {
        openEarsEventsObserver = [[OpenEarsEventsObserver alloc]init];
    }
    
    return openEarsEventsObserver;
}

- (PocketsphinxController *)pocketphinxController{
    if (pocketphinxController == nil) {
        pocketphinxController = [[PocketsphinxController alloc]init];
    }

    return pocketphinxController;
}

#pragma mark - Read Posts and Read instruction

- (void) replyMessage{
    [self.pocketphinxController suspendRecognition];
    [self.fliteController say:@"In your post" withVoice:slt];
}

- (void) ReadStatus{
    if ([_PostsArray count] == 0) {
        [self StopSystem];
        [self.fliteController say:@"You don't have any friends' posts in your timeline" withVoice:slt];
        self.StopButton.hidden = YES;
        self.Title.hidden = NO;
        self.StartButton.hidden = NO;
        _StatusLabel.hidden = YES;
        _shimmeringView.hidden = YES;
    }else{
        Posts *onepost = _PostsArray[_NumberofPostisPlaying];
        _status = isSpeakingNameofPost;
        [self.fliteController say:[NSString stringWithFormat:@"%@ posted a status",onepost.authorname] withVoice:slt];
        _StatusLabel.text = onepost.authorname;
    }
}

- (void) startlistening{
    [self.pocketphinxController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
}

- (void) stoplistening{
    [self.pocketphinxController stopListening];
    
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID{
    
    NSInteger score = [recognitionScore integerValue];
    NSLog(@"%u",_status);
    if ( score <= -20000) {
        _status = _status^WrongCommend;
        [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
        NSLog(@"%@, %@",hypothesis,recognitionScore);
        
    }else if (_status == isStart){
        if ([hypothesis rangeOfString:@"POST"].location != NSNotFound) {
            [self.pocketphinxController suspendRecognition];
            [self ReadStatus];
            
        }else if([hypothesis rangeOfString:@"REPLY"].location != NSNotFound){
            [self.pocketphinxController suspendRecognition];
            _status = messageSystem;
            [self replyMessage];
            
        }else if([hypothesis rangeOfString:@"QUIT"].location != NSNotFound){
            self.StopButton.hidden = YES;
            self.Title.hidden = NO;
            self.StartButton.hidden = NO;
            _StatusLabel.hidden = YES;
            _shimmeringView.hidden = YES;
            [self StopSystem];
        }
//--------------------Dealing with operation----------------------------------
    }else if (_status == isSpeakingGeneralInstruction){
        NSLog(@"Command %@",hypothesis);
        if ([hypothesis rangeOfString:@"COMMENT"].location != NSNotFound) {
            _status = Commenting;
            [self.pocketphinxController suspendRecognition];
            [self.fliteController say:@"Please comment" withVoice:slt];
            NSLog(@"comment");
        }else if ([hypothesis rangeOfString:@"SHARE"].location != NSNotFound){
            _status = Sharing;
            [self.fliteController say:@"Do you want to share? say confirm or cancel" withVoice:slt];
            _StatusLabel.text = @"\"Confirm\"\n\"Cancel\"";
        }else if ([hypothesis rangeOfString:@"POST"].location != NSNotFound){
            _status = Newposting;
            _StatusLabel.text = @"NEWPOST";
            [self.pocketphinxController suspendRecognition];
            [self newPost];
        }else if([hypothesis rangeOfString:@"QUIT"].location != NSNotFound){
            [self.pocketphinxController suspendRecognition];
            [self chooseMode];
            return;
        }else{
            _status = _status^WrongCommend;
            [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
            NSLog(@"%@, %@",hypothesis,recognitionScore);
        }
        
//--------------------Confirm Comment------------------------------------------
        
    }else if (_status == confirmComment){
        if ([hypothesis rangeOfString:@"CONFIRM"].location != NSNotFound) {
            [self.fliteController say:@"Comment Success" withVoice:slt];
            _StatusLabel.text = @"Confirmed";
            [TDSingletonCoreDataManager saveContext];
        }else if([hypothesis rangeOfString:@"REDO"].location != NSNotFound){
            _status = Commenting;
            [self.pocketphinxController suspendRecognition];
            [self.fliteController say:@"Please comment" withVoice:slt];
            _StatusLabel.text = @"COMMENT";
            return;
        }else if([hypothesis rangeOfString:@"CANCEL"].location != NSNotFound){
            [self.fliteController say:@"canceled" withVoice:slt];
        }else{
            _status = _status^WrongCommend;
            [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
            NSLog(@"%@, %@",hypothesis,recognitionScore);
            return;
        }
        if ((_NumberofPostisPlaying+1) < [_PostsArray count])
            _NumberofPostisPlaying ++;
        [self.pocketphinxController suspendRecognition];
        [self ReadStatus];
        
//------------------Confirm Share---------------------------------------------
        
    }else if (_status == Sharing){
        if ([hypothesis rangeOfString:@"CONFIRM"].location != NSNotFound) {
            _status = confirmShare;
            [self.fliteController say:@"Share Success" withVoice:slt];
        }else if([hypothesis rangeOfString:@"CANCEL"].location != NSNotFound){
            _status = confirmShare;
            [self.fliteController say:@"canceled" withVoice:slt];
        }else{
            _status = _status^WrongCommend;
            [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
            NSLog(@"%@, %@",hypothesis,recognitionScore);
            return;
        }
        if ((_NumberofPostisPlaying+1) < [_PostsArray count])
            _NumberofPostisPlaying ++;
        [self.pocketphinxController suspendRecognition];
        [self ReadStatus];
//--------------------Confirm Post---------------------------------------------
        
    }else if(_status == confirmPost){
        NSLog(@"%@, %@",hypothesis,recognitionScore);
        if ([hypothesis rangeOfString:@"CONFIRM"].location != NSNotFound) {
            [self.fliteController say:@"Comment Success" withVoice:slt];
            _StatusLabel.text = @"Confirmed";
            [TDSingletonCoreDataManager saveContext];
        }else if([hypothesis rangeOfString:@"REDO"].location != NSNotFound){
            _status = Newposting;
            [self.pocketphinxController suspendRecognition];
            [self.fliteController say:@"Please comment" withVoice:slt];
            _StatusLabel.text = @"NEWPOST";
            return;
        }else if([hypothesis rangeOfString:@"CANCEL"].location != NSNotFound){
            [self.fliteController say:@"canceled" withVoice:slt];
        }else{
            _status = _status^WrongCommend;
            [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
            NSLog(@"%@, %@",hypothesis,recognitionScore);
            return;
        }
        if ((_NumberofPostisPlaying+1) < [_PostsArray count])
            _NumberofPostisPlaying ++;
        [self.pocketphinxController suspendRecognition];
        [self ReadStatus];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (_status != messageSystem){
        _status = isSpeakingGeneralInstruction;
        [self.fliteController say:@"Say instructions please "/*to make a comment on this post. share to share this post. continue to continue to next post or post to make a new post on your own timeline" */withVoice:slt];
    }
}

- (void) fliteDidFinishSpeaking {
	NSLog(@"Flite has finished speaking"); // Log it.
    
    if (_status == isSpeakingNameofPost) {
        [self saypost];
    }else if(_status == isSpeakingGeneralInstruction){
        [self finishGeneralInstruction];
    }else if(_status & WrongCommend){
        _status = _status^WrongCommend;
        [self finishGeneralInstruction];
    }else if(_status == Commenting){
        [self CommentPosts];
    }else if(_status == confirmComment){
        [self.pocketphinxController resumeRecognition];
    }else if (_status == confirmPost){
        [self.pocketphinxController resumeRecognition];
    }else if (_status == isStart){
        [self finishGeneralInstruction];
    }else if (_status == Sharing){
        [self finishGeneralInstruction];
    }else if (_status == finishMessage){
        [self chooseMode];
    }else if (_status == messageSystem){
        [self previewMypost];
    }
}

- (void) saypost{
    NSError *error;
    Posts *onepost = _PostsArray[_NumberofPostisPlaying];
    self.audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:onepost.posturl error:&error];
    [self.audioplayer setDelegate:self];
    [self.audioplayer play];
}

- (void) previewMypost{
    Mypost *oneMypost = _myposts[_numberOfMypost];
    NSError *error;
    while (oneMypost.relationship == nil) {
        if (_numberOfMypost == ([_myposts count] - 1)) {
            _status = finishMessage;
            [self.fliteController say:@"You don't have meesages" withVoice:slt];
        }
        oneMypost = _myposts[++_numberOfMypost];
    }
    [self.pocketphinxController suspendRecognition];
    _audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:oneMypost.url error:&error];
    [_audioplayer play];
    
//    if ([_audioplayer isPlaying]) {
//        [_audioplayer stop];
//    }

}

- (void) finishGeneralInstruction{
    AudioServicesPlaySystemSound(_sf2);
    [self.pocketphinxController resumeRecognition];
}

- (void) CommentPosts{
    
    if (![self.defaults integerForKey:@"Mycount"]) {
        [self.defaults setInteger:0 forKey:@"Mycount"];
        [self.defaults synchronize];
    }
    
    NSError *error;
    NSInteger Mycount = [self.defaults integerForKey:@"Mycount"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *recordurl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/MyComment%ld.caf",documentsDirectory, Mycount]];
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    self.audiorecorder = [[AVAudioRecorder alloc]initWithURL:recordurl settings:recordSetting error:&error];
    [self.audiorecorder setMeteringEnabled:YES];
    
    
    
    if ([self.audiorecorder prepareToRecord] == 1){
        
        AudioServicesPlaySystemSound(_sf3);
        [self.defaults setInteger:(Mycount+1) forKey:@"Mycount"];
        [self.defaults synchronize];
        NSLog(@"%ld",Mycount);
        Replies *reply = [Replies GenerateNewReply];
        reply.messageurl = recordurl;
        reply.replyofpost = _PostsArray[_NumberofPostisPlaying];
        [_Replies addObject:(reply)];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        [self.audiorecorder record];
        _StatusLabel.text = @"Recording";
        totallevel = 0;
        flag = 0;
        _SilenceTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLevels) userInfo:nil repeats:YES];
        
    }
    
    
//    self.audiorecorder;
}

-(void) newPost{
    
    NSError *error;
    NSInteger Mycount = [self.defaults integerForKey:@"Mycount"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *recordurl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/MyPost%ld.caf",documentsDirectory, Mycount]];
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    self.audiorecorder = [[AVAudioRecorder alloc]initWithURL:recordurl settings:recordSetting error:&error];
    [self.audiorecorder setMeteringEnabled:YES];
    
    
    
    if ([self.audiorecorder prepareToRecord] == 1){
        
        
        AudioServicesPlaySystemSound(_sf3);
        [self.defaults setInteger:(Mycount+1) forKey:@"Mycount"];
        [self.defaults synchronize];
        NSLog(@"%ld",Mycount);
        Mypost *mypost = [Mypost GenerateMyPost];
        mypost.url = recordurl;
        [_myposts addObject:(mypost)];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        [self.audiorecorder record];
        _StatusLabel.text = @"Recording";
        totallevel = 0;
        flag = 0;
        _SilenceTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLevels) userInfo:nil repeats:YES];
    }
}

- (void) updateLevels{
    [self.audiorecorder updateMeters];
    
    if (flag == 0) {
        level[iteration] = [self.audiorecorder averagePowerForChannel:0];
        iteration = (iteration + 1) % interval;
        totallevel += [self.audiorecorder averagePowerForChannel:0];
        if (iteration == 0) {
            flag = 1;
        }
    }else if (totallevel >= -(40*interval)){
        level[iteration] = [self.audiorecorder averagePowerForChannel:0];
        iteration = (iteration + 1) % interval;
        totallevel = totallevel + [self.audiorecorder averagePowerForChannel:0] - level[iteration];
    }else{
        NSLog(@"silence");
        [self.audiorecorder stop];
        if (_status == Commenting) {
            _status = confirmComment;
            [_SilenceTimer invalidate];
            _StatusLabel.text = @"Confirm comment?";
            [self.fliteController say:@"Say confirm, cancel or redo" withVoice:slt];
            
        }else if(_status == Newposting){
            _status = confirmPost;
            NSLog(@"confirm post %u",_status);
            [_SilenceTimer invalidate];
            _StatusLabel.text = @"Confirm post?";
            [self.fliteController say:@"Say confirm, cancel or redo" withVoice:slt];
        }
    }
    NSLog(@"%f",[self.audiorecorder averagePowerForChannel:0]);
}


#pragma mark - SpeechRecognition
- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
    [self.pocketphinxController suspendRecognition];
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}



- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializashimmeringview{
    _shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 150, 320, 150)];
    NSLog(@"%@",self.view);
    [self.view addSubview:_shimmeringView];
    
    _StatusLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    _StatusLabel.textAlignment = NSTextAlignmentCenter;
    _StatusLabel.numberOfLines = 0;
    _StatusLabel.text = @"SPEAKING";
    _StatusLabel.textColor = [UIColor colorWithRed:16.0f/255.0f green:162.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    _StatusLabel.font = [UIFont fontWithName:@"Helvetica Light" size:36];
    
    _shimmeringView.contentView = _StatusLabel;
    // Start shimmering.
    _shimmeringView.shimmering = YES;
}

@end
