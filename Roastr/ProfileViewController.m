//
//  ProfileViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 5/20/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "PostsViewController.h"
#import "AppDelegate.h"

@implementation ProfileViewController
{
	NSURLSession *session;
	float previousOffSet;
	float otherOffSet;
	UIActivityIndicatorView *activityIndicator;
}

- (instancetype)initWithUserID:(int)userID
{
	self = [super init];
	_userID = userID;
	session = [NSURLSession sharedSession];
	[self getUserDataWithCompletionHandler:^(NSString *username, UIImage *profilePicture, int numPosts, int numLikes, int numFriends, int friended){
		_numPosts = numPosts;
		_recentPostsLoaded = 0;
		_recentPostViews = [[NSMutableArray alloc] init];
		_popularPostsLoaded = 0;
		_popularPostViews = [[NSMutableArray alloc] init];
		_loading = YES;
		if (_numPosts > 0)
		{
			if (activityIndicator == nil)
			{
				activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				activityIndicator.frame = CGRectMake(0, _scrollView.bounds.size.height - 40, self.view.bounds.size.width, 40);
			}
			[_scrollView addSubview:activityIndicator];
			[activityIndicator startAnimating];
		}
		[self loadPosts:4];
		_sortingOptions.selectedSegmentIndex = 1;
		[self loadPosts:4];
		_sortingOptions.selectedSegmentIndex = 0;
		_profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bottomMiddleView.bounds.size.height, _bottomMiddleView.bounds.size.height)];
		_profilePicture.image = profilePicture;
		_profilePicture.contentScaleFactor = UIViewContentModeScaleAspectFit;
		_profilePicture.userInteractionEnabled = YES;
		[_bottomMiddleView addSubview:_profilePicture];
		//NSLog(@"%@", profilePicture);
		NSLog(@"%d %d", numFriends, friended);
		if (_userID == [AppDelegate getUserID])
		{
			UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentProfileUploadOptions:)];
			[_profilePicture addGestureRecognizer:tapImage];
		}
		else
		{
			UIButton *message = [UIButton buttonWithType:UIButtonTypeCustom];
			message.frame = CGRectMake(self.view.bounds.size.width - 35, 0, 35, 35);
			[message setImage:[UIImage imageNamed:@"campfireHighlighted.png"] forState:UIControlStateNormal];
			[message addTarget:self action:@selector(loadMessageViewController:) forControlEvents:UIControlEventTouchUpInside];
			[_topMiddleView addSubview:message];
			NSLog(@"%d", friended);
			if (friended == 2)
			{
				UIButton *requestEnemy = [UIButton buttonWithType:UIButtonTypeSystem];
				requestEnemy.frame = CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3);
				requestEnemy.tintColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
				[requestEnemy setTitle:@"Remove enemy" forState:UIControlStateNormal];
				requestEnemy.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
				[requestEnemy addTarget:self action:@selector(removeFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
				[_bottomMiddleView addSubview:requestEnemy];
			}
			else if (friended == 1)
			{
				UIButton *requestEnemy = [UIButton buttonWithType:UIButtonTypeSystem];
				requestEnemy.frame = CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3);
				requestEnemy.tintColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
				[requestEnemy setTitle:@"Accept enemy request" forState:UIControlStateNormal];
				requestEnemy.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
				[requestEnemy addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
				[_bottomMiddleView addSubview:requestEnemy];
			}
			else if (friended == 0)
			{
				UIButton *requestEnemy = [UIButton buttonWithType:UIButtonTypeSystem];
				requestEnemy.frame = CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3);
				requestEnemy.tintColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
				[requestEnemy setTitle:@"Cancel enemy request" forState:UIControlStateNormal];
				requestEnemy.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
				[requestEnemy addTarget:self action:@selector(removeFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
				[_bottomMiddleView addSubview:requestEnemy];
			}
			else
			{
				UIButton *requestEnemy = [UIButton buttonWithType:UIButtonTypeSystem];
				requestEnemy.frame = CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3);
				requestEnemy.tintColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
				[requestEnemy setTitle:@"Send enemy request" forState:UIControlStateNormal];
				requestEnemy.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
				[requestEnemy addTarget:self action:@selector(addFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
				[_bottomMiddleView addSubview:requestEnemy];
			}
		}
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
		backButton.frame = CGRectMake(5, 0, self.view.bounds.size.width / 8, 35);
		[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
		[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
		[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
		[_topMiddleView addSubview:backButton];
		_username = [[UILabel alloc] initWithFrame:CGRectMake(backButton.frame.origin.x + backButton.frame.size.width, 0, self.view.bounds.size.width - (backButton.frame.origin.x + backButton.frame.size.width + 35), 35)];
		_username.text = username;
		_username.textAlignment = NSTextAlignmentCenter;
		_username.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		_username.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
		_username.adjustsFontSizeToFitWidth = YES;
		[_topMiddleView addSubview:_username];
		UILabel *postNumber = [[UILabel alloc] initWithFrame:CGRectMake(_bottomMiddleView.bounds.size.height, 5, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3 - 5)];
		postNumber.text = [NSString stringWithFormat:@"%d", _numPosts];
		postNumber.textAlignment = NSTextAlignmentCenter;
		postNumber.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
		postNumber.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
		postNumber.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:postNumber];
		UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(_bottomMiddleView.bounds.size.height, postNumber.bounds.size.height, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3)];
		postLabel.text = @"Posts";
		postLabel.textAlignment = NSTextAlignmentCenter;
		postLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		postLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:25];
		postLabel.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:postLabel];
		UILabel *likeNumber = [[UILabel alloc] initWithFrame:CGRectMake(2 * _bottomMiddleView.bounds.size.height, 5, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3 - 5)];
		likeNumber.text = [NSString stringWithFormat:@"%d", numLikes];
		likeNumber.textAlignment = NSTextAlignmentCenter;
		likeNumber.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
		likeNumber.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
		likeNumber.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:likeNumber];
		UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * _bottomMiddleView.bounds.size.height, likeNumber.bounds.size.height, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3)];
		likeLabel.text = @"Hates";
		likeLabel.textAlignment = NSTextAlignmentCenter;
		likeLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		likeLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:25];
		likeLabel.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:likeLabel];
		UILabel *friendNumber = [[UILabel alloc] initWithFrame:CGRectMake(3 * _bottomMiddleView.bounds.size.height, 5, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3 - 5)];
		friendNumber.text = [NSString stringWithFormat:@"%d", numFriends];
		friendNumber.textAlignment = NSTextAlignmentCenter;
		friendNumber.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
		friendNumber.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
		friendNumber.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:friendNumber];
		UILabel *friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(3 * _bottomMiddleView.bounds.size.height, likeNumber.bounds.size.height, _bottomMiddleView.bounds.size.height, (_bottomMiddleView.bounds.size.height) / 3)];
		friendLabel.text = @"Enemies";
		friendLabel.textAlignment = NSTextAlignmentCenter;
		friendLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		friendLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:25];
		friendLabel.adjustsFontSizeToFitWidth = YES;
		[_bottomMiddleView addSubview:friendLabel];
		UITapGestureRecognizer *tapFriend =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadFriendsViewController:)];
		[friendNumber addGestureRecognizer:tapFriend];
		tapFriend =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadFriendsViewController:)];
		[friendLabel addGestureRecognizer:tapFriend];
		friendLabel.userInteractionEnabled = YES;
		friendNumber.userInteractionEnabled = YES;
	}];
	return self;
}

