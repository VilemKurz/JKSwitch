//
//  JKSwitch.m
//  JKSwitch
//
//  Created by James Kelly on 8/30/12.
//  Copyright (c) 2012 James Kelly. All rights reserved.
//

#import "JKSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define HORZ_PADDING 0    //padding between the button and the edge of the switch.
#define TAP_SENSITIVITY 25.0 //margin of error to detect if the switch was tapped or swiped.

@interface JKSwitch ()

@property (strong, nonatomic) UIImage *buttonImage;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIImage *borderImage;
@property (strong, nonatomic) UIImage *maskImage;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *buttonImageView;
@property (strong, nonatomic) UIImageView *borderImageView;

@end

@implementation JKSwitch
{
    CGPoint firstTouchPoint;
    float touchDistanceFromButton;
    id returnTarget;
    SEL returnAction;
}

#pragma mark - dynamic frames

- (CGFloat)backgroundWidth {
    return self.backgroundImage.size.width;
}

- (CGFloat)height {
    return self.borderImage.size.height;
}

- (CGFloat)width {
    return self.borderImage.size.width;
}

- (CGFloat)buttonHorizontalDiameter {
    return self.buttonImage.size.width;
}

- (id)initWithOrigin:(CGPoint)origin
     backgroundImage:(UIImage *)bgImage
           maskImage:(UIImage *)maskImage
         buttonImage:(UIImage *)buttonImage
         borderImage:(UIImage *)borderImage {
    
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, borderImage.size.width, borderImage.size.height)];
    
    if (self) {
        
        _backgroundImage = bgImage;
        _maskImage = maskImage;
        _buttonImage = buttonImage;
        _borderImage = borderImage;
        
        [self setupLayout];
    }
    
    return self;
}

- (void)setupLayout {
    
    self.layer.masksToBounds = YES;
    
    //masked view
    //  ->background image
    //  ->mask
    //button image
    //border image
    //
    //The mask is placed over the view, then the background image is slid left and right inside the view.
    //If the mask is applied to the background image directly then the mask will move around with it.
    
    UIView *maskedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width], [self height])];
    [self addSubview:maskedView];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:[self leftBackgroundFrame]];
    [self.backgroundImageView setImage:self.backgroundImage];
    [maskedView addSubview:self.backgroundImageView];
    
    if (self.maskImage) {
        
        CALayer *mask = [CALayer layer];
        mask.contents = (id)[self.maskImage CGImage];
        mask.frame = CGRectMake(0, 0, self.maskImage.size.width, self.maskImage.size.height);
        maskedView.layer.mask = mask;
        maskedView.layer.masksToBounds = YES;
    }
    
    self.borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self width], [self height])];
    [self.borderImageView setImage:self.borderImage];
    [self addSubview:self.borderImageView];
    
    self.buttonImageView = [[UIImageView alloc] initWithFrame:[self leftButtonFrame]];
    [self.buttonImageView setImage:self.buttonImage];
    [self addSubview:self.buttonImageView];
}

- (CGRect)leftButtonFrame {
    CGRect result = CGRectMake(HORZ_PADDING, 0, [self buttonHorizontalDiameter], self.buttonImage.size.height);
    return result;
}

- (CGRect)leftBackgroundFrame {
    CGRect result = CGRectMake( -[self width] + ([self buttonHorizontalDiameter]) + HORZ_PADDING, 0, [self backgroundWidth], [self height]);
    return result;
}

- (CGRect)rightButtonFrame {
    CGRect result = CGRectMake([self width] - [self buttonHorizontalDiameter] - HORZ_PADDING, 0, [self buttonHorizontalDiameter], self.buttonImage.size.height);
    return result;
}

- (CGRect)rightBackgroundFrame {
    CGRect result = CGRectMake(0, 0, [self backgroundWidth], [self height]);
    return result;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    
    self.on = on;
    
    CGRect newBackFrame;
    CGRect newButtonFrame;
    
    if (on) {
        newBackFrame = [self rightBackgroundFrame];
        newButtonFrame = [self rightButtonFrame];
    }
    else {
        newBackFrame = [self leftBackgroundFrame];
        newButtonFrame = [self leftButtonFrame];
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.23];
        [self.backgroundImageView setFrame:newBackFrame];
        [self.buttonImageView setFrame:newButtonFrame];
        [UIView commitAnimations];
    }   
    else {
        [self.backgroundImageView setFrame:newBackFrame];
        [self.buttonImageView setFrame:newButtonFrame];
    }
    [self returnStatus];
}

