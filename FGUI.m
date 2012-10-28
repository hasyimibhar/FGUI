//
//  FGUI.m
//  CocosHUDFramework
//
//  Created by Hasyimi Bahrudin on 10/5/12.
//
//

#import "FGUI.h"
#import "CCLabelBNFont.h"

@implementation NSDictionary (ValueSearch)

- (BOOL)containsValue:(id<NSObject>)value
{
    for (id<NSObject> aValue in [self allValues])
    {
        if ([value isEqual:aValue])
        {
            return YES;
        }
    }
    
    return NO;
}

@end

#if FGUI_DEBUG

@implementation FGUIBoundingBoxNode

- (id)init
{
    if ((self = [super init]))
    {
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
    }
    
    return self;
}

- (void)draw
{
    CC_NODE_DRAW_SETUP();
    
    ccDrawColor4B(0, 0, 255, 150);
    ccPointSize(5.0f);
    ccDrawPoint(ccp(self.parent.contentSize.width * self.parent.anchorPoint.x, self.parent.contentSize.height * self.parent.anchorPoint.y));
    
    ccDrawColor4B(255, 0, 0, 150);
    ccDrawRect(CGPointZero, ccp(self.parent.contentSize.width, self.parent.contentSize.height));
}

@end

#endif

@interface FGUIElement ()
{
    FGUIElement *activeChild;
    
@public
    kmMat3 translateMatrix;
    kmMat3 scaleMatrix;
    kmMat3 rotateMatrix;
}

+ (id)elementWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (BOOL)_touchBegan:(CGPoint)localPosition;
- (void)_touchMoved:(CGPoint)localPosition;
- (void)_touchEnded:(CGPoint)localPosition;
- (BOOL)_isInside:(CGPoint)position;
- (void)_update;

@property (readwrite, assign, nonatomic) FGUIElement * fguiParent;

@end

@interface FGUILayer ()
- (void)_setName:(NSString *)aName;
- (void)_setRoot:(FGUIRoot *)aRoot;
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

@synthesize name, delegate, fguiParent;

