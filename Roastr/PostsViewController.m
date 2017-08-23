//
//  PostsViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 3/3/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "PostsViewController.h"
#import "AppDelegate.h"

@implementation PostsViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
	int previousOffSet;
	//UITableViewController *tableViewController;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	NSLog(@"Get Ads Removed: %d", [AppDelegate getAdsRemoved]);
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	bottomView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	[self.view addSubview:bottomView];
	//self.view.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	CGSize size = [@"Roastr" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:30]}];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2, 20, size.width, 40)];
	title.text = @"Roastr";
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	[self.view addSubview:title];
	UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - size.width + 40) / 2 - 40, 20, 40, 40)];
	logo.image = [UIImage imageNamed:@"roastrtransparent.png"];
	[self.view addSubview:logo];
	previousOffSet = 0;
	//_tableData = [[NSMutableDictionary alloc] init];
	_numPosts = 0;
	_recentPostsLoaded = 0;
	_popularPostsLoaded = 0;
	_loading = YES;
	_recentpostViews = [[NSMutableArray alloc] init];
	_popularpostViews = [[NSMutableArray alloc] init];
	_sortingOptions = [[UISegmentedControl alloc] initWithItems:@[@"Most Recents", @"Most Hates"]];
	[_sortingOptions addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
	_sortingOptions.frame = CGRectMake(0, 60, self.view.bounds.size.width, 30);
	[_sortingOptions setSelectedSegmentIndex:0];
	[_sortingOptions setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[_sortingOptions setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateNormal];
	[_sortingOptions setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateSelected];
	[_sortingOptions setBackgroundColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
	[self.view addSubview:_sortingOptions];
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 139)];
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
	_scrollView.delegate = self;
	_scrollView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:_scrollView];
	/*
	_popularScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 139)];
	_popularScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
	_popularScrollView.delegate = self;
	_popularScrollView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	 */
	_loading = YES;
	[self getPostCountWithCompletionHandler:^(BOOL completed){
		if (_numPosts > 0)
		{
			if (activityIndicator == nil)
			{
				activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
			}
			[self.view addSubview:activityIndicator];
			[activityIndicator startAnimating];
		}
		[_sortingOptions setSelectedSegmentIndex:1];
		[self loadPosts:4];
		[_sortingOptions setSelectedSegmentIndex:0];
		[self loadPosts:4];
	}];
}

- (void)changeView:(id)sender
{
	//NSLog(@"%d", _sortingOptions.selectedSegmentIndex);
	[self showLoadedPosts];
	int temp = _scrollView.contentOffset.y;
	_scrollView.contentOffset = CGPointMake(0, previousOffSet);
	previousOffSet = temp;
}

- (void)loadPosts:(int)posts
{
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		int end = posts + _recentPostsLoaded > _numPosts ? _numPosts : posts + _recentPostsLoaded;
		while (_recentPostsLoaded < end)
		{
			PostView *postView = [[PostView alloc] initWithUser:0 index:_numPosts - _recentPostsLoaded width:self.view.bounds.size.width completionHandler:^(BOOL completed){
				[self showLoadedPosts];
				if (_recentPostsLoaded % posts == 0 || _recentPostsLoaded == _numPosts)
				{
					if ([activityIndicator isAnimating])
					{
						[activityIndicator stopAnimating];
						[activityIndicator removeFromSuperview];
						_loading = NO;
					}
				}
			}];
			[_recentpostViews addObject:postView];
			_recentPostsLoaded++;
		}
		if (![AppDelegate getAdsRemoved])
		{
			PostView *ad = [[PostView alloc] initForAddWithViewController:self width:self.view.bounds.size.width];
			[_recentpostViews addObject:ad];
		}
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		int end = posts + _popularPostsLoaded > _numPosts ? _numPosts : posts + _popularPostsLoaded;
		while (_popularPostsLoaded < end)
		{
			PostView *postView = [[PostView alloc] initWithMostHatesUser:0 index:_popularPostsLoaded + 1 width:self.view.bounds.size.width completionHandler:^(BOOL completed){
				[self showLoadedPosts];
				NSLog(@"%d %d", _popularPostsLoaded, _numPosts);
				if (_popularPostsLoaded % posts == 0 || _popularPostsLoaded == _numPosts)
				{
					if ([activityIndicator isAnimating])
					{
						[activityIndicator stopAnimating];
						[activityIndicator removeFromSuperview];
						_loading = NO;
					}
				}
			}];
			[_popularpostViews addObject:postView];
			_popularPostsLoaded++;
		}
		if (![AppDelegate getAdsRemoved])
		{
			PostView *ad = [[PostView alloc] initForAddWithViewController:self width:self.view.bounds.size.width];
			[_popularpostViews addObject:ad];
		}
	}
}

