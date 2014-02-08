//
//  WebViewController.m
//  BlogReader
//
//  Created by Amit Bijlani on 4/8/13.
//  Copyright (c) 2013 Amit Bijlani. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.index = 0;
    //self.navigationController.toolbarHidden = NO;
    //hard code first value
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lob.com"]];
	[self.webView loadRequest:urlRequest];
    
    PFQuery *query = [PFQuery queryWithClassName:@"sponsorSites"];
    [query setLimit: 1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            self.startups = [NSMutableArray array];
            
            for (NSDictionary *startupDictionary in objects) {
                //NSLog(@"%@", [NSURL URLWithString:[bpDictionary objectForKey:@"url"]]);
                [self.startups addObject:[NSURL URLWithString:[startupDictionary objectForKey:@"url"]]];
                //refresh data
            }
            // Do something with the found objects
            for (PFObject *object in objects) {
                //NSLog(@"%@", object.objectId);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)next:(id)sender {
    //go to the next webview
//}

- (void) nextWebView {
    if (self.index >= self.startups.count - 1) {
        self.index = 0;
    } else {
        self.index++;
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[self.startups objectAtIndex:self.index]];
	[self.webView loadRequest:urlRequest];

}

- (IBAction)next:(UIBarButtonItem *)sender {
    //increment to the next startup
    //self.index++;
    //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[self.startups objectAtIndex:self.index]];
	//[self.webView loadRequest:urlRequest];
    [self nextWebView];
    NSLog(@"%@", [self.startups objectAtIndex:self.index]);
}

- (IBAction)hellYeah:(UIBarButtonItem *)sender {
    //save interest interaction object
    PFObject *hellYeah = [PFObject objectWithClassName:@"interest"];
    //substitue with the email they enter at the beginning
    hellYeah[@"contactEmail"] = @"raj@rjvir.com";
    hellYeah[@"startupURL"] = [[self.startups objectAtIndex:self.index] absoluteString];
    [hellYeah saveInBackground];
    //then do nextWebView
    [self nextWebView];
}

@end