- (void)getUserDataWithCompletionHandler:(void (^)(NSString *username, UIImage *profilePicture, int numPosts, int numLikes, int numFriends, int friended))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getUserData.php?arg1=%d&arg2=%d", _userID, [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  if (error != nil)
									  {
										  NSLog(@"%@", [error localizedDescription]);
									  }
									  else
									  {
										  NSDictionary *postData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
										  if (error == nil)
										  {
											  NSData *imageData = [Base64 decode:[postData valueForKey:@"profilePicture"]];
											  UIImage *image = [UIImage imageWithData:imageData];
											  NSLog(@"%@", image);
											  image = [self roundedRectImageFromImage:image size:CGSizeMake(self.view.bounds.size.width / 4, self.view.bounds.size.width / 4) withCornerRadius:self.view.bounds.size.width / 8];
											  dispatch_async(dispatch_get_main_queue(), ^{
												  completionHandler([postData valueForKey:@"username"], image, [[postData valueForKey:@"posts"] intValue], [[postData valueForKey:@"likes"] intValue], [[postData valueForKey:@"friends"] intValue], [[postData valueForKey:@"friended"] intValue]);
											  });
										  }
										  else
										  {
											  NSLog(@"%@", [error localizedDescription]);
										  }
									  }
								  }];
	[task resume];
}

