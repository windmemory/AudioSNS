//
//  ViewController.h
//  AudioSNS
//
//  Created by Gao Yuan on 4/4/14.
//  Copyright (c) 2014 Gao Yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Slt/Slt.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@class PocketsphinxController;
@class FliteController;

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>{
    Slt *slt;
    
    OpenEarsEventsObserver *openEarsEventsObserver;
    
    PocketsphinxController *pocketsphinxController;
    
    FliteController *fliteController;
    
}
@property (nonatomic) Slt *slt;
@property (nonatomic) FliteController *fliteController;
@property (nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic) PocketsphinxController *pocketphinxController;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;
@property (nonatomic) AVAudioRecorder *audiorecorder;
@property (nonatomic) AVAudioPlayer *audioplayer;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UIButton *StartButton;

- (IBAction)SystemStart:(id)sender;



@end
