//
//  RootViewController.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "RootViewController.h"
#import "UIMacro.h"

@interface RootViewController () {
    
    UIImageView *_imageViewBG;
}

@property (nonatomic, assign) BOOL firstAppear;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.firstAppear = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    //下面这段代码可以注释掉看一下效果 
    if (nil == _imageViewBG) {
        _imageViewBG = [[UIImageView alloc] initWithFrame:self.view.bounds];
        if (IsIphone5()) {
            SetImageForImageView(_imageViewBG, @"Default-568h@2x");
        }
        else {
            SetImageForImageView(_imageViewBG, @"Default@2x");
        }
    }
    [self.view addSubview:_imageViewBG];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_imageViewBG release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    _imageViewBG.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(rootVC:didFirstAppear:)]) {
        [self.delegate rootVC:self didFirstAppear:self.firstAppear];
    }
    self.firstAppear = NO;
}

@end
