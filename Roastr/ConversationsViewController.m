//
//  ConversationsViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 12/15/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "ConversationsViewController.h"
#import "AppDelegate.h"

@implementation ConversationsViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	title.text = @"Direct Roasts";
	title.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	title.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	title.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:30];
	title.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:title];
	/*
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
	backButton.frame = CGRectMake(10, 20, self.view.bounds.size.width / 7, 40);
	[backButton setTintColor:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]];
	[backButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	 */
	_numConversations = 0;
	_conversationsLoaded = 0;
	_conversations = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 109) style:UITableViewStylePlain];
	_conversations.delegate = self;
	_conversations.dataSource = self;
	_conversations.separatorStyle = UITableViewCellSeparatorStyleNone;
	_conversations.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self.view addSubview:_conversations];
	_conversationData = [[NSMutableArray alloc] init];
	_loading = YES;
	[self getConversationCountWithCompletionHandler:^(BOOL completed){
		[self loadConversations:5];
	}];
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
	}
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
}

- (void)loadConversations:(int)conversations
{
	int i = _conversationsLoaded;
	if (conversations + _conversationsLoaded > _numConversations)
	{
		_conversationsLoaded = _numConversations;
	}
	else
	{
		_conversationsLoaded += conversations;
	}
	while (i < _conversationsLoaded)
	{
		[self getConversationWithIndex:i];
		i++;
	}
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	_loading = NO;
}

- (void)getConversationWithIndex:(int)index
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getConversationData.php?arg1=%d&arg2=%d", [AppDelegate getUserID], index]];
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
												  [_conversationData addObject:object];
												  [self sortConversationData];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [_conversations reloadData];
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

- (void)sortConversationData
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	for (int i = 0; i < [_conversationData count]; i++)
	{
		NSDictionary *data1 = [_conversationData objectAtIndex:i];
		NSDate *date1 = [formatter dateFromString:[data1 valueForKey:@"lastSent"]];
		int latest = i;
		for (int j = i + 1; j < [_conversationData count]; j++)
		{
			NSDictionary *data2 = [_conversationData objectAtIndex:j];
			NSDate *date2 = [formatter dateFromString:[data2 valueForKey:@"lastSent"]];
			if ([date1 compare:date2] == NSOrderedDescending)
			{
				//NSLog(@"date1 is later than date2");
				/*
				earliest = j;
				date1 = date2;
				 */
			}
			else if ([date1 compare:date2] == NSOrderedAscending)
			{
				//NSLog(@"date1 is earlier than date2");
				latest = j;
				date1 = date2;
			}
			else
			{
				NSLog(@"dates are the same");
				/*
				if ([[data1 valueForKey:@"id"] intValue] == [[data2 valueForKey:@"id"] intValue])
				{
					[_likeData removeObjectAtIndex:j];
					j--;
				}
				 */
			}
		}
		[_conversationData exchangeObjectAtIndex:i withObjectAtIndex:latest];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_numConversations > _conversationsLoaded && _conversationsLoaded != 0)
	{
		return [_conversationData count] + 1;
	}
	return [_conversationData count];
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
	if (_numConversations > _conversationsLoaded && indexPath.row == [_conversationData count])
	{
		cell.textLabel.text = @"Scroll down to load more Conversations";
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	}
	else
	{
		//long row = _numLikes > _likesLoaded ? indexPath.row -1 : indexPath.row;
		NSLog(@"%lu", [_conversationData count]);
		NSLog(@"%lu", indexPath.row);
		NSDictionary *data = [_conversationData objectAtIndex:indexPath.row];
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
		NSDate *date = [formatter dateFromString:[data valueForKey:@"lastSent"]];
		//NSLog(@"Date: %@", [formatter stringFromDate:date]);
		//NSLog(@"Time Since: %f minutes", [date timeIntervalSinceNow] / 60);
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
	return 70;
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
	MessagesViewController *conversation = [[MessagesViewController alloc] initWithUser1:[AppDelegate getUserID] user2:(int)cell.textLabel.tag];
	//profilePage.username.text = cell.textLabel.text;
	[self presentViewController:conversation animated:YES completion:nil];
	[AppDelegate hideTabBar];
}

- (void)getConversationCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getNumConversations.php?arg1=%d", [AppDelegate getUserID]]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numConversations = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
								  }];
	[task resume];
}
/*
- (IBAction)dismissSelf:(id)sender
{
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
	[viewController dismissViewControllerAnimated:YES completion:nil];
	[AppDelegate showTabBar];
}
*/
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
	if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height)
	{
		if (!_loading)
		{
			if (_conversationsLoaded < _numConversations)
			{
				activityIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
				[self.view addSubview:activityIndicator];
				[activityIndicator startAnimating];
				_loading = YES;
				[self getConversationCountWithCompletionHandler:^(BOOL completed){
					[self loadConversations:5];
				}];
			}
		}
	}
}

@end
