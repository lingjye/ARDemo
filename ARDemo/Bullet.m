//
//  Bullet.m
//  ARDemo
//
//  Created by txooo on 2018/1/2.
//  Copyright © 2018年 txooo. All rights reserved.
//

#import "Bullet.h"


@implementation Bullet

- (instancetype)init {
    if (self = [super init]) {
        SCNSphere *sphere = [SCNSphere sphereWithRadius:0.025];
        self.geometry = sphere;
        
        SCNPhysicsShape *shape = [SCNPhysicsShape shapeWithGeometry:self.geometry options:nil];
        
        self.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:shape];
        self.physicsBody.affectedByGravity = NO;
        
        self.physicsBody.categoryBitMask = CollisionCategoryBullets;
        self.physicsBody.contactTestBitMask = CollisionCategoryShip;
        
        
        SCNMaterial *material = [SCNMaterial material];
        material.diffuse.contents = [UIImage imageNamed:@"bullet_texture"];
        
        self.geometry.materials = @[material];
    }
    return self;
}

@end
