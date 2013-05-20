//
//  JKSwitch.m
//  JKSwitch
//
//  Created by James Kelly on 8/30/12.
//  Copyright (c) 2012 James Kelly. All rights reserved.
//

#import "JKSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define HORIZONTAL_PADDING 2    //padding between the button and the edge of the switch.
#define TAP_SENSITIVITY 2 //margin of error to detect if the switch was tapped or swiped.
#define ANIMATION_DURATION 0.23

@interface JKSwitch ()

@property (strong, nonatomic) UIImage *buttonImage;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIImage *borderImage;
@property (strong, nonatomic) UIImage *maskImage;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *buttonImageView;
@property (strong, nonatomic) UIImageView *borderImageView;

@property (nonatomic) CGPoint firstTouchPoint;
@property (nonatomic) CGFloat touchDistanceFromButton;

@end

@implementation JKSwitch

- (void)setOn:(BOOL)on {
    
    [self setOn:on animated:NO sendActions:NO];
}

- (void)toggleAnimated:(BOOL)animated {
    
    BOOL newStatus = !self.on;
    [self setOn:newStatus animated:animated];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    
    [self setOn:on animated:animated sendActions:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated sendActions:(BOOL)sendActions {
    
    CGRect newButtonFrame;
    if (on) {
        newButtonFrame = [self rightButtonFrame];
    } else {
        newButtonFrame = [self leftButtonFrame];
    }
    CGRect newBackFrame = [self bgRectForButtonOriginX:CGRectGetMinX(newButtonFrame)];
    
    if (animated) {
        
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             
                             self.backgroundImageView.frame = newBackFrame;
                             self.buttonImageView.frame = newButtonFrame;
                         }
                         completion:^(BOOL finished){
                             _on = on;
                             if (sendActions) [self sendActionsForControlEvents:UIControlEventValueChanged];
                         }];
    } else {
        
        [self.backgroundImageView setFrame:newBackFrame];
        [self.buttonImageView setFrame:newButtonFrame];
        _on = on;
        if (sendActions) [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
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

#pragma mark - dynamic frames

- (CGFloat)height {
    return self.borderImage.size.height;
}

- (CGFloat)width {
    return self.borderImage.size.width;
}

- (CGRect)leftButtonFrame {
    CGRect result = CGRectMake(HORIZONTAL_PADDING, 0, self.buttonImage.size.width, self.buttonImage.size.height);
    return result;
}

- (CGRect)leftBackgroundFrame {
    CGRect result = CGRectMake(self.buttonImage.size.width + HORIZONTAL_PADDING - [self width],
                               0,
                               self.backgroundImage.size.width,
                               [self height]);
    return result;
}

- (CGRect)rightButtonFrame {
    CGRect result = CGRectMake([self width] - self.buttonImage.size.width - HORIZONTAL_PADDING, 0, self.buttonImage.size.width, self.buttonImage.size.height);
    return result;
}

- (CGRect)rightBackgroundFrame {
    CGRect result = CGRectMake(0, 0, self.backgroundImage.size.width, [self height]);
    return result;
}

- (CGRect)bgRectForButtonOriginX:(CGFloat)buttonOriginX {
    
    CGRect result = CGRectMake(buttonOriginX - [self width] + self.buttonImage.size.width + HORIZONTAL_PADDING,
                               0,
                               self.backgroundImage.size.width,
                               [self height]);
    return result;
}

- (CGFloat)maxButtonXMovement {
    
    CGFloat result = [self width] - self.buttonImage.size.height - HORIZONTAL_PADDING;
    return result;
}

#pragma mark - Touch event methods.

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    self.firstTouchPoint = [touch locationInView:self];
    self.touchDistanceFromButton = self.firstTouchPoint.x - self.buttonImageView.frame.origin.x;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject]; 
    CGPoint lastTouchPoint = [touch locationInView:self];   
    
    if (self.firstTouchPoint.x < lastTouchPoint.x) {
        //Move the button right
        [self.buttonImageView setFrame:CGRectMake(lastTouchPoint.x - self.touchDistanceFromButton, 0, self.buttonImage.size.width, self.buttonImage.size.height)];
    } 
    else{
        //Move the button left
        [self.buttonImageView setFrame:CGRectMake(lastTouchPoint.x - self.touchDistanceFromButton, 0, self.buttonImage.size.width, self.buttonImage.size.height)];
    }
    
    //Swipe fast enough and the button will be drawn outside the bounds.
    //If so, relocate it to the left/right of the switch.
    if (self.buttonImageView.frame.origin.x > CGRectGetMinX([self rightButtonFrame])) {
        [self.buttonImageView setFrame:[self rightButtonFrame]];
    }
    else if(self.buttonImageView.frame.origin.x < CGRectGetMinX([self leftButtonFrame])) {
        [self.buttonImageView setFrame:[self leftButtonFrame]];
    }
    
    [self.backgroundImageView setFrame:[self bgRectForButtonOriginX:self.buttonImageView.frame.origin.x]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint endTouchPoint = [touch locationInView:self];
    if(self.firstTouchPoint.x > (endTouchPoint.x - TAP_SENSITIVITY) &&
       self.firstTouchPoint.x < (endTouchPoint.x + TAP_SENSITIVITY) &&
       self.firstTouchPoint.y > (endTouchPoint.y - TAP_SENSITIVITY) &&
       self.firstTouchPoint.y < (endTouchPoint.y + TAP_SENSITIVITY)){
        //TAPPED
        [self toggleAnimated:YES];
    
    } else {
        //SWIPED 
        CGRect newButtonFrame;
        BOOL needsMove = NO;
        CGFloat currentButtonMovement;
        
        //If the button is languishing somewhere in the middle of the switch
        //move it to either on or off.
        
        //First, edge cases
        if (self.buttonImageView.frame.origin.x == CGRectGetMinX([self leftButtonFrame])) {
            
            _on = NO;
        
        } else if (self.buttonImageView.frame.origin.x == CGRectGetMinX([self rightButtonFrame])) {
            
            _on = YES;
        
        //Then, right or left
        } else if (self.buttonImageView.center.x < self.borderImageView.center.x) {
            
            //move left
            newButtonFrame = [self leftButtonFrame];
            currentButtonMovement = CGRectGetMinX(self.buttonImageView.frame) - CGRectGetMinX(newButtonFrame);
            _on = NO;
            needsMove = YES;
        
        } else if (self.buttonImageView.center.x > self.borderImageView.center.x) {
            //move right
            newButtonFrame = [self rightButtonFrame];
            currentButtonMovement = CGRectGetMinX([self rightButtonFrame]) - CGRectGetMinX(self.buttonImageView.frame);
            _on = YES;
            needsMove = YES;
        }
        
        if (needsMove){
            
            //duration shortened if we do not move from end to end
            NSTimeInterval durationFraction = (currentButtonMovement * ANIMATION_DURATION) / [self maxButtonXMovement];
            
            [UIView animateWithDuration:durationFraction
                             animations:^{
                                 
                                 [self.buttonImageView setFrame:newButtonFrame];
                                 [self.backgroundImageView setFrame:[self bgRectForButtonOriginX:self.buttonImageView.frame.origin.x]];
                             }
                             completion:^(BOOL finished){
                                 
                                 [self sendActionsForControlEvents:UIControlEventValueChanged];
                             }];
        } else {
            
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }        
    }
}

@end
