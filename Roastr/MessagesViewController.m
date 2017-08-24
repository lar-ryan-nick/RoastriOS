//
//  MessagesViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 12/12/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "MessagesViewController.h"
#import "AppDelegate.h"

@implementation MessagesViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
	NSMutableAttributedString *attributedString;
	UIImage *profilePicture;
	NSMutableAttributedString *messageText;
	//SocketIOClient* socket;
}

- (instancetype)initWithUser1:(int)user1ID user2:(int)user2ID
{
	self = [super init];
	if (self)
	{
		_user1ID = user1ID;
		_user2ID = user2ID;
	}
	return self;
}

- (void)viewDidLoad
{
	if (session == nil)
		session = [NSURLSession sharedSession];
	//NSURL* url = [[NSURL alloc] initWithString:@"http://localhost:8080"];
	//socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	title.text = @"Messages";
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
	_tableData = [[NSMutableDictionary alloc] init];
	_numMessages = 0;
	_messagesLoaded = 0;
	_messages = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 109) style:UITableViewStylePlain];
	_messages.delegate = self;
	_messages.dataSource = self;
	_messages.allowsSelection = NO;
	_messages.separatorStyle = UITableViewCellSeparatorStyleNone;
	_messages.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self getMessageCountWithCompletionHandler:^(BOOL completed){
		[self loadMessages:5 completionHandler:^(BOOL loaded){
			[_messages reloadData];
			if (_messages.contentSize.height - _messages.bounds.size.height > 0)
			{
				_messages.contentOffset = CGPointMake(0, _messages.contentSize.height - _messages.bounds.size.height);
			}
		}];
	}];
	[self.view addSubview:_messages];
	_users = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 356) style:UITableViewStylePlain];
	_users.delegate = self;
	_users.dataSource = self;
	_users.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_users.separatorStyle = UITableViewCellSeparatorStyleNone;
	_messageField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, 3 * self.view.bounds.size.width / 4, 40)];
	_messageField.textColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_messageField.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	_messageField.delegate = self;
	_messageField.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
	[self.view addSubview:_messageField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
	_send = [UIButton buttonWithType:UIButtonTypeSystem];
	_send.frame = CGRectMake(3 * self.view.bounds.size.width / 4, self.view.bounds.size.height - 40, self.view.bounds.size.width / 4, 40);
	[_send setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20], NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]}] forState:UIControlStateNormal];
	_send.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	[_send addTarget:self action:@selector(addMessage:) forControlEvents:UIControlEventTouchUpInside];
	_send.enabled = NO;
	[self.view addSubview:_send];
	_messageData = [[NSMutableArray alloc] init];
	attributedString = [[NSMutableAttributedString alloc] init];
	_loading = YES;
	if (activityIndicator == nil)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(0, self.view.bounds.size.height - 89, self.view.bounds.size.width, 40);
	}
	[self.view addSubview:activityIndicator];
	[activityIndicator startAnimating];
}

