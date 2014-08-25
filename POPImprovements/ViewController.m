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
    
    
    CATransform3D subLayerTransform = CATransform3DIdentity;
    
    /* set perspective */
    subLayerTransform.m34 = -0.002;
    self.view.layer.sublayerTransform = subLayerTransform;
    
    EZPOPTransformView *redContainer = [[EZPOPTransformView alloc] init];
    [redContainer.layer setAnchorPoint:CGPointMake(0,0.5)];
    
    [redContainer setFrame:CGRectMake(100,40,200,100)];
    [redContainer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    
    
    UIView *redView = [[UIView alloc] init];
    //[redView.layer setAnchorPoint:CGPointMake(0,0.5f)];
    
    [redView setFrame:CGRectMake(0,0,20,100)];
    [redView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]];
    [redView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [redView setClipsToBounds:NO];
    
    UIView *blueView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pigeon.jpg"]];
    [blueView.layer setAnchorPoint:CGPointMake(0,0.5f)];
    
    [blueView setFrame:CGRectMake(20,0,100,100)];
    [blueView setBackgroundColor:[UIColor blueColor]];
    [blueView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [blueView setClipsToBounds:NO];
    
    //NSLog(@"position:%f,%f",redView.layer.position.x,redView.layer.position.y);
    
    [redContainer addSubview:redView];
    [redContainer addSubview:blueView];
    [self.view addSubview:redContainer];
    
//    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
//    animation.fromValue = @0;
//    animation.toValue = @1.8;
//    animation.duration = 1;
//    [blueView.layer pop_addAnimation:animation forKey:@"key"];
    
    [redView.layer setOpacity:0.0f];
    [blueView.layer setOpacity:0.0f];
    
    double duration = 0.3;
    CGFloat rotation = M_PI_2-0.01;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [EZPOP objects:@[redContainer.layer,redView.layer,blueView.layer,blueView.layer] addAnimations:
         @[
           /*[EZPOP springWithPropery:kPOPLayerRotationY from:@(0) to:@(M_PI_4) delay:0 params:EZPOPSpring(nil,@10,nil,nil,nil,@25) completion:nil],*/
           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(rotation) to:@0 delay:0 duration:duration timing:nil completion:nil],
           [EZPOP basicWithProperty:kPOPLayerOpacity from:@0 to:@1 delay:0 duration:duration  timing:nil completion:nil],
           [EZPOP basicWithProperty:kPOPLayerRotationY from:@(rotation) to:@0 delay:duration  duration:duration  timing:nil completion:nil],
           [EZPOP basicWithProperty:kPOPLayerOpacity from:@0 to:@1 delay:duration  duration:duration  timing:nil completion:nil]
           /*[EZPOP springWithPropery:kPOPLayerRotationY from:@(0) to:@(1.5) delay:0 params:EZPOPSpring(nil,@10,nil,nil,nil,@0) completion:nil]*/
           ] completion:nil forKey:@"spring"];
    });
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
