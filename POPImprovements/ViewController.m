//
//  ViewController.m
//  POPImprovements
//
//  Created by Adolfo Rodriguez on 2014-08-15.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import "ViewController.h"

#import "EZPOP.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self.view.layer setAnchorPoint:CGPointMake(0.5,0.5)];
    
    
    CATransform3D subLayerTransform = CATransform3DIdentity;
    
    /* set perspective */
    subLayerTransform.m34 = -0.002;
    self.view.layer.sublayerTransform = subLayerTransform;
    
    EZPOPTransformView *redContainer = [[EZPOPTransformView alloc] init];
    [redContainer.layer setAnchorPoint:CGPointMake(0.25,0.5)];
    
    [redContainer setFrame:CGRectMake(50,40,120,100)];
    [redContainer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    
    
//    UIView *redView = [[UIView alloc] init];
//    [redView.layer setAnchorPoint:CGPointMake(0,0.5f)];
//    
//    [redView setFrame:CGRectMake(0,0,20,100)];
//    [redView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
//    [redView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
//    [redView setClipsToBounds:NO];
    
    
    
    
    UIView *blueView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pigeon.jpg"]];
    //[blueView.layer setAnchorPoint:CGPointMake(0,0.5f)];
    
    [blueView setFrame:redContainer.bounds];
    [blueView setBackgroundColor:[UIColor blueColor]];
    [blueView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [blueView setClipsToBounds:YES];
    
    
    UIView *redView = [[UIView alloc] initWithFrame:blueView.frame];
    [redView setBackgroundColor:[UIColor grayColor]];
    [redView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [redView setClipsToBounds:YES];
    
    //NSLog(@"position:%f,%f",redView.layer.position.x,redView.layer.position.y);
    
    //    [redContainer addSubview:redView];
    [redContainer addSubview:blueView];
    [redContainer addSubview:redView];
    [self.view addSubview:redContainer];
    
//    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
//    animation.fromValue = @0;
//    animation.toValue = @1.8;
//    animation.duration = 1;
//    [blueView.layer pop_addAnimation:animation forKey:@"key"];
    
    //[redView.layer setOpacity:0.0f];
    //[blueView.layer setOpacity:0.0f];
    
    double duration = 0.5;
    CGFloat rotation = M_PI_2-0.01;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [EZPOP objects:@[redView.layer,redView.layer,blueView.layer,blueView.layer] addAnimations:
//         @[
//           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(rotation) to:@0 delay:0 duration:duration timing:nil completion:nil],
//           [EZPOP basicWithProperty:kPOPLayerOpacity from:@0 to:@1 delay:0 duration:duration  timing:nil completion:nil],
//           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(rotation) to:@0 delay:duration  duration:duration  timing:nil completion:nil],
//           [EZPOP basicWithProperty:kPOPLayerOpacity from:@0 to:@1 delay:duration  duration:duration  timing:nil completion:nil]
//           ] completion:nil forKey:@"spring"];
//    });
    
    //[redView.layer setOpacity:0.0f];
    
//    CALayer *layer = blueView.layer.sublayers.firstObject;
    
    double extraDelay = 0.001;
    
    [redView setHidden:YES];
    [redView.layer setDoubleSided:YES];
    [blueView.layer setDoubleSided:YES];
    
    [redView.layer setTransform:CATransform3DMakeRotation(M_PI,0,1,0)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [EZPOP objects:@[redContainer.layer,redContainer.layer,redContainer.layer] addAnimations:
         @[
           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(0) to:@(rotation) delay:0 duration:duration timing:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] completion:^(POPAnimation *anim, BOOL completed) {
            
            [redContainer.layer setAnchorPoint:CGPointMake(1-redContainer.layer.anchorPoint.x,0.5)];
            [redContainer.layer setTransform:CATransform3DMakeRotation(-rotation,0,1,0)];
            [blueView.layer setTransform:CATransform3DMakeRotation(M_PI,0,1,0)];
            [redView.layer setTransform:CATransform3DIdentity];
        }],
           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(-rotation) to:@(rotation) delay:duration+extraDelay duration:2*duration timing:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] completion:^(POPAnimation *anim, BOOL completed) {
            
            [redContainer.layer setAnchorPoint:CGPointMake(1-redContainer.layer.anchorPoint.x,0.5)];
            [redContainer.layer setTransform:CATransform3DMakeRotation(-rotation,0,1,0)];
            [blueView.layer setTransform:CATransform3DIdentity];
            [redView.layer setTransform:CATransform3DMakeRotation(M_PI,0,1,0)];
            
        }],
           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(-rotation) to:@(0) delay:3*duration+2*extraDelay duration:duration timing:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] completion:nil]
           
           ] completion:nil forKey:@"spring"];
    });
    
    //[self.view.layer];
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
