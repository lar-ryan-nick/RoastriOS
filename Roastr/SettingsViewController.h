//
//  SettingsViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 12/7/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef SettingsViewController_h
#define SettingsViewController_h

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import "FriendRequestsViewController.h"
#import "LeaderboardViewController.h"

@interface SettingsViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic) UIScrollView *options;
@property (nonatomic) UIButton *showUserProfile;
@property (nonatomic) UIButton *showLeaderboard;
@property (nonatomic) UIButton *friendRequests;
@property (nonatomic) UIButton *logOut;
@property (nonatomic) UIButton *removeAds;
@property (nonatomic) UIButton *restorePurchases;
@property (nonatomic) BOOL areAdsRemoved;
- (IBAction)restore:(id)sender;
- (IBAction)tapsRemoveAds:(id)sender;

@end

#endif /* SettingsViewController_h */
