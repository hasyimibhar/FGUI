//
//  FGUIHelpers.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIHelpers.h"
#import "FGUIElement.h"
#import "FGUIElement_Private.h"

#import "cocos2d.h"

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

void SortChildrenZOrder(FGUIElement *aElement)
{
    assert(aElement);
    
    NSMutableArray *childArray = aElement.childArray;
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