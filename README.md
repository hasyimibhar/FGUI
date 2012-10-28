# FGUI

### Overview
A one batch-count solution for GUI creation for [cocos2d](http://www.cocos2d-iphone.org/), inspired by betajaen's [Gorilla](https://github.com/betajaen/gorilla) framework for [Ogre](http://ogre3d.org/).

**Special thanks to mikezang for his [CCLabelBNFont](http://www.cocos2d-iphone.org/forum/topic/20171/page/2)!**



###TO DO
- OSX support
- ~~Proper transformation using matrices (currently only supports positioning and scaling)~~



###Usage

FGUI uses the familiar scene-graph style of structuring elements in cocos2d.

	// Initialize the root
	FGUIRoot *root = [[FGUI alloc] initWithFile:@"Spritesheet.png"];
	[self addChild:root];
	
	// Create layer
	FGUILayer *layer = [root createLayerWithName:@"Layer1" zOrder:0];
	
#####FGUILabel
	
	FGUILabel *myLabel = [layer createLabelWithName:@"MyLabel" string:@"Hello, world!" fontFile:@"MyBitmapFont.fnt" zOrder:10];
	
#####FGUISprite
	
	FGUISprite *sprite = [self createSpriteWithName:@"MySprite" spriteFrame:CC_SPRITEFRAME(@"MySprint.png") zOrder:69];
	
#####FGUIButton
	
	FGUIButton *myButton = [layer createButtonWithName:@"Button1" spriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")] zOrder:1];
	
	// Use block for press and release callbacks
	
	myButton.onPressBlock = ^{
		CCLOG(@"Someone pressed me!");
	};
	
	myButton.onReleaseBlock = ^{
		CCLOG(@"Phew");
	};
	
	// Or use the plain old selector
	
	[myButton setOnPressWithSelector:@selector(onPress) andTarget:self];
	[myButton setOnReleaseWithSelector:@selector(onRelease) andTarget:self];
	
#####Actions
FGUI elements are really just subclasses of CCNode. You can run CCAction on them!

	FGUILabel *myLabel = [layer1 createLabelWithName:@"MyLabel" string:@"I'm spinning~" fontFile:@"MyBitmapFont" zOrder:0];
        
    // Spin spin spin!
    [myLabel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:360]]];