//
//  FGUIElement+Private.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIElement.h"

@interface FGUIElement ()

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