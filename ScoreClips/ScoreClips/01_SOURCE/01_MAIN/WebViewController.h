//
//  ScoreClipsViewController.h
//  ScoreClips
//
//  Created by Trong Vu on 4/11/13.
//  Copyright (c) 2013 trongvu. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
	
	IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *urlString;
- (IBAction)backPressed:(id)sender;

@end
