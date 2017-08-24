//
//  PostView.m
//  Roastr
//
//  Created by Ryan Wiener on 7/21/16.
//  Copyright © 2016 Ryan Wiener. All rights reserved.
//

#import "PostView.h"
#import "AppDelegate.h"

@implementation PostView
{
	NSURLSession *session;
	NSMutableDictionary *tableData;
}

- (instancetype)initWithUser:(int)user index:(int)index width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler
{
	self = [super initWithFrame:CGRectMake(0, 0, width, 80)];
	session = [NSURLSession sharedSession];
	_loaded = NO;
	if (self)
	{
		self.backgroundColor = [UIColor whiteColor];
		UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPostViewController:)];
		_topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
		[_topBar setBarTintColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
		[_topBar addGestureRecognizer:tapBar];
		tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPostViewController:)];
		_bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, 40)];
		[_bottomBar setBarTintColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
		//[_bottomBar setItems:@[]];
		[_bottomBar addGestureRecognizer:tapBar];
		[self addSubview:_topBar];
		[self addSubview:_bottomBar];
		self.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
		doubleTap.numberOfTapsRequired = 2;
		[self addGestureRecognizer:doubleTap];
	}
	[self getPostDataForUser:user index:index completionHandler:^(int postID, int userID, UIImage *profilePicture, NSString *caption, NSString *username, UIImage *image, int likes, BOOL liked, int comments, int time){
		[self setUpPostWithPostID:postID userID:userID user:user profilePicture:profilePicture caption:caption username:username image:image likes:likes liked:liked comments:comments time:time completionHandler:completionHandler];
	}];
	return self;
}

- (instancetype)initWithPostID:(int)id width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler
{
	self = [self initWithUser:-1 index:id width:width completionHandler:completionHandler];
	return self;
}

- (instancetype)initWithMostHatesUser:(int)user index:(int)index width:(int)width completionHandler:(void (^)(BOOL completed))completionHandler
{
	self = [super initWithFrame:CGRectMake(0, 0, width, 80)];
	session = [NSURLSession sharedSession];
	_loaded = NO;
	if (self)
	{
		self.backgroundColor = [UIColor whiteColor];
		UITapGestureRecognizer *tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPostViewController:)];
		_topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
		[_topBar setBarTintColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
		[_topBar addGestureRecognizer:tapBar];
		tapBar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPostViewController:)];
		_bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, 40)];
		[_bottomBar setBarTintColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
		//[_bottomBar setItems:@[]];
		[_bottomBar addGestureRecognizer:tapBar];
		[self addSubview:_topBar];
		[self addSubview:_bottomBar];
		self.userInteractionEnabled = YES;
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
		doubleTap.numberOfTapsRequired = 2;
		[self addGestureRecognizer:doubleTap];
	}
	[self getPostDataForMostHatesUser:user Index:index completionHandler:^(int postID, int userID, UIImage *profilePicture, NSString *caption, NSString *username, UIImage *image, int likes, BOOL liked, int comments, int time){
		[self setUpPostWithPostID:postID userID:userID user:-1 profilePicture:profilePicture caption:caption username:username image:image likes:likes liked:liked comments:comments time:time completionHandler:completionHandler];
	}];
	return self;
}

