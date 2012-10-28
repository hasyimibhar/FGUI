//
//  FGUIElement.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/28/12.
//
//

#import "CCNode.h"

@class FGUIRoot;

@interface FGUIElement : CCNode
{
    FGUIRoot    *root;
    FGUIElement *fguiParent;
    NSString    *name;
    
    FGUIElement *activeChild;
    
    NSMutableDictionary *childTable;
    NSMutableArray      *childArray;
    BOOL                isArrayDirty;
    
    NSUInteger  fguiZOrder;
}

+ (id)element;

- (void)addElement:(FGUIElement *)aElement name:(NSString *)aName;
- (void)addElement:(FGUIElement *)aElement name:(NSString *)aName zOrder:(NSInteger)aZOrder;
- (void)removeElement:(FGUIElement *)aElement shouldCleanup:(BOOL)shouldCleanup;
- (void)removeFromFGUIParentAndCleanup:(BOOL)shouldCleanup;

- (void)setup;
- (BOOL)touchBegan:(CGPoint)localPosition;
- (void)touchMoved:(CGPoint)localPosition;
- (void)touchEnded:(CGPoint)localPosition;

- (CGPoint)worldPosition;
- (float)worldRotation;
- (CGPoint)worldScale;

@property (readonly, assign, nonatomic) NSString * name;
@property (readonly, assign, nonatomic) FGUIElement * fguiParent;

@end