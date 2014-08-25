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
    
    [redContainer setFrame:CGRectMake(0,40,200,100)];
    [redContainer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    
    
    UIView *redView = [[UIView alloc] init];
    //[redView.layer setAnchorPoint:CGPointMake(0,0.5f)];
    
    [redView setFrame:CGRectMake(0,0,100,100)];
    [redView setBackgroundColor:[UIColor redColor]];
    [redView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [redView setClipsToBounds:NO];
    
    UIView *blueView = [[UIView alloc] init];
    [blueView.layer setAnchorPoint:CGPointMake(0,0.5f)];
    
    [blueView setFrame:CGRectMake(100,0,100,100)];
    [blueView setBackgroundColor:[UIColor blueColor]];
    [blueView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [blueView setClipsToBounds:NO];
    
    //NSLog(@"position:%f,%f",redView.layer.position.x,redView.layer.position.y);
    
    [redContainer addSubview:redView];
    [redContainer addSubview:blueView];
    [self.view addSubview:redContainer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [EZPOP objects:@[/*redContainer.layer,*/blueView.layer] addAnimations:
         @[
           /*[EZPOP springWithPropery:kPOPLayerRotationY from:@(0) to:@(M_PI_4) delay:0 params:EZPOPSpring(nil,@10,nil,nil,nil,@25) completion:nil],*/
           [EZPOP springWithPropery:kPOPLayerRotationY from:@(0) to:@(M_PI_2-0.01) delay:0 params:EZPOPSpring(nil,@10,nil,nil,nil,@0) completion:nil]
           ] completion:nil forKey:@"spring"];
    });
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