- (void)setUpPostWithPostID:(int)postID userID:(int)userID user:(int)user profilePicture:(UIImage*)profilePicture caption:(NSString*)caption username:(NSString*)username image:(UIImage*)image likes:(int)likes liked:(BOOL)liked comments:(int)comments time:(int)time completionHandler:(void (^)(BOOL completed))completionHandler
{
	_postID = postID;
	_userID = userID;
	if (![caption isEqualToString:@""])
	{
		_caption = [[UITextView alloc] init];
		_caption.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
		NSArray *strings = [caption componentsSeparatedByString:@" "];
		CGSize size = CGSizeZero;
		NSDictionary *attributes;
		NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
		for (int i = 0; i < [strings count]; i++)
		{
			NSMutableAttributedString *word = [[NSMutableAttributedString alloc] initWithString:[strings[i] stringByAppendingString:@" "]];
			if ([[word.string substringToIndex:1] isEqualToString:@"@"])
			{
				[word deleteCharactersInRange:NSMakeRange(0, 1)];
				attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:15]};
			}
			else
			{
				attributes = @{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1]};
			}
			[word addAttributes:attributes range:NSMakeRange(0, [word length] - 1)];
			CGSize current = [word.string sizeWithAttributes:attributes];
			size.width += current.width;
			if (size.height < current.height)
			{
				size.height = current.height;
			}
			[attributedText appendAttributedString:word];
		}
		NSString *units = @"seconds";
		if (time == 1)
		{
			units = @"second";
		}
		else if (time >= 86400)
		{
			time /= 86400;
			if (time == 1)
			{
				units = @"day";
			}
			else
			{
				units = @"days";
			}
		}
		else if (time >= 3600)
		{
			time /= 3600;
			if (time == 1)
			{
				units = @"hour";
			}
			else
			{
				units = @"hours";
			}
		}
		else if (time >= 60)
		{
			time /= 60;
			if (time == 1)
			{
				units = @"minute";
			}
			else
			{
				units = @"minutes";
			}
		}
		attributes = @{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]};
		NSAttributedString *timeElapsed = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d %@ ago", time, units] attributes:attributes];
		CGSize current = [timeElapsed.string sizeWithAttributes:attributes];
		size.width += current.width;
		if (size.height < current.height)
		{
			size.height = current.height;
		}
		[attributedText appendAttributedString:timeElapsed];
		_caption.attributedText = attributedText;
		_caption.editable = NO;
		_caption.scrollEnabled = NO;
		_caption.selectable = NO;
		UITapGestureRecognizer *tapCaption = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captionTapped:)];
		[_caption addGestureRecognizer:tapCaption];
		_caption.frame = CGRectMake(0, 40, self.bounds.size.width, (size.height) * ((int)(size.width / (self.bounds.size.width - 16)) + 1) + 16);
		_bottomBar.frame = CGRectMake(0, _caption.frame.size.height + 40, self.bounds.size.width, 40);
		[self addSubview:_caption];
	}
	if (image != nil)
	{
		float height = (image.size.height / image.size.width) * self.bounds.size.width;
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, height)];
		scrollView.maximumZoomScale = 4;
		scrollView.minimumZoomScale = 1;
		scrollView.delegate = self;
		[scrollView setBounces:NO];
		[scrollView setBouncesZoom:NO];
		_imageView = [[UIImageView alloc] init];
		_imageView.frame = scrollView.bounds;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
		[_imageView setImage:image];
		[scrollView addSubview:_imageView];
		if (caption != nil)
		{
			_caption.frame = CGRectMake(0, _imageView.bounds.size.height + 40, self.bounds.size.width, _caption.frame.size.height);
			_bottomBar.frame = CGRectMake(0, _caption.frame.size.height + 40 + _imageView.bounds.size.height, self.bounds.size.width, 40);
		}
		else
		{
			_bottomBar.frame = CGRectMake(0, 40 + scrollView.bounds.size.height, self.bounds.size.width, 40);
		}
		[self addSubview:scrollView];
	}
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	if (profilePicture != nil)
	{
		UIImageView *profilePic = [[UIImageView alloc] initWithImage:profilePicture];
		profilePic.bounds = CGRectMake(0, 0, profilePicture.size.width, profilePicture.size.height);
		UIBarButtonItem *userPic = [[UIBarButtonItem alloc] initWithCustomView:profilePic];
		if (user == _userID)
		{
			[userPic setTarget:self];
			[userPic setAction:@selector(loadProfile:)];
		}
		[barItems addObject:userPic];
	}
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(launchAction:)];
	[share setTintColor:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]];
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithTitle:username style:UIBarButtonItemStylePlain target:self action:@selector(loadProfile:)];
	[userButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} forState:UIControlStateNormal];
	[barItems addObjectsFromArray:@[userButton, space, share]];
	if (user == _userID)
	{
		userButton.enabled = NO;
	}
	if (_userID == [AppDelegate getUserID])
	{
		UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePost:)];
		[trash setTintColor:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]];
		[barItems addObject:trash];
	}
	[_topBar setItems:barItems];
	NSString *title;
	if (likes == 1)
	{
		title = [NSString stringWithFormat:@"%d hate", likes];
	}
	else
	{
		title = [NSString stringWithFormat:@"%d hates", likes];
	}
	UIBarButtonItem *numLikes = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(loadLikesViewController:)];
	[numLikes setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
	if (comments == 1)
	{
		title = [NSString stringWithFormat:@"%d roast", comments];
	}
	else
	{
		title = [NSString stringWithFormat:@"%d roasts", comments];
	}
	UIBarButtonItem *numComments = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(loadCommentsViewController:)];
	[numComments setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
	space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	if (liked)
	{
		UIBarButtonItem *unlike = [[UIBarButtonItem alloc] initWithTitle:@"Unhate" style:UIBarButtonItemStylePlain target:self action:@selector(unlikePost:)];
		[unlike setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
		[_bottomBar setItems:@[unlike, numLikes, space, numComments]];
	}
	else
	{
		UIBarButtonItem *like = [[UIBarButtonItem alloc] initWithTitle:@"Hate" style:UIBarButtonItemStylePlain target:self action:@selector(likePost:)];
		[like setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
		[_bottomBar setItems:@[like, numLikes, space, numComments]];
	}
	_loaded = YES;
	completionHandler(YES);
}

- (void)getPostDataForUser:(int)user index:(int)index completionHandler:(void (^)(int postID, int userID, UIImage *profilePicture, NSString *caption, NSString *username, UIImage *image, int likes, BOOL liked, int comments, int time))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getPostData.php?arg1=%d&arg2=%d&arg3=%d", user, index,  [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
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
										  NSLog(@"Fuck: %@", text);
										  NSDictionary *postData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
										  if (error == nil)
										  {
											  
											  NSData *imageData = [Base64 decode:[postData valueForKey:@"image"]];
											  UIImage *image = [UIImage imageWithData:imageData];
											  NSData *profilePictureData = [Base64 decode:[postData valueForKey:@"profilePicture"]];
											  UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
											  if (profilePicture != nil)
											  {
												  profilePicture = [self roundedRectImageFromImage:profilePicture size:CGSizeMake(30, 30) withCornerRadius:15];
											  }
											  int time = 0;
											  NSLog(@"%@", [postData valueForKey:@"timePosted"]);
											  /*
												  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
												  formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
												  formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
												  NSDate *date = [formatter dateFromString:[postData valueForKey:@"timePosted"]];
												  int time = -(int)[date timeIntervalSinceNow];
											  */
											  dispatch_async(dispatch_get_main_queue(), ^{
												  completionHandler([[postData valueForKey:@"id"] intValue], [[postData valueForKey:@"user"] intValue], profilePicture, [postData valueForKey:@"caption"], [postData valueForKey:@"username"], image, [[postData valueForKey:@"likes"] intValue], [[postData valueForKey:@"liked"] boolValue], [[postData valueForKey:@"comments"] intValue], time);
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

- (void)getPostDataForMostHatesUser:(int)user Index:(int)index completionHandler:(void (^)(int postID, int userID, UIImage *profilePicture, NSString *caption, NSString *username, UIImage *image, int likes, BOOL liked, int comments, int time))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getPostMostHatesData.php?user=%d&post=%d&user2=%d", user, index,  [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  if (error != nil)
									  {
										  NSLog(@"%@", [error localizedDescription]);
									  }
									  else
									  {
										  //NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  //NSLog(@"%@", text);
										  NSDictionary *postData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
										  if (error == nil)
										  {
											  NSData *imageData = [Base64 decode:[postData valueForKey:@"image"]];
											  UIImage *image = [UIImage imageWithData:imageData];
											  NSData *profilePictureData = [Base64 decode:[postData valueForKey:@"profilePicture"]];
											  UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
											  if (profilePicture != nil)
											  {
												  profilePicture = [self roundedRectImageFromImage:profilePicture size:CGSizeMake(30, 30) withCornerRadius:15];
											  }
											  int time = 0;
											  NSLog(@"%@", [postData valueForKey:@"timePosted"]);
											  /*
												  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
												  formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
												  formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
												  NSDate *date = [formatter dateFromString:[postData valueForKey:@"timePosted"]];
												  int time = -(int)[date timeIntervalSinceNow];
											  */
											  dispatch_async(dispatch_get_main_queue(), ^{
												  completionHandler([[postData valueForKey:@"id"] intValue], [[postData valueForKey:@"user"] intValue], profilePicture, [postData valueForKey:@"caption"], [postData valueForKey:@"username"], image, [[postData valueForKey:@"likes"] intValue], [[postData valueForKey:@"liked"] boolValue], [[postData valueForKey:@"comments"] intValue], time);
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

- (instancetype)initForAddWithViewController:(UIViewController*)viewController width:(float)width
{
	self = [super init];
	if (self)
	{
		_nativeExpressAdView = [[GADNativeExpressAdView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, width))];
		_nativeExpressAdView.adUnitID = @"ca-app-pub-9745963391546811/1686142887";
		_nativeExpressAdView.rootViewController = viewController;
		_nativeExpressAdView.delegate = self;
		
		// The video options object can be used to control the initial mute state of video assets.
		// By default, they start muted.
		GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
		videoOptions.startMuted = true;
		[_nativeExpressAdView setAdOptions:@[videoOptions]];
		
		// Set this UIViewController as the video controller delegate, so it will be notified of events
		// in the video lifecycle.
		_nativeExpressAdView.videoController.delegate = self;
		
		GADRequest *request = [GADRequest request];
		[_nativeExpressAdView loadRequest:request];
		//NSLog(@"Ad: %@", _nativeExpressAdView);
		[self addSubview:_nativeExpressAdView];
		_loaded = YES;
	}
	return self;
}

- (void)captionTapped:(UITapGestureRecognizer*)recognizer
{
	UITextView *textView = (UITextView *)recognizer.view;
	
	// Location of the tap in text-container coordinates
	
	NSLayoutManager *layoutManager = textView.layoutManager;
	CGPoint location = [recognizer locationInView:textView];
	location.x -= textView.textContainerInset.left;
	location.y -= textView.textContainerInset.top;
	
	// Find the character that's been tapped on
	
	NSUInteger characterIndex;
	characterIndex = [layoutManager characterIndexForPoint:location
										   inTextContainer:textView.textContainer
				  fractionOfDistanceBetweenInsertionPoints:NULL];
	
	if (characterIndex < textView.textStorage.length)
	{
		
		NSRange range;
		id value = [textView.attributedText attribute:NSForegroundColorAttributeName atIndex:characterIndex effectiveRange:&range];
		
		if (value != nil)
		{
			[self getUserID:[textView.text substringWithRange:range] completionHandler:^(int userID){
				if (userID > 0)
				{
					ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:userID];
					//profilePage.username.text = [textView.attributedText.string substringWithRange:range];
					[self presentViewController:profilePage];
				}
			}];
		}
	}
}

- (void)getUserID:(NSString*)username completionHandler:(void (^)(int userID))completionHandler
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://roastr2.herokuapp.com/getIDForUser.php?arg1='%@'", username];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request
											completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
								  {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  if (![@"user doesn't exists" isEqualToString:text])
									  {
										  dispatch_async(dispatch_get_main_queue(), ^{
											  completionHandler([text intValue]);
										  });
									  }
								  }];
	[task resume];
}

- (void)deletePost:(UIBarButtonItem*)sender
{
	UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	int i;
	for (i = 0; viewController != nil; i++)
	{
		viewController = viewController.presentedViewController;
	}
	NSLog(@"%d", i);
	viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	for (int j = 0; j < i; j++)
	{
		viewController = viewController.presentedViewController;
	}
	if ([viewController isKindOfClass:[PostsViewController class]])
	{
		PostsViewController *postController = (PostsViewController*)viewController;
		[postController deletePost:_postID];
	}
	else if ([viewController isKindOfClass:[ProfileViewController class]])
	{
		ProfileViewController *profileController = (ProfileViewController*)viewController;
		[profileController deletePost:_postID];
	}
	else if ([viewController isKindOfClass:[PostViewController class]])
	{
		PostViewController *postController = (PostViewController*)viewController;
		[postController deletePost];
	}
}

- (IBAction)likePost:(UIBarButtonItem*)sender
{
	UILabel *fire = [[UILabel alloc] initWithFrame:_imageView.bounds];
	fire.text = @"🔥";
	fire.font = [UIFont systemFontOfSize:fire.bounds.size.height / 2];
	fire.textAlignment = NSTextAlignmentCenter;
	[_imageView addSubview:fire];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/addLike.php?user=%d&post=%d", [AppDelegate getUserID], _postID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
									  [self getNumLikesWithCompletionHandler:^(int likes){
										  [fire removeFromSuperview];
										  UIBarButtonItem *numLikes = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d hates", likes] style:UIBarButtonItemStylePlain target:self action:@selector(loadLikesViewController:)];
										  UIBarButtonItem *unlike = [[UIBarButtonItem alloc] initWithTitle:@"Unhate" style:UIBarButtonItemStylePlain target:self action:@selector(unlikePost:)];
										  [numLikes setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
										  [unlike setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
										  [_bottomBar setItems:@[unlike, numLikes, _bottomBar.items[2], _bottomBar.items[3]]];
									  }];
								  }];
	[task resume];
}

- (IBAction)unlikePost:(UIBarButtonItem*)sender
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/removeLike.php?user=%d&post=%d", [AppDelegate getUserID], _postID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@", text);
									  [self getNumLikesWithCompletionHandler:^(int likes){
										  UIBarButtonItem *numLikes = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d hates", likes] style:UIBarButtonItemStylePlain target:self action:@selector(loadLikesViewController:)];
										  UIBarButtonItem *like = [[UIBarButtonItem alloc] initWithTitle:@"Hate" style:UIBarButtonItemStylePlain target:self action:@selector(likePost:)];
										  [like setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
										  [numLikes setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:15]} forState:UIControlStateNormal];
										  [_bottomBar setItems:@[like, numLikes, _bottomBar.items[2], _bottomBar.items[3]]];
									  }];
								  }];
	[task resume];
}

