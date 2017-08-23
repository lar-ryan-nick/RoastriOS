//
//  LikesViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 11/26/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#ifndef LikesViewController_h
#define LikesViewController_h

#import <UIKit/UIKit.h>
#import "Base64.h"
#import <Foundation/Foundation.h>
#import "PostView.h"
#import "ProfileViewController.h"

@interface LikesViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) int postID;
@property (nonatomic) int numLikes;
@property (nonatomic) int likesLoaded;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSMutableArray<NSDictionary*> *likeData;
@property (nonatomic) UITableView *likes;
- (instancetype)initWithPostID:(int)postID;

@end

#endif /* LikesViewController_h */
