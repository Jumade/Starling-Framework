/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 22.07.14
 * Time: 14:16
 * To change this template use File | Settings | File Templates.
 */
package starling.light {
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Point3d;
import net.richardlord.coral.Vector3d;

public class PointLight extends Light{
    private var _distance:Number;
    private var _color:uint;
    public var colorR:Number;
   public var colorG:Number;
   public var colorB:Number;
    public var position:Point3d = new Point3d() ;
    public function PointLight(p_distance:Number, p_color:uint) {
        this._distance = p_distance;
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


    public function get distance():Number {
        return _distance;
    }
}
}
