/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 18.06.14
 * Time: 11:54
 * To change this template use File | Settings | File Templates.
 */
package scenes {
import flash.geom.Vector3D;

import starling.core.Starling;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.display.Transform3DContainer;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.text.BitmapFont;
import starling.text.TextField;

public class TransformContainerScene extends Scene
    {
        private var transform:Transform3DContainer;
        public function TransformContainerScene()
        {



            var image1:Image = new Image(Game.assets.getTexture("starling_round"));
            image1.x = -image1.width*.5;
            image1.y = -image1.height*.5;



            transform = new Transform3DContainer(1000);
            transform.addChild(image1);
            transform.x = Constants.GameWidth*.5;
            transform.y = Constants.GameHeight*.5;




            var bmFont: BitmapFont = new BitmapFont(Game.assets.getTexture("segoe_texture"),Game.assets.getByteArray("segoe"))
            bmFont.distanceFieldFont = true
            bmFont.dfSpread = 3
            TextField.registerBitmapFont(bmFont,"segoe_df");

            var textField1:TextField = new TextField(400,400,"Hi, i'm watching you", "segoe_df",40,0xffffff);

            textField1.y = 110;
            textField1.centerPivot();
            textField1.touchable = false;
            textField1.dfSharpness = .4;
            textField1.dfShadowSize = 4;
            textField1.dfShadowAlpha = .6;
            textField1.dfEffect = TextField.DF_EFFECT_GLOW;

            transform.addChild(textField1);
            addChild(transform);


            Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);


        }
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(stage);


            if(touch)
            {

                transform.setRotation(-(touch.globalX-(Starling.current.stage.stageWidth *.5)) *.1,
                                      (touch.globalY-(Starling.current.stage.stageHeight *.5)) *.1);
            }

        }
        public override function dispose():void
        {
          Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onTouch);
          super.dispose();
        }

    }
}
