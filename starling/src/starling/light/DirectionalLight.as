/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 19.07.14
 * Time: 22:40
 * To change this template use File | Settings | File Templates.
 */
package starling.light {
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Point3d;
import net.richardlord.coral.Vector3d;

public class DirectionalLight {

    public static const DIRECTION_TOP:int = 1;
    public static const DIRECTION_LEFT:int = 2;
    public static const DIRECTION_RIGHT:int = 3;
    public static const DIRECTION_UP:int = 4;
    public static const DIRECTION_DOWN:int = 5;

    private var _intensity:Number;
    private var _position:Point3d = new Point3d(0,0,-1);
    private var _helperMatrix:Matrix3d = new Matrix3d();
    private var _rotationMatrix:Matrix3d = new Matrix3d();
    private var _outPoint:Point3d = new Point3d();
    private var _color:uint;
     public var colorR:Number;
    public var colorG:Number;
    public var colorB:Number;


    public var cameraSpace:Boolean = false;
    public function DirectionalLight(p_intensity:Number, p_color:uint) {
        this._intensity = p_intensity;
        color = p_color;

    }
    public function set color(value:uint):void
     {
         if(_color != value)
         {
             _color = value;

             colorR = (_color >> 16 & 0xFF) / 255.0;
             colorG = (_color >> 8 & 0xFF) / 255.0;
             colorB = (_color & 0xFF) / 255.0;
         }
     }
    public function getPosition(p_cameraRotation:Matrix3d):Point3d
    {
        if(cameraSpace)
        {
            p_cameraRotation.inverse(_helperMatrix)
            _helperMatrix.transformPoint(_position,_outPoint);
        }else
        {
            p_cameraRotation.transformPoint(_position,_outPoint);
        }

        return _outPoint;
    }
    public function getTransformedPoint(p_cam:Matrix3d):Point3d
      {
          p_cam.transformPoint(_position,_outPoint);

          return _outPoint;
      }
    public function appendRotationX(p_val:Number ):void
    {
        _rotationMatrix.reset();
        _rotationMatrix.appendRotation(p_val,Vector3d.X_AXIS);
        _rotationMatrix.transformPointSelf(_position)
    }
    public function appendRotationY(p_val:Number ):void
    {
        _rotationMatrix.reset();
       _rotationMatrix.appendRotation(p_val,Vector3d.Y_AXIS);
        _rotationMatrix.transformPointSelf(_position)
    }
    public function appendRotationZ(p_val:Number ):void
    {
        _rotationMatrix.reset();
       _rotationMatrix.appendRotation(p_val,Vector3d.Z_AXIS);
        _rotationMatrix.transformPointSelf(_position)
    }
    public function setDirection(p_dir:int ):void
    {
         switch(p_dir)
         {
             case DIRECTION_TOP:
                 _position.reset(0,0,-1)
                 break;
             case DIRECTION_LEFT:
                 _position.reset(-1,0,0);
                 break;
             case DIRECTION_RIGHT:
                 _position.reset(1,0,0);
                 break;
             case DIRECTION_UP:
                 _position.reset(0,-1,0);
                 break;
             case DIRECTION_DOWN:
                 _position.reset(0,1,0);
                 break;

         }
    }

    public function get intensity():Number {
        return _intensity;
    }
}
}
