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

void SortChildrenZOrder(id<NSObject> object)
{
    assert(object);
    assert([object isMemberOfClass:FGUIRoot.class] || [object isKindOfClass:FGUIElement.class]);
    
    NSMutableArray *childArray = [object performSelector:@selector(childArray)];
    [childArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         FGUIElement *e1 = (FGUIElement *)obj1;
         FGUIElement *e2 = (FGUIElement *)obj2;
         
         if (e1.zOrder < e2.zOrder)
         {
             return NSOrderedAscending;
         }
         else if (e1.zOrder > e2.zOrder)
         {
             return NSOrderedDescending;
         }
         
         return NSOrderedSame;
     }];
}

#ifdef FGUI_DEBUG

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
    BOOL        isArrayDirty;
}

+ (id)elementWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent;

- (void)_addElement:(FGUIElement *)aElement withName:(NSString *)aName zOrder:(NSInteger)aZOrder;

- (BOOL)_touchBegan:(CGPoint)localPosition;
- (void)_touchMoved:(CGPoint)localPosition;
- (void)_touchEnded:(CGPoint)localPosition;
- (BOOL)_isInside:(CGPoint)position;
- (void)_update;
- (NSInteger)_updateChildrenZOrder:(NSInteger)z;
- (NSInteger)_updateZOrder:(NSInteger)z;

- (CGAffineTransform)_worldTranform;

@property (readonly, assign, nonatomic) NSMutableArray * childArray;

@end

@interface FGUILayer ()
- (void)_setName:(NSString *)aName;
- (void)_setRoot:(FGUIRoot *)aRoot;
- (void)_setParent:(FGUIElement *)aParent;
@end

@interface FGUIRoot ()
{
    FGUILayer   *activeLayer;
    
@public
    BOOL        isArrayDirty;
}

- (void)_addElement:(FGUIElement *)aElement withName:(NSString *)aName zOrder:(NSInteger)aZOrder;

@property (readonly, assign, nonatomic) NSMutableArray * childArray;

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
@synthesize childArray = childArray;

- (NSInteger)zOrder
{
    return fguiZOrder;
}

- (void)setZOrder:(NSInteger)aZOrder
{
    if (aZOrder != fguiZOrder)
    {
        fguiZOrder = aZOrder;
        
        if (fguiParent)
        {
            fguiParent->isArrayDirty = YES;
        }
    
        root->isArrayDirty = YES;
    }
}

- (id)init
{
    if ((self = [super init]))
	{
        root        = nil;
        name        = nil;
        fguiParent  = nil;
        fguiZOrder  = 0;
        
        childTable  = [[NSMutableDictionary alloc] init];
        childArray  = [[NSMutableArray alloc] init];
        activeChild = nil;
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
    [childArray release];
    [childTable release];
    [name release];
	[super dealloc];
}

- (void)onEnter
{
    [super onEnter];
    
#ifdef FGUI_DEBUG
    FGUIBoundingBoxNode *box = [FGUIBoundingBoxNode node];
    [self addChild:box z:FGUI_BBNODE_Z tag:FGUI_BBNODE_TAG];
#endif
}

- (void)onExit
{
#ifdef FGUI_DEBUG
    [self removeChildByTag:FGUI_BBNODE_TAG cleanup:YES];
#endif
    
    [super onExit];
}

- (void)setScale:(float)scale
{
    [super setScale:scale];
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (void)setRotation:(float)rotation
{
    [super setRotation:rotation];
    [self _update];
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        [aChild _update];
    }
}

- (FGUINode *)createNodeWithName:(NSString *)aName
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createNodeWithName:aName zOrder:lastZ + 1];
}

- (FGUINode *)createNodeWithName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    FGUINode *node = [FGUINode elementWithRoot:root andName:aName andParent:self];
    [self _addElement:node withName:aName zOrder:aZOrder];
    return node;
}

- (FGUILayer *)createLayerWithName:(NSString *)aName
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createLayerWithName:aName zOrder:lastZ + 1];
}

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    FGUILayer *layer = [FGUILayer elementWithRoot:root andName:aName andParent:self];
    [self _addElement:layer withName:aName zOrder:aZOrder];
    return layer;
}

- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    [self addLayer:aLayer withName:aName zOrder:lastZ + 1];
}

- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    assert(aLayer);
    assert(aLayer.fguiParent == nil);
    assert(![childArray containsObject:aLayer]);
    assert(![childTable containsValue:aLayer]);
    
    [aLayer _setRoot:root];
    [aLayer _setName:aName];
    [aLayer _setParent:self];
    [self _addElement:aLayer withName:aName zOrder:aZOrder];
    
    [aLayer setup];
}

