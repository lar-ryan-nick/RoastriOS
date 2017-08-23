//
//  PostsViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 3/3/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef PostsViewController_h
#define PostsViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "ProfileViewController.h"
#import "PostViewController.h"
#import "CommentsViewController.h"

@interface PostsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) NSMutableArray *recentpostViews;
@property (nonatomic) NSMutableArray *popularpostViews;
@property (nonatomic) UISegmentedControl *sortingOptions;
@property (nonatomic) UIBarButtonItem *username;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) int numPosts;
@property (nonatomic) BOOL loading;
@property (nonatomic) int recentPostsLoaded;
@property (nonatomic) int popularPostsLoaded;
- (void)deletePost:(int)postID;
- (void)reload;

@end

#endif /* PostsViewController_h */
