//
//  FGUI.m
//  CocosHUDFramework
//
//  Created by Hasyimi Bahrudin on 10/5/12.
//
//

#import "FGUI.h"

@interface FGUIElement ()
{
    FGUIElement *activeChild;
}

+ (id)elementWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (BOOL)_touchBegan:(CGPoint)localPosition;
- (void)_touchMoved:(CGPoint)localPosition;
- (void)_touchEnded:(CGPoint)localPosition;
- (BOOL)_isInside:(CGPoint)position;
@end

@interface FGUIRoot ()
{
    FGUILayer *activeLayer;
}

@property (readonly, assign, nonatomic) CCSpriteBatchNode * batchNode;
@end

@interface FGUIButton ()
{
@public
    CCSprite *sprite;
}

+ (id)buttonWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrameArray:(NSArray *)aSpriteFrameArray;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrameArray:(NSArray *)aSpriteFrameArray;
@end

@interface FGUISprite ()
{
@public
    CCSprite *sprite;
}

+ (id)spriteWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame;
@end

@implementation FGUIElement

+ (id)elementWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent] autorelease];
}

@synthesize name, delegate;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent
{
	if ((self = [super init]))
	{
        assert(aRoot);
        
        root        = aRoot;
        name        = [aName copy];
        parent      = aParent;
        
        childTable  = [[NSMutableDictionary alloc] init];
        activeChild = nil;
	}
	
	return self;
}

- (void)dealloc
{
    [childTable release];
    [name release];
	[super dealloc];
}

- (void)onExit
{
    [super onExit];
}

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(childTable[aName] == nil);
    
    FGUILayer *layer = [FGUILayer elementWithRoot:root andName:aName andParent:self];
    [self addChild:layer z:zOrder];
    childTable[aName] = layer;
    
    return layer;
}

- (void)destroyLayer:(FGUILayer *)aLayer
{
    assert(childTable[aLayer.name]);
    assert(childTable[aLayer.name] == aLayer);
    assert([aLayer isKindOfClass:FGUILayer.class]);
    assert([self.children containsObject:aLayer]);
    
    [aLayer removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aLayer.name];
}

- (FGUIButton *)createButtonWithName:(NSString *)aName spriteFrameArray:(NSArray *)aSpriteFrameArray zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(childTable[aName] == nil);
    
    FGUIButton *button = [FGUIButton buttonWithRoot:root andName:aName andParent:self andSpriteFrameArray:aSpriteFrameArray];
    [self addChild:button z:zOrder];
    [root.batchNode addChild:button->sprite];
    childTable[aName] = button;
    
    return button;
}

- (void)destroyButton:(FGUIButton *)aButton
{
    assert(childTable[aButton.name]);
    assert(childTable[aButton.name] == aButton);
    assert([aButton isKindOfClass:FGUIButton.class]);
    assert([self.children containsObject:aButton]);
    
    [root.batchNode removeChild:aButton->sprite cleanup:YES];
    [aButton removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aButton.name];
}

- (FGUISprite *)createSpriteWithName:(NSString *)aName spriteFrame:(CCSpriteFrame *)aSpriteFrame zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(childTable[aName] == nil);
    
    FGUISprite *sprite = [FGUISprite spriteWithRoot:root andName:aName andParent:self andSpriteFrame:aSpriteFrame];
    [self addChild:sprite z:zOrder];
    [root.batchNode addChild:sprite->sprite];
    childTable[aName] = sprite;
    
    return sprite;
}

- (void)destroySprite:(FGUISprite *)aSprite
{
    assert(childTable[aSprite.name]);
    assert(childTable[aSprite.name] == aSprite);
    assert([aSprite isKindOfClass:FGUISprite.class]);
    assert([self.children containsObject:aSprite]);
    
    [root.batchNode removeChild:aSprite->sprite cleanup:YES];
    [aSprite removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aSprite.name];
}

- (BOOL)_isInside:(CGPoint)position
{
    return CGRectContainsPoint(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), position);
}

