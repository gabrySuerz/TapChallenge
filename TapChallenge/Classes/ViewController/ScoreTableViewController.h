//
//  ScoreTableViewController.h
//  TapChallenge
//
//  Created by Gabriele Suerz on 18/01/17.
//  Copyright © 2017 Gabriele Suerz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScoreTableViewDelegate <NSObject>

/// richiedo i risultati al chiamante e alla classe che conforma al mio protocollo
-(NSArray *)scoreTableViewFetchResults;

/// informo che ho terminato il fetch dei dati
-(void)scoreTableViewDidFetchResults;

@end

@interface ScoreTableViewController : UITableViewController

@property (nonatomic, strong)  NSArray *scoreArray;

@property (nonatomic, unsafe_unretained) id <ScoreTableViewDelegate> delegate;

@end
