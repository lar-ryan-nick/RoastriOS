//
//  CommentsViewController.m
//  Roastr
//
//  Created by Ryan Wiener on 11/12/16.
//  Copyright © 2016 ryanlwiener. All rights reserved.
//

#import "CommentsViewController.h"
#import "AppDelegate.h"

@implementation CommentsViewController
{
	NSURLSession *session;
	UIActivityIndicatorView *activityIndicator;
	NSMutableAttributedString *attributedString;
	UIImage *profilePicture;
	NSMutableAttributedString *commentText;
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
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	title.text = @"Roasts";
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
	_numComments = 0;
	_commentsLoaded = 0;
	_comments = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 100) style:UITableViewStylePlain];
	_comments.delegate = self;
	_comments.dataSource = self;
	_comments.allowsSelection = NO;
	_comments.separatorStyle = UITableViewCellSeparatorStyleNone;
	_comments.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[self getCommentCountWithCompletionHandler:^(BOOL completed){
		[self loadComments:5];
	}];
	[self.view addSubview:_comments];
	_users = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width , self.view.bounds.size.height - 356) style:UITableViewStylePlain];
	_users.delegate = self;
	_users.dataSource = self;
	_users.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_users.separatorStyle = UITableViewCellSeparatorStyleNone;
	_commentField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, 3 * self.view.bounds.size.width / 4, 40)];
	_commentField.textColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_commentField.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	_commentField.delegate = self;
	_commentField.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
	[self.view addSubview:_commentField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
	_roast = [UIButton buttonWithType:UIButtonTypeSystem];
	_roast.frame = CGRectMake(3 * self.view.bounds.size.width / 4, self.view.bounds.size.height - 40, self.view.bounds.size.width / 4, 40);
	[_roast setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Roast" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20], NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1]}] forState:UIControlStateNormal];
	_roast.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:255.0/255 alpha:1];
	[_roast addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
	_roast.enabled = NO;
	[self.view addSubview:_roast];
	_commentData = [[NSMutableArray alloc] init];
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

- (void)loadComments:(int)comments
{
	int i = _commentsLoaded;
	if (comments + _commentsLoaded > _numComments)
	{
		_commentsLoaded = _numComments;
	}
	else
	{
		_commentsLoaded += comments;
	}
	while (i < _commentsLoaded)
	{
		[self getCommentWithIndex:i];
		i++;
	}
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
	_loading = NO;
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
		_roast.enabled = NO;
	}
	else
	{
		_roast.enabled = YES;
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
		NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getLikeUsers.php?arg1=%@", searchText]];
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

- (void)keyboardWillChange:(NSNotification *)notification {
	if ([[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y != self.view.bounds.size.height)
	{
		[UIView animateWithDuration:.1 animations:^{
			_commentField.transform = CGAffineTransformMakeTranslation(0, -[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
			_roast.transform = CGAffineTransformMakeTranslation(0, -[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
		}];
	}
}
/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[UIView animateWithDuration:.1 animations:^{
		_commentField.transform = CGAffineTransformMakeTranslation(0, -256);
		_roast.transform = CGAffineTransformMakeTranslation(0, -256);
	}];
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[_users removeFromSuperview];
	[UIView animateWithDuration:.1 animations:^{
		_commentField.transform = CGAffineTransformIdentity;
		_roast.transform = CGAffineTransformIdentity;
	}];
	return NO;
}

- (void)getCommentWithIndex:(int)index
{
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getCommentData.php?arg1=%d&arg2=%d", _postID, _numComments - index]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
									  {
										  if (error != nil)
										  {
											  NSLog(@"%@", [error localizedDescription]);
										  }
										  else
										  {
											  NSDictionary *comment = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
											  if (comment != nil)
											  {
												  [_commentData addObject:comment];
												  [self sortTableData];
												  dispatch_async(dispatch_get_main_queue(), ^{
													  [_comments reloadData];
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
	for (int i = 0; i < [_commentData count]; i++)
	{
		NSDictionary *data1 = [_commentData objectAtIndex:i];
		NSDate *date1 = [formatter dateFromString:[data1 valueForKey:@"timeCommented"]];
		int earliest = i;
		for (int j = i + 1; j < [_commentData count]; j++)
		{
			NSDictionary *data2 = [_commentData objectAtIndex:j];
			NSDate *date2 = [formatter dateFromString:[data2 valueForKey:@"timeCommented"]];
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
					[_commentData removeObjectAtIndex:j];
					j--;
				}
			}
		}
		[_commentData exchangeObjectAtIndex:i withObjectAtIndex:earliest];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEqual:_comments])
	{
		if (_numComments > _commentsLoaded && _commentsLoaded != 0)
		{
			return [_commentData count] + 1;
		}
		return [_commentData count];
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
	if ([tableView isEqual:_comments])
	{
		long row = _numComments > _commentsLoaded && indexPath.row != 0 ? indexPath.row - 1 : indexPath.row;
		NSDictionary *data = [_commentData objectAtIndex:row];
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
		if (_numComments > _commentsLoaded && indexPath.row == 0)
		{
			cell.textLabel.text = @"Scroll up to load more comments";
			cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
			cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
			return cell;
		}
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		NSDate *date = [formatter dateFromString:[data valueForKey:@"timeCommented"]];
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
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, profilePicture.size.width, profilePicture.size.height)];
			imageView.image = profilePicture;
			imageView.tag = -3;
			imageView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
			[cell.contentView addSubview:imageView];
		}
		else
		{
			UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:-3];
			imageView.frame = CGRectMake(0, 5, profilePicture.size.width, profilePicture.size.height);
			imageView.image = profilePicture;
		}
		if ([cell.contentView viewWithTag:-2] == nil)
		{
			cell.textLabel.text = @"";
			UITextView *textView = [[UITextView alloc] init];
			if (profilePicture == nil)
			{
				textView.frame = CGRectMake(0, 0, 3 * cell.contentView.bounds.size.width / 4, height);
			}
			else
			{
				textView.frame = CGRectMake(profilePicture.size.width, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
			}
			textView.scrollEnabled = NO;
			textView.attributedText = commentText;
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
			if (profilePicture == nil)
			{
				textView.frame = CGRectMake(0, 0, 3 * cell.contentView.bounds.size.width / 4, height);
			}
			else
			{
				textView.frame = CGRectMake(profilePicture.size.width, 0, 3 * cell.contentView.bounds.size.width / 4 - profilePicture.size.width, height);
			}
			textView.attributedText = commentText;
		}
		if ([cell.contentView viewWithTag:-1] == nil)
		{
			UILabel *timeElapsed = [[UILabel alloc] initWithFrame:CGRectMake(3 * cell.contentView.bounds.size.width / 4, 0, cell.contentView.bounds.size.width / 4, height)];
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
			timeElapsed.frame = CGRectMake(3 * cell.contentView.bounds.size.width / 4, 0, cell.contentView.bounds.size.width / 4, height);
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
		int row = _numComments > _commentsLoaded ? (int)indexPath.row - 1 : (int)indexPath.row;
		[self deleteComment:[[[_commentData objectAtIndex:row] valueForKey:@"id"] intValue]];
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
		return 44;
	if (_numComments > _commentsLoaded && indexPath.row == 0)
	{
		return 44;
	}
	long row = _numComments > _commentsLoaded ? indexPath.row - 1 : indexPath.row;
	NSDictionary *data = [_commentData objectAtIndex:row];
	commentText = [[NSMutableAttributedString alloc] init];
	NSMutableAttributedString *word = [[NSMutableAttributedString alloc] initWithString:[[data valueForKey:@"username"] stringByAppendingString:@":"]];
	NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"MarkerFelt-Thin" size:13]};
	[word addAttributes:attributes range:NSMakeRange(0, [word length])];
	CGSize size = [word.string sizeWithAttributes:attributes];
	[commentText appendAttributedString:word];
	NSArray *strings = [[data valueForKey:@"comment"] componentsSeparatedByString:@" "];
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
		[commentText appendAttributedString:word];
	}
	profilePicture = nil;
	NSData *imageData = [Base64 decode:[data valueForKey:@"profilePicture"]];
	profilePicture = [UIImage imageWithData:imageData];
	float height = (size.height + 8) * ((int)(size.width / (3 * tableView.bounds.size.width / 4 - 16)) + 1) + 32;
	if (profilePicture != nil)
	{
		height = (size.height + 8) * ((int)(size.width / (3 * tableView.bounds.size.width / 4 - 56)) + 1) + 32;
	}
	return height;
	
}

- (void)getUserID:(NSString*)username completionHandler:(void (^)(int userID))completionHandler
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getIDForUser.php?arg1='%@'", username];
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
		NSArray *words = [[_commentField.text componentsSeparatedByString:@" "] mutableCopy];
		long index = [attributedString.mutableString length] - [[words lastObject] length];
		if (index < 0)
		{
			index = 0;
		}
		[attributedString deleteCharactersInRange:NSMakeRange(index, [[words lastObject] length])];
		NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:[[tableView cellForRowAtIndexPath:indexPath].textLabel.text stringByAppendingString:@" "]];
		[username addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1] range:NSMakeRange(0, [username.string length] - 1)];
		[attributedString appendAttributedString:username];
		_commentField.attributedText = attributedString;
		[tableView removeFromSuperview];
	}
}

- (IBAction)addComment:(UIButton*)sender
{
	if (![_commentField.attributedText.string isEqualToString:@""])
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
		NSString *comment = [attributedString.string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		comment = [[@"\"" stringByAppendingString:comment] stringByAppendingString:@"\""];
		comment = [comment stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		NSString *requestText = [NSString stringWithFormat:@"comment=%@&post=%d&user=%d", comment, _postID, [AppDelegate getUserID]];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/addComment.php"]];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[requestText dataUsingEncoding:NSUTF8StringEncoding]];
		_roast.enabled = NO;
		NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
													NSLog(@"url output: %@", text);
													dispatch_async(dispatch_get_main_queue(), ^{
														[_users removeFromSuperview];
														attributedString = [[NSMutableAttributedString alloc] init];
														_commentField.attributedText = attributedString;
														[UIView animateWithDuration:.1 animations:^{
															_commentField.transform = CGAffineTransformIdentity;
															_roast.transform = CGAffineTransformIdentity;
														}];
														[_commentField resignFirstResponder];
														int commentsToLoad = _commentsLoaded + 1;
														_commentsLoaded = 0;
														_commentData = [[NSMutableArray alloc] init];
														_tableData = [[NSMutableDictionary alloc] init];
														[self getCommentCountWithCompletionHandler:^(BOOL completed){
															[self loadComments:commentsToLoad];
														}];
													});
												}];
		[task resume];
	}
}

- (void)deleteComment:(int)commentID
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/removeComment.php?arg1=%d", commentID]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  NSLog(@"%@ %d", text, commentID);
									  dispatch_async(dispatch_get_main_queue(), ^{
										  int commentsToLoad = _commentsLoaded - 1;
										  _commentsLoaded = 0;
										  _commentData = [[NSMutableArray alloc] init];
										  _tableData = [[NSMutableDictionary alloc] init];
										  [self getCommentCountWithCompletionHandler:^(BOOL completed){
											  if (_numComments == 0)
											  {
												  [_comments reloadData];
											  }
											  else
											  {
												  [self loadComments:commentsToLoad];
											  }
										  }];
									  });
								  }];
	[task resume];
}

- (void)getCommentCountWithCompletionHandler:(void (^)(BOOL completed))completionHandler
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-35-164-1-3.us-west-2.compute.amazonaws.com/getNumComments.php?arg1=%d", _postID]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
											completionHandler:
								  ^(NSData *data, NSURLResponse *response, NSError *error) {
									  NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
									  _numComments = [text intValue];
									  dispatch_async(dispatch_get_main_queue(), ^{
										  completionHandler(YES);
									  });
								  }];
	[task resume];
}

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
	if ([scrollView isEqual:_comments])
	{
		if (scrollOffset <= -10)
		{
			if (!_loading)
			{
				if (_commentsLoaded < _numComments)
				{
					activityIndicator.frame = CGRectMake(0, 60, self.view.bounds.size.width, 40);
					[self.view addSubview:activityIndicator];
					[activityIndicator startAnimating];
					_loading = YES;
					[self getCommentCountWithCompletionHandler:^(BOOL completed){
						[self loadComments:5];
					}];
				}
			}
		}
	}
}

@end
