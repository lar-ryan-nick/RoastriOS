//
//  LikesViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 11/26/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "LikesViewController.h"
#import "AppDelegate.h"

@implementation LikesViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
}

- (instancetype)initWithPostID:(int)postID
{
	self = [super init];
	if (self)
	{
		_postID = postID;
	}
	return self;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	//self.view.backgroundColor = [UIColor whiteColor];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	title.text = @"Hates";
	title.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:title];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	backButton.frame = CGRectMake(10, 20, self.view.bounds.size.width / 7, 40);
	[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	_numLikes = 0;
	_likesLoaded = 0;
	_likes = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 109) style:UITableViewStylePlain];
	_likes.delegate = self;
	_likes.dataSource = self;
	_likes.separatorStyle = UITableViewCellSeparatorStyleNone;
	_likes.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self.view addSubview:_likes];
	_likeData = [[NSMutableArray alloc] init];
	_loading = YES;
	[self getLikeCountWithCompletionHandler:^(BOOL completed){
		[self loadLikes:5];
	}];
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
	}
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
	[self.view addSubview:[AppDelegate getTabBar]];
}

- (void)loadLikes:(int)likes
{
	int i = _likesLoaded;
	if (likes + _likesLoaded > _numLikes)
	{
		_likesLoaded = _numLikes;
	}
	else
	{
		_likesLoaded += likes;
	}
	while (i < _likesLoaded)
	{
		[self getLikeWithIndex:i];
		i++;
	}
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	_loading = NO;
}

- (void)getLikeWithIndex:(int)index
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getLikeData.php?arg1=%d&arg2=%d", _postID, _numLikes - index]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
									  {
										  if (error != nil)
										  {
											  NSLog(@"Error: %@", [error localizedDescription]);
										  }
										  else
										  {
											  NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
											  if (object != nil)
											  {
												  [_likeData addObject:object];
												  //NSLog(@"%@", _likeData);
												  [self sortLikeData];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [_likes reloadData];
												  });
											  }
											  else
											  {
												  NSLog(@"Error: %@", [error localizedDescription]);
											  }
										  }
									  }];
	[dataTask resume];
}

- (void)sortLikeData
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	for (int i = 0; i < [_likeData count]; i++)
	{
		NSDictionary *data1 = [_likeData objectAtIndex:i];
		NSDate *date1 = [formatter dateFromString:[data1 valueForKey:@"timeLiked"]];
		int earliest = i;
		for (int j = i + 1; j < [_likeData count]; j++)
		{
			NSDictionary *data2 = [_likeData objectAtIndex:j];
			NSDate *date2 = [formatter dateFromString:[data2 valueForKey:@"timeLiked"]];
			if ([date1 compare:date2] == NSOrderedDescending)
			{
				NSLog(@"date1 is later than date2");
				earliest = j;
				date1 = date2;
			}
			else if ([date1 compare:date2] == NSOrderedAscending)
			{
				NSLog(@"date1 is earlier than date2");
			}
			else
			{
				NSLog(@"dates are the same");
				if ([[data1 valueForKey:@"id"] intValue] == [[data2 valueForKey:@"id"] intValue])
				{
					[_likeData removeObjectAtIndex:j];
					j--;
				}
			}
		}
		[_likeData exchangeObjectAtIndex:i withObjectAtIndex:earliest];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_numLikes > _likesLoaded && _likesLoaded != 0)
	{
		return [_likeData count] + 1;
	}
	return [_likeData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
	}
	if (_numLikes > _likesLoaded && indexPath.row == 0)
	{
		cell.textLabel.text = @"Scroll up to load more likes";
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	}
	else
	{
		long row = _numLikes > _likesLoaded ? indexPath.row -1 : indexPath.row;
		NSDictionary *data = [_likeData objectAtIndex:row];
		cell.textLabel.text = [data valueForKey:@"username"];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
		cell.textLabel.tag = [[data valueForKey:@"user"] intValue];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		NSData *imageData = [Base64 decode:[data valueForKey:@"profilePicture"]];
		UIImage  *profilePicture = [UIImage imageWithData:imageData];
		if (profilePicture == nil)
		{
			cell.imageView.image = nil;
		}
		else
		{
			profilePicture = [self roundedRectImageFromImage:profilePicture size:CGSizeMake(40, 40) withCornerRadius:20];
			cell.imageView.image = profilePicture;
		}
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		NSDate *date = [formatter dateFromString:[data valueForKey:@"timeLiked"]];
		NSLog(@"Date: %@", [formatter stringFromDate:date]);
		NSLog(@"Time Since: %f minutes", [date timeIntervalSinceNow] / 60);
		int time = -(int)[date timeIntervalSinceNow];
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
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@ ago", time, units];
		cell.detailTextLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
		cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
		cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
		cell.detailTextLabel.numberOfLines = 0;
	}
	cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	return cell;
}
/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
	if ([tableView cellForRowAtIndexPath:indexPath].textLabel.tag == [AppDelegate getUserID])
	{
 return YES;
	}
	return NO;
 }
 
 -(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
 {
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
 int row = _numComments > _commentsLoaded ? (int)indexPath.row - 1 : (int)indexPath.row;
 [self deleteComment:[[_keys objectAtIndex:row] intValue]];
	}];
	deleteAction.backgroundColor = [UIColor redColor];
	return @[deleteAction];
 }
 
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
 {
	
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (IBAction)closeProfile:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:(int)cell.textLabel.tag];
	//profilePage.username.text = cell.textLabel.text;
	[self presentViewController:profilePage animated:YES completion:nil];
	[AppDelegate showTabBar];
}

- (void)getLikeCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getNumLikes.php?arg1=%d", _postID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numLikes = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	float scrollOffset = scrollView.contentOffset.y;
	if (scrollOffset <= -10)
	{
		if (!_loading)
		{
			if (_likesLoaded < _numLikes)
			{
				activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
				[self.view addSubview:activityIndicator];
				[activityIndicator startAnimating];
				_loading = YES;
				[self getLikeCountWithCompletionHandler:^(BOOL completed){
					[self loadLikes:5];
				}];
			}
		}
	}
}

@end
