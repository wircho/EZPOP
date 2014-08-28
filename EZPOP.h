//
//  EZPOP.h
//  POPImprovements
//
//  Created by Adolfo Rodriguez on 2014-08-21.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <POP/POP.h>

#define EZPOPTiming(X1,Y1,X2,Y2) [CAMediaTimingFunction functionWithControlPoints:X1 :Y1 :X2 :Y2]

#define EZPOPSpring(S,B,F,M,T,V) [EZPOPSpringParams speed:S bounciness:B friction:F mass:M tension:T velocity:V]

#define EZPOPDeterminant(T)

@interface EZPOPSpringParams : NSObject

+ (instancetype)speed:(NSNumber*)springSpeed bounciness:(NSNumber*)springBounciness friction:(NSNumber*)dynamicsFriction mass:(NSNumber*)dynamicsMass tension:(NSNumber*)dynamicsTension velocity:(NSNumber*)velocity;

@property (nonatomic,strong) NSNumber *springSpeed;
@property (nonatomic,strong) NSNumber *springBounciness;
@property (nonatomic,strong) NSNumber *dynamicsFriction;
@property (nonatomic,strong) NSNumber *dynamicsMass;
@property (nonatomic,strong) NSNumber *dynamicsTension;
@property (nonatomic,strong) NSNumber *velocity;

@end

@interface EZPOPTransformView : UIView

@end

@interface EZPOPBasicAnimation : POPCustomAnimation

@property (nonatomic,copy) id fromValue;
@property (nonatomic,copy) id toValue;
@property (nonatomic,assign) CFTimeInterval duration;
@property (nonatomic,strong) CAMediaTimingFunction *timingFunction;

+ (EZPOPBasicAnimation *)animationWithPropertyNamed:(NSString*)property;


@end

//@interface EZPOPAnchoredView : UIView
//
//@end
//
//@interface EZPOPLeftAnchoredView : EZPOPAnchoredView
//
//@end
//
//@interface EZPOPRightAnchoredView : EZPOPAnchoredView
//
//@end

@interface EZPOP : NSObject

+ (EZPOP*)instance;

+ (POPBasicAnimation*)basicWithProperty:(NSString*)property from:(id)from to:(id)to delay:(CFTimeInterval)delay duration:(CFTimeInterval)duration timing:(CAMediaTimingFunction*)function completion:(void(^)(POPAnimation*,BOOL))completion;

+ (POPSpringAnimation*)springWithPropery:(NSString*)property from:(id)from to:(id)to delay:(CFTimeInterval)delay params:(EZPOPSpringParams*)params completion:(void(^)(POPAnimation*,BOOL))completion;

+ (void)objects:(NSArray*)objects addAnimations:(NSArray*)animations completion:(void(^)(NSArray*,NSArray*,POPAnimation*))completion forKey:(NSString*)key;

+ (void)removeAnimationsForKey:(NSString*)key;

@end
