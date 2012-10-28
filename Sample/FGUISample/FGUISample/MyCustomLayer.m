//
//  MyCustomLayer.m
//  FGUISample
//
//  Created by Hasyimi Bahrudin on 10/24/12.
//
//

#import "MyCustomLayer.h"

@implementation MyCustomLayer

- (void)setup
{
    FGUIButton *button = [self createButtonWithName:@"Button1" spriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")] zOrder:1];
    button.anchorPoint = ccp(0.5f, 0);
    button.position = ccp(50, 50);
    
    [button runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360]]];
    
    FGUIButton *button2 = [self createButtonWithName:@"Button2" spriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")] zOrder:1];
    button2.anchorPoint = ccp(0.5f, 0.5f);
    button2.position = ccp(300, 50);
    button2.isEnabled = NO;
    
    [button2 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360]]];
    [button2 runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:1.0f scale:1.5f] two:[CCScaleTo actionWithDuration:1.0f scale:1.0f]]]];
}

@end
