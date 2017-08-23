//
//  ProfileViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 5/20/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef ProfileViewController_h
#define ProfileViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "CommentsViewController.h"
#import "MessagesViewController.h"
#import "FriendsViewController.h"
//@import GoogleMobileAds;

@interface ProfileViewController : UIViewController <UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) UIView *topMiddleView;
@property (nonatomic) UIView *bottomMiddleView;
//@property (nonatomic) UIView *bottomView;
@property (nonatomic) UILabel *username;
@property (nonatomic) UIImageView *profilePicture;
@property (nonatomic) NSMutableArray *recentPostViews;
@property (nonatomic) NSMutableArray *popularPostViews;
@property (nonatomic) UISegmentedControl *sortingOptions;
//@property (nonatomic) NSMutableDictionary *tableData;
//@property (nonatomic) UIBarButtonItem *share;
//@property (nonatomic) UIBarButtonItem *trash;
//@property (nonatomic) NSMutableArray *shares;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIViewController *cropImage;
@property (nonatomic) NSData *imageData;
@property (nonatomic) NSString *caption;
@property (nonatomic) BOOL loading;
//@property (nonatomic) BOOL infoShowing;
@property (nonatomic) int userID;
@property (nonatomic) int numPosts;
@property (nonatomic) int recentPostsLoaded;
@property (nonatomic) int popularPostsLoaded;
- (instancetype)initWithUserID:(int)userID;
- (void)deletePost:(int)postID;

@end


#endif /* ProfileViewController_h */
