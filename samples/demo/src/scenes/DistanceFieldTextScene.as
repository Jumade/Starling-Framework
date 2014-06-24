
package scenes
{
import flash.utils.getTimer;

import starling.events.Event;
import starling.text.BitmapFont;
import starling.text.TextField;

public class DistanceFieldTextScene extends Scene
    {
        private var textField1:TextField;
        private var textField2:TextField;
        private var textField3:TextField;
        public function DistanceFieldTextScene()
        {
            init();
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(e:Event):void {
            var scale:Number = 2.3+(Math.sin(getTimer()/5000)*1.7); //from 0.7 to 4.9
            textField1.scaleX = textField1.scaleY =scale;
            textField2.scaleX = textField2.scaleY =scale;
            textField3.scaleX = textField3.scaleY =scale;
        }



        public override function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            super.dispose();
        }
        private function init():void
        {
            var bmFont: BitmapFont = new BitmapFont(Game.assets.getTexture("segoe_texture"),Game.assets.getByteArray("segoe"))
            bmFont.distanceFieldFont = true
            bmFont.dfSpread = 3
            TextField.registerBitmapFont(bmFont,"segoe_df");

            textField1 = new TextField(300,100,"Hello", "segoe_df",40,0xffffff);
            textField1.x = Constants.GameWidth*.5;
            textField1.y = 100;
            textField1.centerPivot();
            textField1.touchable = false;

            textField1.dfSharpness = .4;
            textField1.dfShadowSize = 3;
            textField1.dfShadowAlpha = 1;
            textField1.dfEffect = TextField.DF_EFFECT_GLOW;
            addChild(textField1);

            textField2 = new TextField(300,100,"Hello", "segoe_df",40,0xffffff);
            textField2.x = Constants.GameWidth*.5;
            textField2.y = 230;
            textField2.centerPivot();
            textField2.touchable = false;


            textField2.dfSharpness = .4;
            textField2.dfShadowSize = 2;
            textField2.dfShadowAlpha = 1;
            textField2.dfEffect = TextField.DF_EFFECT_STROKE;
            addChild(textField2);

            textField3 = new TextField(300,100,"Hello", "segoe_df",40,0xffffff);
            textField3.x = Constants.GameWidth*.5;
            textField3.y = 360;
            textField3.centerPivot();
            textField3.touchable = false;

            textField3.dfSharpness = .4;
            textField3.dfShadowSize = 2;
            textField3.dfShadowAlpha = 1;
            addChild(textField3);
        }
    }
}