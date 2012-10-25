//
//  TestScene.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "TestScene.h"
#import "MyCustomLayer.h"
#import "matrix.h"

@interface TestScene ()
- (void)onButtonPressed;
- (void)onButtonReleased;
@end

@implementation TestScene

- (id)init
{
	if ((self = [super init]))
	{
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Spritesheet.plist"];
        guiRoot = [[FGUIRoot alloc] initWithFile:@"Spritesheet.png"];
        
        // Disable anti-aliasing, because I'm using pixel font
        [[guiRoot.batchNode texture] setAliasTexParameters];
        [self addChild:guiRoot];
        
        FGUILayer *layer1 = [guiRoot createLayerWithName:@"Layer1" zOrder:0];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        FGUILabel *titleLabel = [layer1 createLabelWithName:@"Title" string:@"Hello, world!" fontFile:@"HeadingFont.fnt" zOrder:10];
        titleLabel.position = ccp(winSize.width / 2, winSize.height - 50);
        titleLabel.scale = 2.0f;

        FGUILabel *subtitleLabel = [layer1 createLabelWithName:@"Subtitle" string:@"Damn, it works! Thank you, mikezang!" fontFile:@"BodyFont.fnt" zOrder:10];
        subtitleLabel.position = ccp(winSize.width / 2, winSize.height - 70);
        
        subtitleLabel.scale = 2.0f;
        
        [subtitleLabel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:CC_DEGREES_TO_RADIANS(360)]]];
        
        MyCustomLayer *layer2 = [MyCustomLayer node];
        [guiRoot addLayer:layer2 withName:@"MyLayer" zOrder:20];
        layer2.position = ccp(300, 300);
	}
	
	return self;
}

- (void)dealloc
{
    [guiRoot release];
	[super dealloc];
}

- (void)onButtonPressed
{
    CCLOG(@"(SEL) Pressed!");
}

- (void)onButtonReleased
{
    CCLOG(@"(SEL) Released!");
}

@end
