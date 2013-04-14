//
//  ScoreClipsViewController.m
//  ScoreClips
//
//  Created by Trong Vu on 4/11/13.
//  Copyright (c) 2013 trongvu. All rights reserved.
//

#import "ScoreClipsViewController.h"
#import "AppViewController.h"
#import "SupportFunction.h"
#import "KOFilesViewController.h"
#import "KOFileTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "KOAppDelegate.h"
#import "KOData.h"
#import "KOFileObject.h"
#import "KOMenuObject.h"
#import "KOSegmentedControl.h"
#import "WebViewController.h"

@interface ScoreClipsViewController () {
    V8HorizontalPickerView                  *pickerView;
    APIRequester                            *_APIRequester;
    NSMutableDictionary                     *_scoreJsons;
    NSMutableArray                          *_scoreDates;
    int                                     _scoreIndex;
}

@end

@implementation ScoreClipsViewController

@synthesize fileTableView;
@synthesize fileSegmentedControl;
@synthesize shadowViewBottom, shadowViewTop;
@synthesize fileObject, fileObjects, selectedFileObjects;

#pragma mark - View lifecycle

- (ScoreClipsViewController *)initWithFileObject:(KOFileObject *)myDir
{
    self = [super init];
    self.fileObject = myDir;
    return self;
}

- (void)secondAnimate {
	KOFileTableViewCell *cell = (KOFileTableViewCell *)[fileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
	[cell iconButtonTap];
}


//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//    _mainTableView.backgroundColor = [UIColor redColor];
//    _mainTableView.opaque = NO;
//    _mainTableView.backgroundView = nil;
//    
//	// Do any additional setup after loading the view, typically from a nib.
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)todayPressed:(id)sender {
    //ALERT(@"AAAA", @"AAAAA");
    
    [AppDataManager AppDataManagerShared].delegate = self;
    [[AppDataManager AppDataManagerShared] getDataType:ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS forceUpdate:NO];
}

- (void)viewDidUnload {
    [self setPriceSelectorImg:nil];
    pickerView = nil;
    [_scoreDates removeAllObjects];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _scoreIndex = 0;
    _APIRequester = [APIRequester new];
    
    // init picker view
    CGRect r = self.priceSelectorImg.frame;
    
    if ([[UIDevice currentDevice] resolution] == UIDeviceResolution_iPhoneRetina4) {
        r = self.priceSelectorImg.frame;
        r.origin.y += 85;
        self.priceSelectorImg.frame = r;
    }

    
    //r.origin.y -=20; // delta of font
    pickerView = [[V8HorizontalPickerView alloc] initWithFrame:r];
    pickerView.backgroundColor   = [UIColor clearColor];
    pickerView.selectedTextColor = [UIColor darkGrayColor];
    pickerView.textColor   = [UIColor darkTextColor];
    pickerView.delegate    = self;
    pickerView.dataSource  = self;
    pickerView.elementFont = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:23];
    [self.view addSubview:pickerView];
    
    // TrongV - single file selected
    _isSingleFileSelected = TRUE;
    
	//self.fileObjects = [[KOData sharedInstance] listDirectory];
	self.selectedFileObjects = [NSMutableArray array];
	
	[self.view setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]]; /*#fff9f4*/
	
    CGRect rect = self.view.bounds;
    rect.origin.y += HEIGHT_TOOL_BAR;
    rect.size.height -= 2*HEIGHT_TOOL_BAR + 5;
	fileTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
	[fileTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[fileTableView setBackgroundColor:[UIColor clearColor]];
	[fileTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[fileTableView setDelegate:(id<UITableViewDelegate>)self];
	[fileTableView setDataSource:(id<UITableViewDataSource>)self];
	[fileTableView setShowsHorizontalScrollIndicator:NO];
	[self.view addSubview:fileTableView];
	
    //rect = self.view.bounds;
	rect.origin.y = 0;
    rect.size.height = 3;
    
    shadowViewBottom = [[UIView alloc] initWithFrame:rect];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shadowViewBottom.frame];
    [shadowViewBottom.layer setMasksToBounds:YES];
	[shadowViewBottom.layer setShadowColor:[UIColor blackColor].CGColor];
	[shadowViewBottom.layer setShadowOffset:CGSizeMake(0.0f, -2.0f)];
    [shadowViewBottom.layer setShadowOpacity:0.55f];
    [shadowViewBottom.layer setShadowRadius:5.0f];
    [shadowViewBottom.layer setShadowPath:shadowPath.CGPath];
	
    [fileTableView setTableFooterView:shadowViewBottom];
    
    rect = CGRectMake(0, -20, 1084, 20);
    shadowViewTop = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:shadowViewTop];
    
	rect.origin.y = 20;
    rect.size.height = 3;
    shadowPath = [UIBezierPath bezierPathWithRect:rect];
    [shadowViewTop.layer setMasksToBounds:YES];
	[shadowViewTop.layer setShadowColor:[UIColor blackColor].CGColor];
	[shadowViewTop.layer setShadowOffset:CGSizeMake(0.0f, -2.0f)];
	[shadowViewTop.layer setShadowOpacity:0.55f];
	[shadowViewTop.layer setShadowRadius:5.0f];
	[shadowViewTop.layer setShadowPath:shadowPath.CGPath];
    
    // down shadow from sortbar
    rect = CGRectMake(-20, 0, 1084, 20);
    UIView *shadowView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:shadowView];
	
    rect.origin.y = 0;
    rect.size.height = 3;
	
    shadowPath = [UIBezierPath bezierPathWithRect:rect];
    [shadowView.layer setMasksToBounds:NO];
	[shadowView.layer setShadowColor:[UIColor blackColor].CGColor];
	[shadowView.layer setShadowOffset:CGSizeMake(0.0f, -2.0f)];
	[shadowView.layer setShadowOpacity:0.55f];
	[shadowView.layer setShadowRadius:3.0f];
	[shadowView.layer setShadowPath:shadowPath.CGPath];
    
    // call API to get all date
    [AppDataManager AppDataManagerShared].delegate = self;
    [[AppDataManager AppDataManagerShared] getDataType:ENUM_API_REQUEST_TYPE_GET_SCORE_DATES forceUpdate:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    [self scrollViewDidScroll:fileTableView];
}

