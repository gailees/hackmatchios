//
//  WebViewController.h
//  BlogReader
//
//  Created by Amit Bijlani on 4/8/13.
//  Copyright (c) 2013 Amit Bijlani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WebViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *blogPosts;
@property (strong, nonatomic) NSURL *blogPostURL;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
//- (IBAction)next:(id)sender;


@end
