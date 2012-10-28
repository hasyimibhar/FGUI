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
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        FGUIElement *layer = [FGUIElement element];
        layer.anchorPoint = ccp(0.5f, 0.5f);
        layer.position = ccp(winSize.width / 2, winSize.height / 2);
        [guiRoot addElement:layer name:@"Layer"];

        FGUILabel *titleLabel = [FGUILabel labelWithString:@"Hello, world!" file:@"HeadingFont.fnt"];
        titleLabel.position = ccp(0, winSize.height / 2 - 20);
        titleLabel.scale = 2.0f;
        [layer addElement:titleLabel name:@"TitleLabel"];

        FGUILabel *subtitleLabel = [FGUILabel labelWithString:@"Damn, it works! Thank you, mikezang!" file:@"BodyFont.fnt"  width:90.0f alignment:kCCTextAlignmentLeft];
        subtitleLabel.position = ccp(0, winSize.height / 2 - 50);
        subtitleLabel.scale = 2.0f;
        [layer addElement:subtitleLabel name:@"SubtitleLabel"];
        
        [subtitleLabel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:360]]];

        MyCustomLayer *layer2 = [MyCustomLayer element];
        [guiRoot addElement:layer2 name:@"MyLayer" zOrder:20];
	}
	
	return self;
}

- (void)dealloc
{
    [guiRoot release];
	[super dealloc];
}

@end
