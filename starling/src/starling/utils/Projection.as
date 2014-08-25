/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 19.07.14
 * Time: 23:09
 * To change this template use File | Settings | File Templates.
 */
package starling.utils {
import net.richardlord.coral.Matrix3d;

public class Projection {
    private var _matrix:Matrix3d = new Matrix3d()
    public function Projection() {
    }

    public function setPerspectiveProjection(p_width:int, p_height:int, p_perspective:Number, p_near:Number, p_far:Number):void
    {
        var f:Number = 1.0 / ((p_width * .5) / p_perspective);
        var aspect:Number = p_width / p_height;

        _matrix.n11 = f;
        _matrix.n12 = 0;
        _matrix.n13 = 0;
        _matrix.n14 = 0;

        _matrix.n21 = 0;
        _matrix.n22 = -f * aspect;
        _matrix.n23 = 0;
        _matrix.n24 = 0;

        _matrix.n31 = 0;
        _matrix.n32 = 0;
        _matrix.n33 = p_far / (p_near - p_far);
        _matrix.n34 =  (p_far * p_near) / (p_near - p_far);

        _matrix.n41 = 0;
        _matrix.n42 = 0;
        _matrix.n43 = -1;
        _matrix.n44 = 0;


       // _matrix = _matrix1
    }
    public function setOrthographicProjection(p_width:int, p_height:int):void
    {


        _matrix.n11 = 2.0/p_width;
        _matrix.n12 = 0;
        _matrix.n13 = 0;
        _matrix.n14 = 0;

        _matrix.n21 = 0;
        _matrix.n22 = -2.0/p_height;
        _matrix.n23 = 0;
        _matrix.n24 = 0;

        _matrix.n31 = 0;
        _matrix.n32 = 0;
        _matrix.n33 = 1;
        _matrix.n34 = 0;

        _matrix.n41 = 0;
        _matrix.n42 = 0;
        _matrix.n43 = 0;
        _matrix.n44 = 1;

    }


    public function get matrix():Matrix3d {
        return _matrix;
    }
}
}
