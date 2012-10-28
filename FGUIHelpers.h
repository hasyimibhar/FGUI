//
//  FGUIHelpers.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "CCSprite.h"

@interface NSDictionary (ValueSearch)
- (BOOL)containsValue:(id<NSObject>)value;
@end

#ifdef FGUI_DEBUG

// For debugging purpose

#define FGUI_BBNODE_Z       (100000)
#define FGUI_BBNODE_TAG     (0xBADF00D)

@interface FGUIBoundingBoxNode : CCSprite

@end

#endif

extern void SortChildrenZOrder(id<NSObject> object);