- (void)doubleTap:(UITapGestureRecognizer*)sender
{
	[self performSelector:[_bottomBar.items objectAtIndex:0].action withObject:[[UIBarButtonItem alloc] init]];
}

- (IBAction)loadLikesViewController:(UIBarButtonItem*)sender
{
	LikesViewController *likeController = [[LikesViewController alloc] initWithPostID:_postID];
	[self presentViewController:likeController];
}

- (IBAction)loadCommentsViewController:(UIBarButtonItem*)sender
{
	[AppDelegate hideTabBar];
	CommentsViewController *commentsViewController = [[CommentsViewController alloc] initWithPostID:_postID];
	[self presentViewController:commentsViewController];
}

- (void)loadPostViewController:(UIBarButtonItem*)sender
{
	NSLog(@"Shit");
	PostViewController *postController = [[PostViewController alloc] initWithPostID:_postID];
	[self presentViewController:postController];
}

- (void)presentViewController:(UIViewController*)viewControllerToBePresented
{
	UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	int i;
	for (i = 0; viewController != nil; i++)
	{
		viewController = viewController.presentedViewController;
	}
	NSLog(@"%d", i);
	viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	for (int j = 0; j < i; j++)
	{
		viewController = viewController.presentedViewController;
	}
	[viewController presentViewController:viewControllerToBePresented animated:YES completion:nil];
}

- (void)loadUsersWhoLikedPostWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getUsersWhoLikedPost.php?arg1=%d", _postID]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
									  {
										  if (error != nil)
											  NSLog(@"%@", [error localizedDescription]);
										  tableData = [[NSMutableDictionary alloc] init];
										  //tableData[@""] = @"";
										  [tableData addEntriesFromDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
										  [tableData removeObjectForKey:@"No results found"];
										  NSLog(@"%@", tableData);
										  dispatch_async(dispatch_get_main_queue(), ^{
											  completionHandler(YES);
										  });
									  }];
	[dataTask resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	cell.textLabel.text = [tableData.allKeys objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	cell.contentView.backgroundColor = [UIColor blackColor];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void)getNumLikesWithCompletionHandler:(void (^)(int likes))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getNumLikes.php?arg1=%d", _postID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler([text intValue]);
									  });
								  }];
	[task resume];
}

- (IBAction)loadProfile:(UIBarButtonItem*)sender
{
	ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:_userID];
	//profilePage.username.text = sender.title;
	[self presentViewController:profilePage];
}

- (IBAction)launchAction:(id)sender
{
	[AppDelegate hideTabBar];
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_imageView.image] applicationActivities:nil];
	activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
		[AppDelegate showTabBar];
	};
	[self presentViewController:activityViewController];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
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

- (int)getHeight
{
	if (_imageView == nil && _caption == nil)
		return self.bounds.size.width;
	return _imageView.bounds.size.height + _caption.bounds.size.height + _topBar.bounds.size.height + _bottomBar.bounds.size.height;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"PostID: %d  Caption: %@ UserID: %d", _postID, _caption.text, _userID];
}

@end
