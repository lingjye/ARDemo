
//
//  Ship.m
//  ARDemo
//
//  Created by txooo on 2018/1/4.
//  Copyright © 2018年 txooo. All rights reserved.
//

#import "Ship.h"
#import "Bullet.h"

@implementation Ship

- (instancetype)init {
    if (self = [super init]) {
        SCNBox *box = [SCNBox boxWithWidth:0.1 height:0.1 length:0.1 chamferRadius:0];
        self.geometry = box;
        
        SCNPhysicsShape *shape = [SCNPhysicsShape shapeWithGeometry:box options:nil];
        
        self.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:shape];
        self.physicsBody.affectedByGravity = false;
        
        self.physicsBody.categoryBitMask = CollisionCategoryShip;
        self.physicsBody.contactTestBitMask = CollisionCategoryBullets;
        // add texture
        
        SCNMaterial *material = [SCNMaterial material];
        material.diffuse.contents = [UIImage imageNamed:@"galaxy"];
        self.geometry.materials = @[material,material,material,material,material,material];
    }
    return self;
}

@end
