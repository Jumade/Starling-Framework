/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 18.06.14
 * Time: 11:54
 * To change this template use File | Settings | File Templates.
 */
package scenes {
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Transform3DContainer;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.BitmapFont;
import starling.text.TextField;

import utils.RoundButton;

public class TransformContainerHitScene extends Scene
    {
        private var transform:Transform3DContainer;
        public function TransformContainerHitScene()
        {

            transform = new Transform3DContainer(400);
            transform.x = Constants.GameWidth*.5;
            transform.y = Constants.GameHeight*.5;
            transform.touchable = true;// touch is disabled by default



            for(var x:int = 0; x < 4; x++)
            {
                for(var y:int = 0; y < 4; y++)
                {

                    var q:Quad = new Quad(60,60,Math.random()*0xffffff);
                    q.x = (x-2) * q.width;
                    q.y = (y-2) * q.height;
                    transform.addChild(q);
                    q.addEventListener(TouchEvent.TOUCH, onTouchQuad);
                }
            }

            addChild(transform);

            transform.setRotation(20,-55,10);

        }

        private function onTouchQuad(e:TouchEvent):void {

            if (e.getTouch(e.target as DisplayObject, TouchPhase.HOVER))
            {
                DisplayObject(e.target).alpha = .3;
            }
            else
            {
                DisplayObject(e.target).alpha = 1;
            }
        }

    }
}
