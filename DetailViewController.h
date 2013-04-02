//
//  DetailViewController.h
//  ElfDictIOS
//
//  Created by Rebecca Mitchell on 3/31/13.
//  Copyright (c) 2013 Rebecca M. All rights reserved. 
//

#import <UIKit/UIKit.h>
#import "WordDefinition.h"

@interface DetailViewController : UIViewController {
    IBOutlet UIWebView *m_htmlView;
}

@property (strong, nonatomic) WordDefinition *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
