package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';

	var bg:FlxBackdrop;
	var logo:FlxSprite;
	var bgSprites:Array<FlxSprite> = [];
	var menuItems:Array<{sprite:FlxSprite, id:String, state:Class<FlxState>, locked:Bool}> = [];
	var curSelected:Int = 0;
	var canSelect:Bool = true;

	override function create()
	{
		super.create();

		FlxG.camera.zoom = 0.85;
		FlxG.mouse.visible = true;

		bg = new FlxBackdrop(Paths.image("susmainmenu/bg/bg"));
		bg.velocity.x = -50;
		bg.scale.set(0.8, 0.8);
		bg.scrollFactor.set(0.5, 0.5);
		add(bg);

		for (i in 2...8) {
			var spr = new FlxSprite(-360, -300).loadGraphic(Paths.image("susmainmenu/bg/bg" + i));
			spr.scale.set(0.8, 0.8);
			add(spr);
			bgSprites.push(spr);
		}

		logo = new FlxSprite(-360, -300).loadGraphic(Paths.image("susmainmenu/bg/logo"));
		logo.scale.set(0.8, 0.8);
		add(logo);

		var options:Array<{id:String, state:Class<FlxState>, locked:Bool}> = [
			{id:"plsygames", state:FreeplayState, locked:false},
			{id:"options", state:OptionsState, locked:false},
			{id:"mods", state:null, locked:true},
			{id:"shop", state:null, locked:true},
			{id:"credits", state:CreditsState, locked:false}
		];

		var startY = -300;
		for (i in 0...options.length) {
			var spr = new FlxSprite(-360, startY + i * 0).loadGraphic(Paths.image("susmainmenu/" + options[i].id));
			spr.scale.set(0.8, 0.8);
			spr.ID = i;
			if (options[i].locked) {
				spr.color = 0xFFFF0000;
			}
			add(spr);
			menuItems.push({sprite:spr, id:options[i].id, state:options[i].state, locked:options[i].locked});
		}

		updateSelection();

		#if mobile
		addTouchPad("UP_DOWN", "A_B");
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mouseX = (FlxG.mouse.x / FlxG.width) * 2 - 1;
		var mouseY = (FlxG.mouse.y / FlxG.height) * 2 - 1;

		FlxG.camera.scroll.x += (mouseX * 30 - FlxG.camera.scroll.x) * 0.05;
		FlxG.camera.scroll.y += (mouseY * 40 - FlxG.camera.scroll.y) * 0.05;

		if (!canSelect) return;

		if (controls.UI_UP_P) {
			curSelected--;
			if (curSelected < 0) curSelected = menuItems.length - 1;
			while (menuItems[curSelected].locked) {
				curSelected--;
				if (curSelected < 0) curSelected = menuItems.length - 1;
			}
			updateSelection();
		}

		if (controls.UI_DOWN_P) {
			curSelected++;
			if (curSelected >= menuItems.length) curSelected = 0;
			while (menuItems[curSelected].locked) {
				curSelected++;
				if (curSelected >= menuItems.length) curSelected = 0;
			}
			updateSelection();
		}

		if (controls.ACCEPT && !menuItems[curSelected].locked) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			selectOption(curSelected);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}
	}

	function updateSelection() {
		for (i in 0...menuItems.length) {
			var spr = menuItems[i].sprite;
			if (i == curSelected && !menuItems[i].locked) {
				spr.color = 0xFFFFFFFF;
			} else if (menuItems[i].locked) {
				spr.color = 0xFFFF0000;
			} else {
				spr.color = 0xFF888888;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function selectOption(index:Int) {
		canSelect = false;
		var item = menuItems[index];
		
		if (item.state != null) {
			if (item.id == "options") {
				MusicBeatState.switchState(new OptionsState());
				OptionsState.onPlayState = false;
				if (PlayState.SONG != null) {
					PlayState.SONG.arrowSkin = null;
					PlayState.SONG.splashSkin = null;
					PlayState.stageUI = 'normal';
				}
			} else {
				MusicBeatState.switchState(Type.createInstance(item.state, []));
			}
		}
	}
}