#pragma mark - UITableViewDatasource

- (void)scrollViewDidScroll:(UIScrollView *)tableView {
    CGRect frame = shadowViewTop.frame;
    frame.origin.y = tableView.frame.origin.y - tableView.contentOffset.y - shadowViewTop.frame.size.height;
    shadowViewTop.frame = frame;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fileObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	KOFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileTableViewCell"];
	if (!cell)
		cell = [[KOFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileTableViewCell"];
    
    // reset background for reused cells
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-short"]];
	[backgroundImageView setContentMode:UIViewContentModeTopRight];
	[cell setBackgroundView:backgroundImageView];
	
	KOFileObject *fileObject1 = [self.fileObjects objectAtIndex:indexPath.row];
	
	cell.fileObject = fileObject1;
	
	[cell.iconButton setSelected:[self.selectedFileObjects containsObject:cell.fileObject]];
    
    // show "tall" bg if selected
    if ([cell.iconButton isSelected]) {
		if ([self.selectedFileObjects count] == 1) {
            [self applyTallBgAndSegmentedControlToCell:cell];
        }
    }
	
	if ([fileObject1 isDirectory]) {
		[cell setIsFile:NO];
		
		[cell.countLabel setHidden:NO];
		
		[cell.changedLabel setHidden:YES];
		[cell.changedValueLabel setHidden:YES];
		[cell.sizeLabel setHidden:YES];
		[cell.sizeValueLabel setHidden:YES];
		
        [cell.countLabel setText:[fileObject1 scoreString]];
        if ([fileObject1 finalScoreString]) {
            [cell.countLabel setText:[fileObject1 finalScoreString]];
        }
		if ([fileObject1 scoreString] && [fileObject1 finalScoreString])
			[cell.countLabel setText:[NSString stringWithFormat:@"%@\n[%@]",[fileObject1 scoreString],[fileObject1 finalScoreString]]];
        
        if (![fileObject1 scoreString] && ![fileObject1 finalScoreString]) {
            [cell.countLabel setHidden:YES];
        }
            
	} else {
		[cell setIsFile:YES];
		
		[cell.countLabel setHidden:YES];
		
		[cell.changedLabel setHidden:NO];
		[cell.changedValueLabel setHidden:NO];
		[cell.sizeLabel setHidden:NO];
		[cell.sizeValueLabel setHidden:NO];
	}
	
	[cell.titleTextField setText:[fileObject1 base]];
	//[cell.titleTextField sizeToFit];
	
	[cell.createdValueLabel setText:[fileObject1 descString]];
	[cell.sizeValueLabel setText:[fileObject1 sizeString]];
	//[cell.changedValueLabel setText:[fileObject1 descString]];
	
	[cell setDelegate:(id<KOFileTableViewCellDelegate>)self];
	[cell setIndexPath:indexPath];
	
	[cell.accessoryView setAutoresizingMask:UIViewAutoresizingNone];
    
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.selectedFileObjects count] == 1)
		if ([self.selectedFileObjects containsObject:[self.fileObjects objectAtIndex:indexPath.row]])
			return 140;
	return 85;
}

