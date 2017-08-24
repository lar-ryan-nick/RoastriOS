//
//  ImageViewController.m
//  Learn
//
//  Created by Ryan Wiener on 10/20/15.
//  Copyright © 2015 Computer Science Team. All rights reserved.
//

#import "PostingViewController.h"
#import "AppDelegate.h"

@implementation PostingViewController
{
	NSURLSession *session;
	//NSMutableAttributedString *attributedString;
}

- (void)viewDidLoad
{
	session = [NSURLSession sharedSession];
	UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
	topView.backgroundColor = [UIColor colorWithRed:58.0/255 green:191.0/255 blue:188.0/255 alpha:1];
	[self.view addSubview:topView];
	//attributedString = [[NSMutableAttributedString alloc] init];
	_upload = [UIButton buttonWithType:UIButtonTypeSystem];
	[_upload addTarget:self action:@selector(saveToDatabase:) forControlEvents:UIControlEventTouchUpInside];
	[_upload setTitle:@"Post" forState:UIControlStateNormal];
	_upload.frame = CGRectMake(0, self.view.bounds.size.height - 90, self.view.bounds.size.width, 41);
	_upload.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	[_upload setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Post" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:40], NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]}] forState:UIControlStateNormal];
	_upload.enabled = NO;
	_cropper =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.width)];
	_cropper.delegate = self;
	_imageView = [[UIImageView alloc] init];
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	_cropper.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_cropper.maximumZoomScale = 5;
	[_cropper addSubview:_imageView];
	/*
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	_imageView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	 */
	_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.width + 60, self.view.bounds.size.width, self.view.bounds.size.height - self.view.bounds.size.width - 150)];
	_textView.text = @"Enter your caption or status update here";
	_textView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
	_textView.textColor = [UIColor grayColor];
	_textView.delegate = self;
	UITapGestureRecognizer *resignKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)];
	resignKeyboard.delegate = self;
	[self.view addGestureRecognizer:resignKeyboard];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
	_users = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.width - 152) style:UITableViewStylePlain];
	_users.delegate = self;
	_users.dataSource = self;
	_users.separatorStyle = UITableViewCellSeparatorStyleNone;
	_users.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
	_toolBar.barStyle = UIBarStyleDefault;
	[_toolBar setBarTintColor:[UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1]];
	UIBarButtonItem *photoLibraryButton = [[UIBarButtonItem alloc] initWithTitle:@"Photo Library"
																		   style:UIBarButtonItemStylePlain
																		  target:self
																		  action:@selector(showImagePickerForPhotoPicker:)];
	[photoLibraryButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]} forState:UIControlStateNormal];
	UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithTitle:@"Camera"
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(showImagePickerForCamera:)];
	[cameraButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:252.0/255 green:194.0/255 blue:41.0/255 alpha:1]} forState:UIControlStateNormal];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:nil];
	NSMutableArray *toolbarItems = [NSMutableArray arrayWithObjects:photoLibraryButton, flexibleSpace, cameraButton, nil];
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		// There is not a camera on this device, so don't show the camera button.
		[toolbarItems removeObjectAtIndex:2];
	}
	[_toolBar setItems:toolbarItems animated:NO];
	//self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_upload];
	[self.view addSubview:_cropper];
	[self.view addSubview:_textView];
	[self.view addSubview:_toolBar];
}

