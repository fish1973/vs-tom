package states;

import flixel.input.mouse.FlxMouseEventManager;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;


class FreeplaySelectState extends MusicBeatState
{
	var clicked:Bool = false;

	var garbo:Array<String> = ['story', 'side', 'extra', 'mystery', 'legacy'];
	var categoryImage:FlxSprite;
	var bs:FlxTypedGroup<FlxSprite>;

	var grow:FlxTween;
	var shrink:FlxTween;

	var curSelected:Int = -1;
	var chose:Bool = false;
	var lockScreen:Bool = false;
	public static var category:String = "";

	var xd:FlxSprite;
	var luigiText:FlxText;
	var titleText:FlxText;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		//idk if this is actually necessary at all but i'm keeping it just in case

		persistentUpdate = true;

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var colorTween = FlxTween.color(bg, 3, 0xFF51c273, 0xFF4e2b8a, { type: PINGPONG, ease: FlxEase.smootherStepInOut } );

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('grid'));
		grid.scrollFactor.set();
		grid.setGraphicSize(Std.int(grid.width * 3), Std.int(grid.height * 3));
		grid.color = 0xFF000000;
		grid.velocity.set(100, 100);
		grid.updateHitbox();
		grid.alpha = 0.2;
		grid.screenCenter(X);
		add(grid);
		//grid code stolen from vs joeseph (thanks fyrid) also this bg stuff is just taken from the main menu

		titleText = new FlxText(0, 60, FlxG.width, "Choose a Category", 32);
		titleText.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titleText);

		bs = new FlxTypedGroup<FlxSprite>();
		add(bs);

		for (i in 0...garbo.length)
			{
				categoryImage = new FlxSprite().loadGraphic(Paths.image('categories/' + garbo[i]));
				categoryImage.updateHitbox();
				categoryImage.color = 0xFFFFFF;
				categoryImage.antialiasing = ClientPrefs.data.antialiasing;
				categoryImage.ID = i;
				bs.add(categoryImage);

				switch(garbo[i]) {
					case 'story':
						categoryImage.x = 100;
						categoryImage.y = 180;
					case 'side':
						categoryImage.x = Std.int(FlxG.width - 524 - 100);
						categoryImage.y = 180;
					case 'extra':
						categoryImage.x = 100;
						categoryImage.y = Std.int(180 + 263 + 35);
					case 'mystery':
						categoryImage.y = Std.int(180 + 263 + 35);
						categoryImage.screenCenter(X);
					case 'legacy':
						categoryImage.x = Std.int(FlxG.width - 339 - 100);
						categoryImage.y = Std.int(180 + 263 + 35);
				}
			}

		xd = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		xd.alpha = 0;
		add(xd);

		luigiText = new FlxText(0, 0, FlxG.width,
			"You must complete all songs in the \n
			Story, Side, and Extra categories \n
			in order to enter this category. \n \n
			Press Accept to exit.", 32);
		luigiText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		luigiText.screenCenter(Y);
		luigiText.alpha = 0;
		add(luigiText);

		super.create();
		
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && lockScreen) {
			lockScreen = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(xd, {alpha: 0}, 0.5);
			FlxTween.tween(luigiText, {alpha: 0}, 0.5);
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
		}

		if(controls.BACK) {
			if (!lockScreen) {
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.mouse.visible = false;
			}
		}

		for (i in 0...bs.members.length) {
			if (FlxG.mouse.overlaps(bs.members[i])) {
				curSelected = i;

				if (FlxG.mouse.justPressed && !lockScreen) {
						if (garbo[curSelected] != 'mystery') {
							FlxTween.cancelTweensOf(bs.members[i]);
							chose = true;
							FlxG.mouse.visible = false;
							category = garbo[curSelected];
							FlxTween.tween(bs.members[i], {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.backInOut});
							bs.members[i].color = 0xFFFFFF;
						}

						switch(garbo[curSelected]) {
							case 'story':
								MusicBeatState.switchState(new FreeplayState());
							case 'side':
								MusicBeatState.switchState(new FreeplayState());
							case 'extra':
								MusicBeatState.switchState(new FreeplayState());
							case 'legacy':
								MusicBeatState.switchState(new FreeplayState());
							case 'mystery':
								lockScreen = true;
								FlxTween.tween(xd, {alpha: 0.6}, 1);
								FlxTween.tween(luigiText, {alpha: 1}, 1);
								FlxTween.tween(FlxG.sound.music, {volume: 0}, 1);
								FlxG.sound.play(Paths.sound('mysteryLocked'), 2);
						}
				}
			}
		}

		for (item in bs.members) {
			if (!chose && !lockScreen) {
				if (item.ID == curSelected) {
					FlxTween.cancelTweensOf(item);
					grow = FlxTween.tween(item, {'scale.x': 1.1, 'scale.y': 1.1}, 0.3, {ease: FlxEase.quartOut});
					item.color = 0xFFFFFF;
				} else if (item.ID != curSelected && item.color != 0xCACACA) {
					FlxTween.cancelTweensOf(item);
					shrink = FlxTween.tween(item, {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.quartOut});
					item.color = 0xCACACA;
				}
			}
		}

		super.update(elapsed);
	}
}
