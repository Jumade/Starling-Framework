/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 22.08.14
 * Time: 11:06
 * To change this template use File | Settings | File Templates.
 */
package
{
import flash.geom.Point;
import flash.system.System;
    import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.getDefinitionByName;

import net.richardlord.coral.Point3d;

import net.richardlord.coral.Vector3d;

import scenes.Scene;

import starling.camera.OrbitCameraController;

import starling.core.Starling;
    import starling.display.BlendMode;
    import starling.display.Button;
import starling.display.ColorVoxel;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.light.DirectionalLight;
import starling.light.PointLight;
import starling.textures.Texture;
    import starling.utils.AssetManager;
import starling.view.VoxelView;

import utils.ProgressBar;

    public class Voxel_Game extends Sprite
    {
        private var view:VoxelView;
        private var _light1:PointLight;
        private var _light2:PointLight;
        private var _light1Quad:Quad;
        private var _light2Quad:Quad;

        private var _rotationVelocity:Point3d = new Point3d(.01,.02,0)
        private var _mouseDown:Boolean;

        private var _orbit:OrbitCameraController;

        public function Voxel_Game()
        {

        }

        public function start():void
        {
            view = new VoxelView(400);
            view.ambientLight = new DirectionalLight(.5,0xdef8ff)
            view.ambientLight.cameraSpace = true;
            view.ambientLight.appendRotationX(Math.PI *.2);
            addChild(view)

            _orbit = new OrbitCameraController(view.camera,400);


           _light1 = new PointLight(.035,0xffcb2e)
            view.addLight(_light1);

           _light2 = new PointLight(.015,0x3399d4)
            view.addLight(_light2);



            for(var ix:int = 0;ix < 3; ix++)
            {
               for(var iy:int = 0;iy < 3; iy++)
               {
                   for(var iz:int = 0;iz < 3; iz++)
                   {
                       var r:Number = (ix/3)*240 + 15;
                       var g:Number = (iy/3)*255 + 0;
                       var b:Number = (iz/3)*200 + 55;
                       var v:ColorVoxel = new ColorVoxel(70,( r << 16 ) | ( g << 8 ) | b);
                       v.x = (ix-1) * 75 ;
                       v.y = (iy-1) * 75 ;
                       v.z = (iz-1) * 75 ;

                       view.addChild(v);
                   }
               }


            }

           _light1Quad = new Quad(20,20,0xf8f79f);
           _light1Quad.x = stage.stageWidth*.5;
           _light1Quad.y = stage.stageHeight * .35;
           _light1Quad.centerPivot()


           _light2Quad = new Quad(20,20,0x6c90f7);
           _light2Quad.x = stage.stageWidth*.5;
           _light2Quad.y = stage.stageHeight * .65;
            _light2Quad.centerPivot()

           addChild(_light1Quad);
           addChild(_light2Quad);


           addEventListener(Event.ENTER_FRAME, onEnterFrame);
           stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
           stage.addEventListener(TouchEvent.TOUCH, onTouch);
        }
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(stage);
            if ( touch == null) return;

            var quad1interaction:Boolean =  event.interactsWith(_light1Quad);
            var quad2interaction:Boolean =  event.interactsWith(_light2Quad);
            if(!quad1interaction && !quad2interaction)
            {
                if (touch.phase == TouchPhase.BEGAN )
               {
                    _mouseDown = true;
                   _rotationVelocity.x = 0;
                   _rotationVelocity.y = 0;
               }
               if (touch.phase == TouchPhase.ENDED )
               {
                    _mouseDown = false;
               }
            }


            if (touch.phase == TouchPhase.MOVED )
            {
                if(quad1interaction)
                {
                    _light1Quad.x =  touch.globalX;
                    _light1Quad.y =  touch.globalY;
                }else if(quad2interaction)
                {
                    _light2Quad.x =  touch.globalX;
                    _light2Quad.y =  touch.globalY;
                }else
                {
                    var move:Point =  touch.getMovement(stage)

                  _rotationVelocity.x =  move.y * .01;
                  _rotationVelocity.y =  -move.x * .01;


                  _orbit.move(_rotationVelocity.x,_rotationVelocity.y)
                }


            }

            Mouse.cursor = ( quad1interaction || quad2interaction) ?
                        MouseCursor.HAND : MouseCursor.AUTO;
        }

        private function onEnterFrame(event:Event):void {

            if(!_mouseDown)
            {
                _orbit.move(_rotationVelocity.x,_rotationVelocity.y)
                if(Math.abs(_rotationVelocity.x) > 0.001)
                _rotationVelocity.x *= .99;

                _rotationVelocity.y *= .99;

            }


           var world1:Vector3d = view.camera.clipToWorld( _light1Quad.x, _light1Quad.y,  200);
           _light1.position.x =  world1.x;
           _light1.position.y =  world1.y;
           _light1.position.z =  world1.z;

           var world2:Vector3d = view.camera.clipToWorld( _light2Quad.x, _light2Quad.y,  200);
           _light2.position.x =  world2.x;
           _light2.position.y =  world2.y;
           _light2.position.z =  world2.z;


        }

        private function onKey(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.SPACE)
                Starling.current.showStats = !Starling.current.showStats;
            else if (event.keyCode == Keyboard.X)
                Starling.context.dispose();
        }


    }
}