- (IBAction)saveToDatabase:(id)sender
{
	if ([_textView.text isEqualToString:@"Enter your caption or status update here"])
	{
		_textView.text = @"";
	}
	NSMutableAttributedString *attributedString = [_textView.attributedText mutableCopy];
	if (_imageView.image == nil && [attributedString.string isEqualToString:@""])
	{
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create Post" message:@"Please select an image or type a caption before posting." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
			[self dismissViewControllerAnimated:YES completion:nil];
		}];
		[alert addAction:ok];
		[self presentViewController:alert animated:YES completion:nil];
		_textView.text = @"Enter your caption or status update here";
	}
	else
	{
		_upload.enabled = NO;
		_textView.editable = NO;
		NSMutableData *requestData;
		NSString *imageString;
		for (int i = 0; i < [attributedString.string length]; i++)
		{
			NSRange range;
			if ([attributedString attribute:NSForegroundColorAttributeName atIndex:i effectiveRange:&range] != nil)
			{
				[attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"@"] atIndex:i];
				i += range.length;
			}
		}
		NSString *postText = [attributedString.string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		postText = [[@"\"" stringByAppendingString:postText] stringByAppendingString:@"\""];
		postText = [postText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		NSURL *url= [NSURL URLWithString:[NSString stringWithFormat:@"https://roastr2.herokuapp.com/addPost.php"]];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		if (_imageView.image != nil)
		{
			NSLog(@"%f %f %f", _cropper.bounds.size.width, _cropper.contentOffset.x, _cropper.contentSize.width);
			NSLog(@"%f %f %f", _cropper.contentOffset.y, _cropper.bounds.size.height, _cropper.contentSize.height);
			float left = _cropper.contentOffset.x < 0 ? -_cropper.contentOffset.x : 0;
			float top = _cropper.contentOffset.y < 0 ? -_cropper.contentOffset.y : 0;
			float width = _cropper.bounds.size.width + _cropper.contentOffset.x  > _cropper.contentSize.width ? _cropper.bounds.size.width - left - (_cropper.contentOffset.x + _cropper.bounds.size.width - (_cropper.contentSize.width)) : _cropper.bounds.size.width - left;
			float height = _cropper.contentOffset.y + _cropper.bounds.size.height > _cropper.contentSize.height ? _cropper.bounds.size.height - top - (_cropper.contentOffset.y + _cropper.bounds.size.height - (_cropper.contentSize.height)) : _cropper.bounds.size.height - top;
			CGRect grabRect = CGRectMake(left, top + _cropper.frame.origin.y, width, height);
			if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			{
				UIGraphicsBeginImageContextWithOptions(grabRect.size, NO, [UIScreen mainScreen].scale);
			} else
			{
				UIGraphicsBeginImageContext(grabRect.size);
			}
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			CGContextTranslateCTM(ctx, -grabRect.origin.x, -grabRect.origin.y);
			[self.view.layer renderInContext:ctx];
			UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			CGRectIsNull(grabRect);
			NSData *imageData = UIImageJPEGRepresentation(viewImage, 0.4);
			imageString = [Base64 encode:imageData];
			imageString = [imageString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
		}
		requestData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"image=%@&caption=%@&userID=%d", imageString, postText, [AppDelegate getUserID]] dataUsingEncoding:NSUTF8StringEncoding]];
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
											  dispatch_async(dispatch_get_main_queue(), ^{
												  _imageView.image = nil;
												  _textView.text = @"Enter your caption or status update here";
												  _textView.textColor = [UIColor grayColor];
												  _textView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
												  _textView.editable = YES;
											  });
										  }
									  }];
		[task resume];
	}
}

