//
//  UIProgressBar.h
//  
//
//  Created by xiangwei.ma
//  
//

#import <UIKit/UIKit.h>


@interface UICustomProgressBar : UIView 
{
	float minValue, maxValue;
	float currentValue;
	UIColor *lineColor, *progressRemainingColor, *progressColor;
}

@property (nonatomic, assign) float minValue, maxValue, currentValue;
@property (nonatomic, retain) UIColor *lineColor, *progressRemainingColor, *progressColor;

-(void)setNewRect:(CGRect)newFrame;

@end
