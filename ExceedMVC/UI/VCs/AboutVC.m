//
//  AboutVC.m
//  ExceedMVC
//
//  Created by yangjh on 13-6-7.
//  Copyright (c) 2013年 yjh4866. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()

@end

@implementation AboutVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"关于";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickClose:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [leftItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ClickEvent

- (void)clickClose:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(aboutVCClose:)]) {
        [self.delegate aboutVCClose:self];
    }
}

@end