- (void)showLoadedPosts
{
	float scrollOffset = _scrollView.contentOffset.y;
	_scrollView.contentSize = CGSizeZero;
	for (UIView *postView in _scrollView.subviews)
	{
		[postView removeFromSuperview];
	}
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		for (PostView *postView in _recentpostViews)
		{
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
		for (PostView *postView in _popularpostViews)
		{
			if (postView.loaded)
			{
				postView.frame = CGRectMake(0, _scrollView.contentSize.height, self.view.bounds.size.width, [postView getHeight]);
				_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _scrollView.contentSize.height + [postView getHeight] + 40);
				[_scrollView addSubview:postView];
			}
		}
	}
	NSLog(@"%@", _popularpostViews);
	_scrollView.contentOffset = CGPointMake(0, scrollOffset);
}

- (PostView*)getPostViewWithPostID:(int)id
{
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		for (PostView *postView in _recentpostViews)
		{
			if (postView.postID == id)
			{
				return postView;
			}
		}
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		for (PostView *postView in _popularpostViews)
		{
			if (postView.postID == id)
			{
				return postView;
			}
		}
	}
	return nil;
}

- (void)getPostCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getPostCount.php?arg1=%d", 1]];
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
										  [_recentpostViews removeObject:postView];
										  _recentPostsLoaded--;
										  _numPosts--;
										  dispatch_async(dispatch_get_main_queue(), ^{
											  [self showLoadedPosts];
										  });
									  }];
		[task resume];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No, don't delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	[warning addAction:cancel];
	[warning addAction:delete];
	[self presentViewController:warning animated:YES completion:nil];
}

- (void)reload
{
	if (_sortingOptions.selectedSegmentIndex == 0)
	{
		/*
		[session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
			for (NSURLSessionDataTask *dataTask in dataTasks)
			{
				if ([dataTask.originalRequest.URL.absoluteString containsString:@"getPostData.php"])
				{
					[dataTask cancel];
				}
			}
		}];
		 */
		_recentpostViews = [[NSMutableArray alloc] init];
		_recentPostsLoaded = 0;
		for (UIView *subView in _scrollView.subviews)
		{
			[subView removeFromSuperview];
		}
		NSLog(@"%@", _recentpostViews);
	}
	else if (_sortingOptions.selectedSegmentIndex == 1)
	{
		/*
		[session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
			for (NSURLSessionDataTask *dataTask in dataTasks)
			{
				if ([dataTask.originalRequest.URL.absoluteString containsString:@"getPostMostHatesData.php"])
				{
					[dataTask cancel];
				}
			}
		}];
		 */
		_popularpostViews = [[NSMutableArray alloc] init];
		_popularPostsLoaded = 0;
		for (UIView *subView in _scrollView.subviews)
		{
			[subView removeFromSuperview];
		}
		NSLog(@"%@", _popularpostViews);
	}
	_loading = YES;
	activityIndicator.frame = CGRectMake(0, 90, self.view.bounds.size.width, 40);
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
	[self getPostCountWithCompletionHandler:^(BOOL completed){
		[self loadPosts:4];
	}];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	float scrollViewHeight = scrollView.frame.size.height;
	float scrollContentSizeHeight = scrollView.contentSize.height;
	float scrollOffset = scrollView.contentOffset.y;
	if ([scrollView isEqual:_scrollView])
	{
		if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
		{
			if (!_loading)
			{
				if (_sortingOptions.selectedSegmentIndex == 0)
				{
				if (_recentPostsLoaded < _numPosts)
				{
					activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
					[self.view addSubview:activityIndicator];
					[activityIndicator startAnimating];
					_loading = YES;
					[self loadPosts:4];
				}
				}
				else if (_sortingOptions.selectedSegmentIndex == 1)
				{
					if (_popularPostsLoaded < _numPosts)
					{
						activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
						[self.view addSubview:activityIndicator];
						[activityIndicator startAnimating];
						_loading = YES;
						[self loadPosts:4];
					}
				}
			}
		}
		else if (scrollOffset < -100)
		{
			[self reload];
			scrollView.contentOffset = CGPointMake(0, 0);
		}
	}
}

@end
