//
//  ConversationsViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 12/15/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef ConversationsViewController_h
#define ConversationsViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
//#import "PostView.h"
#import "MessagesViewController.h"

@interface ConversationsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int numConversations;
@property (nonatomic) int conversationsLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableArray<NSDictionary*> *conversationData;
@property (nonatomic) UITableView *conversations;

@end

#endif /* ConversationsViewController_h */
