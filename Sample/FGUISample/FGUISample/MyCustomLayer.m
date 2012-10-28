//
//  MyCustomLayer.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "MyCustomLayer.h"

@interface MyCustomLayer ()
- (void)onButtonPressed;
- (void)onButtonReleased;
@end

@implementation MyCustomLayer

- (void)setup
{
    FGUISprite *sprite = [FGUISprite spriteWithSpriteFrame:CC_SPRITEFRAME(@"Sprite.png")];
    sprite.position = ccp(300, 300);
    [self addElement:sprite name:@"Sprite"];
    
    [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360]]];
    
    FGUIButton *button = [FGUIButton buttonWithSpriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")]];
    button.anchorPoint = ccp(0.5f, 0);
    button.position = ccp(50, 50);
    [sprite addElement:button name:@"Button1" zOrder:10];
    
    [button setOnPressWithSelector:@selector(onButtonPressed) andTarget:self];
    [button setOnReleaseWithSelector:@selector(onButtonReleased) andTarget:self];
    
    [button runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360]]];
    
    FGUIButton *button2 = [FGUIButton buttonWithSpriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")]];
    button2.anchorPoint = ccp(0.5f, 0.5f);
    button2.position = ccp(250, 50);
    button2.isEnabled = NO;
    [sprite addElement:button2 name:@"Button2" zOrder:1];
    
    [button2 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360]]];
    [button2 runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:1.0f scale:1.5f] two:[CCScaleTo actionWithDuration:1.0f scale:1.0f]]]];
    
    FGUIButton *button3 = [FGUIButton buttonWithSpriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")]];
    button3.anchorPoint = ccp(0.5f, 0);
    button3.position = ccp(600, 100);
    [self addElement:button3 name:@"Button1"];
    
    button3.onPressBlock = ^
    {
        CCLOG(@"(BLOCK) Pressed!");
    };
    
    button3.onReleaseBlock = ^
    {
        CCLOG(@"(BLOCK) Released!");
        [self removeFromFGUIParentAndCleanup:YES];
    };
}

- (void)onButtonPressed
{
    CCLOG(@"(SEL) Pressed!");
}

- (void)onButtonReleased
{
    CCLOG(@"(SEL) Released!");
}

@end
