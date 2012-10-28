//
//  FGUIElement.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/28/12.
//
//

#import "FGUIElement.h"
#import "FGUIRoot.h"
#import "CCLabelBNFont.h"
#import "FGUIElement_Private.h"
#import "FGUIHelpers.h"
#import "CGPointExtension.h"

@implementation FGUIElement

#pragma mark Class methods
#pragma mark -

+ (id)element
{
    return [[[self alloc] init] autorelease];
}

#pragma mark Public methods
#pragma mark -

@synthesize name, fguiParent;

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
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%@) Name = %@, Z = %d", NSStringFromClass(self.class), name, fguiZOrder];
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

//- (void)setAnchorPoint:(CGPoint)anchorPoint
//{
//    [super setAnchorPoint:anchorPoint];
//    [self _update];
//    
//    for (FGUIElement *aChild in [childTable allValues])
//    {
//        [aChild _update];
//    }
//}
//
//- (void)setContentSize:(CGSize)contentSize
//{
//    [super setContentSize:contentSize];
//    [self _update];
//    
//    for (FGUIElement *aChild in [childTable allValues])
//    {
//        [aChild _update];
//    }
//}

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

- (void)addElement:(FGUIElement *)aElement name:(NSString *)aName
{
    NSInteger lastZ = [[childArray lastObject] zOrder];
    [self addElement:aElement name:aName zOrder:lastZ + 1];
}

- (void)addElement:(FGUIElement *)aElement name:(NSString *)aName zOrder:(NSInteger)aZOrder
{
    assert(aElement);
    assert(aElement->fguiParent == nil);
    assert(aElement.parent == nil);
    assert(aElement->name == nil);
    assert(aName);
    assert(![childArray containsObject:aElement]);
    assert(![self.children containsObject:aElement]);
    assert(![childTable containsValue:aElement]);
    assert(childTable[aName] == nil);
    
    aElement->root = root;
    aElement->fguiParent = self;
    aElement->name = [aName copy];
    aElement.zOrder = aZOrder;
    
    [self addChild:aElement];
    [childArray addObject:aElement];
    childTable[aName] = aElement;

    [aElement _update];
    [aElement setup];
}

- (void)removeElement:(FGUIElement *)aElement shouldCleanup:(BOOL)shouldCleanup
{
    assert(aElement);
    assert(aElement.fguiParent == self);
    assert(aElement.parent == self);
    assert([childArray containsObject:aElement]);
    assert(childTable[aElement.name]);
    assert(childTable[aElement.name] == aElement);
    assert([self.children containsObject:aElement]);
    
    [aElement removeFromParentAndCleanup:shouldCleanup];
    [childTable removeObjectForKey:aElement.name];
    [childArray removeObject:aElement];
    
    if (!shouldCleanup)
    {
        [aElement->name release];
        aElement->name = nil;
    }
}

- (void)removeFromFGUIParentAndCleanup:(BOOL)shouldCleanup
{
    [fguiParent ? fguiParent : root removeElement:self shouldCleanup:shouldCleanup];
}

- (void)setup
{
    
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


- (CGPoint)worldPosition
{
    return CGPointApplyAffineTransform(self.position, fguiParent ? [fguiParent _worldTranform] : CGAffineTransformIdentity);
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

- (void)visit
{
    if (isArrayDirty)
    {
        SortChildrenZOrder(self);
        isArrayDirty = NO;
    }
    
    [super visit];
}

#pragma mark Private methods
#pragma mark -

@synthesize childArray;

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

- (CGAffineTransform)_worldTranform
{
    CGAffineTransform t = [self nodeToParentTransform];
    
	for (FGUIElement *p = self.fguiParent; p != nil; p = p.fguiParent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    
	return t;
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

@end