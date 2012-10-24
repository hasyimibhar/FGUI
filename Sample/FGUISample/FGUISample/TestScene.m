//
//  TestScene.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "TestScene.h"

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
        
        FGUIButton *button = [layer1 createButtonWithName:@"Button1" spriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")] zOrder:1];
        button.anchorPoint = ccp(0.5f, 0);
        button.position = ccp(200, 200);
        
        button.onPressBlock = ^{
            CCLOG(@"(Block) Pressed!");
        };
        
        button.onReleaseBlock = ^{
            CCLOG(@"(Block) Released!");
        };
        
        [button setOnPressWithSelector:@selector(onButtonPressed) andTarget:self];
        [button setOnReleaseWithSelector:@selector(onButtonReleased) andTarget:self];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        FGUILabel *label = [layer1 createLabelWithName:@"Label1" string:@"Hello, world!" fontFile:@"HeadingFont.fnt" zOrder:10];
        label.position = ccp(winSize.width / 2, winSize.height - 50);
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