- (void)keyboardWillChange:(NSNotification *)notification {
	[UIView animateWithDuration:.1 animations:^{
		_textView.transform = CGAffineTransformMakeTranslation(0, -[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height + 90);
	}];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([_textView.text isEqualToString:@"Enter your caption or status update here"])
	{
		_textView.text = @"";
		_textView.textColor = [UIColor blackColor];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	[_users removeFromSuperview];
	[UIView animateWithDuration:.1 animations:^{
		_textView.transform = CGAffineTransformIdentity;
	}];
	if ([_textView.text isEqualToString:@""])
	{
		_textView.text = @"Enter your caption or status update here";
		_textView.textColor = [UIColor grayColor];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isDescendantOfView:_users])
	{
		return NO;
	}
	return YES;
}

- (IBAction)resignKeyboard:(UITapGestureRecognizer*)sender
{
	[_textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	NSMutableAttributedString *attributedString = [_textView.attributedText mutableCopy];
	if (range.location < [attributedString length])
	{
		NSRange effectiveRange;
		id attribute = [attributedString attribute:NSForegroundColorAttributeName atIndex:range.location effectiveRange:&effectiveRange];
		if (attribute != nil)
		{
			[attributedString removeAttribute:NSForegroundColorAttributeName range:effectiveRange];
			[attributedString replaceCharactersInRange:range withString:text];
		}
		else
		{
			[attributedString replaceCharactersInRange:range withString:text];
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MarkerFelt-Thin" size:20] range:NSMakeRange(0, [attributedString.string length])];
		}
	}
	else
	{
		[attributedString replaceCharactersInRange:range withString:text];
		NSRange effectiveRange;
		id attribute = [attributedString attribute:NSForegroundColorAttributeName atIndex:range.location effectiveRange:&effectiveRange];
		if (attribute != nil)
		{
			if ([text isEqualToString:@" "])
			{
				[attributedString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(effectiveRange.location + effectiveRange.length - 1, 1)];
			}
			else
			{
				[attributedString removeAttribute:NSForegroundColorAttributeName range:effectiveRange];
			}
		}
		else
		{
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MarkerFelt-Thin" size:20] range:NSMakeRange(0, [attributedString.string length])];
		}
	}
	if ([attributedString.string isEqualToString:@""])
	{
		if (_imageView.image == nil)
		{
			_upload.enabled = NO;
		}
		[_users removeFromSuperview];
	}
	else
	{
		_upload.enabled = YES;
		NSString *searchText = [[attributedString.string componentsSeparatedByString:@" "] lastObject];
		[self loadSimilarUserswithText:searchText completionHandler:^(BOOL results){
			if (results)
			{
				[_users reloadData];
				[[textView superview] addSubview:_users];
			}
			else
			{
				[_users removeFromSuperview];
			}
		}];
	}
	textView.attributedText = attributedString;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"SimpleTableItem";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}
	cell.textLabel.text = [_tableData.allKeys objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:20];
	cell.textLabel.textColor = [UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1];
	//cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	cell.contentView.backgroundColor = [UIColor colorWithRed:45.0/255 green:49.0/255 blue:66.0/255 alpha:1];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableView cellForRowAtIndexPath:indexPath].textLabel.tag == [AppDelegate getUserID] && ![[_tableData.allValues objectAtIndex:indexPath.row] isEqualToString:@""])
	{
		return YES;
	}
	return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSArray *words = [[_textView.text componentsSeparatedByString:@" "] mutableCopy];
	NSMutableAttributedString *attributedString = [_textView.attributedText mutableCopy];
	long index = [attributedString.mutableString length] - [[words lastObject] length];
	if (index < 0)
	{
		index = 0;
	}
	NSLog(@"%lu", index);
	[attributedString deleteCharactersInRange:NSMakeRange(index, [[words lastObject] length])];
	NSLog(@"%@", attributedString);
	NSMutableAttributedString *username = [[NSMutableAttributedString alloc] initWithString:[[tableView cellForRowAtIndexPath:indexPath].textLabel.text stringByAppendingString:@" "]];
	[username addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:231.0/255 green:114.0/255 blue:37.0/255 alpha:1], NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Thin" size:20]} range:NSMakeRange(0, [username.string length] - 1)];
	[attributedString appendAttributedString:username];
	NSLog(@"%@", attributedString);
	_textView.attributedText = attributedString;
	[tableView removeFromSuperview];
}
/*
 - (UIImage*)saveImageWithText:(id)sender
 {
 textField2.center = CGPointMake(self.view.bounds.size.width / 2, _imageView.center.y + _imageView.bounds.size.height / 2 + 20);
 [textField1 resignFirstResponder];
 [textField2 resignFirstResponder];
 CGRect grabRect = CGRectMake(_imageView.center.x - _imageView.bounds.size.width / 2, _imageView.center.y - _imageView.bounds.size.height / 2 - 40, _imageView.bounds.size.width, 80 + _imageView.bounds.size.height);
 if ([textField1.text isEqual:@"" ] && [textField2.text  isEqual:@""])
 grabRect = CGRectMake(_imageView.center.x - _imageView.bounds.size.width / 2, _imageView.center.y - _imageView.bounds.size.height / 2, _imageView.bounds.size.width, _imageView.bounds.size.height);
 else if ([textField1.text isEqual:@""])
 grabRect = CGRectMake(_imageView.center.x - _imageView.bounds.size.width / 2, _imageView.center.y - _imageView.bounds.size.height / 2, _imageView.bounds.size.width, 40 + _imageView.bounds.size.height);
 else if ([textField2.text isEqual:@""])
 grabRect = CGRectMake(_imageView.center.x - _imageView.bounds.size.width / 2, _imageView.center.y - _imageView.bounds.size.height / 2 - 40, _imageView.bounds.size.width, 40 + _imageView.bounds.size.height);
 if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
 UIGraphicsBeginImageContextWithOptions(grabRect.size, NO, [UIScreen mainScreen].scale);
 } else {
 UIGraphicsBeginImageContext(grabRect.size);
 }
 CGContextRef ctx = UIGraphicsGetCurrentContext();
 CGContextTranslateCTM(ctx, -grabRect.origin.x, -grabRect.origin.y);
 [self.view.layer renderInContext:ctx];
 UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 CGRectIsNull(grabRect);
 return viewImage;
 }
 */
- (IBAction)showImagePickerForCamera:(id)sender
{
	[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
	[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
	_imagePickerController = [[UIImagePickerController alloc] init];
	_imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	_imagePickerController.sourceType = sourceType;
	_imagePickerController.delegate = self;
	[AppDelegate hideTabBar];
	
	if (sourceType == UIImagePickerControllerSourceTypeCamera)
	{
		//The user wants to use the camera interface. Set up our custom overlay view for the camera.
		_imagePickerController.showsCameraControls = YES;
	}
	[self presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[AppDelegate showTabBar];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	_cropper.zoomScale = 1;
	float ratio = image.size.height / image.size.width;
	_cropper.contentSize = CGSizeMake(_cropper.bounds.size.width, ratio * _cropper.bounds.size.width);
	float x = (int)ratio ? (_cropper.contentSize.width / .9 - _cropper.bounds.size.width) / 2 : 0;
	float y = (int)ratio ? 0 : (_cropper.bounds.size.height - _cropper.contentSize.height) / 2;
	_cropper.contentOffset = CGPointMake(0, -y);
	if (y)
	{
		_cropper.minimumZoomScale = 1;
		//_cropper.contentInset = UIEdgeInsetsMake(y, x, y, x);
	}
	else
	{
		_cropper.minimumZoomScale = .9;
		//_cropper.contentSize = CGSizeMake(_cropper.contentSize.width * 1.1, _cropper.contentSize.height * 1.1);
		//x = (_cropper.contentSize.width - _cropper.bounds.size.width) / 2;
		//_cropper.contentInset = UIEdgeInsetsMake(y, x, y, x);
	}
	_cropper.contentInset = UIEdgeInsetsMake(y, x, y, x);
	_imageView.frame = CGRectMake(0, 0, _cropper.contentSize.width, _cropper.contentSize.height);
	[_imageView setImage:image];
	_upload.enabled = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
	_imagePickerController = nil;
	[AppDelegate showTabBar];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

@end
