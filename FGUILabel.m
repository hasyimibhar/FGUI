//
//  FGUILabel.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUILabel.h"
#import "FGUIElement_Private.h"
#import "FGUIRoot.h"
#import "CGPointExtension.h"

@implementation FGUILabel

#pragma mark Class methods
#pragma mark -

+ (id)labelWithString:(NSString *)aString file:(NSString *)aFile
{
    return [[[self alloc] initWithString:aString file:aFile] autorelease];
}

+ (id)labelWithString:(NSString *)aString file:(NSString *)aFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment
{
    return [[[self alloc] initWithString:aString file:aFile width:aWidth alignment:aAlignment] autorelease];
}

#pragma mark Public methods
#pragma mark -

@dynamic string, width, alignment;
@dynamic color, opacity;

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

- (ccColor3B)color
{
    return label.color;
}

- (void)setColor:(ccColor3B)color
{
    label.color = color;
}

- (GLubyte)opacity
{
    return label.opacity;
}

- (void)setOpacity:(GLubyte)opacity
{
    label.opacity = opacity;
}

- (CCArray *)children
{
    return label.children;
}

- (id)initWithString:(NSString *)aString file:(NSString *)aFile
{
    if ((self = [self initWithString:aString file:aFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentCenter]))
	{
	}
	
	return self;
}

- (id)initWithString:(NSString *)aString file:(NSString *)aFile width:(float)aWidth alignment:(CCTextAlignment)aAlignment
{
    if ((self = [super init]))
	{
        label               = [[CCLabelBNFont alloc] initWithString:aString fntFile:aFile width:aWidth alignment:aAlignment];
        assert(label);
        
        self.contentSize    = label.contentSize;
        self.anchorPoint    = ccp(0.5f, 0.5f);
	}
	
	return self;
}

- (void)dealloc
{
    [label release];
    [super dealloc];
}

- (void)_onAdd
{
    [super _onAdd];
    
    [root.batchNode addChild:label z:zOrder_];
//    label.position = CGPointZero;
}

- (void)_onRemove
{
    [label removeFromParentAndCleanup:NO];
    
    [super _onRemove];
}

- (void)_update
{
    [super _update];
    
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