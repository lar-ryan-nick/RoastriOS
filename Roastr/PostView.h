//
//  PostView.h
//  Roastr
//
//  Created by Ryan Wiener on 7/21/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef PostView_h
#define PostView_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Base64.h"
#import "LikesViewController.h"
@import GoogleMobileAds;

@interface PostView : UIView <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate>

@property (nonatomic) UIToolbar *topBar;
@property (nonatomic) UIToolbar *bottomBar;
@property (nonatomic) UITextView *caption;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) GADNativeExpressAdView *nativeExpressAdView;
@property (nonatomic) int postID;
@property (nonatomic) int userID;
@property (nonatomic) BOOL loaded;
@property (nonatomic) BOOL captionLoaded;
@property (nonatomic) BOOL imageLoaded;
@property (nonatomic) BOOL userIDLoaded;
@property (nonatomic) BOOL bottomLoaded;
- (instancetype)initWithUser:(int)user index:(int)index width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler;
- (instancetype)initWithPostID:(int)id width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler;
- (instancetype)initWithMostHatesUser:(int)user index:(int)index width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler;
- (instancetype)initForAddWithViewController:(UIViewController*)viewController width:(float)width;
- (int)getHeight;

@end

#endif /* PostView_h */
