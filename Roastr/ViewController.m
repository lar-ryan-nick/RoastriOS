//
//  ViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 1/29/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSURLSession *session;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _passwordText = @"";
    session = [NSURLSession sharedSession];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
    [self.view addSubview:topView];
    _roastr = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height / 5 - 20)];
    _roastr.text = @"Roastr";
    _roastr.textColor = [UIColor orangeColor];
    _roastr.textAlignment = NSTextAlignmentCenter;
	_roastr.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:80];
	_logIn = [UIButton buttonWithType:UIButtonTypeSystem];
	[_logIn addTarget:self action:@selector(logUser:) forControlEvents:UIControlEventTouchUpInside];
	_logIn.frame = CGRectMake(0, 4 * self.view.bounds.size.height / 5, self.view.bounds.size.width, self.view.bounds.size.height / 5);
	[_logIn setTitle:@"Log In" forState:UIControlStateNormal];
	_logIn.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
	[_logIn setTintColor:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]];
	_signIn = [UIButton buttonWithType:UIButtonTypeSystem];
	[_signIn addTarget:self action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
	_signIn.frame = CGRectMake(0, 3 * self.view.bounds.size.height / 5, self.view.bounds.size.width, self.view.bounds.size.height / 5);
	[_signIn setTitle:@"Create Account" forState:UIControlStateNormal];
	_signIn.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
	[_signIn setTintColor:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]];
    _username = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 5 + 40, self.view.bounds.size.width, self.view.bounds.size.height / 5 - 40)];
    _username.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    _username.textColor = [UIColor whiteColor];
    _username.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
    _username.textAlignment = NSTextAlignmentCenter;
    //_username.borderStyle = UITextBorderStyleLine;
    _username.tag = 1;
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.delegate = self;
    NSString *userText = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (userText)
        _username.text = userText;
    _password = [[UITextField alloc] initWithFrame:CGRectMake(0, 2 * self.view.bounds.size.height / 5 + 40, self.view.bounds.size.width, self.view.bounds.size.height / 5 - 40)];
    _password.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:25];
    _password.textColor = [UIColor blackColor];
    _password.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
    _password.textAlignment = NSTextAlignmentCenter;
    //_password.borderStyle = UITextBorderStyleLine;
    _password.tag = 2;
    _password.autocorrectionType = UITextAutocorrectionTypeNo;
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.delegate = self;
    if (_userOk == nil)
    {
        _userOk = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 5, self.view.bounds.size.width, 40)];
        _userOk.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		_userOk.backgroundColor= _username.backgroundColor;
    }
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 5, self.view.bounds.size.width, 40)];
    _usernameLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	_usernameLabel.text = @" Username";
	_usernameLabel.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
    _passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 *self.view.bounds.size.height / 5, self.view.bounds.size.width, 40)];
    _passwordLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	_passwordLabel.text = @" Password";
	_passwordLabel.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
    NSString *passText = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (passText)
    {
        _passwordText = passText;
        for (int i = 0; i < _passwordText.length; i++)
        {
            _password.text = [_password.text stringByAppendingString:@"😡"];
        }
     }
    self.view.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
    [self.view addSubview:_username];
    [self.view addSubview:_usernameLabel];
    //[self.view addSubview:_userOk];
    [self.view addSubview:_password];
    [self.view addSubview:_passwordLabel];
    [self.view addSubview:_roastr];
	[self.view addSubview:_logIn];
	[self.view addSubview:_signIn];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    if ([string isEqualToString:@" "])
        string = @"_";
    if (textField.tag == 1)
    {
		[self.view addSubview:_userOk];
		_userOk.textColor = [UIColor blackColor];
		textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (textField.text.length != 0)
        {
			NSLog(@"Fuck");
            [self checkUsername:textField.text completionHandler:^(BOOL taken){
                if (taken)
                {
                    _userOk.text = @"That username is already taken";
                }
                else
                {
                    _userOk.text = @"That username is available";
                }
                }];
            return NO;
        }
    }
    else if (textField.tag == 2)
    {
        NSRange range2 = NSMakeRange(range.location / [@"😡" length], range.length / [@"😡" length]);
        _passwordText = [_passwordText stringByReplacingCharactersInRange:range2 withString:string];
        textField.text = @"";
        for (int i = 0; i < _passwordText.length; i++)
        {
            textField.text = [textField.text stringByAppendingString:@"😡"];
        }
        NSLog(@"%@", _passwordText);
        return NO;
     }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)checkUsername:(NSString*)user completionHandler:(void (^)(BOOL taken))completionHandler
{
	NSLog(@"Ass");
    user = [user stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://roastr2.herokuapp.com/checkUser.php?arg1='%@'", user];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  if (error != nil)
									  {
										  NSLog(@"%@", [error localizedDescription]);
									  }
									  else
									  {
										NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										NSLog(@"Output: %@", text);
										_userOk.textColor = [UIColor blackColor];
										if ([@"User already exists" isEqualToString:text])
										{
											dispatch_async(dispatch_get_main_queue(), ^{
												completionHandler(YES);
											});
										}
										else
										{
											dispatch_async(dispatch_get_main_queue(), ^{
												completionHandler(NO);
											});
										}
									  }
                                  }];
    [task resume];
}

- (IBAction)logUser:(UIButton*)sender
{
	[self checkUsername:_username.text completionHandler:^(BOOL taken){
		if (taken)
		{
			[self checkPasswordWithUser:_username.text completionHandler:^(BOOL correct){
				if (correct)
				{
					AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
					[appDelegate logUser];
				}
			}];
		}
		else
		{
			_userOk.text = @"That username has not been created yet.";
			_userOk.textColor = [UIColor blackColor];
		}
	}];
}

- (void)addUser:(NSString*)user completionHandler:(void (^)(BOOL created))completionHandler
{
    if ([user isEqualToString:@""] || [_passwordText isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Can't create Account" message:@"Please enter a username and password before hitting create account." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        user = [user stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        _passwordText = [_passwordText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://roastr2.herokuapp.com/addUser.php?username='%@'&password='%@'", user, _passwordText];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"%@",text);
                                      if ([@"User already exists" isEqualToString:text])
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(NO);
                                          });
                                      }
                                      else
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(YES);
                                          });
                                      }
                                  }];
    [task resume];
    }
}

- (void)addUser:(UIButton*)sender
{
	[self addUser:_username.text completionHandler:^(BOOL created){
		if (created)
		{
			[self logUser:sender];
		}
	}];
}

- (void)checkPasswordWithUser:(NSString*)user completionHandler:(void (^)(BOOL correct))completionHandler
{
    NSLog(@"%@ %@", user, _passwordText);
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://roastr2.herokuapp.com/checkPassword.php?arg1='%@'&arg2=%@", user, _passwordText];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"%@",text);
                                      if ([@"Password is correct" isEqualToString:text])
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              _userOk.text = @"That password is correct";
                                              completionHandler(YES);
                                          });
                                      }
                                      else
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              _userOk.text = @"That password is incorrect";
                                              completionHandler(NO);
                                          });
                                      }
                                  }];
    [task resume];
}

@end
