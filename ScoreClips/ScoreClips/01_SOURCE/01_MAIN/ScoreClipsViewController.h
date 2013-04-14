//
//  ScoreClipsViewController.h
//  ScoreClips
//
//  Created by Trong Vu on 4/11/13.
//  Copyright (c) 2013 trongvu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
#import "KOFileTableViewCell.h"
#import "KOMenuObject.h"
#import "V8HorizontalPickerView.h"

@class KOSegmentedControl;

@interface ScoreClipsViewController : UIViewController <AppDataManagerDelegate,UITableViewDelegate, UITableViewDataSource, KOFileTableViewCellDelegate,V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource,APIRequesterProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *priceSelectorImg;

- (IBAction)todayPressed:(id)sender;

@property (nonatomic, strong) KOFileObject *fileObject;
@property (nonatomic, strong) NSMutableArray *fileObjects;
@property (nonatomic, strong) NSMutableArray *selectedFileObjects;
@property (nonatomic, strong) UITableView *fileTableView;
@property (nonatomic, strong) UIImageView *sortBarView;
@property (nonatomic, strong) KOSegmentedControl *fileSegmentedControl;
@property (nonatomic, strong) NSArray *menuObjects;
@property (strong) UIView *shadowViewBottom;
@property (strong) UIView *shadowViewTop;
@property (strong) UIImageView *tutorialImageView;

// Trongv - support case 1 selected
@property (nonatomic,assign) BOOL  isSingleFileSelected;

- (ScoreClipsViewController *)initWithFileObject:(KOFileObject *)myDir;
- (void)updateAllCells;
- (void)tapOnFileObject:(KOFileObject *)fileObject;

@end

