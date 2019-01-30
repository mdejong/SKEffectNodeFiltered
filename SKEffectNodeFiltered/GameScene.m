//
//  GameScene.m
//  SKEffectNodeFiltered
//
//  Created by Mo DeJong on 1/29/19.
//  Copyright © 2019 HelpURock. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property (nonatomic, retain) SKEffectNode *effectNode;

@property (nonatomic, retain) SKSpriteNode *backgroundNode;

@property (nonatomic, retain) SKLabelNode *memoryUsedNode;

@property (nonatomic, assign) CGSize backgroundSize;

@property (nonatomic, assign) int frameOffset;

@end

@implementation GameScene

// iPad memory use with largest possible texture.
// Note that dynamic resize is done in hardware so this
// animation has minimal CPU impact.
//
// With 4096x4096 grayscale sources : 68 megs

-(void)didMoveToView:(SKView *)view {
  self.scene.backgroundColor = [UIColor blackColor];
  
  NSString *filename;
  CGSize nodeSizeInPixels;
  
  if ((1)) {
    // Use of a the max size texture quickly leads to memory issues
    filename = @"SmileyFace8bitGray_4096.png";
    nodeSizeInPixels = CGSizeMake(4096, 4096);
  } else {
    // Using a smaller texture does not crash as easily
    filename = @"SmileyFace8bitGray_1024.png";
    nodeSizeInPixels = CGSizeMake(1024, 1024);
  }

  int scale = (int) [UIScreen mainScreen].scale;
  CGSize nodeSizeInPoints = CGSizeMake(nodeSizeInPixels.width / scale, nodeSizeInPixels.height / scale);
  
  SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:nodeSizeInPoints];
  
  background.texture = [SKTexture textureWithImageNamed:filename];
  
  self.backgroundNode = background;
  self.backgroundSize = background.size;
  
  if ((0)) {
    // Define initial bg size
    background.size = CGSizeMake(self.backgroundSize.width / 4, self.backgroundSize.height  / 4);
  }
  
  if (1) {
    NSLog(@"initial background size %d x %d", (int)self.backgroundSize.width, (int)self.backgroundSize.height);
  }
  
  // Pixelate CoreImage filter
  
  CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
  [pixellateFilter setDefaults]; // Remember to setDefaults...
  [pixellateFilter setValue:@(25.0) forKey:@"inputScale"];
  
  SKEffectNode *effectNode = [[SKEffectNode alloc] init];
  effectNode.shouldEnableEffects = TRUE; // enable CoreImage filtering
  effectNode.shouldRasterize = FALSE; // generate and then discard tmp framebuffer
  //effectNode.shouldRasterize = TRUE;
  effectNode.shouldCenterFilter = TRUE;
  effectNode.filter = pixellateFilter;
  self.effectNode = effectNode;
  
  [effectNode addChild:background];
  [self addChild:effectNode];
  
  effectNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
  
  if (1) {
    NSLog(@"initial background node size %d x %d", (int)background.size.width, (int)background.size.height);
  }
  
  // Display amount of RAM in terms of BGRA pixels that would be used for this texture
  
  int numBytes = nodeSizeInPixels.width * nodeSizeInPixels.height * sizeof(uint32_t);
  
  SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
  label.text = [NSString stringWithFormat:@"RAM %5d mB", numBytes / 1000 / 1000];
  label.fontSize = 25;
  label.fontColor = [SKColor whiteColor];
  label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
  label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  label.position = CGPointMake(0, 0);
  [self addChild:label];
  
  self.memoryUsedNode = label;
  
  return;
}

-(void)update:(CFTimeInterval)currentTime {
  const BOOL dumpBackgroundSize = TRUE;
  
  const int speedStep = 4;
  
  // Set this to 1 to disable the animation on each render
  if ((0)) {
    return;
  }
  
  // Rendering only 3 frames still leaks a ton of memory, but
  // not enough to crash the app.
  
//  if (self.frameOffset >= 3) {
//    return;
//  }
  
  int numSteps = self.backgroundSize.width;
  
  self.frameOffset = self.frameOffset + 1;
  SKSpriteNode *backgroundNode = self.backgroundNode;
  int over = self.frameOffset % numSteps;
  over *= (speedStep * speedStep);
  
  backgroundNode.size = CGSizeMake(self.backgroundSize.width - over, self.backgroundSize.height - over);
  
  if (backgroundNode.size.width < 10 || backgroundNode.size.height < 10) {
    self.frameOffset = 0;
    backgroundNode.size = self.backgroundSize;
  }
  
  if (dumpBackgroundSize) {
    NSLog(@"resize background to %d x %d", (int)backgroundNode.size.width, (int)backgroundNode.size.height);
  }
  return;
}

@end
