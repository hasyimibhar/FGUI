//
//  FGUISprite.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUISprite.h"
#import "FGUIRoot.h"
#import "FGUIElement_Private.h"
#import "CGPointExtension.h"

@implementation FGUISprite

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    return [[[self alloc] initWithSpriteFrame:aSpriteFrame] autorelease];
}

@synthesize spriteFrame;
@dynamic color, opacity;

- (void)setSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    assert(aSpriteFrame);
    spriteFrame = aSpriteFrame;
    [sprite setDisplayFrame:spriteFrame];
    self.contentSize = sprite.contentSize;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    sprite.anchorPoint = anchorPoint;
}

- (ccColor3B)color
{
    return sprite.color;
}

- (void)setColor:(ccColor3B)color
{
    sprite.color = color;
}

- (GLubyte)opacity
{
    return sprite.opacity;
}

- (void)setOpacity:(GLubyte)opacity
{
    sprite.opacity = opacity;
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
	if ((self = [super init]))
	{
        assert(aSpriteFrame);
        
        sprite              = [[CCSprite alloc] initWithSpriteFrame:aSpriteFrame];
        self.contentSize    = sprite.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
	}
	
	return self;
}

- (void)dealloc
{
    assert(sprite.parent == nil);
    [sprite release];
	[super dealloc];
}

- (void)_onAdd
{
    [super _onAdd];
    
    [root.batchNode addChild:sprite z:zOrder_];
}

- (void)_onRemove
{
    [sprite removeFromParentAndCleanup:NO];
    
    [super _onRemove];
}

- (void)_update
{
    [super _update];
    
    sprite.position = [self worldPosition];
    sprite.rotation = [self worldRotation];
    
    CGPoint scale = [self worldScale];
    sprite.scaleX = scale.x;
    sprite.scaleY = scale.y;
}

- (NSInteger)_updateZOrder:(NSInteger)z
{
    [root.batchNode reorderChild:sprite z:z++];
    return z;
}

@end