- (void)tapOnFileObject:(KOFileObject *)fileObject {
	//
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	KOFileTableViewCell *cell = (KOFileTableViewCell *)[fileTableView cellForRowAtIndexPath:indexPath];
    
	[self tapOnFileObject:cell.fileObject];
}

#pragma mark - Actions

- (void)updateFooter {
	CGRect rect = fileTableView.tableFooterView.frame;
	rect.size.height = 20;
	fileTableView.tableFooterView.frame = rect;
}

- (void)iconButtonAction:(KOFileTableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.clipsToBounds = YES;
	
	if ([self.selectedFileObjects containsObject:cell.fileObject]) {
		[cell.iconButton setSelected:NO];
		[self.selectedFileObjects removeObject:cell.fileObject];
	} else {
		[cell.iconButton setSelected:YES];
		
        // Trongv - single file selected mode
        if (_isSingleFileSelected) {
            //[cell.iconButton setSelected:NO];
            for (KOFileTableViewCell* visibleCell in [fileTableView visibleCells]) {
                if (visibleCell != cell) {
                    [visibleCell.iconButton setSelected:NO];
                }
            }
            [self.selectedFileObjects removeAllObjects];
            self.fileObject = cell.fileObject;
        }
		[self.selectedFileObjects addObject:cell.fileObject];
        
	}
	
    [self performSelector:@selector(showOrHideFSC:) withObject:cell afterDelay:0.0];
}

- (void)showOrHideFSC:(KOFileTableViewCell *)cell
{
    
	[fileTableView beginUpdates];
    
	if ([cell.iconButton isSelected]) {
		if ([self.selectedFileObjects count] == 1) {
			UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-tall"]];
			[backgroundImageView setContentMode:UIViewContentModeTopRight];
			[cell setBackgroundView:backgroundImageView];
			
			
		} else {
            if ([cell.contentView.subviews containsObject:fileSegmentedControl]){
                [fileSegmentedControl removeFromSuperview];
                fileSegmentedControl = nil;
            }
        }
        [self performSelector:@selector(selektor2:) withObject:nil afterDelay:0.3];
	} else {
		[self performSelector:@selector(selektor:) withObject:cell afterDelay:0.3];
	}
	
	
	[self performSelector:@selector(updateAllCells)];
    
    
    [fileTableView endUpdates];
}

