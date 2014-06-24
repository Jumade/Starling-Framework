/**
 * Created by IntelliJ IDEA.
 * User: julian
 * Date: 20.02.14
 * Time: 12:45
 * To change this template use File | Settings | File Templates.
 */
package starling.particles {
public class PDParticleDisplay extends ParticleDisplay {
    public var colorArgb:ColorArgb;
    public var colorArgbDelta:ColorArgb;
    public var startX:Number, startY:Number;
    public var velocityX:Number, velocityY:Number;
    public var radialAcceleration:Number;
    public var tangentialAcceleration:Number;
    public var emitRadius:Number, emitRadiusDelta:Number;
    public var emitRotation:Number, emitRotationDelta:Number;
    public var rotationDelta:Number;
    public var scaleDelta:Number;
    public function PDParticleDisplay() {
        colorArgb = new ColorArgb();
        colorArgbDelta = new ColorArgb();
    }
}
}
