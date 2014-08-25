/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 31.07.14
 * Time: 14:56
 * To change this template use File | Settings | File Templates.
 */
package starling.camera {
import starling.core.*;

import flash.geom.Matrix;

import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Point3d;
import net.richardlord.coral.Vector3d;
import net.richardlord.coral.Vector3d;

import starling.utils.Projection;

public class Camera {
    private var _projection:Projection = new Projection()
    private var _perspective:Number;
    private var _viewPortWidth:int;
    private var _viewPortHeight:int;

    public var position:Vector3d = new Vector3d(0,0,0);
    public var rotation:Matrix3d = new Matrix3d();


    public function Camera(p_perspective:Number) {

        _perspective =  p_perspective;
        _viewPortWidth = Starling.current.stage.stageWidth;
        _viewPortHeight = Starling.current.stage.stageHeight;
        _projection.setPerspectiveProjection(_viewPortWidth,_viewPortHeight,_perspective, 0.1,_perspective*2)

    }
    public function onResize():void {
        _viewPortWidth = Starling.current.stage.stageWidth;
        _viewPortHeight = Starling.current.stage.stageHeight;
        _projection.setPerspectiveProjection(_viewPortWidth,_viewPortHeight,_perspective, 0.1,_perspective*2)
    }

    public function get perspective():Number {
          return _perspective;
    }

    public function set perspective(value:Number):void {
       _perspective = value;
       _projection.setPerspectiveProjection(_viewPortWidth,_viewPortHeight,_perspective, 0.1,_perspective*2)
    }


    private var _worldToClipMatrix:Matrix3d = new Matrix3d()
    public function get worldToClipMatrix():Matrix3d
    {
        _worldToClipMatrix.reset()
        _worldToClipMatrix.appendTranslation(-position.x, -position.y, -position.z);

        _worldToClipMatrix.append(rotation)
       // _worldToClipMatrix.invert();
        _worldToClipMatrix.append(_projection.matrix)

        return _worldToClipMatrix;
    }
    private var _mouseVector:Vector3d = new Vector3d();
    public function clipToWorld(p_x:Number, p_y:Number, p_z:Number):Vector3d
    {



       _mouseVector.x = p_x- viewPortWidth*.5;
       _mouseVector.y = p_y- viewPortHeight*.5;
       _mouseVector.z = p_z;


       var zFactor:Number = (_perspective - p_z) / _perspective;

       _mouseVector.x *= zFactor;
       _mouseVector.y *= zFactor;
       _worldToClipMatrix.assign(rotation)
        _worldToClipMatrix.invert()
       _worldToClipMatrix.appendTranslation(position.x, position.y, position.z);
       _worldToClipMatrix.transformVectorSelf(_mouseVector)
       return _mouseVector;
    }



    public function get viewPortWidth():int {
        return _viewPortWidth;
    }

    public function get viewPortHeight():int {
        return _viewPortHeight;
    }
}
}
