package starling.particles
{


public class ParticleDisplay
{

    protected var _color:uint = 0xffffff;
    public var colorR:Number = 1;
    public var colorG:Number= 1;
    public var colorB:Number= 1;
    protected var _alpha:Number = 1;
    public var scale:Number = 1;
    public var rotation:Number = 1;

    public var currentTime:Number;
    public var totalTime:Number;
    public var x:Number;
    public var y:Number;
    public var pma:Boolean;

    public function ParticleDisplay()
    {

        x = y = rotation = currentTime = 0.0;
        totalTime = _alpha = scale = 1.0;
    }

    /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
    public function get color():uint
    {
        return _color
    }
    /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
    public function get alpha():Number
    {
        return _alpha
    }

    /** Sets the colors of all vertices to a certain value. */
    public function set color(value:uint):void
    {
        if(value != _color)
        {
            _color = value;
           var multiplier:Number = pma ? _alpha : 1.0;
           colorR = ((_color >> 16) & 0xff) / 255.0 * multiplier;
           colorG = ((_color >>  8) & 0xff) / 255.0 * multiplier;
           colorB = ( _color        & 0xff) / 255.0 * multiplier;
        }



    }

    /** Sets the colors of all vertices to a certain value. */
    public function set alpha(value:Number):void
    {
        if(value != _alpha)
        {
            _alpha = value;
           var multiplier:Number = pma ? _alpha : 1.0;
           colorR = ((_color >> 16) & 0xff) / 255.0 * multiplier;
           colorG = ((_color >>  8) & 0xff) / 255.0 * multiplier;
           colorB = ( _color        & 0xff) / 255.0 * multiplier;
        }



    }

}
}
