//
//  SearchVC.h
//  twittersearch
//
//  Created by crkmnstr on 1/15/13.
//  Copyright (c) 2013 evilBlue. All rights reserved.
//

@interface SearchVC : UIViewController <UITableViewDataSource, UITextFieldDelegate>
{
    IBOutlet UITableView        *_searchTable;
    
    IBOutlet UIButton           *_searchButton;
    
    UITextField                 *_searchTextfield;
    
    IBOutlet NSLayoutConstraint *_vSpaceConstraint;
}

@end
