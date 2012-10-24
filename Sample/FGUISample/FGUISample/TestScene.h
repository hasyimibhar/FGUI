//
//  TestScene.h
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "cocos2d.h"
#import "FGUI.h"

#define CC_SPRITEFRAME(s)   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:s]

@interface TestScene : CCScene
{
    FGUIRoot *guiRoot;
}

@end
