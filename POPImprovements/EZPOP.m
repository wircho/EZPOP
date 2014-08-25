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
    animation.fromValue = from;
    animation.toValue = to;
    animation.beginTime = CACurrentMediaTime()+delay;
    animation.duration = duration;
    animation.timingFunction = function;
    animation.completionBlock = completion;
    
    return animation;
}

+ (POPSpringAnimation*)springWithPropery:(NSString*)property from:(id)from to:(id)to delay:(CFTimeInterval)delay params:(EZPOPSpringParams*)params completion:(void(^)(POPAnimation*,BOOL))completion
{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:property];
    animation.fromValue = from;
    animation.toValue = to;
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
    animation.completionBlock = completion;
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
        [animation setCompletionBlock:^(POPAnimation *anim, BOOL completed) {
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
