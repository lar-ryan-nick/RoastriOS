//
//  PostViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 10/28/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef PostViewController_h
#define PostViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "ProfileViewController.h"
#import "CommentsViewController.h"

@interface PostViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) PostView *postView;
//@property (nonatomic) NSMutableDictionary *tableData;
//@property (nonatomic) UIBarButtonItem *share;
//@property (nonatomic) UIBarButtonItem *username;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) CommentsViewController *comments;
- (instancetype)initWithPostID:(int)postID;
- (void)deletePost;

@end

#endif /* PostViewController_h */
