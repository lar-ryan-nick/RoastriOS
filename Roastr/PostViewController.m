//
//  PostViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 10/28/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "PostViewController.h"
#import "AppDelegate.h"

@implementation PostViewController
{
    NSURLSession *session;
    UIActivityIndicatorView *activityIndicator;
    UITableViewController *tableViewController;
}

- (instancetype)initWithPostID:(int)postID
{
	_postView = [[PostView alloc] initWithPostID:postID width:self.view.bounds.size.width completionHandler:^(BOOL completed){
		_postView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [_postView getHeight]);
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 109)];
		/*
		_comments = [[CommentsViewController alloc] initWithPostID:postID];
		[self presentViewController:_comments animated:NO completion:^{
			[_comments dismissViewControllerAnimated:NO completion:nil];
			_comments.comments.frame = CGRectMake(0, [_postView getHeight], self.view.bounds.size.width, _comments.comments.bounds.size.height);
			_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, [_postView getHeight] + _comments.comments.bounds.size.height);
			[_scrollView addSubview:_comments.comments];
		}];
		 */
		_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, [_postView getHeight]);
		_scrollView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
        [_scrollView addSubview:_postView];
		[self.view addSubview:_scrollView];
	}];
	session = [NSURLSession sharedSession];
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	bottomView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	[self.view addSubview:bottomView];
	CGSize size = [@"Roastr" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:30]}];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2, 20, size.width, 40)];
	title.text = @"Roastr";
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	[self.view addSubview:title];
	UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2 - 40, 20, 40, 40)];
	logo.image = [UIImage imageNamed:@"roastrtransparent.png"];
	[self.view addSubview:logo];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	backButton.frame = CGRectMake(5, 20, self.view.bounds.size.width / 8, 35);
	[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	[self.view addSubview:[AppDelegate getTabBar]];
}

- (void)deletePost
{
	UIAlertController *warning = [UIAlertController alertControllerWithTitle:@"Delete Post?" message:@"Are you sure you want to delete the post?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Yes, delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/removePost.php?arg1=%d", _postView.postID]];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
												completionHandler:
									  ^(NSData *data, NSURLResponse *response, NSError *error) {
										  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  NSLog(@"%@", text);
										  [self dismissSelf:text];
									  }];
		[task resume];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No, don't delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
		[warning dismissViewControllerAnimated:YES completion:nil];
	}];
	[warning addAction:cancel];
	[warning addAction:delete];
	[self presentViewController:warning animated:YES completion:nil];
}

- (IBAction)dismissSelf:(id)sender
{
	[self.presentingViewController.view addSubview:[AppDelegate getTabBar]];
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}

@end