- (void)loadMessages:(int)messages completionHandler:(void (^)(BOOL loaded))completionHandler
{
	/*
	int i = _messagesLoaded;
	if (messages + _messagesLoaded > _numMessages)
	{
		_messagesLoaded = _numMessages;
	}
	else
	{
		_messagesLoaded += messages;
	}
	NSLog(@"Fuck");
	 */
	int finished = _messagesLoaded + messages > _numMessages ? _numMessages : _messagesLoaded + messages;
	for (int i = _messagesLoaded; i < finished; i++)
	{
		[self getMessageWithIndex:i completionHandler:^(BOOL completed){
			_messagesLoaded++;
			if (_messagesLoaded == finished)
			{
				NSLog(@"%@", _messageData);
				completionHandler(YES);
				_loading = NO;
				[activityIndicator stopAnimating];
				[activityIndicator removeFromSuperview];
			}
		}];
		//NSLog(@"%d", i);
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (range.location < [attributedString length])
	{
		NSRange effectiveRange;
		NSDictionary *attributes = [attributedString attributesAtIndex:range.location effectiveRange:&effectiveRange];
		if ([attributes count] != 0)
		{
			[attributedString removeAttribute:NSForegroundColorAttributeName range:effectiveRange];
		}
		[attributedString replaceCharactersInRange:range withString:string];
	}
	else
	{
		[attributedString replaceCharactersInRange:range withString:string];
		NSRange effectiveRange;
		NSDictionary *attributes = [attributedString attributesAtIndex:range.location effectiveRange:&effectiveRange];
		if ([attributes count] != 0)
		{
			[attributedString removeAttribute:NSForegroundColorAttributeName range:effectiveRange];
		}
	}
	if ([attributedString.string isEqualToString:@""])
	{
		_send.enabled = NO;
	}
	else
	{
		_send.enabled = YES;
	}
	textField.attributedText = attributedString;
	NSString *searchText = [[textField.attributedText.string componentsSeparatedByString:@" "] lastObject];
	[self loadSimilarUserswithText:searchText completionHandler:^(BOOL results){
		if (results)
		{
			[_users reloadData];
			[[textField superview] addSubview:_users];
		}
		else
		{
			[_users removeFromSuperview];
		}
	}];
	return NO;
}

- (void)loadSimilarUserswithText:(NSString*)searchText completionHandler:(void (^)(BOOL results))completionHandler
{
	searchText = [searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
	if ([searchText isEqualToString:@""])
	{
		completionHandler(NO);
	}
	else
	{
		NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getLikeUsers.php?arg1=%@", searchText]];
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
		NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
										  {
											  if (error != nil)
											  {
												  NSLog(@"%@", [error localizedDescription]);
											  }
											  else
											  {
												  _tableData = [[NSMutableDictionary alloc] init];
												  [_tableData addEntriesFromDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
												  NSString *first = [NSString stringWithFormat:@"%@", _tableData.allKeys[0]];
												  BOOL results = [first isEqualToString:@"No results found"];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  completionHandler(!results);
												  });
											  }
										  }];
		[dataTask resume];
	}
}
/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[UIView animateWithDuration:.1 animations:^{
		_messageField.transform = CGAffineTransformMakeTranslation(0, -[[[note userInfo]
																		objectForKey:UIKeyboardBoundsUserInfoKey]CGRectValue].size.height;);
		_send.transform = CGAffineTransformMakeTranslation(0, -[[[note userInfo]
																objectForKey:UIKeyboardBoundsUserInfoKey]CGRectValue].size.height;);
	}];
}
 */
