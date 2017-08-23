//
//  AppDelegate.h
//  Roastr
//
//  Created by Ryan Wiener on 1/29/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "PostViewController.h"
#import "PostingViewController.h"
#import "PostsViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "Base64.h"
#import "MessagesViewController.h"
#import "ConversationsViewController.h"

static int userID;
static int adsRemoved;
static UITabBar *tabBar;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITextFieldDelegate, UITabBarDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ViewController *viewController;
@property (nonatomic) PostingViewController *postScreen;
@property (nonatomic) PostsViewController *loggedIn;
@property (nonatomic) SearchViewController *searchScreen;
@property (nonatomic) SettingsViewController *settingsPage;
@property (nonatomic) ConversationsViewController *conversationsPage;
@property (nonatomic) NSMutableArray<UIViewController*> *postsPresentedViewControllers;
@property (nonatomic) NSMutableArray<UIViewController*> *searchPresentedViewControllers;
@property (nonatomic) NSMutableArray<UIViewController*> *settingsPresentedViewControllers;
@property (nonatomic) NSMutableArray<UIViewController*> *conversationsPresentedViewControllers;
/*
@property (nonatomic) UITabBarItem *homeButton;
@property (nonatomic) UITabBarItem *postButton;
@property (nonatomic) UITabBarItem *searchButton;
@property (nonatomic) UITabBarItem *settingsButton;
 */
- (void)logUser;
- (void)logOut;
+ (int)getUserID;
+ (BOOL)getAdsRemoved;
+ (void)setAdsRemoved:(BOOL)removedAds;
+ (UITabBar*)getTabBar;
+ (void)hideTabBar;
+ (void)showTabBar;

@end

#endif
