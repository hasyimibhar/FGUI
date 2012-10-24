//
//  FGUI.h
//  CocosHUDFramework
//
//  Created by Hasyimi Bahrudin on 10/5/12.
//
//

#import "cocos2d.h"

@class FGUIRoot;
@class FGUILayer;
@class FGUISprite;
@class FGUIButton;
@class FGUIElement;

@protocol FGUIElementDelegate
- (void)guiElementTouchBegan:(FGUIElement *)aElement;
- (void)guiElementTouchMoved:(FGUIElement *)aElement;
- (void)guiElementTouchEnded:(FGUIElement *)aElement;
@end

@interface FGUIElement : CCNode
{
    FGUIRoot    *root;
    FGUIElement *parent;
    NSString    *name;
    
    NSMutableDictionary *childTable;
}

- (FGUILayer *)createLayerWithName:(NSString *)aName zOrder:(int)zOrder;
- (void)destroyLayer:(FGUILayer *)aLayer;

- (FGUIButton *)createButtonWithName:(NSString *)aName spriteFrameArray:(NSArray *)aSpriteFrameArray zOrder:(int)zOrder;
- (void)destroyButton:(FGUIButton *)aButton;

- (FGUISprite *)createSpriteWithName:(NSString *)aName spriteFrame:(CCSpriteFrame *)aSpriteFrame zOrder:(int)zOrder;
- (void)destroySprite:(FGUISprite *)aSprite;

- (BOOL)touchBegan:(CGPoint)localPosition;
- (void)touchMoved:(CGPoint)localPosition;
- (void)touchEnded:(CGPoint)localPosition;

- (CGPoint)worldPosition;
- (CGPoint)convertToLocalPosition:(CGPoint)aPosition;

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
- (void)destroyLayer:(FGUILayer *)aLayer;
- (void)destroyLayerWithName:(NSString *)aLayerName;

@end

@interface FGUILayer : FGUIElement

@end

@interface FGUIButton : FGUIElement
{
    CCSpriteFrame *normalSpriteFrame;
    CCSpriteFrame *selectedSpriteFrame;
    CCSpriteFrame *disabledSpriteFrame;
    BOOL isEnabled;
}

- (void)setSpriteFramesWithArray:(NSArray *)aSpriteFrameArray;

@property (readwrite, assign, nonatomic) CCSpriteFrame * normalSpriteFrame;
@property (readwrite, assign, nonatomic) CCSpriteFrame * selectedSpriteFrame;
@property (readwrite, assign, nonatomic) CCSpriteFrame * disabledSpriteFrame;
@property (readwrite, assign) BOOL isEnabled;

@end

@interface FGUISprite : FGUIElement
{
    CCSpriteFrame *spriteFrame;
}

@property (readwrite, assign, nonatomic) CCSpriteFrame * spriteFrame;

@end