//
//  ViewController.m
//  ARDemo
//
//  Created by txooo on 2018/1/2.
//  Copyright © 2018年 txooo. All rights reserved.
//

#import "ViewController.h"
#import "Bullet.h"
#import "Ship.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <ARSCNViewDelegate,SCNPhysicsContactDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, assign) NSInteger userScore;

@end

    
@implementation ViewController

- (void)setUserScore:(NSInteger)userScore {
    _userScore = userScore;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scoreLabel.text = [NSString stringWithFormat:@"%ld",userScore];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [[SCNScene alloc] init];//[SCNScene sceneNamed:@"art.scnassets/explosion.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    self.sceneView.scene.physicsWorld.contactDelegate = self;
    
    [self addNewShip];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.sceneView addGestureRecognizer:tap];
    
    self.userScore = 0;
}

- (void)addNewShip {
    Ship *cubeNode = [[Ship alloc] init];
    CGFloat posX = [self floatBetweenFirst:-0.5 sencond:0.5];
    CGFloat posY = [self floatBetweenFirst:-0.5 sencond:0.5];
    // SceneKit/AR coordinates are in meters
    cubeNode.position = SCNVector3Make(posX, posY, -1);
    
    [self.sceneView.scene.rootNode addChildNode:cubeNode];
}

- (CGFloat)floatBetweenFirst:(CGFloat)first sencond:(CGFloat)second {
     // random float between upper and lower bound (inclusive)
    return (CGFloat)((CGFloat)arc4random() / (CGFloat)UINT32_MAX) * (first - second) + second;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureSession];
}

- (void)configureSession{
    if ([ARWorldTrackingConfiguration isSupported]) {
        // Create a session configuration
        ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        // Run the view's session
        [self.sceneView.session runWithConfiguration:configuration];
    }else {
        ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
        [self.sceneView.session runWithConfiguration:configuration];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)didTapScreen:(UITapGestureRecognizer *)sender { // fire bullet in direction camera is facing
    
    // Play torpedo sound when bullet is launched
    [self playSoundEffect:SoundEffectTorpedo];
    
    Bullet *bulletsNode = [[Bullet alloc] init];
    NSArray *userVewctor = [self getUserVector];
    SCNVector3 position = [userVewctor.firstObject SCNVector3Value];
    SCNVector3 direction = [userVewctor.lastObject SCNVector3Value];
    bulletsNode.position = position; // SceneKit/AR coordinates are in meters
    
    [bulletsNode.physicsBody applyForce:direction impulse:YES];
    
    [self.sceneView.scene.rootNode addChildNode:bulletsNode];
    
}

- (NSArray *)getUserVector{ // (direction, position)
    ARFrame *frame = self.sceneView.session.currentFrame;
    if (frame) {
        SCNMatrix4 mat = SCNMatrix4FromMat4(frame.camera.transform);
        
        SCNVector3 pos = SCNVector3Make(mat.m41, mat.m42, mat.m43);
        SCNVector3 dir = SCNVector3Make(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33);
        return @[[NSValue valueWithSCNVector3:pos],[NSValue valueWithSCNVector3:dir]];
    }
    return @[[NSValue valueWithSCNVector3:SCNVector3Make(0, 0, -1)],[NSValue valueWithSCNVector3:SCNVector3Make(0, 0, -0.2)]];
}

- (void)playSoundEffect:(SoundEffect)effect {
    
    // Async to avoid substantial cost to graphics processing (may result in sound effect delay however)
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *src = nil;
        switch (effect) {
            case SoundEffectExplosion:
                src = @"explosion";
                break;
            case SoundEffectCollision:
                src = @"collision";
                break;
            case SoundEffectTorpedo:
                src = @"torpedo";
                break;
            default:
                break;
        }
        NSURL *effectURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:src ofType:@"mp3"]];
        
        if (effectURL) {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:effectURL error:nil];
            [self.player play];
        }
    });
}

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

#pragma mark SCNPhysicsContactDelegate
- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact {
    //print("did begin contact", contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask)
    if (contact.nodeA.physicsBody.categoryBitMask == CollisionCategoryShip || contact.nodeB.physicsBody.categoryBitMask == CollisionCategoryShip) {
        NSLog(@"Hit ship!");
        [self removeNodeWithAnimation:contact.nodeB explosion:NO];// remove the bullet
        self.userScore += 1;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // remove/replace ship after half a second to visualize collision
            [self removeNodeWithAnimation:contact.nodeA explosion:YES];
            [self addNewShip];
        });
    }
}

- (void)removeNodeWithAnimation:(SCNNode *)node explosion:(BOOL)explosion {

    // Play collision sound for all collisions (bullet-bullet, etc.)
    [self playSoundEffect:SoundEffectCollision];
    
    if (explosion) {
        // Play explosion sound for bullet-ship collisions
        [self playSoundEffect:SoundEffectExplosion];
        
        SCNParticleSystem *particleSystem = [SCNParticleSystem particleSystemNamed:@"explosion" inDirectory:nil];
        
        SCNNode *systemNode = [[SCNNode alloc] init];
        
        [systemNode addParticleSystem:particleSystem];

        // place explosion where node is
        systemNode.position = node.position;
        [self.sceneView.scene.rootNode addChildNode:systemNode];
    }

    // remove node
    [node removeFromParentNode];
}

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        _scoreLabel.textColor = [UIColor yellowColor];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:_scoreLabel];
    }
    return _scoreLabel;
}

@end
