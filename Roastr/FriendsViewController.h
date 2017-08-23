//
//  FriendsViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 12/20/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef FriendsViewController_h
#define FriendsViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "ProfileViewController.h"

@interface FriendsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int userID;
@property (nonatomic) int numFriends;
@property (nonatomic) int friendsLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableArray<NSDictionary*> *friendData;
@property (nonatomic) UITableView *friends;
- (instancetype)initWithUserID:(int)userID;

@end

#endif /* FriendsViewController_h */