- (FGUIButton *)createButtonWithName:(NSString *)aName spriteFrameArray:(NSArray *)aSpriteFrameArray
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createButtonWithName:aName spriteFrameArray:aSpriteFrameArray zOrder:lastZ + 1];
}

- (FGUIButton *)createButtonWithName:(NSString *)aName spriteFrameArray:(NSArray *)aSpriteFrameArray zOrder:(NSInteger)aZOrder
{
    FGUIButton *button = [FGUIButton buttonWithRoot:root andName:aName andParent:self andSpriteFrameArray:aSpriteFrameArray];
    [self _addElement:button withName:aName zOrder:aZOrder];
    return button;
}

- (FGUISprite *)createSpriteWithName:(NSString *)aName spriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createSpriteWithName:aName spriteFrame:aSpriteFrame zOrder:lastZ + 1];
}

- (FGUISprite *)createSpriteWithName:(NSString *)aName spriteFrame:(CCSpriteFrame *)aSpriteFrame zOrder:(NSInteger)aZOrder
{
    FGUISprite *sprite = [FGUISprite spriteWithRoot:root andName:aName andParent:self andSpriteFrame:aSpriteFrame];
    [self _addElement:sprite withName:aName zOrder:aZOrder];
    return sprite;
}

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createLabelWithName:aName string:aString fontFile:aFontFile zOrder:lastZ + 1];
}

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile zOrder:(NSInteger)aZOrder
{
    return [self createLabelWithName:aName string:aString fontFile:aFontFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentCenter zOrder:aZOrder];
}

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    return [self createLabelWithName:aName string:aString fontFile:aFontFile width:aWidth alignment:aAlignment zOrder:lastZ + 1];
}

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment zOrder:(NSInteger)aZOrder
{
    FGUILabel *label = [FGUILabel labelWithRoot:root andName:aName andParent:self andFile:aFontFile];
    label.string = aString;
    label.width = aWidth;
    label.alignment = aAlignment;
    
    [self _addElement:label withName:aName zOrder:aZOrder];
    return label;
}

- (void)destroyElement:(FGUIElement *)aElement
{
    assert(aElement);
    assert([childArray containsObject:aElement]);
    assert(childTable[aElement.name]);
    assert(childTable[aElement.name] == aElement);
    assert([self.children containsObject:aElement]);
    
    [aElement removeFromParentAndCleanup:YES];
    [childTable removeObjectForKey:aElement.name];
    [childArray removeObject:aElement];
}

- (void)_addElement:(FGUIElement *)aElement withName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    assert(aElement);
    assert(aName);
    assert(childTable[aName] == nil);
    
    aElement.zOrder = aZOrder;
    [self addChild:aElement];
    [childArray addObject:aElement];
    childTable[aName] = aElement;
}

- (BOOL)_isInside:(CGPoint)position
{
    return CGRectContainsPoint(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), [self convertToNodeSpace:position]);
}

- (BOOL)_touchBegan:(CGPoint)localPosition
{
    activeChild = nil;
    BOOL isTouchSwallowed = NO;
    
    for (FGUIElement *aChild in [childTable allValues])
    {
        if ([aChild _touchBegan:localPosition])
        {
            activeChild = aChild;
            isTouchSwallowed = YES;
            break;
        }
    }
    
    if (activeChild == nil)
    {
        isTouchSwallowed = [self touchBegan:localPosition];
    }
    
    return isTouchSwallowed;
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
    return NO;
}

- (void)touchMoved:(CGPoint)localPosition
{
    
}

- (void)touchEnded:(CGPoint)localPosition
{
    
}

- (CGAffineTransform)_worldTranform
{
    CGAffineTransform t = [self nodeToParentTransform];
    
	for (FGUIElement *p = self.fguiParent; p != nil; p = p.fguiParent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    
	return t;
}

- (CGPoint)worldPosition
{
    return CGPointApplyAffineTransform(self.position, [self.fguiParent _worldTranform]);
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

- (NSInteger)_updateChildrenZOrder:(NSInteger)z
{
    z = [self _updateZOrder:z];
    
    for (FGUIElement *aChild in childArray)
    {
        z = [aChild _updateChildrenZOrder:z];
    }
    
    return z;
}

- (NSInteger)_updateZOrder:(NSInteger)z
{
    return z;
}

- (void)visit
{
    if (isArrayDirty)
    {
        SortChildrenZOrder(self);
        isArrayDirty = NO;
    }
    
    [super visit];
}

@end

@implementation FGUIRoot

@synthesize batchNode;
@synthesize childArray = layerArray;

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
        layerArray      = [[NSMutableArray alloc] init];
        isArrayDirty    = YES;
	}
	
	return self;
}

