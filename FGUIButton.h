//
//  FGUIButton.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIElement.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"

typedef void(^VoidBlock)(void);

@interface FGUIButton : FGUIElement
{
    CCSprite        *sprite;
    CCSpriteFrame   *normalSpriteFrame;
    CCSpriteFrame   *selectedSpriteFrame;
    CCSpriteFrame   *disabledSpriteFrame;
    BOOL            isEnabled;
    
    SEL             onPressSelector;
    id              onPressTarget;
    
    SEL             onReleaseSelector;
    id              onReleaseTarget;
    
    VoidBlock       onPressBlock;
    VoidBlock       onReleaseBlock;
}

+ (id)buttonWithSpriteFrameArray:(NSArray *)aSpriteFrameArray;

- (id)initWithSpriteFrameArray:(NSArray *)aSpriteFrameArray;

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