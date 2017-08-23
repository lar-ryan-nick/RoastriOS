//
//  ImageViewController.h
//  Learn
//
//  Created by Ryan Wiener on 10/20/15.
//  Copyright © 2015 Computer Science Team. All rights reserved.
//

#ifndef ImageViewController_h
#define ImageViewController_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Base64.h"
@import AVFoundation;

@interface PostingViewController : UIViewController <UINavigationControllerDelegate, UIScrollViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic) UITextView *textView;
@property (nonatomic) UIScrollView *cropper;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIToolbar *toolBar;
@property (nonatomic) UIBarButtonItem *photoLibraryButton;
@property (nonatomic) UIBarButtonItem *cameraButton;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) UIButton *upload;
@property (nonatomic) UITableView *users;
@property (nonatomic) NSMutableDictionary *tableData;

@end


#endif /* ImageViewController_h */