- (void)viewDidLoad
{
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	_topMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 35)];
	_topMiddleView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	_topMiddleView.autoresizesSubviews = NO;
	[self.view addSubview:_topMiddleView];
	_bottomMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.width / 4)];
	_bottomMiddleView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_bottomMiddleView.autoresizesSubviews = NO;
	[self.view addSubview:_bottomMiddleView];
	_sortingOptions = [[UISegmentedControl alloc] initWithItems:@[@"Most Recents", @"Most Hates"]];
	_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
	[_sortingOptions addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
	[_sortingOptions setSelectedSegmentIndex:0];
	[_sortingOptions setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[_sortingOptions setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateNormal];
	[_sortingOptions setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateSelected];
	[_sortingOptions setBackgroundColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
	[self.view addSubview:_sortingOptions];
	/*
	 _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 55 + self.view.bounds.size.width / 4, self.view.bounds.size.width, 10)];
	 _bottomView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	 _bottomView.autoresizesSubviews = NO;
	 [self.view addSubview:_bottomView];
	 */
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30 + _sortingOptions.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - (79 + _sortingOptions.frame.origin.y))];
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
	_scrollView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	_scrollView.delegate = self;
	[self.view addSubview:[AppDelegate getTabBar]];
	//_scrollView.bounces = NO;
	[self.view addSubview:_scrollView];
}

- (void)changeView:(id)sender
{
	[self showLoadedPosts];
	_scrollView.delegate = nil;
	int temp = _scrollView.contentOffset.y;
	_scrollView.contentOffset = CGPointMake(0, otherOffSet);
	otherOffSet = temp;
	_scrollView.delegate = self;
}

- (void)loadPosts:(int)num
{
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		for (int i = _recentPostsLoaded; i < num + _recentPostsLoaded && i < _numPosts; i++)
		{
			PostView *postView = [[PostView alloc] initWithUser:_userID index:_numPosts - i width:self.view.bounds.size.width completionHandler:^(BOOL completed){
				_recentPostsLoaded++;
				[self showLoadedPosts];
				if (_recentPostsLoaded % num == 0 || _recentPostsLoaded == _numPosts)
				{
					if ([activityIndicator isAnimating])
					{
						[activityIndicator stopAnimating];
						[activityIndicator removeFromSuperview];
						_loading = NO;
					}
				}
			}];
			[_recentPostViews addObject:postView];
		}
		if (![AppDelegate getAdsRemoved])
		{
			PostView *ad = [[PostView alloc] initForAddWithViewController:self width:self.view.bounds.size.width];
			[_recentPostViews addObject:ad];
		}
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		for (int i = _popularPostsLoaded; i < num + _popularPostsLoaded && i < _numPosts; i++)
		{
			PostView *postView = [[PostView alloc] initWithMostHatesUser:_userID index:i + 1 width:self.view.bounds.size.width completionHandler:^(BOOL completed){
				_popularPostsLoaded++;
				[self showLoadedPosts];
				if (_popularPostsLoaded % num == 0 || _popularPostsLoaded == _numPosts)
				{
					if ([activityIndicator isAnimating])
					{
						[activityIndicator stopAnimating];
						[activityIndicator removeFromSuperview];
						_loading = NO;
					}
				}
			}];
			[_popularPostViews addObject:postView];
		}
		if (![AppDelegate getAdsRemoved])
		{
			PostView *ad = [[PostView alloc] initForAddWithViewController:self width:self.view.bounds.size.width];
			[_popularPostViews addObject:ad];
		}
	}
}

