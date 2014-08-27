//
//  EZPOP.m
//  POPImprovements
//
//  Created by Adolfo Rodriguez on 2014-08-21.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import "EZPOP.h"

#import <POP/POP.h>

#define ANIMATION_KEY_FORMAT @"%@__%p"

//struct EZPOPTimingFunctionControlPoints
//{
//    float x1;
//    float x2;
//    float y1;
//    float y2;
//};

@interface EZPOPWeakObject : NSObject

@property (nonatomic,weak) id object;
+ object:(id)object;

@end

@implementation EZPOPWeakObject

+ (id)object:(id)object
{
    EZPOPWeakObject *weakObject = [[EZPOPWeakObject alloc] init];
    weakObject.object = object;
    
    return weakObject;
}

@end

@interface EZPOPBasicAnimation ()

@property (nonatomic,assign) float* controlPoints;

@end

@implementation EZPOPBasicAnimation

@synthesize timingFunction = _timingFunction;

//+ (EZPOPBasicAnimation *)animationWithPropertyNamed:(NSString *)property
//{
//    if ([property isEqualToString:kPOPLayerRotationX]){
//        EZPOPBasicAnimation *animation = [EZPOPBasicAnimation animationWithBlock:^BOOL(id target, POPCustomAnimation *animation) {
//            EZPOPBasicAnimation *basicAnimation = (EZPOPBasicAnimation*)animation;
//            CGFloat epsilon = MIN(basicAnimation.currentTime,basicAnimation.duration)/basicAnimation.duration;
//            CGFloat actualEpsilon = epsilon;//TODO: FIX THIS
//            CGFloat currentValue = [basicAnimation.fromValue floatValue]*(1-actualEpsilon) + [basicAnimation.toValue floatValue]*actualEpsilon;
//        }];
//    }else if ([property isEqualToString:kPOPLayerRotationY]){
//        
//    }else{
//        NSLog(@"Not supported yet!");
//        abort();
//        return nil;
//    }
//}

- (CAMediaTimingFunction *)timingFunction
{
    if (_timingFunction==nil){
        _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self saveControlPoints];
    }
    return _timingFunction;
}

- (void)setTimingFunction:(CAMediaTimingFunction *)timingFunction
{
    _timingFunction = timingFunction;
    [self saveControlPoints];
}

- (void)saveControlPoints
{
    float control1[2] = {0.0f,0.0f};
    float control2[2] = {0.0f,0.0f};
    [self.timingFunction getControlPointAtIndex:1 values:control1];
    [self.timingFunction getControlPointAtIndex:2 values:control2];
    
    self.controlPoints = malloc(sizeof(float)*4);
    self.controlPoints[0] = control1[0];
    self.controlPoints[1] = control1[1];
    self.controlPoints[2] = control2[0];
    self.controlPoints[3] = control2[1];
    
}

@end

@implementation EZPOPTransformView

+ (Class)layerClass
{
    return [CATransformLayer class];
}

@end



@implementation EZPOPSpringParams

+ (instancetype)speed:(NSNumber *)springSpeed bounciness:(NSNumber *)springBounciness friction:(NSNumber *)dynamicsFriction mass:(NSNumber *)dynamicsMass tension:(NSNumber *)dynamicsTension velocity:(NSNumber *)velocity
{
    EZPOPSpringParams *params = [[self alloc] init];
    params.springSpeed = springSpeed;
    params.springBounciness = springBounciness;
    params.dynamicsFriction = dynamicsFriction;
    params.dynamicsMass = dynamicsMass;
    params.dynamicsTension = dynamicsTension;
    params.velocity = velocity;
    return params;
}

@end

@interface EZPOP ()

@property (nonatomic,strong) NSMutableDictionary *animationArrays;
@property (nonatomic,strong) NSMutableDictionary *animationCompletionBooleanArrays;
@property (nonatomic,strong) NSMutableDictionary *animationCompletions;
@property (nonatomic,strong) NSMutableDictionary *animationObjectArrays;

@end

@implementation EZPOP

+ (EZPOP*)instance
{
    static EZPOP *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZPOP alloc] init];
    });
    return instance;
}

+ (POPBasicAnimation*)basicWithProperty:(NSString*)property from:(id)from to:(id)to delay:(CFTimeInterval)delay duration:(CFTimeInterval)duration timing:(CAMediaTimingFunction*)function completion:(void(^)(POPAnimation*,BOOL))completion
{
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:property];
    if (from != nil){
        animation.fromValue = from;
    }
    if (to != nil){
        animation.toValue = to;
    }
    animation.beginTime = CACurrentMediaTime()+delay;
    animation.duration = duration;
    if (function != nil){
        animation.timingFunction = function;
    }
    if (completion != nil){
        animation.completionBlock = completion;
    }
    
    return animation;
}

