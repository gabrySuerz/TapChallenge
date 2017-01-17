//
//  ViewController.m
//  TapChallenge
//
//  Created by Gabriele Suerz on 13/01/17.
//  Copyright © 2017 Gabriele Suerz. All rights reserved.
//

#import "ViewController.h"

#define GameTimer 1
#define GameTime 5

@interface ViewController (){
    int _tapsCount;
    int _timeCount;
    int _tapsHistory;
    
    NSTimer *_gameTimer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initializeGame];
}

-(void)initializeGame{
    _tapsCount = 0;
    _timeCount = GameTime;
    
    [self.tapsCountLabel setText:@"Tap to play"];
    [self.timeLabel setText:[NSString stringWithFormat:@"Time Challenge - %i sec",_timeCount]];
}

-(void)viewDidAppear:(BOOL)animated{
    [self mostraUltimoRisultato:[[NSUserDefaults standardUserDefaults] integerForKey:@"TapsCount"]];
}

#pragma mark - actions

-(IBAction)buttonPressed:(id)sender{
    
    //il timer viene creato solo non esiste
    if(_gameTimer == nil){
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:GameTimer target:self selector:@selector(timerTick) userInfo:nil repeats:true];
    }
    
    //aumento e mostro i tap
    _tapsCount++;
    
    [self.tapsCountLabel setText:[NSString stringWithFormat:@"%i", _tapsCount]];
    
}

-(void)timerTick{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _timeCount--;
    NSString *message, *title;
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%i sec",_timeCount]];
    
    if(_timeCount == 0){
        [_gameTimer invalidate]; //invalidare per eliminare definitivamente
        _gameTimer = nil;//eliminare il puntatore
        
        if(_tapsHistory<_tapsCount){
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

-(int)risultato{
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"TapsCount"];
    return value;
}

-(void)saveGame{
    [[NSUserDefaults standardUserDefaults] setInteger:_tapsCount forKey:@"TapsCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
