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

typedef enum{
    isStart,
    isSpeakingNameofPost,
    isSpeakingPost,
    isSpeakingGeneralInstruction,
    isSpeakingCommentInstruction,
    isSpeakingShareInstruction,
    isSpeakingNewPostInstruction,
    SoundEffectFinishSpeakPost,
    SoundEffectdefault
}Status;

@interface ViewController ()


@property (nonatomic) int NumberofPostisPlaying;
@property (nonatomic) Status status;
@property (nonatomic) UILabel *StatusLabel;
@property (nonatomic) FBShimmeringView *shimmeringView;
@end

@implementation ViewController

@synthesize fliteController;
@synthesize slt;
@synthesize openEarsEventsObserver;
@synthesize pocketphinxController;
@synthesize pathToDynamicallyGeneratedDictionary;
@synthesize pathToDynamicallyGeneratedLanguageModel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.StopButton.hidden = YES;
    self.StartButton.hidden = YES;
    _NumberofPostisPlaying = 0;
    
    [self.openEarsEventsObserver setDelegate:self];
    NSError *error = nil;
    AVAudioSession *audiosession = [AVAudioSession sharedInstance];
    [audiosession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audiosession setActive:YES error:nil];
    
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
    
    
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSArray *words = [NSArray arrayWithObjects:@"COMMENT", @"SHARE", @"YES", @"NO", @"MESSAGE", @"POSTS", @"MAKE",@"POST", nil];
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
    
//--------------record setting not use for now------------------------------------------------
//    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
//    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record.caf",[[NSBundle mainBundle] resourcePath]]];
//--------------------------------------------------------------------------------------------
    
    
    
    [self.fliteController say:[NSString stringWithFormat:@"Welcome to Voice based SNS, press START button to start"] withVoice:self.slt];
    self.StartButton.hidden = NO;
    
    _status = isStart;
    
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
    
    [self ReadStatus];

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
}

#pragma mark - Read Posts and Read instruction

- (void) ReadStatus{
    NSLog(@"%ld",[_PostsArray count]);
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
    }
}
- (void) fliteDidFinishSpeaking {
	NSLog(@"Flite has finished speaking"); // Log it.
    NSError *error;
    
    if (_status == isSpeakingNameofPost) {
        Posts *onepost = _PostsArray[_NumberofPostisPlaying];
        self.audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:onepost.posturl error:&error];
        [self.audioplayer setDelegate:self];
        [self.audioplayer play];
        return;
    }else if(_status == isSpeakingGeneralInstruction){
        [self startlistening];
        return;
    }
    
//    if ((_NumberofPostisPlaying+1) < [_PostsArray count]) {
//        _NumberofPostisPlaying ++;
//    }
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

- (void) startlistening{
    [self.pocketphinxController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    
}

- (void) stoplistening{
    [self.pocketphinxController stopListening];
    
}

-(void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID{
    
    NSInteger score = [recognitionScore integerValue];
    
    if ( score <= -1000) {
        NSLog(@"invalid command with word: %@, score: %@",hypothesis,recognitionScore);
        [self.fliteController say:@"Wrong command, please try again" withVoice:slt];
    }
    else
        NSLog(@"Command %@",hypothesis);
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    _status = isSpeakingGeneralInstruction;
    
    [self.fliteController say:@"Say Comment to make a comment on this post. share to share this post. continue to continue to next post or post to make a new post on your own timeline" withVoice:slt];
    
}


#pragma mark - SpeechRecognition
- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
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
    _shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 220, 320, 150)];
    NSLog(@"%@",self.view);
    [self.view addSubview:_shimmeringView];
    
    _StatusLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    _StatusLabel.textAlignment = NSTextAlignmentCenter;
    _StatusLabel.text = @"Speaking";
    _StatusLabel.textColor = [UIColor colorWithRed:16.0f/255.0f green:162.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    _StatusLabel.font = [UIFont fontWithName:@"Helvetica Light" size:36];
    
    _shimmeringView.contentView = _StatusLabel;
    // Start shimmering.
    _shimmeringView.shimmering = YES;
}

@end
