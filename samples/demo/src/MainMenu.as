package
{
    import flash.utils.getQualifiedClassName;
    
    import scenes.AnimationScene;
    import scenes.BenchmarkScene;
    import scenes.BlendModeScene;
    import scenes.CustomHitTestScene;
    import scenes.DistanceFieldTextScene;

    import scenes.MaskScene;
    import scenes.MovieScene;
    import scenes.MultiTextureBenchmark;
    import scenes.ParticleScene;
import scenes.TextBenchmarkScene;
import scenes.TextScene;
    import scenes.TextureScene;
    import scenes.TouchScene;

    import scenes.TransformContainerHitScene;
    import scenes.TransformContainerScene;
import scenes.ColorVoxelScene;

import starling.core.Starling;
    import starling.display.Button;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;


import starling.text.TextField;
    import starling.textures.Texture;
    import starling.utils.VAlign;

    public class MainMenu extends Sprite
    {

        public function MainMenu()
        {
            init();
        }
        
        private function init():void
        {
            var logo:Image = new Image(Game.assets.getTexture("logo"));
            addChild(logo);
            
            var scenesToCreate:Array = [
                ["Textures", TextureScene],
                ["Multitouch", TouchScene],
                ["TextFields", TextScene],
                ["Animations", AnimationScene],
                ["Custom hit-test", CustomHitTestScene],
                ["Movie Clip", MovieScene],
                ["Blend Modes", BlendModeScene],
                ["Clipping", MaskScene]
            ];

            var newScenesToCreate:Array = [
              ["Original Benchmark", BenchmarkScene],
              ["Color Voxel", ColorVoxelScene],

              ["Particles", ParticleScene],
              ["DF TextField", DistanceFieldTextScene],
              ["3D Transform", TransformContainerScene],
              ["3D hit-test", TransformContainerHitScene]

            ];
            
            var buttonTexture:Texture = Game.assets.getTexture("button_medium");
            var count:int = 0;


            for each (var sceneToCreate:Array in newScenesToCreate)
            {
                var sceneTitle:String = sceneToCreate[0];
                var sceneClass:Class  = sceneToCreate[1];

                var button:Button = new Button(buttonTexture, sceneTitle);
                button.x = count % 2 == 0 ? 28 : 167;
                button.y = 138 + int(count / 2) * 44;
                button.name = getQualifiedClassName(sceneClass);
                addChild(button);

                if (newScenesToCreate.length % 2 != 0 && count % 2 == 1)
                    button.y += 24;

                ++count;
            }
            count = 0;
            for each (var sceneToCreate:Array in scenesToCreate)
            {
                var sceneTitle:String = sceneToCreate[0];
                var sceneClass:Class  = sceneToCreate[1];
                
                var button:Button = new Button(buttonTexture, sceneTitle);
                button.x = count % 2 == 0 ? 28 : 167;
                button.y = 280 + int(count / 2) * 44;
                button.name = getQualifiedClassName(sceneClass);
                addChild(button);
                
                if (scenesToCreate.length % 2 != 0 && count % 2 == 1)
                    button.y += 24;
                
                ++count;
            }

            var newHeadingText:TextField = new TextField(310, 64, "New Features", "Verdana", 12);
            newHeadingText.x = 5;
            newHeadingText.y = 138 - newHeadingText.height;
            newHeadingText.vAlign = VAlign.BOTTOM;
            newHeadingText.touchable = false;
            var headingText:TextField = new TextField(310, 64, "Original Features", "Verdana", 12);
            headingText.x = 5;
            headingText.y = 280 - headingText.height;
            headingText.vAlign = VAlign.BOTTOM;
            headingText.touchable = false;
            addChild(headingText);
            addChild(newHeadingText);

            // show information about rendering method (hardware/software)
            
            var driverInfo:String = Starling.context.driverInfo;
            var infoText:TextField = new TextField(310, 64, driverInfo, "Verdana", 10);
            infoText.x = 5;
            infoText.y = 475 - infoText.height;
            infoText.vAlign = VAlign.BOTTOM;
            infoText.addEventListener(TouchEvent.TOUCH, onInfoTextTouched);
            addChildAt(infoText, 0);
        }
        
        private function onInfoTextTouched(event:TouchEvent):void
        {
            if (event.getTouch(this, TouchPhase.ENDED))
                Starling.current.showStats = !Starling.current.showStats;
        }
    }
}