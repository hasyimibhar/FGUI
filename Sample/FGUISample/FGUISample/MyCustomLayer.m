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
    button.position = ccp(200, 200);
    
    FGUIButton *button2 = [self createButtonWithName:@"Button2" spriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")] zOrder:1];
    button2.anchorPoint = ccp(0.5f, 0);
    button2.position = ccp(500, 200);
    button2.isEnabled = NO;
}

@end
