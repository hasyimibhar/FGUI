//
//  FGUIButton.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIButton.h"
#import "FGUIElement_Private.h"
#import "FGUIRoot.h"
#import "CGPointExtension.h"

@implementation FGUIButton

+ (id)buttonWithSpriteFrameArray:(NSArray *)aSpriteFrameArray
{
    return [[[self alloc] initWithSpriteFrameArray:aSpriteFrameArray] autorelease];
}

@synthesize normalSpriteFrame, selectedSpriteFrame, disabledSpriteFrame, onPressBlock, onReleaseBlock;
@dynamic isEnabled;

- (void)setNormalSpriteFrame:(CCSpriteFrame *)aNormalSpriteFrame
{
    assert(aNormalSpriteFrame);
    normalSpriteFrame = aNormalSpriteFrame;
}

- (void)setSelectedSpriteFrame:(CCSpriteFrame *)aSelectedSpriteFrame
{
    assert(aSelectedSpriteFrame);
    selectedSpriteFrame = aSelectedSpriteFrame;
}

- (void)setDisabledSpriteFrame:(CCSpriteFrame *)aDisabledSpriteFrame
{
    assert(aDisabledSpriteFrame);
    
    disabledSpriteFrame = aDisabledSpriteFrame;
}

- (BOOL)isEnabled
{
    return isEnabled;
}

- (void)setIsEnabled:(BOOL)aIsEnabled
{
    isEnabled = aIsEnabled;
    [sprite setDisplayFrame:isEnabled ? normalSpriteFrame : disabledSpriteFrame];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    sprite.anchorPoint = anchorPoint;
}

- (id)initWithSpriteFrameArray:(NSArray *)aSpriteFrameArray
{
	if ((self = [super init]))
	{
        assert(aSpriteFrameArray);
        assert(aSpriteFrameArray.count == 3);
        
        isEnabled           = YES;
        sprite              = [[CCSprite alloc] initWithSpriteFrame:aSpriteFrameArray[0]];
        self.contentSize    = sprite.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
        onPressSelector     = nil;
        onPressTarget       = nil;
        onReleaseSelector   = nil;
        onReleaseTarget     = nil;
        onPressBlock        = nil;
        onReleaseBlock      = nil;
        
        [self setSpriteFramesWithArray:aSpriteFrameArray];
	}
	
	return self;
}

- (void)dealloc
{
    [onReleaseBlock release];
    [onPressBlock release];
    [sprite release];
	[super dealloc];
}

- (void)onEnter
{
    [super onEnter];
    [root.batchNode addChild:sprite z:zOrder_];
}

- (void)onExit
{
    [sprite removeFromParentAndCleanup:NO];
    [super onExit];
}

- (void)setSpriteFramesWithArray:(NSArray *)aSpriteFrameArray
{
    assert(aSpriteFrameArray.count == 3);
    
    self.normalSpriteFrame      = aSpriteFrameArray[0];
    self.selectedSpriteFrame    = aSpriteFrameArray[1];
    self.disabledSpriteFrame    = aSpriteFrameArray[2];
}

- (void)setOnPressWithSelector:(SEL)aSelector andTarget:(id)aTarget
{
    assert(aSelector && aTarget);
    onPressSelector     = aSelector;
    onPressTarget       = aTarget;
}

- (void)setOnReleaseWithSelector:(SEL)aSelector andTarget:(id)aTarget
{
    assert(aSelector && aTarget);
    onReleaseSelector   = aSelector;
    onReleaseTarget     = aTarget;
}

- (BOOL)touchBegan:(CGPoint)localPosition
{
    if (isEnabled && [self _isInside:localPosition])
    {
        [sprite setDisplayFrame:selectedSpriteFrame];
        [onPressTarget performSelector:onPressSelector];
        
        if (onPressBlock)
        {
            onPressBlock();
        }
        
        return YES;
    }
    
    return NO;
}

- (void)touchEnded:(CGPoint)localPosition
{
    [sprite setDisplayFrame:normalSpriteFrame];
    [onReleaseTarget performSelector:onReleaseSelector];
    
    if (onReleaseBlock)
    {
        onReleaseBlock();
    }
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