//
//  WebViewController.m
//  BlogReader
//
//  Created by Amit Bijlani on 4/8/13.
//  Copyright (c) 2013 Amit Bijlani. All rights reserved.
//

#import "WebViewController.h"
#import "NSMutableArray_Shuffling.h"
#import <Apptimize/Apptimize.h>


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
    [self loadStartupsFromParse];
    
    //array of webviews
    
    WebView *webView = [[WebView alloc] init];
    self.webView = webView;
    
    //hard code first value
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://secret.ly"]];
    
    [webView loadRequest:urlRequest];
    
    [self.view addSubview:webView];
    
    //setting constraints so that webview doesnt overlap with [top] and [bottom]
    //webviews automatically account for them
    NSDictionary *views = @{ @"web": webView, @"top": self.topLayoutGuide, @"bottom": self.bottomLayoutGuide };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[web]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[web]|" options:0 metrics:nil views:views]];
    
    //**use webviews array by instantiating webview by webview
    //when someone hits next just throw away that webView and instantiate a new one to add to the queue
    
    //take the first 4, make 4 webviews
    //use queue and always be hiding all views but the first view and showing the first view in the queue
    

    
    [self inititializeGestures:webView];
    
    //<meta name="viewport" content="width=device-width" />
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadStartupsFromParse {
    //load startups from parse
    PFQuery *query = [PFQuery queryWithClassName:@"sponsorSites"];
    [query setLimit: 1000];
    [query whereKey:@"tags" equalTo:@"mobile"];
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
            //shuffle around startups so they aren't in the same order -- first startup is still hard coded
            [self.startups shuffle];
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



- (void) addStartupToArray:(NSURL *) startupUrl {
    WebView *webView = [[WebView alloc] init];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:startupUrl];
    [webView loadRequest:urlRequest];
    
    //setting constraints so that webview doesnt overlap with [top] and [bottom]
    //webviews automatically account for them
    NSDictionary *views = @{ @"web": webView, @"top": self.topLayoutGuide, @"bottom": self.bottomLayoutGuide };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[web]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[web]|" options:0 metrics:nil views:views]];
    
    [self addWebViewtoWebViews:webView];
}

- (void) addWebViewtoWebViews:(WebView *) webView {
    [self.webViews addObject: webView];
}

- (void) initializeWebViews {
    for (int i=0; i<3; i++) {
        [self addStartupToArray:[self.startups objectAtIndex:i]];
    }
}

//shift by popping first element from array
- (void) removeWebViewtoWebViews {
    [self.webViews removeObjectAtIndex:0];
}

//need to take webview as an input
- (void) inititializeGestures:(WebView *) webView {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [webView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [webView addGestureRecognizer:swipeLeft];
}

- (void) nextWebView {
    if (self.index >= self.startups.count - 1) {
        self.index = 0;
    } else {
        self.index++;
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[self.startups objectAtIndex:self.index]];
	[self.webView loadRequest:urlRequest];
    //[self.webView loadRequest:urlRequest];

    NSLog(@"%@", [self.startups objectAtIndex:self.index]);
}

- (void) hellYeahNextWebView {
    //save interest interaction object
    PFObject *hellYeah = [PFObject objectWithClassName:@"interest"];
    //substitue with the email they enter at the beginning
    hellYeah[@"contactEmail"] = @"raj@rjvir.com";
    hellYeah[@"startupURL"] = [[self.startups objectAtIndex:self.index] absoluteString];
    [hellYeah saveInBackground];
    //then do nextWebView
    [self nextWebView];
}

- (IBAction)next:(UIBarButtonItem *)sender {
    //increment to the next startup
    //self.index++;
    //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[self.startups objectAtIndex:self.index]];
	//[self.webView loadRequest:urlRequest];
    [self nextWebView];
}

- (IBAction)hellYeah:(UIBarButtonItem *)sender {
    //check if there is data cached for userEmail and userUrl
    //if there isn't, drop down a view that collects that data once and caches it

    //try one
    /*
    CGRect frame = YourView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    
    frame.origin.x = 0; //
    pushView.frame = frame;
    self.YourView.frame = CGRectMake(250, 45, 500, 960);
    [UIView commitAnimations];
     */
    //try two
    /*
    MyModalViewController *targetController = [[[MyModalViewController alloc] init] autorelease];
    
    targetController.modalPresentationStyle = UIModalPresentationFormSheet;
    targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //transition shouldn't matter
    [self presentModalViewController:targetController animated:YES];
    
    targetController.view.superview.frame = CGRectMake(0, 0, 200, 200);//it's important to do this after
    
    presentModalViewController targetController.view.superview.center = self.view.center;
     */
    [self hellYeahNextWebView];

}

// MARK: - Gesture Recognizers
- (void)swipeRightAction:(UISwipeGestureRecognizer*)recognizer
{
    NSLog(@"swipe right");
    [self hellYeahNextWebView];
}

- (void)swipeLeftAction:(UISwipeGestureRecognizer*)recognizer
{
    NSLog(@"swipe left");
    [self nextWebView];
}
/*

- (IBAction)swipeRight:(id)sender {
    [self nextWebView];
}

- (IBAction)swipeLeft:(id)sender {
    [self nextWebView];
}
 */
@end
