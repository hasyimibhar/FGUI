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
- ~~Change the API, replacing all the `create` methods with one `addElement`, so that the user can create their own elements~~
- ~~Folowing the change above, I will probably need to separate all the classes into individual .m/.h pair (it's starting to confuse me!)~~
- Modify the code so that `setup` method is not necessary, and initialization can be done inside the `init` method

###Usage

FGUI uses the familiar scene-graph style of structuring elements in cocos2d.

#####FGUIRoot
`FGUIRoot` is obviously the root of the entire FGUI scene graph. Each `FGUIRoot` contains a `CCSpriteBatchNode`, which should contain all of your UI assets packed together (using [Zwoptex](http://zwopple.com/zwoptex/), [TexturePacker](http://www.codeandweb.com/texturepacker), etc).

	#import "FGUI.h"

	// Initialize the root
	FGUIRoot *root = [[FGUI alloc] initWithFile:@"Spritesheet.png"];
	[self addChild:root];
	
#####FGUILabel
	
	// Create label
	FGUILabel *myLabel = [FGUILabel labelWithString:@"Hello, world!" file:@"MyBitmapFont.fnt"];
	// Then add it to the root
	[root addElement:myLabel name:@"MyLabel"];
	
#####FGUISprite
	
	FGUISprite *sprite = [FGUISprite spriteWithSpriteFrame:CC_SPRITEFRAME(@"Sprite.png")];
	
	// An element can be added as a child of any other element! Not just the root!
	[myLabel addElement:sprite name:@"Sprite"];
	
#####FGUIButton
	
	FGUIButton *myButton = [FGUIButton buttonWithSpriteFrameArray:@[CC_SPRITEFRAME(@"Button_Normal.png"), CC_SPRITEFRAME(@"Button_Selected.png"), CC_SPRITEFRAME(@"Button_Disabled.png")]];
	[root addElement:myButton name:@"MyButton" zOrder:100];
	
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

	FGUILabel *spinningLabel = [FGUILabel labelWithString:@"I'm spinning~" file:@"MyBitmapFont.fnt"];
	[root addElement:spinningLabel name:@"SpinningLabel"];
        
    // Spin spin spin!
    [spinningLabel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0f angle:360]]];
    
###CCLabelBNFont
`CCLabelBNFont` class comes with the source code. It's a friend of `CCLabelBMFont` (note the one letter difference), which basically allows bitmap fonts to be added as a child of `CCSpriteBatchNode`. Kudos to **mikezang** for writing the class, otherwise the "one batch count" will never be achievable. :)