- (id)init
{
    if ((self = [super init]))
	{
        root        = nil;
        name        = nil;
        fguiParent  = nil;
        
        childTable  = [[NSMutableDictionary alloc] init];
        activeChild = nil;
        
        kmMat3Identity(&translateMatrix);
        kmMat3Identity(&scaleMatrix);
        kmMat3Identity(&rotateMatrix);
	}
	
	return self;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent
{
	if ((self = [self init]))
	{
        assert(aRoot);
        
        root        = aRoot;
        name        = [aName copy];
        fguiParent  = aParent;
	}
	
	return self;
}

- (void)dealloc
{
    [childTable release];
    [name release];
	[super dealloc];
}

- (void)onEnter
{
    [super onEnter];
    
#if FGUI_DEBUG
    FGUIBoundingBoxNode *box = [FGUIBoundingBoxNode node];
    [self addChild:box z:FGUI_BBNODE_Z tag:FGUI_BBNODE_TAG];
#endif
}

- (void)onExit
{
#if FGUI_DEBUG
    [self removeChildByTag:FGUI_BBNODE_TAG cleanup:YES];
#endif
    
    [super onExit];
}

- (void)setScale:(float)scale
{
    [super setScale:scale];
    scaleMatrix.mat[0] = scale;
    scaleMatrix.mat[4] = scale;
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    scaleMatrix.mat[0] = scaleX;
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    scaleMatrix.mat[4] = scaleY;
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    translateMatrix.mat[6] = position.x;
    translateMatrix.mat[7] = position.y;
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setRotation:(float)rotation
{
    [super setRotation:rotation];
    rotateMatrix.mat[0] = cosf(rotation);
    rotateMatrix.mat[1] = -sinf(rotation);
    rotateMatrix.mat[3] = sinf(rotation);
    rotateMatrix.mat[4] = cosf(rotation);
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (FGUINode *)createNodeWithName:(NSString *)aName zOrder:(int)zOrder
{
    assert(aName);
    assert(zOrder >= 0);
    assert(childTable[aName] == nil);
    
    FGUINode *node = [FGUINode elementWithRoot:root andName:aName andParent:self];
    [self addChild:node z:zOrder];
    childTable[aName] = node;
    node.fguiParent = self;
    
    return node;
}

- (void)destroyNode:(FGUINode *)aNode
{
    assert(childTable[aNode.name]);
    assert(childTable[aNode.name] == aNode);
    assert([aNode isKindOfClass:FGUINode.class]);
    assert([self.children containsObject:aNode]);
    
    [aNode removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aNode.name];
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
    return CGRectContainsPoint(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), [self convertToNodeSpace:position]);
}

- (BOOL)_touchBegan:(CGPoint)localPosition
{
    activeChild = nil;
    
    if ([self touchBegan:localPosition])
    {
        for (FGUIElement *aChild in [childTable allValues])
        {
            if ([aChild _touchBegan:localPosition])
            {
                activeChild = aChild;
                break;
            }
        }
        
        return childTable.count == 0 || activeChild != nil;
    }
    
    return NO;
}

- (void)_touchMoved:(CGPoint)localPosition
{
    [self touchMoved:localPosition];
    [activeChild _touchMoved:localPosition];
}

- (void)_touchEnded:(CGPoint)localPosition
{
    [self touchEnded:localPosition];
    [activeChild _touchEnded:localPosition];
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

- (kmMat3)transformationMatrix
{
    kmMat3 transformationMatrix;
    
    kmMat3 actualTranslateMatrix = translateMatrix;
    
    // Adjust anchor point
    if (!CGPointEqualToPoint(self.anchorPointInPoints, CGPointZero))
    {
        actualTranslateMatrix.mat[6] -= self.anchorPointInPoints.x;
        actualTranslateMatrix.mat[7] -= self.anchorPointInPoints.y;
    }
    
    kmMat3Multiply(&transformationMatrix, &actualTranslateMatrix, &rotateMatrix);
    kmMat3Multiply(&transformationMatrix, &transformationMatrix, &scaleMatrix);
    
    if (fguiParent != nil)
    {
        kmMat3 parentMatrix = [fguiParent transformationMatrix];
        kmMat3Multiply(&transformationMatrix, &transformationMatrix, &parentMatrix);
    }
    
    return transformationMatrix;
}

- (CGPoint)worldPosition
{
    kmVec2 p;
    p.x = self.position.x;
    p.y = self.position.y;
    
    if (self.ignoreAnchorPointForPosition)
    {
        p.x += self.anchorPointInPoints.x;
        p.y += self.anchorPointInPoints.y;
    }
    
    if (fguiParent)
    {
        kmMat3 m = [fguiParent transformationMatrix];
        kmVec2Transform(&p, &p, &m);
    }
    
    return ccp(p.x, p.y);
}

- (float)worldRotation
{
    float worldRotation = self.rotation;
    
    if (fguiParent)
    {
        worldRotation += [fguiParent worldRotation];
    }
    
    return worldRotation;
}

- (CGPoint)worldScale
{
    CGPoint worldScale = ccp(self.scaleX, self.scaleY);
    
    if (fguiParent)
    {
        CGPoint parentScale = [fguiParent worldScale];
        worldScale = ccp(worldScale.x * parentScale.x, worldScale.y * parentScale.y);
    }

    return worldScale;
}

- (void)_update
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

- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName zOrder:(int)zOrder
{
    assert(aLayer);
    assert(aLayer.fguiParent == nil);
    assert(![layerTable containsValue:aLayer]);
    assert(aName);
    assert(zOrder >= 0);
    assert(layerTable[aName] == nil);
    
    [aLayer _setRoot:self];
    [aLayer _setName:aName];
    [self addChild:aLayer z:zOrder];
    layerTable[aName] = aLayer;
    [aLayer setup];
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
        if ([aLayer _isInside:touchPosition] && [aLayer _touchBegan:touchPosition])
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
    if ([activeLayer _isInside:touchPosition])
    {
        [activeLayer _touchMoved:touchPosition];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    [activeLayer _touchEnded:touchPosition];
    activeLayer = nil;
}

@end

@implementation FGUINode

- (BOOL)touchBegan:(CGPoint)localPosition
{
    return NO;
}

@end

@implementation FGUILayer

- (id)init
{
    if ((self = [super init]))
	{
        self.contentSize = [[CCDirector sharedDirector] winSize];
	}
	
	return self;
}

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

- (void)setup
{
    
}

- (void)_setName:(NSString *)aName
{
    assert(aName);
    [name release];
    name = [aName copy];
}

- (void)_setRoot:(FGUIRoot *)aRoot
{
    assert(aRoot);
    root = aRoot;
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
    sprite.position = [self worldPosition];
    sprite.rotation = [self worldRotation];
    
    CGPoint scale = [self worldScale];
    sprite.scaleX = scale.x;
    sprite.scaleY = scale.y;
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
        self.scale          = 1.0f;
	}
	
	return self;
}

- (void)dealloc
{
    [sprite release];
	[super dealloc];
}

- (void)_update
{
    sprite.position = [self worldPosition];
    sprite.rotation = [self worldRotation];
    
    CGPoint scale = [self worldScale];
    sprite.scaleX = scale.x;
    sprite.scaleY = scale.y;
}

- (BOOL)touchBegan:(CGPoint)localPosition
{
    return NO;
}

@end

@implementation FGUILabel

+ (id)labelWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andFile:aFile] autorelease];
}

@dynamic string;

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    [super setAnchorPoint:anchorPoint];
    label.anchorPoint = anchorPoint;
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

- (void)_update
{
    label.position = [self worldPosition];
    label.rotation = [self worldRotation];
    
    CGPoint scale = [self worldScale];
    label.scaleX = scale.x;
    label.scaleY = scale.y;
}

- (BOOL)touchBegan:(CGPoint)localPosition
{
    return NO;
}

@end