- (KOSegmentedControl *)createFileSegmentedControlForCell:(UITableViewCell *)cell
{
    NSMutableArray *menuObjs = [NSMutableArray array];
    
    for (KOMenuObject *menuObject in [[KOData sharedInstance] getMenuObjectsForFile]) {
        [menuObjs addObject:[UIImage imageNamed:menuObject.iconOn]];
    }
    
    KOSegmentedControl *f = [[KOSegmentedControl alloc] initWithItems:menuObjs];
    CGFloat percentage = 0.80;
    [f setFrame:CGRectMake(cell.frame.size.width * (1-percentage) / 2, 84, cell.frame.size.width * percentage, 56)];
    
    [f setMomentary:YES];
    [f setMenuObjects:[[KOData sharedInstance] getMenuObjectsForFile]];
    
    [f setSegmentedControlStyle:UISegmentedControlStyleBordered];
	[f addTarget:self action:@selector(fileSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [f setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [f setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [f setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [f setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [f setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [f setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    return f;
}

- (void)applyTallBgAndSegmentedControlToCell:(UITableViewCell *)cell {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-tall"]];
    [backgroundImageView setContentMode:UIViewContentModeTopRight];
    [cell setBackgroundView:backgroundImageView];
    
    if (true) {
        fileSegmentedControl = [self createFileSegmentedControlForCell:cell];
        
        for (UIView *v in cell.contentView.subviews) {
            if ([v isKindOfClass:[KOSegmentedControl class]]) [v removeFromSuperview];
        }
        
        [cell.contentView addSubview:fileSegmentedControl];
    }
}

- (void)updateAllCells {
	for (int section = 0; section < [fileTableView numberOfSections]; section++) {
		for (int row = 0; row < [fileTableView numberOfRowsInSection:section]; row++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
			KOFileTableViewCell *cell = (KOFileTableViewCell *)[fileTableView cellForRowAtIndexPath:indexPath];
			
			if ([self.selectedFileObjects containsObject:cell.fileObject]) {
				if ([self.selectedFileObjects count] == 1) {
                    [self applyTallBgAndSegmentedControlToCell:cell];
				} else
					[self performSelector:@selector(selektor:) withObject:cell afterDelay:0.3];
			} else {
				[self performSelector:@selector(selektor:) withObject:cell afterDelay:0.3];
			}
		}
	}
}

- (void)selektor:(KOFileTableViewCell *)cell {
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-short"]];
	[backgroundImageView setContentMode:UIViewContentModeTopRight];
	[cell setBackgroundView:backgroundImageView];
	
	if ([cell.contentView.subviews containsObject:fileSegmentedControl]){
		[fileSegmentedControl removeFromSuperview];
		fileSegmentedControl = nil;
	}
    
    shadowViewBottom.hidden = NO;
    [self scrollViewDidScroll:fileTableView];
}

- (void)selektor2:(id)sender
{
    shadowViewBottom.hidden = NO;
    [self scrollViewDidScroll:fileTableView];
}

- (void)deselectSegmentAtIndex:(NSNumber *)index {
	[fileSegmentedControl setImage:[UIImage imageNamed:[(KOMenuObject *)[[fileSegmentedControl menuObjects] objectAtIndex:[index intValue]] iconOn]] forSegmentAtIndex:[index intValue]];
}

- (void)fileSegmentedControlValueChanged:(id)sender {
	NSInteger i = [(KOSegmentedControl *)sender selectedSegmentIndex];
	
	[fileSegmentedControl setImage:[UIImage imageNamed:[(KOMenuObject *)[[fileSegmentedControl menuObjects] objectAtIndex:i] iconOff]] forSegmentAtIndex:i];
    
	[self performSelector:@selector(deselectSegmentAtIndex:) withObject:[NSNumber numberWithInt:i] afterDelay:0.30f];
    
    // first menu object -> view clips
    if (i == 0 && self.fileObject.ancestorFileObjects.count > 0) {
        IntroVideoViewController *temVC = [[IntroVideoViewController alloc] initWithNibName:@"IntroVideoViewController" bundle:nil];
        temVC.URLClips = self.fileObject.ancestorFileObjects;
        [self presentViewController:temVC animated:YES completion:nil];
    } 

    if (i == 1 && self.fileObject.sourceUrl) {
        WebViewController *temVC = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
        temVC.urlString = self.fileObject.sourceUrl;
        [self presentViewController:temVC animated:YES completion:nil];
    }

}

#pragma mark - KOFileTableViewDelegate
- (void)fileTableViewCell:(KOFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath {
	[self iconButtonAction:cell indexPath:indexPath];
}

//#pragma mark UITableViewDelegate Methods
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return  [_scoreClips count];
//}
//
//// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
//// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *kCustomCellID = @"MyCellID";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID];
//        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//    }
//    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    
//    cell.textLabel.numberOfLines = 1;
//    
//    NSMutableDictionary *clipInfo = [_scoreClips objectAtIndex:indexPath.row];
//    
//    clipInfo = [SupportFunction normalizeDictionary:clipInfo];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[clipInfo objectForKey:@"team1"],[clipInfo objectForKey:@"team2"]];
//    cell.textLabel.textColor = [UIColor blackColor];
//        
//    //cell.textLabel.textAlignment = UITextAlignmentLeft;
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
//    cell.backgroundColor = [UIColor colorWithRed:0.3 green:0.9 blue:0.1 alpha:0.5];
//    
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"did select = %d", indexPath.row);
//    //[[AppViewController Shared] changeToVideoClip:nil];
//    IntroVideoViewController *temVC = [[IntroVideoViewController alloc] initWithNibName:@"IntroVideoViewController" bundle:nil];
//    [self presentViewController:temVC animated:YES completion:nil];
//
//}


#pragma mark - APIRequesterProtocol

- (void)requestData:(ENUM_API_REQUEST_TYPE) type {
    NSString *strURL = @"";
    switch (type) {
        case ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS:
        {
            [[AppViewController Shared] isRequesting:YES andRequestType:type andFrame:FRAME(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, [SupportFunction getDeviceWidth], [SupportFunction getDeviceHeight] - HEIGHT_HOME_VIEW_CONTROLLER_TITLE)];
            
            NSString *date = [_scoreDates objectAtIndex:_scoreIndex];
            strURL = [NSString stringWithFormat:@"%@/%@", STRING_REQUEST_URL_GET_SCORE_CLIPS_ON_DAY,date];
            [_APIRequester requestWithType:type andRootURL:strURL andPostMethodKind:NO andParams:nil andDelegate:self];
            break;
        }
        case ENUM_API_REQUEST_TYPE_GET_SCORE_DATES:
        {
            [[AppViewController Shared] isRequesting:YES andRequestType:type andFrame:FRAME(0, HEIGHT_HOME_VIEW_CONTROLLER_TITLE, [SupportFunction getDeviceWidth], [SupportFunction getDeviceHeight] - HEIGHT_HOME_VIEW_CONTROLLER_TITLE)];
            
            strURL = [NSString stringWithFormat:@"%@", STRING_REQUEST_URL_GET_SCORE_DATES];
            [_APIRequester requestWithType:type andRootURL:strURL andPostMethodKind:NO andParams:nil andDelegate:self];
            break;
        }
        default:
            break;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type {
    //VKLog(@"requestFinished: %@", [request responseString]);
    
    [[AppViewController Shared] isRequesting:NO andRequestType:type andFrame:CGRectZero];
    
    NSError *error;
    SBJSON *sbJSON = [SBJSON new];
    
    if (![sbJSON objectWithString:[request responseString] error:&error] || request.responseStatusCode != 200 || !request) {
        //ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_SERVER_ERROR);
        return;
    }
    
    //NSMutableArray *jsonData = [sbJSON objectWithString:[request responseString] error:&error];
    
    if (type == ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS) {
        NSMutableArray *jsonData = [sbJSON objectWithString:[request responseString] error:&error];
        self.fileObjects = [[KOData sharedInstance] listClipInfo:jsonData];
        [fileTableView reloadData];
    }
    if (type == ENUM_API_REQUEST_TYPE_GET_SCORE_DATES) {
        NSMutableDictionary *jsonData = [sbJSON objectWithString:[request responseString] error:&error];
        _scoreDates = [jsonData objectForKey:@"dates"];
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
        _scoreDates = [NSMutableArray arrayWithArray:[_scoreDates sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]]; //
        
        
        [pickerView reloadData];
        [pickerView scrollToElement:0 animated:YES];

    }
}

- (void)requestFailed:(ASIHTTPRequest *)request andType:(ENUM_API_REQUEST_TYPE)type {
    //VKLog(@" requestFailed %@ ", request.responseString);
    
    [[AppViewController Shared] isRequesting:NO andRequestType:ENUM_API_REQUEST_TYPE_INVALID andFrame:CGRectZero];
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        //ALERT(STRING_ALERT_CONNECTION_ERROR_TITLE, STRING_ALERT_CONNECTION_ERROR);
    }
    
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [_scoreDates count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@", [_scoreDates objectAtIndex:index]];
}

-(UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index
{
    return [_scoreDates objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    //    UIFont * numberFont = [UIFont fontWithName:FONT_BEBAS_NEUE size:32];
    //	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    //    NSString *text = [NSString stringWithFormat:@"$%@", [_priceList objectAtIndex:index]];
    //    if (_viewType == ENUM_PURCHASE_VIEW_TYPE_POINT) {
    //        text = [NSString stringWithFormat:@"00%@", [_priceList objectAtIndex:index]];
    //    }
    //	CGSize textSize = [text sizeWithFont:numberFont
    //					   constrainedToSize:constrainedSize
    //						   lineBreakMode:UILineBreakModeWordWrap];
	return 180.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    
    NSLog(@"Selected index %d", index);
    _scoreIndex = index;
//    [AppDataManager AppDataManagerShared].delegate = self;
//    [[AppDataManager AppDataManagerShared] getDataType:ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS forceUpdate:NO];
    [self requestData:ENUM_API_REQUEST_TYPE_GET_SCORE_CLIPS];
}

@end