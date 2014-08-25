/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 13.07.14
 * Time: 11:56
 * To change this template use File | Settings | File Templates.
 */
package starling.view {
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Point3d;
import net.richardlord.coral.Vector3d;

import starling.camera.Camera;
import starling.core.Starling;

import starling.display.*;

import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.errors.IllegalOperationError;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Vector3D;

import starling.core.RenderSupport;

import starling.core.Starling;
import starling.light.DirectionalLight;
import starling.light.Light;
import starling.light.PointLight;
import starling.utils.Projection;

public class VoxelView extends DisplayObjectContainer {


    private var _constantData:Vector.<Number> = new Vector.<Number>();
    private var _fragmentConstantData:Vector.<Number> = new Vector.<Number>();


    private var _ambientLight:DirectionalLight;
    private var _lights:Array = [];
    public var programId:int = -1;

    private var _camera:Camera;

    public function VoxelView(p_perspective:Number = 500) {
        touchable = false;
        _camera = new Camera(p_perspective)


    }
   public function addLight(p_light:Light):void
   {
       _lights.push(p_light);
       stateChanged = true;
   }




    private var _camPoint:Point3d = new Point3d()
    private var stateId:int;
    private var stateChanged:Boolean = true;
    public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void {
        p_parentUpdateTransform = updateTransform(p_parentUpdateTransform);
        p_parentUpdateColor = updateColor(p_parentUpdateColor);


        support.finishDraw();

        support.setCamera(_camera);
        var cmatrix:Matrix3d = _camera.worldToClipMatrix;


        _constantData[0] = cmatrix.n11;
        _constantData[1] = cmatrix.n12;
        _constantData[2] = cmatrix.n13;
        _constantData[3] = cmatrix.n14;

        _constantData[4] = cmatrix.n21;
        _constantData[5] = cmatrix.n22;
        _constantData[6] = cmatrix.n23;
        _constantData[7] = cmatrix.n24;

        _constantData[8] = cmatrix.n31;
        _constantData[9] = cmatrix.n32;
        _constantData[10] = cmatrix.n33;
        _constantData[11] = cmatrix.n34;

        _constantData[12] = cmatrix.n41;
        _constantData[13] = cmatrix.n42;
        _constantData[14] = cmatrix.n43;
        _constantData[15] = cmatrix.n44;

       if(_ambientLight)
       {


           var l:Point3d = _ambientLight.getPosition(camera.rotation)
           _constantData[16] = l.x;
           _constantData[17] = l.y;
           _constantData[18] = l.z;
           _constantData[19] = _ambientLight.intensity;

           _constantData[20] = _ambientLight.colorR;
           _constantData[21] = _ambientLight.colorG;
           _constantData[22] = _ambientLight.colorB;
           _constantData[23] = .5;

       }



        var fc:int = 0;
       for each(var light:PointLight in _lights)
       {

          var l2:Point3d = light.position;

           _fragmentConstantData[fc++] = l2.x;
           _fragmentConstantData[fc++] = l2.y;
           _fragmentConstantData[fc++] = l2.z;
           _fragmentConstantData[fc++] = light.distance;

           _fragmentConstantData[fc++] = light.colorR;
           _fragmentConstantData[fc++] = light.colorG;
           _fragmentConstantData[fc++] = light.colorB;
           _fragmentConstantData[fc++] = 0;


       }

        if(stateChanged)
         {
             updateStateID()
             stateChanged = false;
         }
        support.mColorVoxelRenderer.setProgram(programId)

        Starling.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,_fragmentConstantData);
        Starling.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,_constantData);


        Starling.context.setCulling(Context3DTriangleFace.FRONT);
        var numChildren:int = mChildren.length;
        for (var i:int = 0; i < numChildren; ++i) {
            var child:DisplayObject = mChildren[i];

            if (child.visible) {
                child.render(support, p_parentUpdateTransform, p_parentUpdateColor, p_draw && hasVisibleArea);

            }
        }
        support.finishDraw();
        support.setProjectionMatrix()
        Starling.context.setCulling(Context3DTriangleFace.NONE);
    }
    protected  function updateStateID():void
   {
       stateId = 0;

       var lightCount:int =_lights.length;

       if(lightCount == 1)
           stateId |= 1 << 0;
       else if(lightCount == 2)
           stateId |= 1 << 1;

       programId = stateId;

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

    public function get ambientLight():DirectionalLight {
        return _ambientLight;
    }

    public function get camera():Camera {
        return _camera;
    }

    public function set ambientLight(value:DirectionalLight):void {
        _ambientLight = value;
    }
}
}
