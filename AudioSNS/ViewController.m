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
#import <FBShimmering.h>
#import <FBShimmeringView.h>
#import <FBShimmeringLayer.h>
#import <CoreData/CoreData.h>
#import "TDSingletonCoreDataManager.h"
#import "Posts.h"

@interface ViewController ()

@property (nonatomic) NSArray *PostsArray;
@property (nonatomic) NSArray *Replies;
@property (nonatomic) int NumberofPostisPlaying;
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
    
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,[NSNumber numberWithInt:16],AVEncoderBitRateKey,[NSNumber numberWithInt:2],AVNumberOfChannelsKey,[NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record.caf",[[NSBundle mainBundle] resourcePath]]];
    
    
    self.audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    self.audiorecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    
    [self.fliteController say:[NSString stringWithFormat:@"Welcome to Voice based SNS, press START button to start"] withVoice:self.slt];
    
    
    
}

- (IBAction)SystemStart:(id)sender{
    
    self.StopButton.hidden = NO;
    self.Title.hidden = YES;
    self.StartButton.hidden = YES;
    
    
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:shimmeringView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Speaking";
    loadingLabel.textColor = [UIColor colorWithRed:16.0f/255.0f green:162.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    loadingLabel.font = [UIFont fontWithName:@"Helvetica Light" size:36];
    
    shimmeringView.contentView = loadingLabel;
    // Start shimmering.
    shimmeringView.shimmering = YES;
    
    [self ReadStatus];

}

- (IBAction)SystemStop:(id)sender {
    self.StopButton.hidden = YES;
    self.Title.hidden = NO;
    self.StartButton.hidden = NO;
    if ([self.audioplayer isPlaying]) {
        [self.audioplayer stop];
    }
    if ([self.audiorecorder isRecording]) {
        [self.audiorecorder stop];
    }
    if ([self.fliteController speechInProgress]) {
        [self.fliteController interruptTalking];
    }
}

#pragma mark - Read Posts and Read instruction

- (void) ReadStatus{
    
    Posts *onepost = _PostsArray[_NumberofPostisPlaying];
    [self.fliteController say:[NSString stringWithFormat:@"%@ posted a status",onepost.authorname] withVoice:slt];
    
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
    pocketphinxController.returnNbest = 0;
    pocketphinxController.nBestNumber = 6;

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
    
    
    
    [self startlistening];
    
    
    
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

- (void) fliteDidFinishSpeaking {
	NSLog(@"Flite has finished speaking"); // Log it.
    NSError *error;
    Posts *onepost = _PostsArray[_NumberofPostisPlaying];
    self.audioplayer = [[AVAudioPlayer alloc]initWithContentsOfURL:onepost.posturl error:&error];
    if (self.fliteController.speechInProgress) {
        [self.fliteController interruptTalking];
    }
    [self.audioplayer setDelegate:self];
    _NumberofPostisPlaying ++;
    [self.audioplayer play];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
