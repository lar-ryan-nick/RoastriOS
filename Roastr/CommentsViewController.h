//
//  CommentsViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 11/12/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef CommentsViewController_h
#define CommentsViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "ProfileViewController.h"
//#import "CommentsTableViewCell.h"

@interface CommentsViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int postID;
@property (nonatomic) int numComments;
@property (nonatomic) int commentsLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableDictionary *tableData;
@property (nonatomic) UITableView *comments;
@property (nonatomic) UITableView *users;
@property (nonatomic) NSMutableArray<NSDictionary*> *commentData;
@property (nonatomic) UITextField *commentField;
@property (nonatomic) UIButton *roast;
- (instancetype)initWithPostID:(int)postID;

@end

#endif /* CommentsViewController_h */
