//
//  ViewController.m
//  TapChallenge
//
//  Created by Gabriele Suerz on 13/01/17.
//  Copyright © 2017 Gabriele Suerz. All rights reserved.
//

#import "GameViewController.h"
#import "ScoreTableViewController.h"

#define GameTimer 1
#define GameTime 5
#define FirstTime @"FirstTime"

#define Defaults [NSUserDefaults standardUserDefaults]
#define Results @"User Score"

@interface GameViewController (){
    int _tapsCount;
    int _timeCount;
    int _tapsHistory;
    UILabel _nuovaLabel;
    
    NSTimer *_gameTimer;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initializeGame];
    
    //titolo navigation bar
    self.title = @"Tap Challenge";
    
    //creo il pulsante per la tableview
    UIBarButtonItem *scoreButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(scoreButtonPressed)];
    
    //imposto il pulsante a destra
    self.navigationItem.rightBarButtonItem = scoreButtonItem;
    
    //nuova label con inserimento da codice
    _nuovaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 100, 40)];
    [_nuovaLabel setText:@"CodeLabel"];
    [_nuovaLabel setBackgroundColor:[UIColor redColor]];
    [_nuovaLabel setTextColor:[UIColor whiteColor]];
    [_nuovaLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:_nuovaLabel];
}

-(void)viewDidAppear:(BOOL)animated{
    /*if([self firstTime] == false){
        [Defaults setBool:true forKey:FirstTime];
        [Defaults synchronize];
    }
    else{
        if([self risultati].count > 0){
            NSNumber *value = [self risultati].firstObject;
            [self mostraUltimoRisultato:value.intValue];
        }
    }*/
    
    [self resumeGame];
    
    [UIView animateWithDuration:5 animations:^{
        [_nuovaLabel setCenter:CGPointMake(300, 300)];
        [_nuovaLabel setAlpha:0];
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self pauseGame];
}

-(void)initializeGame{
    _tapsCount = 0;
    _timeCount = GameTime;
    
    [self.tapsCountLabel setText:@"Tap to play"];
    [self.timeLabel setText:[NSString stringWithFormat:@"%i sec",_timeCount]];
}

-(void)pauseGame {
    if(_gameTimer != nil){
        [_gameTimer invalidate];
        _gameTimer = nil;
    }
}

-(void)resumeGame {
    if(_timeCount != 0 && _tapsCount > 0){
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:GameTimer target:self selector:@selector(timerTick) userInfo:nil repeats:true];
    }
}

#pragma mark - actions

-(void)scoreButtonPressed{
    //UIViewController *viewController = [[UIViewController alloc] init];
    //viewController.title = @"Nuova view";
    
    //
    ScoreTableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScoreTableViewController"];
    
    NSArray *resultArray = [self risultati];
    [tableViewController setScoreArray:resultArray];
    
    tableViewController.delegate = self;
    
    [self.navigationController pushViewController:tableViewController animated:true];
}

-(IBAction)tapGestureRacognizerDidRecognize:(id)sender{
    
    //il timer viene creato solo non esiste
    if(_gameTimer == nil){
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:GameTimer target:self selector:@selector(timerTick) userInfo:nil repeats:true];
    }
    
    //aumento e mostro i tap
    _tapsCount++;
    
    [self.tapsCountLabel setText:[NSString stringWithFormat:@"%i", _tapsCount]];
}

-(IBAction)buttonPressed:(id)sender{
    
}

-(void)timerTick{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _timeCount--;
    NSString *message, *title;
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%i sec",_timeCount]];
    
    if(_timeCount == 0){
        [_gameTimer invalidate]; //invalidare per eliminare definitivamente
        _gameTimer = nil;//eliminare il puntatore
        
        if(_tapsHistory < _tapsCount){
            [self saveGame];
            message=[NSString stringWithFormat:@"Loser with: %i taps!",_tapsCount];
            title=@"Game Over";
        } else{
            message=[NSString stringWithFormat:@"Winner with: %i taps!",_tapsCount];
            title=@"You Win";
        }
        
        UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK Action premuta");
        }];
        
        [alertViewController addAction:okAction];
        [self presentViewController:alertViewController animated:true completion:nil];
        
        [self initializeGame];
    }
}

#pragma mark - UI

-(void)mostraUltimoRisultato:(int)risultato{
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"Il punteggio più alto" message:[NSString stringWithFormat:@"%i",risultato] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OK Action premuta");
    }];
    
    [alertViewController addAction:okAction];
    [self presentViewController:alertViewController animated:true completion:nil];
}

#pragma mark - persistence

-(NSArray *)risultati{
    NSArray *array = [Defaults objectForKey:Results];
    
    if(array == nil){
        array = @[];
    }
    
    return array;
}

-(bool)firstTime{
    return [Defaults boolForKey:FirstTime];
}

-(void)saveGame{
    NSMutableArray *array = [[Defaults objectForKey:Results] mutableCopy];
    if(array == nil){
        //OLD
        //array = [[NSMutableArray alloc] init].mutableCopy;
        array = @[].mutableCopy;
    }
    
    //OLD //NSNumber *number = [NSNumber numberWithInt:_tapsCount
    [array addObject:@(_tapsCount)];
    
    NSArray *arrayToBeSaved = [array sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        NSInteger value1 = obj1.integerValue, value2=obj2.integerValue;
        if (value1 == value2){
            return NSOrderedSame;
        }
        
        if (value1 < value2){
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    NSLog(@"%@",arrayToBeSaved);
    
    [Defaults setObject:arrayToBeSaved forKey:Results];
    [Defaults synchronize];
}

#pragma mark - ScoreTableViewDelegate

-(NSArray *)scoreTableViewFetchResults{
    return [self risultati];
}

-(void)scoreTableViewDidFetchResults{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