- (void)toggleAnimated:(BOOL)animated {
    
    if (self.on) {
        [self setOn:NO animated:animated];
    }
    else {
        [self setOn:YES animated:animated];
    }
}

-(void)returnStatus{
    //The following line may cause a warning - "performSelector may cause a leak because its selector is unknown".
    //This is because ARC's behaviour is tied in with objective-c naming conventions of methods (convenience constructors that return autoreleased objects
    //vs. init methods that return retained objects). ARC doesn't know what _action is, so it doesn't know how to deal with it.  This is a known issue.
    //              http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [returnTarget performSelector:returnAction withObject:self];
    #pragma clang diagnostic pop
}

#pragma mark - Touch event methods.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    firstTouchPoint = [touch locationInView:self];
    touchDistanceFromButton = firstTouchPoint.x - self.buttonImageView.frame.origin.x;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject]; 
    CGPoint lastTouchPoint = [touch locationInView:self];   
    
    if (firstTouchPoint.x < lastTouchPoint.x) {
        //Move the button right
        [self.buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, [self buttonHorizontalDiameter], self.buttonImage.size.height)];
    } 
    else{
        //Move the button left
        [self.buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, [self buttonHorizontalDiameter], self.buttonImage.size.height)];
    }
    
    //Swipe fast enough and the button will be drawn outside the bounds.
    //If so, relocate it to the left/right of the switch.
    if (self.buttonImageView.frame.origin.x > ([self width] - [self buttonHorizontalDiameter] - HORZ_PADDING)) {
        [self.buttonImageView setFrame:[self rightButtonFrame]];
    }
    else if(self.buttonImageView.frame.origin.x < HORZ_PADDING){
        [self.buttonImageView setFrame:[self leftButtonFrame]];
    }
    
    [self.backgroundImageView setFrame:CGRectMake(self.buttonImageView.frame.origin.x - [self width] + [self buttonHorizontalDiameter], 0, [self backgroundWidth], [self height])];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint endTouchPoint = [touch locationInView:self];
    if(firstTouchPoint.x > (endTouchPoint.x - TAP_SENSITIVITY) &&
       firstTouchPoint.x < (endTouchPoint.x + TAP_SENSITIVITY) &&
       firstTouchPoint.y > (endTouchPoint.y - TAP_SENSITIVITY) &&
       firstTouchPoint.y < (endTouchPoint.y + TAP_SENSITIVITY)){
        //TAPPED
        [self toggleAnimated:YES];
    }
    else {
        //SWIPED 
        CGRect newButtonFrame;
        float distanceToEnd;
        BOOL needsMove = NO;
        
        //If the button is languishing somewhere in the middle of the switch
        //move it to either on or off.
        
        //First, edge cases
        if (self.buttonImageView.frame.origin.x == HORZ_PADDING) {
            distanceToEnd = 0;
            self.on = NO;
        }
        else if(self.buttonImageView.frame.origin.x == ([self width] - [self buttonHorizontalDiameter] - HORZ_PADDING)){
            distanceToEnd = 0;
            self.on = YES;
        }
        //Then, right or left
        if(self.buttonImageView.frame.origin.x < (([self width] / 2) - ([self buttonHorizontalDiameter] / 2))){
            //move left
            newButtonFrame = [self leftButtonFrame];
            distanceToEnd = self.buttonImageView.frame.origin.x;
            self.on = NO;
            needsMove = YES;
        }
        else if(self.buttonImageView.frame.origin.x < ([self width] - [self buttonHorizontalDiameter] - HORZ_PADDING)){
            //move right
            newButtonFrame = [self rightButtonFrame];
            distanceToEnd = [self width] - self.buttonImageView.frame.origin.x - [self buttonHorizontalDiameter];
            self.on = YES;
            needsMove = YES;
        }
        
        if (needsMove){
            //animate more quickly if the button is towards the end of the switch.
            float animTime = distanceToEnd / 140;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelay:0];
            [UIView setAnimationDuration:animTime];
            [self.buttonImageView setFrame:newButtonFrame];
            [self.backgroundImageView setFrame:CGRectMake(self.buttonImageView.frame.origin.x - [self width] + [self buttonHorizontalDiameter], 0, [self backgroundWidth], [self height])];
            [UIView commitAnimations];
        }
        [self returnStatus];
    }
}

#pragma mark - Event handling.

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events {
    if (events & UIControlEventValueChanged) {
        returnTarget = target;
        returnAction = action;
    }
}

@end
