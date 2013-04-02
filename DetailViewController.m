//
//  DetailViewController.m
//  ElfDictIOS
//
//  Created by Rebecca Mitchell on 3/31/13.
//  Copyright (c) 2013 Rebecca M. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view. 
        [self configureView];
        
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        
        NSMutableString *html = [NSMutableString stringWithFormat:
                            @"<html><head>"
                            "<style type=\"text/css\">"
                            "body{"
                            "font-family:'Georgia', sans-serif;"
                            "background-image:url(%@);"
                            "}"
                            ",</style>"
                            "</head>"
                          "<body>", @"tranlation-background.png"];
        
       // NSMutableString *html = [NSMutableString stringWithString: @"<html><head><title></title></head><body style=\"background:transparent;\">"];
        
        [html appendFormat: @"<div style=\"padding: 5px; font-size:25px; font-weight:bold; text-align:center; height:35px; background:white; -webkit-border-radius: 10px;\">%@</div>", [self.detailItem word]];
        
        NSMutableString *commentString = [NSMutableString string];
        NSString *author = [self.detailItem author];
        
        NSString *statment = @"We neither can nor do claim affiliation with Middle-earth Enterprises nor Tolkien Estate";
        
        if ([self.detailItem comments] != nil)
            [commentString appendString:[self.detailItem comments]];
        else
            [commentString appendString: @"No comments found for this word."];
        
        [html appendFormat: @"<div style=\"background:white; -webkit-border-radius: 10px; margin-top:10px; padding: 10px;\"> <div style=\"color:#cccccc; font-size:14;\">Comments: </div><div style=\"margin-top:5px; \">%@</div> <div style=\"color:#cccccc; margin-top:20px; text-align:right; font-size:14;\">%@</div></div>", commentString, author];
        
        [html appendString:@"</body></html>"];
        
        [[self navigationItem] setTitle:[self.detailItem translation]];
        
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
        [m_htmlView loadHTMLString:html baseURL:baseURL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
