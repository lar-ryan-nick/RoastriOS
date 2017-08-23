//
//  LeaderboardViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 12/31/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef LeaderboardViewController_h
#define LeaderboardViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "ProfileViewController.h"

@interface LeaderboardViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int numUsers;
@property (nonatomic) int enemyLeadersLoaded;
@property (nonatomic) int hateLeadersLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableArray<NSDictionary*> *enemyLeadersData;
@property (nonatomic) NSMutableArray<NSDictionary*> *hateLeadersData;
@property (nonatomic) UITableView *enemyLeaders;
@property (nonatomic) UITableView *hateLeaders;
@property (nonatomic) UISegmentedControl *leaderType;

@end

#endif /* LeaderboardViewController_h */
