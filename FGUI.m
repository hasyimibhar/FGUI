//
//  FGUI.m
//  CocosHUDFramework
//
//  Created by Hasyimi Bahrudin on 10/5/12.
//
//

#import "FGUI.h"
#import "CCLabelBNFont.h"

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
- (void)_updateScale;
- (void)_updateScaleX;
- (void)_updateScaleY;
@end

@interface FGUIRoot ()
{
    FGUILayer *activeLayer;
}

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

@interface FGUILabel ()
{
@public
    CCLabelBNFont *label;
}

+ (id)labelWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile;
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

- (void)setScale:(float)scale
{
    [super setScale:scale];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _updateScale];
        [aChild setScale:scale];
    }
}

- (void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _updateScaleX];
        [aChild setScaleX:scaleX];
    }
}

- (void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _updateScaleY];
        [aChild setScaleY:scaleY];
    }
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

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(childTable[aName] == nil);
    
    FGUILabel *label = [FGUILabel labelWithRoot:root andName:aName andParent:self andFile:aFontFile];
    label.string = aString;
    [self addChild:label z:zOrder];
    [root.batchNode addChild:label->label];
    childTable[aName] = label;
    
    return label;
}

- (void)destroyLabel:(FGUILabel *)aLabel
{
    assert(childTable[aLabel.name]);
    assert(childTable[aLabel.name] == aLabel);
    assert([aLabel isKindOfClass:FGUILabel.class]);
    assert([self.children containsObject:aLabel]);
    
    [root.batchNode removeChild:aLabel->label cleanup:YES];
    [aLabel removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aLabel.name];
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

- (void)_updateScale
{
    
}

- (void)_updateScaleX
{
    
}

- (void)_updateScaleY
{
    
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
        onPressBlock();
        return YES;
    }
    
    return NO;
}

- (void)touchEnded:(CGPoint)localPosition
{
    [sprite setDisplayFrame:normalSpriteFrame];
    [onReleaseTarget performSelector:onReleaseSelector];
    onReleaseBlock();
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

- (void)setScale:(float)scale
{
    [super setScale:scale];
    sprite.scale = scale * (parent ? parent.scale : 1);
}

- (void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    sprite.scaleX = scaleX;
}

- (void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    sprite.scaleY = scaleY;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
	if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        sprite              = [[CCSprite alloc] initWithSpriteFrame:aSpriteFrame];
        self.contentSize    = sprite.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
        self.scale          = 1.0f;
	}
	
	return self;
}

- (void)dealloc
{
    [sprite release];
	[super dealloc];
}

- (void)_updateScale
{
    sprite.scale = self.scale * (parent ? parent.scale : 1);
}

- (void)_updateScaleX
{
    sprite.scaleX = self.scaleX * (parent ? parent.scaleX : 1);
}

- (void)_updateScaleY
{
    sprite.scaleY = self.scaleY * (parent ? parent.scaleY : 1);
}

@end

@implementation FGUILabel

+ (id)labelWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andFile:aFile] autorelease];
}

@dynamic string;

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    label.position = [self worldPosition];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    label.anchorPoint = anchorPoint;
}

- (void)setScale:(float)scale
{
    [super setScale:scale];
    label.scale = scale * (parent ? parent.scale : 1);
}

- (void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    label.scaleX = scaleX;
}

- (void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    label.scaleY = scaleY;
}

- (NSString *)string
{
    return [[label.string copy] autorelease];
}

- (void)setString:(NSString *)string
{
    assert(string);
    label.string = string;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile
{
    if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        label               = [[CCLabelBNFont alloc] initWithString:@"" fntFile:aFile];
        assert(label);
        
        self.contentSize    = label.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
        self.scale          = 1.0f;
	}
	
	return self;
}

- (void)dealloc
{
    [label release];
    [super dealloc];
}

- (void)_updateScale
{
    label.scale = self.scale * (parent ? parent.scale : 1);
    label.position = ccpAdd(self.parent.position, ccpMult(self.position, self.parent.scale));
}

- (void)_updateScaleX
{
    label.scaleX = self.scaleX * (parent ? parent.scaleX : 1);
    label.position = ccpAdd(self.parent.position, ccp(self.position.x * self.parent.scaleX, self.position.y * self.parent.scaleY));
}

- (void)_updateScaleY
{
    label.scaleY = self.scaleY * (parent ? parent.scaleY : 1);
    label.position = ccpAdd(self.parent.position, ccp(self.position.x * self.parent.scaleX, self.position.y * self.parent.scaleY));
}

@end
