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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startRecord:(id)sender {
}

- (IBAction)stopRecord:(id)sender {
}
@end
