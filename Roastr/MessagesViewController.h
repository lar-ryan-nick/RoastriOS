//
//  MessagesViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 12/12/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef MessagesViewController_h
#define MessagesViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "ProfileViewController.h"
//@import SocketIO;

@interface MessagesViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int user1ID;
@property (nonatomic) int user2ID;
@property (nonatomic) int numMessages;
@property (nonatomic) int messagesLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableDictionary *tableData;
@property (nonatomic) UITableView *messages;
@property (nonatomic) UITableView *users;
@property (nonatomic) NSMutableArray<NSDictionary*> *messageData;
@property (nonatomic) UITextField *messageField;
@property (nonatomic) UIButton *send;
- (instancetype)initWithUser1:(int)user1ID user2:(int)user2ID;
- (void)refreshMessages;

@end

#endif /* MessagesViewController_h */