- (void)showLoadedPosts
{
	_scrollView.delegate = nil;
	float scrollOffset = _scrollView.contentOffset.y;
	_scrollView.contentSize = CGSizeZero;
	for (UIView *subview in _scrollView.subviews)
	{
		[subview removeFromSuperview];
	}
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		for (PostView *postView in _recentPostViews)
		{
			//[postView removeFromSuperview];
			if (postView.loaded)
			{
				postView.frame = CGRectMake(0, _scrollView.contentSize.height, self.view.bounds.size.width, [postView getHeight]);
				_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _scrollView.contentSize.height + [postView getHeight] + 40);
				[_scrollView addSubview:postView];
			}
		}
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		for (PostView *postView in _popularPostViews)
		{
			//[postView removeFromSuperview];
			if (postView.loaded)
			{
				postView.frame = CGRectMake(0, _scrollView.contentSize.height, self.view.bounds.size.width, [postView getHeight]);
				_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _scrollView.contentSize.height + [postView getHeight] + 40);
				[_scrollView addSubview:postView];
			}
		}
	}
	_scrollView.contentOffset = CGPointMake(0, scrollOffset);
	_scrollView.delegate = self;
}

- (PostView*)getPostViewWithPostID:(int)id
{
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		for (PostView *postView in _recentPostViews)
		{
			if (postView.postID == id)
			{
				return postView;
			}
		}
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		for (PostView *postView in _popularPostViews)
		{
			if (postView.postID == id)
			{
				return postView;
			}
		}
	}
	return nil;
}

- (void)deletePost:(int)postID
{
	UIAlertController *warning = [UIAlertController alertControllerWithTitle:@"Delete Post?" message:@"Are you sure you want to delete the post?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Yes, delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/removePost.php?arg1=%d", postID]];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
												completionHandler:
									  ^(NSData *data, NSURLResponse *response, NSError *error) {
										  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  NSLog(@"%@", text);
										  PostView *postView = [self getPostViewWithPostID:postID];
										  [_recentPostViews removeObject:postView];
										  _recentPostsLoaded--;
										  _numPosts--;
										  dispatch_async(dispatch_get_main_queue(), ^{
											  [self showLoadedPosts];
										  });
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

- (void)getImageCountWithIndex:(int)index completionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getImageCount.php?arg1=%d", index]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numPosts = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
								  }];
	[task resume];
}

- (void)addFriendRequest:(id)sender
{
	[sender removeFromSuperview];
	UILabel *enemy = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3)];
	enemy.text = [NSString stringWithFormat:@"Enemy request send"];
	enemy.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	enemy.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
	enemy.textAlignment = NSTextAlignmentCenter;
	enemy.adjustsFontSizeToFitWidth = YES;
	[_bottomMiddleView addSubview:enemy];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/addFriendRequest.php?user1=%d&user2=%d", [AppDelegate getUserID], _userID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
								  }];
	[task resume];
}

- (void)acceptFriendRequest:(id)sender
{
	[sender removeFromSuperview];
	UILabel *enemy = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3)];
	enemy.text = [NSString stringWithFormat:@"%@ is an enemy", _username.text];
	enemy.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	enemy.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
	enemy.textAlignment = NSTextAlignmentCenter;
	enemy.adjustsFontSizeToFitWidth = YES;
	[_bottomMiddleView addSubview:enemy];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/acceptFriendRequestBetweenUsers.php?user1=%d&user2=%d", _userID, [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
								  }];
	[task resume];
}

