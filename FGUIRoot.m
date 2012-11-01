//
//  FGUIRoot.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/28/12.
//
//

#import "FGUIRoot.h"
#import "FGUIElement_Private.h"
#import "FGUIHelpers.h"
#import "CCDirector.h"
#import "CCDirectorIOS.h"
#import "CCTouchDispatcher.h"

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
	}
	
	return self;
}

- (void)dealloc
{
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

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    return [self _touchBegan:touchPosition];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    [self _touchMoved:touchPosition];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    [self _touchEnded:touchPosition];
}

- (void)visit
{
    for (FGUIElement *aChild in childArray)
    {
        if (aChild->isArrayDirty)
        {
            isArrayDirty = YES;
            break;
        }
    }
    
    BOOL shouldUpdateZOrder = isArrayDirty;
    
    [super visit];
    
    if (shouldUpdateZOrder)
    {
        NSInteger z = 0;
        for (FGUIElement *aChild in childArray)
        {
            z = [aChild _updateChildrenZOrder:z];
        }
    }
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
    
    aElement->root = self;
    aElement->name = [aName copy];
    aElement.zOrder = aZOrder;
    
    [self addChild:aElement];
    [childArray addObject:aElement];
    childTable[aName] = aElement;
    
    [aElement _setRoot:self];
    [aElement _update];
    [aElement _onAdd];
}

- (void)removeElement:(FGUIElement *)aElement shouldCleanup:(BOOL)shouldCleanup
{
    assert(aElement);
    assert(aElement.fguiParent == nil);
    assert(aElement.parent == self);
    assert([childArray containsObject:aElement]);
    assert(childTable[aElement.name]);
    assert(childTable[aElement.name] == aElement);
    assert([self.children containsObject:aElement]);
    
    [aElement _onRemove];
    if (shouldCleanup)
    {
        [aElement _destroy];
    }
    
    [aElement removeFromParentAndCleanup:shouldCleanup];
    [childTable removeObjectForKey:aElement.name];
    [childArray removeObject:aElement];
    
    if (!shouldCleanup)
    {
        [aElement->name release];
        aElement->name = nil;
    }
}

- (void)setup
{
    [self doesNotRecognizeSelector:_cmd];
}

- (CGPoint)worldPosition
{
    [self doesNotRecognizeSelector:_cmd];
    return CGPointZero;
}

- (float)worldRotation
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (CGPoint)worldScale
{
    [self doesNotRecognizeSelector:_cmd];
    return CGPointZero;
}

- (void)_onAdd
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_onRemove
{
    [self doesNotRecognizeSelector:_cmd];
}

@end