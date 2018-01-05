//
//  Bullet.h
//  ARDemo
//
//  Created by txooo on 2018/1/2.
//  Copyright © 2018年 txooo. All rights reserved.
//

#import <SceneKit/SceneKit.h>

typedef NS_OPTIONS(NSInteger, CollisionCategory) {
    CollisionCategoryBullets = 1 << 0, // 00...01
    CollisionCategoryShip = 1 << 1 // 00..10
};

typedef NS_ENUM(NSInteger ,SoundEffect) {
    SoundEffectExplosion ,//"explosion"
    SoundEffectCollision,//collision
    SoundEffectTorpedo //torpedo
};


@interface Bullet : SCNNode


@end