- (void)removeFriendRequest:(id)sender
{
	[sender removeFromSuperview];
	UILabel *enemy = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 4, 2 * _bottomMiddleView.bounds.size.height / 3, 3 * self.view.bounds.size.width / 4, _bottomMiddleView.bounds.size.height / 3)];
	enemy.text = [NSString stringWithFormat:@"%@ is no longer an enemy", _username.text];
	enemy.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	enemy.textColor = [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1];
	enemy.textAlignment = NSTextAlignmentCenter;
	enemy.adjustsFontSizeToFitWidth = YES;
	[_bottomMiddleView addSubview:enemy];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/removeFriendRequestBetweenUsers.php?user1=%d&user2=%d", _userID, [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
								  }];
	[task resume];
}

- (IBAction)dismissSelf:(id)sender
{
	/*
	 UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	 int i;
	 for (i =0; viewController != nil; i++)
	 {
		viewController = viewController.presentedViewController;
	 }
	 NSLog(@"%d", i);
	 viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	 for (int j = 0; j < i - 1; j++)
	 {
		viewController = viewController.presentedViewController;
	 }
	 */
	[self.presentingViewController.view addSubview:[AppDelegate getTabBar]];
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (void)loadMessageViewController:(id)sender
{
	MessagesViewController *messageViewController = [[MessagesViewController alloc] initWithUser1:[AppDelegate getUserID] user2:_userID];
	[self presentViewController:messageViewController animated:YES completion:nil];
}

- (void)loadFriendsViewController:(id)sender
{
	FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithUserID:_userID];
	[self presentViewController:friendsViewController animated:YES completion:nil];
}

