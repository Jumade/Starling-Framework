/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 13.07.14
 * Time: 11:56
 * To change this template use File | Settings | File Templates.
 */
package starling.display {
import starling.core.RenderSupport;

public class ColorVoxel extends Quad{

   private var _alpha:Number = 1;

    public var worldZ:Number = 0;
    private var mZ:Number = 0;

    public function ColorVoxel(p_size:Number, p_color:uint=0xffffff,
                                 premultipliedAlpha:Boolean=true) {
         super(p_size,p_size,p_color,premultipliedAlpha)

    }



    override public function updateTransform(p_parent:Boolean):Boolean {

        if(super.updateTransform(p_parent))
        {
            worldZ = -mZ;

          return true;
        } else return false;

    }

    /** @inheritDoc */
    public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void
    {
        p_parentUpdateTransform = updateTransform(p_parentUpdateTransform);
        p_parentUpdateColor = updateColor(p_parentUpdateColor);



        if(p_draw && hasVisibleArea)
             support.drawColorVoxel(this);
    }
    /** The x coordinate of the object relative to the local coordinates of the parent. */
    public function get z():Number { return mZ; }
    public function set z(value:Number):void
    {
       if (mZ != value)
       {
           mZ = value;
           mTransformChanged = true;
           transformDirty = true;
       }
    }

}
}