- (BOOL)_touchBegan:(CGPoint)localPosition
{
    if ([self touchBegan:localPosition])
    {
        for (FGUIElement *aChild in [childTable allValues])
        {
            if ([aChild _touchBegan:[aChild convertToLocalPosition:localPosition]])
            {
                activeChild = aChild;
                break;
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (void)_touchMoved:(CGPoint)localPosition
{
    [self touchMoved:localPosition];
    [activeChild _touchMoved:[activeChild convertToLocalPosition:localPosition]];
}

- (void)_touchEnded:(CGPoint)localPosition
{
    [self touchEnded:localPosition];
    [activeChild _touchEnded:[activeChild convertToLocalPosition:localPosition]];
    activeChild = nil;
}

- (BOOL)touchBegan:(CGPoint)localPosition
{
    return YES;
}

- (void)touchMoved:(CGPoint)localPosition
{
    
}

- (void)touchEnded:(CGPoint)localPosition
{
    
}

- (CGPoint)worldPosition
{
    if (parent == nil)
    {
        return self.position;
    }
    
    return ccpAdd([parent worldPosition], self.position);
}

- (CGPoint)convertToLocalPosition:(CGPoint)aPosition
{
    return ccpSub(aPosition, ccpSub(self.position, ccp(self.contentSize.width * self.anchorPoint.x, self.contentSize.height * self.anchorPoint.y)));
}

@end

@implementation FGUIRoot

@synthesize batchNode;

+ (id)guiWithFile:(NSString *)aFile
{
    return [[[self alloc] initWithFile:aFile] autorelease];
}

- (id)initWithFile:(NSString *)aFile
{
	if ((self = [super init]))
	{
        batchNode       = [CCSpriteBatchNode batchNodeWithFile:aFile];
        assert(batchNode);
        [self addChild:batchNode];
        
        activeLayer     = nil;
        layerTable      = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
    [layerTable release];
	[super dealloc];
}

- (void)onEnter
{
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(layerTable[aName] == nil);
    
    FGUILayer *layer = [FGUILayer elementWithRoot:self andName:aName andParent:nil];
    [self addChild:layer z:zOrder];
    layerTable[aName] = layer;
    
    return layer;
}

- (void)destroyLayer:(FGUILayer *)aLayer
{
    assert(layerTable[aLayer.name]);
    assert(layerTable[aLayer.name] == aLayer);
    assert([aLayer isKindOfClass:FGUILayer.class]);
    assert([self.children containsObject:aLayer]);
    
    [aLayer removeFromParentAndCleanup:YES];
    [layerTable removeObjectForKey:aLayer.name];
}

- (void)destroyLayerWithName:(NSString *)aLayerName
{
    FGUILayer *layer = layerTable[aLayerName];
    assert(layer);
    [self destroyLayer:layer];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
    for (FGUILayer *aLayer in [layerTable allValues])
    {
        if ([aLayer _isInside:[aLayer convertToLocalPosition:touchPosition]] && [aLayer _touchBegan:[aLayer convertToLocalPosition:touchPosition]])
        {
            activeLayer = aLayer;
            return YES;
        }
    }
    
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    if ([activeLayer _isInside:[activeLayer convertToLocalPosition:touchPosition]])
    {
        [activeLayer _touchMoved:[activeLayer convertToLocalPosition:touchPosition]];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    [activeLayer _touchEnded:[activeLayer convertToLocalPosition:touchPosition]];
    activeLayer = nil;
}

@end

@implementation FGUILayer

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent
{
	if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        self.contentSize = [[CCDirector sharedDirector] winSize];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end

@implementation FGUIButton

+ (id)buttonWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrameArray:(NSArray *)aSpriteFrameArray
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andSpriteFrameArray:aSpriteFrameArray] autorelease];
}

@synthesize normalSpriteFrame, selectedSpriteFrame, disabledSpriteFrame;
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

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    sprite.position = [self worldPosition];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    sprite.anchorPoint = anchorPoint;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrameArray:(NSArray *)aSpriteFrameArray
{
	if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        assert(aSpriteFrameArray);
        assert(aSpriteFrameArray.count == 3);
        
        isEnabled           = YES;
        sprite              = [[CCSprite alloc] initWithSpriteFrame:aSpriteFrameArray[0]];
        self.contentSize    = sprite.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
        
        [self setSpriteFramesWithArray:aSpriteFrameArray];
	}
	
	return self;
}

- (void)dealloc
{
    [sprite release];
	[super dealloc];
}

- (void)setSpriteFramesWithArray:(NSArray *)aSpriteFrameArray
{
    assert(aSpriteFrameArray.count == 3);
    
    self.normalSpriteFrame = aSpriteFrameArray[0];
    self.selectedSpriteFrame = aSpriteFrameArray[1];
    self.disabledSpriteFrame = aSpriteFrameArray[2];
}

- (BOOL)touchBegan:(CGPoint)localPosition
{
    if (isEnabled && [self _isInside:localPosition])
    {
        [sprite setDisplayFrame:selectedSpriteFrame];
        return YES;
    }
    
    return NO;
}

- (void)touchEnded:(CGPoint)localPosition
{
    [sprite setDisplayFrame:normalSpriteFrame];
}

@end

@implementation FGUISprite

+ (id)spriteWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andSpriteFrame:aSpriteFrame] autorelease];
}

@synthesize spriteFrame;

- (void)setSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    assert(aSpriteFrame);
    spriteFrame = aSpriteFrame;
    [sprite setDisplayFrame:spriteFrame];
    self.contentSize = sprite.contentSize;
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    sprite.position = [self worldPosition];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    sprite.anchorPoint = anchorPoint;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
	if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        sprite              = [[CCSprite alloc] initWithSpriteFrame:aSpriteFrame];
        self.contentSize    = sprite.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
	}
	
	return self;
}

- (void)dealloc
{
    [sprite release];
	[super dealloc];
}

@end
