//
//  FGUISprite.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/29/12.
//
//

#import "FGUIElement.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"

@interface FGUISprite : FGUIElement
{
    CCSprite        *sprite;
    CCSpriteFrame   *spriteFrame;
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)aSpriteFrame;

- (id)initWithSpriteFrame:(CCSpriteFrame *)aSpriteFrame;

@property (readwrite, assign, nonatomic) CCSpriteFrame * spriteFrame;
@property (readwrite, nonatomic) ccColor3B color;
@property (readwrite, nonatomic) GLubyte opacity;

@end
