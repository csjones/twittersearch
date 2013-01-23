//
//  SearchVC.m
//  twittersearch
//
//  Created by crkmnstr on 1/15/13.
//  Copyright (c) 2013 evilBlue. All rights reserved.
//

#import "SearchVC.h"
#import "TwitterSearch.h"
#import "ZAActivityBar.h"
#import "PrettyCustomViewTableViewCell.h"

@interface SearchVC ()

- (void)prepAnimation;
- (void)initSearchRequest;
- (IBAction)buttonTouchUpInside:(id)sender;
- (void)keyboardDidHide:(NSNotification*)notification;

@end

@implementation SearchVC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Draw a custom gradient
    CAGradientLayer *buttonGradient = [CAGradientLayer layer];
    
    buttonGradient.frame = _searchButton.bounds;
    buttonGradient.colors = [NSArray arrayWithObjects:  (id)[[UIColor colorWithRed:83.f / 255.f green:164.f / 255.f blue:222.f / 255.f alpha:1.0f] CGColor],
                                                        (id)[[UIColor colorWithRed:41.f / 255.f green:124.f / 255.f blue:183.f / 255.f alpha:1.0f] CGColor],
                                                        nil];
    
    _searchButton.clipsToBounds = TRUE;
    _searchButton.layer.borderWidth = 1.f;
    _searchButton.layer.cornerRadius = 8.f;
    _searchButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [_searchButton.layer insertSublayer:buttonGradient atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self prepAnimation];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SearchVC - Private

- (void)prepAnimation
{
    _searchButton.enabled = TRUE;
    _searchTextfield.enabled = TRUE;
    
    [UIView animateWithDuration:.3f
					 animations:^{
                         CGRect mainFrame = [[UIScreen mainScreen] bounds];
                         
                         _vSpaceConstraint.constant = mainFrame.size.height > 480 ? 350 : 300;
                         
                         [self.view layoutIfNeeded];
					 }
					 completion:^(BOOL finished){
                         [_searchTextfield becomeFirstResponder];
					 }];
}

- (void)initSearchRequest
{
    _searchButton.enabled = FALSE;
    _searchTextfield.enabled = FALSE;
    
    [_searchTextfield resignFirstResponder];
    
    [UIView animateWithDuration:.3f
					 animations:^{
                         CGRect mainFrame = [[UIScreen mainScreen] bounds];
                         
                         _vSpaceConstraint.constant = mainFrame.size.height > 480 ? 250 : 200;
                         
                         [self.view layoutIfNeeded];
					 }];
}

- (IBAction)buttonTouchUpInside:(id)sender
{
    [self initSearchRequest];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	[ZAActivityBar showWithStatus:@"Searching Twitter" forAction:@"search"];
    
    [[TwitterSearch sharedInstance] searchWithTerms:_searchTextfield.text
                                          onSuccess:^{
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [ZAActivityBar showSuccessWithStatus:@"Got Results!" forAction:@"search"];
                                              });
                                              
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                  [self performSegueWithIdentifier:@"results" sender:nil];
                                              });
                                          }
                                          onFailure:^(NSError *error) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [ZAActivityBar showErrorWithStatus:@"Failed To Get Results" forAction:@"search"];
                                              });
                                              
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                  [self prepAnimation];
                                              });
                                          }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PrettyTableViewCell *prettyCell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
	
	if(!prettyCell)
	{
		prettyCell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
	}
	
	[prettyCell prepareForTableView:tableView indexPath:indexPath];
	
	prettyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    prettyCell.imageView.image = [UIImage imageNamed:@"search"];
    
	//	Configure the cell...
	CGRect	cellFrame = prettyCell.frame;
	
	cellFrame.size.width -= 90.f;
	cellFrame.size.height -= 10.f;
	
    _searchTextfield = [[UITextField alloc] initWithFrame:cellFrame];
	
	_searchTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	_searchTextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_searchTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_searchTextfield.backgroundColor = prettyCell.backgroundColor;
	_searchTextfield.textAlignment = NSTextAlignmentLeft;
    _searchTextfield.font = [UIFont systemFontOfSize:25];
    _searchTextfield.returnKeyType = UIReturnKeyGo;
    _searchTextfield.placeholder = @"Crazy Panda";
    _searchTextfield.delegate = self;
	_searchTextfield.tag = 314;
	
    //	Add textfield to the cell
	prettyCell.accessoryView = _searchTextfield;
	
    return prettyCell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self initSearchRequest];
    
    return TRUE;
}

@end