- (void)dealloc
{
    [layerArray release];
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

- (FGUILayer *)createLayerWithName:(NSString *)aName
{
    NSInteger lastZ = [[layerArray lastObject] zOrder];
    return [self createLayerWithName:aName zOrder:lastZ + 1];
}

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    FGUILayer *layer = [FGUILayer elementWithRoot:self andName:aName andParent:nil];
    [self _addElement:layer withName:aName zOrder:aZOrder];
    
    return layer;
}

- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName
{
    NSInteger lastZ = [[layerArray lastObject] zOrder];
    return [self addLayer:aLayer withName:aName zOrder:lastZ + 1];
}

- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    assert(aLayer);
    assert(aLayer.fguiParent == nil);
    assert(![layerArray containsObject:aLayer]);
    assert(![layerTable containsValue:aLayer]);
    
    [aLayer _setRoot:self];
    [aLayer _setName:aName];
    [self _addElement:aLayer withName:aName zOrder:aZOrder];
    
    [aLayer setup];
}

- (void)destroyLayer:(FGUILayer *)aLayer
{
    assert(aLayer);
    assert(layerTable[aLayer.name]);
    assert([layerArray containsObject:aLayer]);
    assert(layerTable[aLayer.name] == aLayer);
    assert([aLayer isKindOfClass:FGUILayer.class]);
    assert([self.children containsObject:aLayer]);
    
    [aLayer removeFromParentAndCleanup:YES];
    [layerTable removeObjectForKey:aLayer.name];
    [layerArray removeObject:aLayer];
}

- (void)destroyLayerWithName:(NSString *)aLayerName
{
    [self destroyLayer:layerTable[aLayerName]];
}

- (void)_addElement:(FGUIElement *)aElement withName:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    assert(aElement);
    assert(aName);
    assert(layerTable[aName] == nil);
    
    aElement.zOrder = aZOrder;
    [self addChild:aElement];
    [layerArray addObject:aElement];
    layerTable[aName] = aElement;
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

- (void)visit
{
    if (isArrayDirty)
    {
        SortChildrenZOrder(self);
    }
    
    [super visit];
    
    if (isArrayDirty)
    {
        isArrayDirty = NO;
        
        NSInteger z = 0;
        for (FGUIElement *aChild in layerArray)
        {
            z = [aChild _updateChildrenZOrder:z];
        }
    }
}

@end

@implementation FGUINode


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

- (void)_setParent:(FGUIElement *)aParent
{
    assert(aParent);
    fguiParent = aParent;
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

- (void)onEnter
{
    [super onEnter];
    [root.batchNode addChild:sprite z:zOrder_];
}

- (void)onExit
{
    [sprite removeFromParentAndCleanup:YES];
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

@implementation FGUISprite

+ (id)spriteWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andSpriteFrame:(CCSpriteFrame *)aSpriteFrame
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andSpriteFrame:aSpriteFrame] autorelease];
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

- (void)onEnter
{
    [super onEnter];
    [root.batchNode addChild:sprite z:zOrder_];
}

- (void)onExit
{
    [sprite removeFromParentAndCleanup:YES];
    [super onExit];
}

- (void)_update
{
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

@implementation FGUILabel

+ (id)labelWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile
{
    return [[[self alloc] initWithRoot:aRoot andName:aName andParent:aParent andFile:aFile] autorelease];
}

@dynamic string, width, alignment;

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
    self.contentSize = label.contentSize;
}

- (float)width
{
    return label.width;
}

- (void)setWidth:(float)width
{
    label.width = width;
}

- (CCTextAlignment)alignment
{
    return label.alignment;
}

- (void)setAlignment:(CCTextAlignment)alignment
{
    label.alignment = alignment;
}

- (id)initWithRoot:(FGUIRoot *)aRoot andName:(NSString *)aName andParent:(FGUIElement *)aParent andFile:(NSString *)aFile
{
    if ((self = [super initWithRoot:aRoot andName:aName andParent:aParent]))
	{
        label               = [[CCLabelBNFont alloc] initWithString:@"" fntFile:aFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentCenter];
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

- (void)onEnter
{
    [super onEnter];
    [root.batchNode addChild:label z:zOrder_];
}

- (void)onExit
{
    [label removeFromParentAndCleanup:YES];
    [super onExit];
}

- (void)_update
{
    label.position = [self worldPosition];
    label.rotation = [self worldRotation];
    
    CGPoint scale = [self worldScale];
    label.scaleX = scale.x;
    label.scaleY = scale.y;
}

- (NSInteger)_updateZOrder:(NSInteger)z
{
    [root.batchNode reorderChild:label z:z++];
    return z;
}

@end
