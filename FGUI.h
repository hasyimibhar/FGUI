//
//  FGUI.h
//  CocosHUDFramework
//
//  Created by Hasyimi Bahrudin on 10/5/12.
//
//

#import "cocos2d.h"

@interface NSDictionary (ValueSearch)
// Helper method for searching a value inside a dictionary
- (BOOL)containsValue:(id<NSObject>)value;
@end

#ifdef FGUI_DEBUG

// For debugging purpose

#define FGUI_BBNODE_Z       (100000)
#define FGUI_BBNODE_TAG     (0xBADF00D)

@interface FGUIBoundingBoxNode : CCSprite

@end

#endif

@class FGUIRoot;
@class FGUINode;
@class FGUILayer;
@class FGUISprite;
@class FGUIButton;
@class FGUILabel;
@class FGUIElement;

typedef void(^VoidBlock)(void);

@protocol FGUIElementDelegate
- (void)guiElementTouchBegan:(FGUIElement *)aElement;
- (void)guiElementTouchMoved:(FGUIElement *)aElement;
- (void)guiElementTouchEnded:(FGUIElement *)aElement;
@end

@interface FGUIElement : CCNode
{
    FGUIRoot    *root;
    FGUIElement *fguiParent;
    NSString    *name;
    
    NSMutableDictionary *childTable;
}

- (FGUINode *)createNodeWithName:(NSString *)aName zOrder:(int)zOrder;
- (void)destroyNode:(FGUINode *)aNode;

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(int)zOrder;
- (void)destroyLayer:(FGUILayer *)aLayer;

- (FGUIButton *)createButtonWithName:(NSString *)aName spriteFrameArray:(NSArray *)aSpriteFrameArray zOrder:(int)zOrder;
- (void)destroyButton:(FGUIButton *)aButton;

- (FGUISprite *)createSpriteWithName:(NSString *)aName spriteFrame:(CCSpriteFrame *)aSpriteFrame zOrder:(int)zOrder;
- (void)destroySprite:(FGUISprite *)aSprite;

- (FGUILabel *)createLabelWithName:(NSString *)aName string:(NSString *)aString fontFile:(NSString *)aFontFile zOrder:(int)zOrder;
- (void)destroyLabel:(FGUILabel *)aLabel;

- (BOOL)touchBegan:(CGPoint)localPosition;
- (void)touchMoved:(CGPoint)localPosition;
- (void)touchEnded:(CGPoint)localPosition;

- (CGPoint)worldPosition;
- (float)worldRotation;
- (CGPoint)worldScale;

@property (readonly, assign, nonatomic) NSString * name;
@property (readwrite, assign, nonatomic) id<FGUIElementDelegate> delegate;

@end

@interface FGUIRoot : CCNode<CCTargetedTouchDelegate>
{
    CCSpriteBatchNode *batchNode;
    NSMutableDictionary *layerTable;
}

+ (id)guiWithFile:(NSString *)aFile;

- (id)initWithFile:(NSString *)aFile;

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(int)zOrder;
- (void)addLayer:(FGUILayer *)aLayer withName:(NSString *)aName zOrder:(int)zOrder;

- (void)destroyLayer:(FGUILayer *)aLayer;
- (void)destroyLayerWithName:(NSString *)aLayerName;

@property (readonly, assign, nonatomic) CCSpriteBatchNode * batchNode;

@end

@interface FGUINode : FGUIElement

@end

@interface FGUILayer : FGUIElement
- (void)setup;
@end

@interface FGUIButton : FGUIElement
{
    CCSpriteFrame *normalSpriteFrame;
    CCSpriteFrame *selectedSpriteFrame;
    CCSpriteFrame *disabledSpriteFrame;
    BOOL isEnabled;
    
    SEL onPressSelector;
    id onPressTarget;
    
    SEL onReleaseSelector;
    id onReleaseTarget;
    
    VoidBlock onPressBlock;
    VoidBlock onReleaseBlock;
}

- (void)setSpriteFramesWithArray:(NSArray *)aSpriteFrameArray;
- (void)setOnPressWithSelector:(SEL)aSelector andTarget:(id)aTarget;
- (void)setOnReleaseWithSelector:(SEL)aSelector andTarget:(id)aTarget;

@property (readwrite, assign, nonatomic) CCSpriteFrame * normalSpriteFrame;
@property (readwrite, assign, nonatomic) CCSpriteFrame * selectedSpriteFrame;
@property (readwrite, assign, nonatomic) CCSpriteFrame * disabledSpriteFrame;
@property (readwrite, assign) BOOL isEnabled;

@property (readwrite, copy, nonatomic) VoidBlock onPressBlock;
@property (readwrite, copy, nonatomic) VoidBlock onReleaseBlock;

@end

@interface FGUISprite : FGUIElement
{
    CCSpriteFrame *spriteFrame;
}

@property (readwrite, assign, nonatomic) CCSpriteFrame * spriteFrame;

@end

@interface FGUILabel : FGUIElement

@property (readwrite, copy, nonatomic) NSString * string;

@end