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
#define FirstTime @"FirstTime"

#define Defaults [NSUserDefaults standardUserDefaults]
#define Results @"User Score"

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
    if([self firstTime] == false){
        [Defaults setBool:true forKey:FirstTime];
        [Defaults synchronize];
    }
    else{
        if([self risultati].count > 0){
            NSNumber *value = [self risultati].firstObject;
            [self mostraUltimoRisultato:value.intValue];
        }
    }
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
        int value1 = obj1.integerValue, value2=obj2.integerValue;
        if (value1 == value2){
            return NSOrderedSame;
        }
        
        if (value1 < value2){
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    [Defaults setObject:arrayToBeSaved forKey:Results];
    [Defaults synchronize];
}

@end