+ (POPSpringAnimation*)springWithPropery:(NSString*)property from:(id)from to:(id)to delay:(CFTimeInterval)delay params:(EZPOPSpringParams*)params completion:(void(^)(POPAnimation*,BOOL))completion
{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:property];
    if (from != nil){
        animation.fromValue = from;
    }
    if (to != nil){
        animation.toValue = to;
    }
    animation.beginTime = CACurrentMediaTime()+delay;
    if (params.springSpeed != nil){
        animation.springSpeed = params.springSpeed.floatValue;
    }
    if (params.springBounciness != nil){
        animation.springBounciness = params.springBounciness.floatValue;
    }
    if (params.dynamicsFriction != nil){
        animation.dynamicsFriction = params.dynamicsFriction.floatValue;
    }
    if (params.dynamicsMass != nil){
        animation.dynamicsMass = params.dynamicsMass.floatValue;
    }
    if (params.dynamicsTension != nil){
        animation.dynamicsTension = params.dynamicsTension.floatValue;
    }
    if (params.velocity != nil){
        animation.velocity = params.velocity;
    }
    if (completion != nil){
        animation.completionBlock = completion;
    }
    return animation;
}

+ (void)objects:(NSArray*)objects addAnimations:(NSArray*)animations completion:(void(^)(NSArray*,NSArray*,POPAnimation*))completion forKey:(NSString*)key
{
    NSAssert(objects.count>0 && animations.count==objects.count,@"Please provide the same number of animations as objects!");
    
    EZPOP *instance = [self instance];
    
    NSAssert(instance.animationArrays[key] == nil,@"This key is already being used!");
    
    NSMutableArray *completionBooleans = @[].mutableCopy;
    NSMutableArray *weakObjects = @[].mutableCopy;
    
    for (int i=0;i<objects.count;i+=1){
        id object = objects[i];
        POPAnimation *animation = animations[i];
        [completionBooleans addObject:[NSNull null]];
        [weakObjects addObject:[EZPOPWeakObject object:object]];
        
        [object pop_addAnimation:animation forKey:[NSString stringWithFormat:ANIMATION_KEY_FORMAT,key,(void*)animation]];
        void(^oldCompletion)(POPAnimation*,BOOL) = animation.completionBlock;
        [animation setCompletionBlock:^(POPAnimation *anim, BOOL completed) {
            if (oldCompletion != nil){
                oldCompletion(anim,completed);
            }
            [self handleFinishedAnimation:anim completed:completed];
        }];
    }
    
    instance.animationArrays[key] = animations;
    instance.animationObjectArrays[key] = weakObjects;
    if (completion==nil){
        instance.animationCompletions[key] = [NSNull null];
    }else{
        instance.animationCompletions[key] = completion;
    }
}

+ (void)removeAnimationsForKey:(NSString*)key
{
    EZPOP *instance = [self instance];
    
    NSArray *objects = instance.animationObjectArrays[key];
    NSArray *animations = instance.animationArrays[key];
    
    if (objects != nil){
        for (int i=0;i<objects.count;i+=1){
            EZPOPWeakObject *weakObject = objects[i];
            POPAnimation *animation = animations[i];
            [weakObject.object pop_removeAnimationForKey:[NSString stringWithFormat:ANIMATION_KEY_FORMAT,key,(void*)animation]];
        }
    }
    
    [instance.animationArrays removeObjectForKey:key];
    [instance.animationCompletionBooleanArrays removeObjectForKey:key];
    [instance.animationCompletions removeObjectForKey:key];
    [instance.animationObjectArrays removeObjectForKey:key];
}

+ (void)handleFinishedAnimation:(POPAnimation*)anim completed:(BOOL)completed
{
    EZPOP *instance = [self instance];
    
    for (NSString *key in instance.animationArrays){
        NSArray *animations = instance.animationArrays[key];
        NSUInteger index;
        if (animations != nil && (index = [animations indexOfObject:anim]) != NSNotFound){
            NSMutableArray *booleans = instance.animationCompletionBooleanArrays[key];
            booleans[index] = @(completed);
            
            BOOL allCompleted = YES;
            for (NSNumber *boolean in booleans){
                if (!boolean.boolValue){
                    allCompleted = NO;
                }
            }
            
            if (allCompleted){
                void(^completion)(NSArray*,NSArray*,POPAnimation*) = instance.animationCompletions[key];
                if (completion != nil){
                    completion(animations,booleans,anim);
                    [instance.animationArrays removeObjectForKey:key];
                    [instance.animationCompletionBooleanArrays removeObjectForKey:key];
                    [instance.animationCompletions removeObjectForKey:key];
                    [instance.animationObjectArrays removeObjectForKey:key];
                }
            }
            
            break;
        }
    }
}

- (NSMutableDictionary *)animationArrays
{
    if (_animationArrays == nil){
        _animationArrays = @{}.mutableCopy;
    }
    
    return _animationArrays;
}

- (NSMutableDictionary *)animationCompletions
{
    if (_animationCompletions==nil){
        _animationCompletions = @{}.mutableCopy;
    }
    
    return _animationCompletions;
}

- (NSMutableDictionary *)animationCompletionBooleanArrays
{
    if (_animationCompletionBooleanArrays==nil){
        _animationCompletionBooleanArrays = @{}.mutableCopy;
    }
    
    return _animationCompletionBooleanArrays;
}

- (NSMutableDictionary *)animationObjectArrays
{
    if (_animationObjectArrays==nil){
        _animationObjectArrays = @{}.mutableCopy;
    }
    
    return _animationObjectArrays;
}

@end
