//
//  MainVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@property (nonatomic, assign) BOOL firstLoadVCs;

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.firstLoadVCs = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.firstLoadVCs) {
        if ([self.dataSource respondsToSelector:@selector(mainVC:loadViewControllers:)]) {
            NSMutableArray *marrVC = [[NSMutableArray alloc] init];
            [self.dataSource mainVC:self loadViewControllers:marrVC];
            self.viewControllers = marrVC;
            [marrVC release];
        }
        
        self.firstLoadVCs = NO;
    }
}

@end
