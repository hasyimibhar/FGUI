# FGUI

### Overview
A one batch-count solution for GUI creation for [cocos2d](http://www.cocos2d-iphone.org/), inspired by betajaen's [Gorilla](https://github.com/betajaen/gorilla) framework for [Ogre](http://ogre3d.org/).

**Special thanks to mikezang for his [CCLabelBNFont](http://www.cocos2d-iphone.org/forum/topic/20171/page/2)!**

###What does FGUI stands for?
$*#%ingGUI of course. No, I'm just kidding. It stands for "Fishcake GUI". Fishcake is my Internet nickname. No, I'm not going to explain why.

###Why FGUI?
As far as I know, generally, it is always good to keep the batch count low. The way to ensure that in cocos2d is by making use of `CCSpriteBatchNode` (one `CCSpriteBatchNode` equals one batch count). However, cocos2d doesn't allow `CCMenuItem` to be added to a `CCSpriteBatchNode`. Which means that if you have 20 buttons on the screen, the batch count will increase by 20! For main menus, options screens, or any other external UI, that's fine. But that's not good for in-game UI (e.g. HUD), because it will affect the framerate of the game.

FGUI solves this problem by not using `CCMenu` and `CCMenuItem` at all. Buttons are simply `CCSprite` that can recieve touch events. It's not hard to do it yourself, but it's a lot of tedious work. So I decided to do the hardwork myself, and share it with everyone.  Hopefully someone will find it useful. :)

###TO DO
- OSX support
- ~~Proper transformation using matrices (currently only supports positioning and scaling)~~
- ~~Proper z-ordering (same convention as cocos2d)~~
- Change the API, replacing all the `create` methods with one `addElement`, so that the user can create their own elements
- Folowing the change above, I will probably need to separate all the classes into individual .m/.h pair (it's starting to confuse me!)
- More documentation (especially on how you can create your own modular GUI groups by subclassing `FGUILayer`)

###Usage

FGUI uses the familiar scene-graph style of structuring elements in cocos2d.

	#import "FGUI.h"

	// Initialize the root
	FGUIRoot *root = [[FGUI alloc] initWithFile:@"Spritesheet.png"];
	[self addChild:root];
	
	// Create layer
	FGUILayer *layer = [root createLayerWithName:@"Layer1" zOrder:0];
	
#####FGUILabel
	
	// Create label as a child of layer
	FGUILabel *myLabel = [layer createLabelWithName:@"MyLabel" string:@"Hello, world!" fontFile:@"MyBitmapFont.fnt" zOrder:10];
	
#####FGUISprite
	
	// Create sprite as a child of layer
	FGUISprite *sprite = [self createSpriteWithName:@"MySprite" spriteFrame:CC_SPRITEFRAME(@"MySprint.png") zOrder:69];
	
#####FGUIButton
	
	// Create myButton as a child of layer
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
FGUI elements are really just subclasses of `CCNode`. You can run `CCAction` on them!

	FGUILabel *myLabel = [layer createLabelWithName:@"MyLabel" string:@"I'm spinning~" fontFile:@"MyBitmapFont" zOrder:0];
        
    // Spin spin spin!
    [myLabel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:360]]];
    
###CCLabelBNFont
`CCLabelBNFont` class comes with the source code. It's a friend of `CCLabelBMFont` (note the one letter difference), which basically allows bitmap fonts to be added as a child of `CCSpriteBatchNode`. Kudos to **mikezang** for writing the class, otherwise the "one batch count" will never be achievable. :)