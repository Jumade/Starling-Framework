/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 13.07.14
 * Time: 12:46
 * To change this template use File | Settings | File Templates.
 */
package scenes {
import starling.core.Starling;
import starling.display.ColorVoxel;
import starling.display.VoxelContainer;
import starling.events.Touch;
import starling.events.TouchEvent;

public class ColorVoxelScene extends Scene
    {
        private var transform:VoxelContainer;
        public function ColorVoxelScene()
        {




            transform = new VoxelContainer(300);

            transform.x = Constants.GameWidth*.5;
            transform.y = Constants.GameHeight*.5;

            for(var ix:int = 0;ix < 4; ix++)
            {
                for(var iy:int = 0;iy < 4; iy++)
                {
                    for(var iz:int = 0;iz < 4; iz++)
                    {
                        var r:Number = (ix/4)*240 + 15;
                        var g:Number = (iy/4)*240 + 15;
                        var b:Number = (iz/4)*240 + 15;
                        var v:ColorVoxel = new ColorVoxel(40,( r << 16 ) | ( g << 8 ) | b);
                        v.x = (ix-2) * 56 +8;
                        v.y = (iy-2) * 56 +8;
                        v.z = (iz-2) * 56 +8;

                        transform.addChild(v);
                    }
                }


            }



            addChild(transform);


            Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);


         }
         private function onTouch(event:TouchEvent):void
         {
             var touch:Touch = event.getTouch(stage);


             if(touch)
             {

                 transform.setRotation(-(touch.globalX-(Starling.current.stage.stageWidth *.5)) *.8,
                                       (touch.globalY-(Starling.current.stage.stageHeight *.5)) *.6);
             }

         }

    }
}
