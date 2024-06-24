package states;

import flixel.input.mouse.FlxMouseEventManager;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;


class FreeplaySelectState extends MusicBeatState
{
	var clicked:Bool = false;

	var garbo:Array<String> = ['story', 'side', 'extra', 'legacy', 'mystery'];
	var categoryImage:FlxSprite;
	var bs:FlxTypedGroup<FlxSprite>;

	var grow:FlxTween;
	var shrink:FlxTween;

	var curSelected:Int = -1;
	var chose:Bool = false;
	var lockScreen:Bool = false;

	var xd:FlxSprite;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

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
					case 'legacy':
						categoryImage.y = Std.int(180 + 263 + 35);
						categoryImage.screenCenter(X);
					case 'mystery':
						categoryImage.x = Std.int(FlxG.width - 339 - 100);
						categoryImage.y = Std.int(180 + 263 + 35);
				}
			}

		xd = new FlxSprite().loadGraphic(Paths.image('xd'));
		xd.scrollFactor.set();
		xd.updateHitbox();
		xd.screenCenter();
		xd.alpha = 0;
		add(xd);

		super.create();
		
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && lockScreen) {
			lockScreen = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(xd, {alpha: 0}, 0.5);
		}

		if(controls.BACK) {
			if (!lockScreen) {
				MusicBeatState.switchState(new MainMenuState());
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
								FlxTween.tween(xd, {alpha: 1}, 3);
						}
					}
			}
		}

		for (item in bs.members) {
			if (!chose && !lockScreen) {
				if (item.ID == curSelected) {
					FlxTween.cancelTweensOf(item);
					grow = FlxTween.tween(item, {'scale.x': 1.1, 'scale.y': 1.1}, 0.3, {ease: FlxEase.quartOut});
					item.color = 0xCACACA;
				} else if (item.ID != curSelected && item.color != 0xFFFFFF) {
					FlxTween.cancelTweensOf(item);
					shrink = FlxTween.tween(item, {'scale.x': 1, 'scale.y': 1}, 0.3, {ease: FlxEase.quartOut});
					item.color = 0xFFFFFF;
				}
			}
		}

		super.update(elapsed);
	}
}