- (void)presentProfileUploadOptions:(UITapGestureRecognizer*)sender
{
	NSLog(@"Fuck");
	UIAlertController *uploadSelections = [UIAlertController alertControllerWithTitle:@"Upload Profile Picture From" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"PhotoLibrary" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}];
	[uploadSelections addAction:photoLibrary];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
			[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
		}];
		[uploadSelections addAction:camera];
	}
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
		[uploadSelections dismissViewControllerAnimated:YES completion:nil];
		[AppDelegate showTabBar];
	}];
	[uploadSelections addAction:cancel];
	//[AppDelegate hideTabBar];
	[self presentViewController:uploadSelections animated:YES completion:nil];
	[AppDelegate hideTabBar];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.sourceType = sourceType;
	imagePickerController.delegate = self;
	//[AppDelegate hideTabBar];
	if (sourceType == UIImagePickerControllerSourceTypeCamera)
	{
		//The user wants to use the camera interface. Set up our custom overlay view for the camera.
		imagePickerController.showsCameraControls = YES;
	}
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[AppDelegate showTabBar];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissViewController:(UIBarButtonItem*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:nil];
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	_cropImage = [[UIViewController alloc] init];
	UIToolbar *options = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, _cropImage.view.bounds.size.width, 40)];
	options.barTintColor = [UIColor blackColor];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
	[cancel setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addImage:)];
	[done setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
	[options setItems:@[cancel, space, done]];
	[_cropImage.view addSubview:options];
	UIScrollView *cropper = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, _cropImage.view.bounds.size.width, _cropImage.view.bounds.size.width)];
	cropper.maximumZoomScale = 5;
	cropper.minimumZoomScale = 1;
	cropper.delegate = self;
	cropper.tag = 1;
	UIImageView *selectedImage = [[UIImageView alloc] initWithFrame:cropper.bounds];
	selectedImage.tag = 2;
	selectedImage.contentMode = UIViewContentModeScaleAspectFit;
	[selectedImage setImage:image];
	[cropper addSubview:selectedImage];
	[_cropImage.view addSubview:cropper];
	UIImageView *cover = [[UIImageView alloc] initWithFrame:cropper.frame];
	[cover setImage:[UIImage imageNamed:@"cover.png"]];
	cover.alpha = .5;
	cover.tag = 3;
	[_cropImage.view addSubview:cover];
	[self presentViewController:_cropImage animated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (void)addImage:(UIBarButtonItem*)sender
{
	UIView *cover = [_cropImage.view viewWithTag:3];
	cover.alpha = 0;
	CGRect grabRect = [_cropImage.view viewWithTag:1].frame;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		UIGraphicsBeginImageContextWithOptions(grabRect.size, NO, [UIScreen mainScreen].scale);
	}
	else
	{
		UIGraphicsBeginImageContext(grabRect.size);
	}
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(ctx, -grabRect.origin.x, -grabRect.origin.y);
	[_cropImage.view.layer renderInContext:ctx];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGRectIsNull(grabRect);
	image = [self roundedRectImageFromImage:image size:_profilePicture.bounds.size withCornerRadius:_profilePicture.center.x];
	[_profilePicture setImage:image];
	NSData *imageData = UIImageJPEGRepresentation(image, 0);
	NSString *imageString = [Base64 encode:imageData];
	imageString = [imageString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	NSData *requestData = [[NSData alloc] initWithData:[[NSString stringWithFormat:@"picture=%@&userID=%d", imageString, [AppDelegate getUserID]] dataUsingEncoding:NSUTF8StringEncoding]];
	NSURL *url= [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/setProfilePicture.php"]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:requestData];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  if (error != nil)
									  {
										  NSLog(@"%@", [error localizedDescription]);
									  }
									  else
									  {
										  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  NSLog(@"%@", text);
									  }
								  }];
	[task resume];
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (UIImage*)roundedRectImageFromImage:(UIImage *)image size:(CGSize)imageSize withCornerRadius:(float)cornerRadius
{
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	CGRect bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
	[[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:cornerRadius] addClip];
	[image drawInRect:bounds];
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return finalImage;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	UIView *cropper = [_cropImage.view viewWithTag:1];
	return [cropper viewWithTag:2];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//if (!decelerate)
	//{
	if (_bottomMiddleView.bounds.size.height < self.view.bounds.size.width / 8)
	{
		[UIView animateWithDuration:.5 animations:^{
			_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, 0);
			//_bottomView.frame = CGRectMake(0, 55, self.view.bounds.size.width, 10);
			_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
			_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
			//_scrollView.contentOffset = CGPointMake(0, scrollOffset);
		}];
	}
	else
	{
		[UIView animateWithDuration:.5 animations:^{
			_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.width / 4);
			//_bottomView.frame = CGRectMake(0, 55 + _bottomMiddleView.frame.size.height, self.view.bounds.size.width, 10);
			_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
			_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
			for (UIView *subview in _bottomMiddleView.subviews)
			{
				subview.alpha = 1;
			}
		}];
	}
	//}
}
/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (_bottomMiddleView.bounds.size.height < self.view.bounds.size.width / 8)
	{
		//[UIView animateWithDuration:.5 animations:^{
			_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, 0);
			//_bottomView.frame = CGRectMake(0, 55, self.view.bounds.size.width, 10);
			_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
			_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
			//_scrollView.contentOffset = CGPointMake(0, scrollOffset);
		//}];
	}
	else
	{
		//[UIView animateWithDuration:.5 animations:^{
			_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.width / 4);
			//_bottomView.frame = CGRectMake(0, 55 + _bottomMiddleView.frame.size.height, self.view.bounds.size.width, 10);
			_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
			_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
			for (UIView *subview in _bottomMiddleView.subviews)
			{
				subview.alpha = 1;
			}
		//}];
	}
}
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	float scrollViewHeight = scrollView.frame.size.height;
	float scrollContentSizeHeight = scrollView.contentSize.height;
	float scrollOffset = scrollView.contentOffset.y;
	if ([scrollView isEqual:_scrollView])
	{
		float difference = previousOffSet - scrollOffset;
		if (difference < 0 && scrollOffset >= 0 && !CGRectEqualToRect(_bottomMiddleView.frame, CGRectMake(0, 55, self.view.bounds.size.width, 0)))
		{
			difference = _bottomMiddleView.frame.size.height + difference >= 0 ? difference : -_bottomMiddleView.frame.size.height;
			NSLog(@"%f", difference);
			//if (difference > -20)
			//{
				//[UIView animateWithDuration:1 animations:^{
					_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, _bottomMiddleView.frame.size.height + difference);
					//_bottomView.frame = CGRectMake(0, 55, self.view.bounds.size.width, 10);
					_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
					_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
					//_scrollView.contentOffset = CGPointMake(0, scrollOffset);
				//}];
				for (UIView *subview in _bottomMiddleView.subviews)
				{
					if (subview.alpha > 0)
					{
						subview.alpha -= .01;
					}
				}
			//}
		}
		else if (difference > 0 && scrollOffset <= scrollContentSizeHeight + scrollViewHeight && !CGRectEqualToRect(_bottomMiddleView.frame, CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.width / 4)))
		{
			difference = _bottomMiddleView.frame.size.height + difference <= self.view.bounds.size.width / 4 ? difference : self.view.bounds.size.width / 4 - _bottomMiddleView.frame.size.height;
			NSLog(@"%f", difference);
			//if (difference < 20)
			//{
				//[UIView animateWithDuration:1 animations:^{
					_bottomMiddleView.frame = CGRectMake(0, 55, self.view.bounds.size.width, _bottomMiddleView.frame.size.height + difference);
					//_bottomView.frame = CGRectMake(0, 55 + _bottomMiddleView.frame.size.height, self.view.bounds.size.width, 10);
					//_scrollView.contentOffset = CGPointMake(0, scrollOffset);
					_sortingOptions.frame = CGRectMake(0, 55 + _bottomMiddleView.bounds.size.height, self.view.bounds.size.width, 30);
					_scrollView.frame = CGRectMake(0, _sortingOptions.frame.origin.y + 30, self.view.bounds.size.width, self.view.bounds.size.height - (_sortingOptions.frame.origin.y + 79));
				//}];
				for (UIView *subview in _bottomMiddleView.subviews)
				{
					subview.alpha = _bottomMiddleView.bounds.size.height / (self.view.bounds.size.width / 4);
				}
			//}
		}
		if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
		{
			if (!_loading)
			{
				if (_sortingOptions.selectedSegmentIndex == 0)
				{
					if (_recentPostsLoaded < _numPosts)
					{
						activityIndicator.frame = CGRectMake(0, _scrollView.bounds.size.height - 40, self.view.bounds.size.width, 40);
						[_scrollView addSubview:activityIndicator];
						[activityIndicator startAnimating];
						_loading = YES;
						[self loadPosts:4];
					}
				}
				else if (_sortingOptions.selectedSegmentIndex == 1)
				{
					if (_popularPostsLoaded < _numPosts)
					{
						activityIndicator.frame = CGRectMake(0, _scrollView.bounds.size.height - 40, self.view.bounds.size.width, 40);
						[_scrollView addSubview:activityIndicator];
						[activityIndicator startAnimating];
						_loading = YES;
						[self loadPosts:4];
					}
				}
			}
		}
		else if (scrollOffset < -100)
		{
			[session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
				for (NSURLSessionDataTask *dataTask in dataTasks)
				{
					[dataTask cancel];
				}
			}];
			if (_sortingOptions.selectedSegmentIndex == 0)
			{
				for (UIView *subView in _scrollView.subviews)
				{
					[subView removeFromSuperview];
					[_recentPostViews removeObject:subView];
				}
				_recentPostsLoaded = 0;
			}
			else if (_sortingOptions.selectedSegmentIndex == 1)
			{
				for (UIView *subView in _scrollView.subviews)
				{
					[subView removeFromSuperview];
					[_popularPostViews removeObject:subView];
				}
				_popularPostsLoaded = 0;
			}
			activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
			[_scrollView addSubview:activityIndicator];
			[activityIndicator startAnimating];
			_loading = YES;
			[self getImageCountWithIndex:_userID completionHandler:^(BOOL completed){
				[self loadPosts:4];
			}];
		}
		previousOffSet = scrollOffset;
	}
}

@end