- (void)keyboardWillChange:(NSNotification *)notification {
	if ([[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y != self.view.bounds.size.height)
	{
		[UIView animateWithDuration:.1 animations:^{
			_messageField.transform = CGAffineTransformMakeTranslation(0, -[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
			_send.transform = CGAffineTransformMakeTranslation(0, -[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
		}];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[_users removeFromSuperview];
	[UIView animateWithDuration:.1 animations:^{
		_messageField.transform = CGAffineTransformIdentity;
		_send.transform = CGAffineTransformIdentity;
	}];
	return NO;
}

- (void)getMessageWithIndex:(int)index completionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getMessageData.php?user1=%d&user2=%d&index=%d", _user1ID, _user2ID, _numMessages - index]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
									  {
										  if (error != nil)
										  {
											  NSLog(@"%@", [error localizedDescription]);
										  }
										  else
										  {
											  NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
											  if (message != nil)
											  {
												  [_messageData addObject:message];
												  //NSLog(@"%@", _messageData);
												  [self sortTableData];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  completionHandler(YES);
												  });
											  }
											  else
											  {
												  NSLog(@"%@", [error localizedDescription]);
											  }
										  }
									  }];
	[dataTask resume];
}

- (void)sortTableData
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	for (int i = 0; i < [_messageData count]; i++)
	{
		NSDictionary *data1 = [_messageData objectAtIndex:i];
		NSDate *date1 = [formatter dateFromString:[data1 valueForKey:@"timeSent"]];
		int earliest = i;
		for (int j = i + 1; j < [_messageData count]; j++)
		{
			NSDictionary *data2 = [_messageData objectAtIndex:j];
			NSDate *date2 = [formatter dateFromString:[data2 valueForKey:@"timeSent"]];
			if ([date1 compare:date2] == NSOrderedDescending)
			{
				earliest = j;
				date1 = date2;
			}
			else if ([date1 compare:date2] == NSOrderedAscending)
			{
			}
			else
			{
				if ([[data1 valueForKey:@"id"] intValue] == [[data2 valueForKey:@"id"] intValue])
				{
					[_messageData removeObjectAtIndex:j];
					j--;
				}
			}
		}
		[_messageData exchangeObjectAtIndex:i withObjectAtIndex:earliest];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEqual:_messages])
	{
		if (_numMessages > _messagesLoaded && _messagesLoaded != 0)
		{
			return [_messageData count] + 1;
		}
		return [_messageData count];
	}
	return [_tableData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if ([tableView isEqual:_messages])
	{
		/*
		 NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[[data valueForKey:@"username"] stringByAppendingString:@":"]];
		 NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:13]};
		 [text addAttributes:attributes range:NSMakeRange(0, [text.string length])];
		 NSArray *strings = [[data valueForKey:@"comment"] componentsSeparatedByString:@" "];
		 for (int i = 0; i < [strings count]; i++)
		 {
			NSMutableAttributedString *word = [[NSMutableAttributedString alloc] initWithString:[@" " stringByAppendingString:strings[i]]];
			if ([[word.string substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"@"])
			{
		 [word deleteCharactersInRange:NSMakeRange(1, 1)];
		 attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:13]};
			}
			else
			{
		 attributes = @{NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:15], NSForegroundColorAttributeName: [UIColor whiteColor]};
			}
			[word addAttributes:attributes range:NSMakeRange(1, [word.string length] - 1)];
			[text appendAttributedString:word];
		 }
		 */
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
		}
		if (_numMessages > _messagesLoaded && indexPath.row == 0)
		{
			cell.textLabel.text = @"Scroll up to load more messages";
			cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
			return cell;
		}
		cell.textLabel.text = @"";
		long row = _numMessages > _messagesLoaded && indexPath.row != 0 ? indexPath.row - 1 : indexPath.row;
		NSDictionary *data = [_messageData objectAtIndex:row];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		NSDate *date = [formatter dateFromString:[data valueForKey:@"timeSent"]];
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
		float height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
		if (profilePicture != nil)
		{
			profilePicture = [self roundedRectImageFromImage:profilePicture size:CGSizeMake(40, 40) withCornerRadius:20];
		}
		if ([cell.contentView viewWithTag:-3] == nil)
		{
			cell.textLabel.text = @"";
			UIImageView *imageView = [[UIImageView alloc] init];
			if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
			{
				imageView.frame = CGRectMake(cell.contentView.bounds.size.width - profilePicture.size.width, 5, profilePicture.size.width, profilePicture.size.height);
			}
			else
			{
				imageView.frame = CGRectMake(0, 5, profilePicture.size.width, profilePicture.size.height);
			}
			imageView.image = profilePicture;
			imageView.tag = -3;
			imageView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
			[cell.contentView addSubview:imageView];
		}
		else
		{
			UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:-3];
			if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
			{
				imageView.frame = CGRectMake(cell.contentView.bounds.size.width - profilePicture.size.width, 5, profilePicture.size.width, profilePicture.size.height);
			}
			else
			{
				imageView.frame = CGRectMake(0, 5, profilePicture.size.width, profilePicture.size.height);
			}
			imageView.image = profilePicture;
		}
		if ([cell.contentView viewWithTag:-2] == nil)
		{
			UITextView *textView = [[UITextView alloc] init];
			textView.attributedText = messageText;
			if (profilePicture == nil)
			{
				if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
				{
					textView.frame = CGRectMake(cell.contentView.bounds.size.width / 4, 0, 3 * cell.contentView.bounds.size.width / 4, height);
					textView.textAlignment = NSTextAlignmentRight;
				}
				else
				{
					textView.frame = CGRectMake(0, 0, 3 * cell.contentView.bounds.size.width / 4, height);
					textView.textAlignment = NSTextAlignmentLeft;
				}
			}
			else
			{
				if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
				{
					textView.frame = CGRectMake(cell.contentView.bounds.size.width / 4, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
					textView.textAlignment = NSTextAlignmentRight;
				}
				else
				{
					textView.frame = CGRectMake(profilePicture.size.width, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
					textView.textAlignment = NSTextAlignmentLeft;
				}
			}
			textView.scrollEnabled = NO;
			textView.userInteractionEnabled = YES;
			textView.editable = NO;
			textView.selectable = NO;
			textView.tag = -2;
			textView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
			UITapGestureRecognizer *tapComment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTapped:)];
			[textView addGestureRecognizer:tapComment];
			[cell.contentView addSubview:textView];
		}
		else
		{
			UITextView *textView = (UITextView*)[cell.contentView viewWithTag:-2];
			textView.attributedText = messageText;
			if (profilePicture == nil)
			{
				if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
				{
					textView.frame = CGRectMake(cell.contentView.bounds.size.width / 4, 0, 3 * cell.contentView.bounds.size.width / 4, height);
					textView.textAlignment = NSTextAlignmentRight;
				}
				else
				{
					textView.frame = CGRectMake(0, 0, 3 * cell.contentView.bounds.size.width / 4, height);
					textView.textAlignment = NSTextAlignmentLeft;
				}
			}
			else
			{
				if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
				{
					textView.frame = CGRectMake(cell.contentView.bounds.size.width / 4, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
					textView.textAlignment = NSTextAlignmentRight;
				}
				else
				{
					textView.frame = CGRectMake(profilePicture.size.width, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
					textView.textAlignment = NSTextAlignmentLeft;
				}
			}
		}
		if ([cell.contentView viewWithTag:-1] == nil)
		{
			UILabel *timeElapsed = [[UILabel alloc] init];
			if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
			{
				timeElapsed.frame = CGRectMake(0, 0, cell.contentView.bounds.size.width / 4, height);
				timeElapsed.textAlignment = NSTextAlignmentRight;
			}
			else
			{
				timeElapsed.frame = CGRectMake(3 * cell.contentView.bounds.size.width / 4, 0, cell.contentView.bounds.size.width / 4, height);
				timeElapsed.textAlignment = NSTextAlignmentLeft;
			}
			timeElapsed.text = [NSString stringWithFormat:@"%d %@ ago", time, units];
			timeElapsed.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
			timeElapsed.textColor = [UIColor grayColor];
			timeElapsed.lineBreakMode = NSLineBreakByWordWrapping;
			timeElapsed.numberOfLines = 0;
			timeElapsed.tag = -1;
			[cell.contentView addSubview:timeElapsed];
		}
		else
		{
			UILabel *timeElapsed = (UILabel*)[cell.contentView viewWithTag:-1];
			if ([[data valueForKey:@"user"] intValue] == [AppDelegate getUserID])
			{
				timeElapsed.frame = CGRectMake(0, 0, cell.contentView.bounds.size.width / 4, height);
				timeElapsed.textAlignment = NSTextAlignmentRight;
			}
			else
			{
				timeElapsed.frame = CGRectMake(3 * cell.contentView.bounds.size.width / 4, 0, cell.contentView.bounds.size.width / 4, height);
				timeElapsed.textAlignment = NSTextAlignmentLeft;
			}
			timeElapsed.text = [NSString stringWithFormat:@"%d %@ ago", time, units];
		}
		cell.textLabel.tag = [[data valueForKey:@"user"] intValue];
	}
	else if ([tableView isEqual:_users])
	{
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
		}
		cell.textLabel.text = [_tableData.allKeys objectAtIndex:indexPath.row];
		cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	}
	cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	return cell;
}

- (void)commentTapped:(UITapGestureRecognizer*)recognizer
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
			if (range.location == 0)
			{
				range.length -= 1;
			}
			[self getUserID:[textView.attributedText.string substringWithRange:range] completionHandler:^(int userID){
				if (userID > 0)
				{
					[self getUserID:[textView.text substringWithRange:range] completionHandler:^(int userID){
						if (userID > 0)
						{
							ProfileViewController *profilePage = [[ProfileViewController alloc] initWithUserID:userID];
							//profilePage.username.text = [textView.attributedText.string substringWithRange:range];
							[self presentViewController:profilePage animated:YES completion:nil];
							[AppDelegate showTabBar];
						}
					}];
				}
			}];
		}
		NSLog(@"%@", NSStringFromRange(range));
	}
}

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
		int row = _numMessages > _messagesLoaded ? (int)indexPath.row - 1 : (int)indexPath.row;
		[self deleteMessage:[[[_messageData objectAtIndex:row] valueForKey:@"id"] intValue]];
	}];
	deleteAction.backgroundColor = [UIColor redColor];
	return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isEqual:_users])
	{
		return 44;
	}
	if (_numMessages > _messagesLoaded && indexPath.row == 0)
	{
		return 44;
	}
	long row = _numMessages > _messagesLoaded ? indexPath.row - 1 : indexPath.row;
	NSDictionary *data = [_messageData objectAtIndex:row];
	messageText = [[NSMutableAttributedString alloc] init];
	NSMutableAttributedString *word = [[NSMutableAttributedString alloc] initWithString:[[data valueForKey:@"username"] stringByAppendingString:@":"]];
	NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:13]};
	[word addAttributes:attributes range:NSMakeRange(0, [word length])];
	CGSize size = [word.string sizeWithAttributes:attributes];
	[messageText appendAttributedString:word];
	NSArray *strings = [[data valueForKey:@"message"] componentsSeparatedByString:@" "];
	for (int i = 0; i < [strings count]; i++)
	{
		if ([strings[i] length] == 0)
		{
			continue;
		}
		word = [[NSMutableAttributedString alloc] initWithString:[@" " stringByAppendingString:strings[i]]];
		if ([[word.string substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"@"])
		{
			[word deleteCharactersInRange:NSMakeRange(1, 1)];
			attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:13]};
		}
		else
		{
			attributes = @{NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:15], NSForegroundColorAttributeName: [UIColor whiteColor]};
		}
		[word addAttributes:attributes range:NSMakeRange(1, [word.string length] - 1)];
		CGSize current = [word.string sizeWithAttributes:attributes];
		size.width += current.width;
		if (size.height < current.height)
		{
			size.height = current.height;
		}
		[messageText appendAttributedString:word];
	}
	profilePicture = nil;
	NSData *imageData = [Base64 decode:[data valueForKey:@"profilePicture"]];
	profilePicture = [UIImage imageWithData:imageData];
	float height = (size.height) * ((int)(size.width / (3 * tableView.bounds.size.width / 4 - 16)) + 1) + 32;
	if (profilePicture != nil)
	{
		height = (size.height) * ((int)(size.width / (3 * tableView.bounds.size.width / 4 - 64)) + 1) + 32;
	}
	return height;
	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([tableView isEqual:_users])
	{
		NSArray *words = [[_messageField.text componentsSeparatedByString:@" "] mutableCopy];
		long index = [attributedString.mutableString length] - [[words lastObject] length];
		if (index < 0)
		{
			index = 0;
		}
		[attributedString deleteCharactersInRange:NSMakeRange(index, [[words lastObject] length])];
		NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:[[tableView cellForRowAtIndexPath:indexPath].textLabel.text stringByAppendingString:@" "]];
		[username addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1] range:NSMakeRange(0, [username.string length] - 1)];
		[attributedString appendAttributedString:username];
		_messageField.attributedText = attributedString;
		[tableView removeFromSuperview];
	}
}

