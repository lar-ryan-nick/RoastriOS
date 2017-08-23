//
//  ViewController.h
//  Roastr
//
//  Created by Ryan Wiener on 1/29/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#ifndef ViewController_h
#define ViewController_h

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) UILabel *userOk;
@property (nonatomic) UILabel *roastr;
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *passwordLabel;
@property (nonatomic) UIButton *logIn;
@property (nonatomic) UIButton *signIn;
@property (nonatomic) NSString *passwordText;
@property (nonatomic) UITextField *username;
@property (nonatomic) UITextField *password;
- (void)checkUsername:(NSString*)user completionHandler:(void (^)(BOOL taken))completionHandler;
- (void)addUser:(NSString*)user completionHandler:(void (^)(BOOL created))completionHandler;
- (void)checkPasswordWithUser:(NSString*)user completionHandler:(void (^)(BOOL correct))completionHandler;

@end

#endif
