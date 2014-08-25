/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 22.08.14
 * Time: 11:02
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Sprite;
import flash.system.Capabilities;
import flash.text.AntiAliasType;

import starling.core.Starling;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.AssetManager;

[SWF(width="600", height="600", frameRate="60", backgroundColor="#16252e")]
   public class Voxel_Demo_Web extends Sprite
   {


       private var mStarling:Starling;

       public function Voxel_Demo_Web()
       {
           if (stage) start();
           else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
       }

       private function start():void
       {
           Starling.multitouchEnabled = true; // for Multitouch Scene
           Starling.handleLostContext = true; // required on Windows, needs more memory

           mStarling = new Starling(Voxel_Game, stage);
           mStarling.simulateMultitouch = true;
           mStarling.enableErrorChecking = Capabilities.isDebugger;
           mStarling.start();

           // this event is dispatched when stage3D is set up
           mStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
       }

       private function onAddedToStage(event:Object):void
       {
           removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
           start();
       }

       private function onRootCreated(event:Event, game:Voxel_Game):void
       {
           // set framerate to 30 in software mode
           if (mStarling.context.driverInfo.toLowerCase().indexOf("software") != -1)
               mStarling.nativeStage.frameRate = 30;



           // game will first load resources, then start menu
           game.start();
       }
   }
}