- (IBAction)addMessage:(UIButton*)sender
{
	if (![_messageField.attributedText.string isEqualToString:@""])
	{
		for (int i = 0; i < [attributedString.string length]; i++)
		{
			NSRange range;
			if ([[attributedString attributesAtIndex:i effectiveRange:&range] count] != 0)
			{
				[attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"@"] atIndex:i];
				i += range.length;
			}
		}
		NSLog(@"%@", attributedString.string);
		NSString *message = [attributedString.string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		//comment = [[@"\"" stringByAppendingString:comment] stringByAppendingString:@"\""];
		message = [message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		NSString *requestText = [NSString stringWithFormat:@"message=%@&sender=%d&receiver=%d", message, _user1ID, _user2ID];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/addMessage.php"]];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[requestText dataUsingEncoding:NSUTF8StringEncoding]];
		_send.enabled = NO;
		NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
													NSLog(@"url output: %@", text);
													dispatch_async(dispatch_get_main_queue(), ^{
														[_users removeFromSuperview];
														attributedString = [[NSMutableAttributedString alloc] init];
														_messageField.attributedText = attributedString;
														[UIView animateWithDuration:.1 animations:^{
															_messageField.transform = CGAffineTransformIdentity;
															_send.transform = CGAffineTransformIdentity;
														}];
														[_messageField resignFirstResponder];
														[self refreshMessages];
													});
												}];
		[task resume];
	}
}

