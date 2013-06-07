//
//  MoreVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-6.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "MoreVC.h"

@interface MoreVC ()

@end

@implementation MoreVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100.0f, 200.0f, 120.0f, 50.0f);
    [button setTitle:@"关于" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickAbout:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ClickEvent

- (void)clickAbout:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(moreVCShowAbout:)]) {
        [self.delegate moreVCShowAbout:self];
    }
}

@end
