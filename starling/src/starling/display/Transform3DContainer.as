/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 18.06.14
 * Time: 09:32
 * To change this template use File | Settings | File Templates.
 */
package starling.display {
import flash.display.Sprite;
import flash.display3D.Context3DProgramType;
import flash.errors.IllegalOperationError;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Vector3D;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.events.ResizeEvent;

public class Transform3DContainer extends DisplayObjectContainer {
    private static const AXIS_X:Vector3D = new Vector3D(0, 1, 0);
    private static const AXIS_Y:Vector3D = new Vector3D(1, 0, 0);
    private static const AXIS_Z:Vector3D = new Vector3D(0, 0, 1);

    private var _matrix3d:Matrix3D = new Matrix3D();
    private var _projectionMatrix:Matrix3D = new Matrix3D();
    private var _worldMatrix:Matrix3D = new Matrix3D();
    private var _positionMatrix:Matrix3D = new Matrix3D();
    private var _xOffset:Number = 0;
    private var _yOffset:Number = 0;
    private var _zOffset:Number = 0;

    private var _xRotation:Number = 0;
    private var _yRotation:Number = 0;
    private var _zRotation:Number = 0;


    private var _perspective:Number;
    private var _viewPortWidth:int;
    private var _viewPortHeight:int;

    public function Transform3DContainer(p_perspective:Number = 500) {
        touchable = false;
        this._perspective = p_perspective;
        _viewPortWidth = Starling.current.stage.stageWidth;
        _viewPortHeight = Starling.current.stage.stageHeight;

        _matrix3d = new Matrix3D();

        updatePerspectiveMatrix()
    }

    public function onResize():void {
        _viewPortWidth = Starling.current.stage.stageWidth;
        _viewPortHeight = Starling.current.stage.stageHeight;
        updatePerspectiveMatrix();
    }

    private function updatePerspectiveMatrix():void {
        this._zOffset = -_perspective;
        // var f:Number = 1.0 / Math.tan(fov);

        var f:Number = 1.0 / ((_viewPortWidth * .5) / _perspective);
        var near:Number = 0.1;
        var far:Number = _perspective * 2;
        var aspect:Number = _viewPortWidth / _viewPortHeight;
        _projectionMatrix.rawData = new <Number>[
            f , 0, 0, 0,
            0, -f * aspect, 0, 0,
            0, 0, far / (near - far), (far * near) / (near - far),
            0, 0, -1, 0
        ];
        updatePositionMatrix();
        updateMatrix();
    }


    public function appendRotation(x:Number = 0, y:Number = 0, z:Number = 0):void {
        _matrix3d.appendRotation(x, AXIS_X);
        _matrix3d.appendRotation(y, AXIS_Y);
        _matrix3d.appendRotation(z, AXIS_Z);

        _xRotation += x;
        _yRotation += y;
        _zRotation += z;


    }

    public function setRotation(x:Number = 0, y:Number = 0, z:Number = 0):void {
        if (x != 0)
            _xRotation = x;
        if (y != 0)
            _yRotation = y;
        if (z != 0)
            _zRotation = z;
        updateMatrix()
    }

    private function updateMatrix():void {
        var rawData:Vector.<Number> = _matrix3d.rawData;
        rawData[0] = 1;
        rawData[1] = 0;
        rawData[2] = 0;
        rawData[3] = 0;//x
        rawData[4] = 0;
        rawData[5] = 1;
        rawData[6] = 0;
        rawData[7] = 0;//y
        rawData[8] = 0;
        rawData[9] = 0;
        rawData[10] = 1;
        rawData[11] = _zOffset;//z
        rawData[12] = 0;
        rawData[13] = 0;
        rawData[14] = 0;
        rawData[15] = 1;
        _matrix3d.rawData = rawData;

        if (_xRotation != 0)
            _matrix3d.appendRotation(_xRotation, AXIS_X);
        if (_yRotation != 0)
            _matrix3d.appendRotation(_yRotation, AXIS_Y);
        if (_zRotation != 0)
            _matrix3d.appendRotation(_zRotation, AXIS_Z);

    }

    public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void {
        p_parentUpdateTransform = updateTransform(p_parentUpdateTransform);
        p_parentUpdateColor = updateColor(p_parentUpdateColor);

        if (p_parentUpdateTransform) {
            _xOffset = worldX;
            _yOffset = worldY;
            worldX = 0;
            worldY = 0;
            updatePositionMatrix()
        }


        support.finishDraw();


        _matrix3d.copyToMatrix3D(_worldMatrix);
        _worldMatrix.prepend(_positionMatrix);

        Starling.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _worldMatrix, false);
        var numChildren:int = mChildren.length;

        for (var i:int = 0; i < numChildren; ++i) {
            var child:DisplayObject = mChildren[i];

            if (child.mVisible) {
                child.render(support, p_parentUpdateTransform, p_parentUpdateColor, p_draw && hasVisibleArea);

            }


        }
        support.finishDraw();
        support.setProjectionMatrix()
    }

    private function updatePositionMatrix():void {
        _positionMatrix.identity();
        var rawData:Vector.<Number> = _positionMatrix.rawData;
        rawData[3] = -(1 - (_xOffset / (_viewPortWidth * .5)));
        rawData[7] = 1 - (_yOffset / (_viewPortHeight * .5));
        _positionMatrix.rawData = rawData;

        _positionMatrix.append(_projectionMatrix);
    }


    private var _viewNormal:Vector3D = new Vector3D(0, 0, 1);
    private var _viewDistance:Number = 0;
    private var _transformedPoint:Point = new Point()

    public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject {
        if (forTouch && (!visible || !touchable))
            return null;
        /*
         var p1:Vector3D = new Vector3D(0,0,0)
         var p2:Vector3D = new Vector3D(1,0,0)
         var p3:Vector3D = new Vector3D(0,1,0);

         var ba:Vector3D = p2.subtract(p1);
         var ca:Vector3D = p3.subtract(p1);

         var normal:Vector3D =  ba.crossProduct(ca);
         normal.normalize();
         var distance:Number = normal.dotProduct(p3);

         trace(normal.toString(),distance)
         */


        var cam:Vector3D = new Vector3D(0, 0, -_zOffset);
        cam = _matrix3d.transformVector(cam);


        var look:Vector3D = getMouseVector(localPoint.x, localPoint.y);
        look = _matrix3d.transformVector(look);
        look = look.subtract(cam);


        var nDotCam:Number = _viewNormal.dotProduct(cam);
        var nDotLook:Number = _viewNormal.dotProduct(look);

        var scale:Number = ((_viewDistance - nDotCam) / nDotLook)
        look.scaleBy(scale);
        var intersection:Vector3D = cam.add(look)


        _transformedPoint.x = intersection.x;
        _transformedPoint.y = intersection.y;

        var numChildren:int = mChildren.length;
        for (var i:int = numChildren - 1; i >= 0; --i) // front to back!
        {
            var child:DisplayObject = mChildren[i];
            var target:DisplayObject = child.hitTest(_transformedPoint, forTouch);

            if (target)
                return target;
        }

        return null;
    }

    private var _mouseVector:Vector3D = new Vector3D();

    private function getMouseVector(p_x:Number, p_y:Number):Vector3D {
        p_x -= _xOffset;
        p_y -= _yOffset;

        _mouseVector.x = p_x;
        _mouseVector.y = p_y;
        return _mouseVector
    }


    public function get perspective():Number {
        return _perspective;
    }

    public function set perspective(value:Number):void {
        _perspective = value;
        updatePerspectiveMatrix();
    }


    /** @private */
    public override function set width(value:Number):void {
        throw new IllegalOperationError("Cannot set width of 3DContainer");
    }

    /** @private */
    public override function set height(value:Number):void {
        throw new IllegalOperationError("Cannot set height of 3DContainer");
    }

    /** @private */
    public override function set scaleX(value:Number):void {
        throw new IllegalOperationError("Cannot scale 3DContainer");
    }

    /** @private */
    public override function set scaleY(value:Number):void {
        throw new IllegalOperationError("Cannot scale 3DContainer");
    }

    /** @private */
    public override function set rotation(value:Number):void {
        throw new IllegalOperationError("Cannot rotate 3DContainer");
    }
}
}