- (void)deleteMessage:(int)messageID
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/removeMessage.php?arg1=%d", messageID]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@ %d", text, messageID);
									  dispatch_async(dispatch_get_main_queue(), ^{
										  int messagesToLoad = _messagesLoaded - 1;
										  _messagesLoaded = 0;
										  _messageData = [[NSMutableArray alloc] init];
										  _tableData = [[NSMutableDictionary alloc] init];
										  [self getMessageCountWithCompletionHandler:^(BOOL completed){
											  if (_numMessages == 0)
											  {
												  [_messages reloadData];
											  }
											  else
											  {
												  [self loadMessages:messagesToLoad completionHandler:^(BOOL loaded){
													  [_messages reloadData];
												  }];
											  }
										  }];
									  });
								  }];
	[task resume];
}

- (void)getMessageCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/getNumMessages.php?user1=%d&user2=%d", _user1ID, _user2ID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numMessages = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
								  }];
	[task resume];
}

- (void)refreshMessages
{
	int messagesToLoad = _messagesLoaded + 1;
	_messagesLoaded = 0;
	_messageData = [[NSMutableArray alloc] init];
	_tableData = [[NSMutableDictionary alloc] init];
	[self getMessageCountWithCompletionHandler:^(BOOL completed){
		[self loadMessages:messagesToLoad completionHandler:^(BOOL loaded){
			[_messages reloadData];
			if (_messages.contentSize.height - _messages.bounds.size.height > 0)
			{
				_messages.contentOffset = CGPointMake(0, _messages.contentSize.height - _messages.bounds.size.height);
			}
		 }];
	}];
}

- (IBAction)dismissSelf:(id)sender
{
	UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
	int i;
	for (i = 0; viewController != nil; i++)
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
	if ([scrollView isEqual:_messages])
	{
		if (scrollView.contentOffset.y <= -50)
		{
			if (!_loading)
			{
				if (_messagesLoaded < _numMessages)
				{
					activityIndicator.frame = CGRectMake(0, 60, self.view.bounds.size.width, 40);
					[self.view addSubview:activityIndicator];
					[activityIndicator startAnimating];
					_loading = YES;
					[self getMessageCountWithCompletionHandler:^(BOOL completed){
						[self loadMessages:5 completionHandler:^(BOOL loaded){
							[_messages reloadData];
						}];
					}];
				}
			}
		}
	}
}

@end
