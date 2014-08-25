/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 23.08.14
 * Time: 12:50
 * To change this template use File | Settings | File Templates.
 */
package starling.camera {
import net.richardlord.coral.Matrix3d;
import net.richardlord.coral.Vector3d;

public class OrbitCameraController {
    private var _camera:Camera;
    private var _distance:Number;

    private const X_AXIS:Vector3d = Vector3d.X_AXIS;
       private const Y_AXIS:Vector3d = Vector3d.Y_AXIS;
       private const Z_AXIS:Vector3d = Vector3d.Z_AXIS;
    public function OrbitCameraController(p_camera:Camera, p_distance:Number) {
        this._camera = p_camera;
        this._distance = p_distance;
        _camera.position.z = _distance;
    }

    private var _helperMatrix:Matrix3d = new Matrix3d()
    public function move(p_x:Number,p_y:Number):void
    {
        _camera.rotation.appendRotation(-p_x,X_AXIS)
        _camera.rotation.appendRotation(-p_y,Y_AXIS)

        _camera.position.x = 0;
        _camera.position.y = 0;
        _camera.position.z = _distance;

        _camera.rotation.inverse(_helperMatrix)
        _helperMatrix.transformVectorSelf(_camera.position);
    }

    public function get distance():Number {
        return _distance;
    }

    public function set distance(value:Number):void {
        _distance = value;
    }
}
}
