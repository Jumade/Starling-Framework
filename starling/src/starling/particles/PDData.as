/**
 * Created by IntelliJ IDEA.
 * User: julian
 * Date: 20.11.13
 * Time: 10:18
 * To change this template use File | Settings | File Templates.
 */
package starling.particles {
import flash.display3D.Context3DBlendFactor;

import starling.utils.deg2rad;

public class PDData {
    // emitter configuration                            // .pex element name
    public var mEmitterType:int;                       // emitterType
    public var mEmitterXVariance:Number;               // sourcePositionVariance x
    public var mEmitterYVariance:Number;               // sourcePositionVariance y

    // particle configuration
    public var mMaxNumParticles:int;                   // maxParticles
    public var mLifespan:Number;                       // particleLifeSpan
    public var mLifespanVariance:Number;               // particleLifeSpanVariance
    public var mStartSize:Number;                      // startParticleSize
    public var mStartSizeVariance:Number;              // startParticleSizeVariance
    public var mEndSize:Number;                        // finishParticleSize
    public var mEndSizeVariance:Number;                // finishParticleSizeVariance
    public var mEmitAngle:Number;                      // angle
    public var mEmitAngleVariance:Number;              // angleVariance
    public var mStartRotation:Number;                  // rotationStart
    public var mStartRotationVariance:Number;          // rotationStartVariance
    public var mEndRotation:Number;                    // rotationEnd
    public var mEndRotationVariance:Number;            // rotationEndVariance

    // gravity configuration
    public var mSpeed:Number;                          // speed
    public var mSpeedVariance:Number;                  // speedVariance
    public var mGravityX:Number;                       // gravity x
    public var mGravityY:Number;                       // gravity y
    public var mRadialAcceleration:Number;             // radialAcceleration
    public var mRadialAccelerationVariance:Number;     // radialAccelerationVariance
    public var mTangentialAcceleration:Number;         // tangentialAcceleration
    public var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance

    // radial configuration
    public var mMaxRadius:Number;                      // maxRadius
    public var mMaxRadiusVariance:Number;              // maxRadiusVariance
    public var mMinRadius:Number;                      // minRadius
    public var mRotatePerSecond:Number;                // rotatePerSecond
    public var mRotatePerSecondVariance:Number;        // rotatePerSecondVariance

    // color configuration
    public var mStartColor:ColorArgb;                  // startColor
    public var mStartColorVariance:ColorArgb;          // startColorVariance
    public var mEndColor:ColorArgb;                    // finishColor
    public var mEndColorVariance:ColorArgb;            // finishColorVariance

    public var mBlendFactorSource:String;
    public var mBlendFactorDestination:String;
    public function PDData(config:XML) {
        parseConfig(config);
    }
    private function parseConfig(config:XML):void
    {
        mEmitterXVariance = parseFloat(config.sourcePositionVariance.attribute("x"));
        mEmitterYVariance = parseFloat(config.sourcePositionVariance.attribute("y"));
        mGravityX = parseFloat(config.gravity.attribute("x"));
        mGravityY = parseFloat(config.gravity.attribute("y"));
        mEmitterType = getIntValue(config.emitterType);
        mMaxNumParticles = getIntValue(config.maxParticles);
        mLifespan = Math.max(0.01, getFloatValue(config.particleLifeSpan));
        mLifespanVariance = getFloatValue(config.particleLifespanVariance);
        mStartSize = getFloatValue(config.startParticleSize);
        mStartSizeVariance = getFloatValue(config.startParticleSizeVariance);
        mEndSize = getFloatValue(config.finishParticleSize);
        mEndSizeVariance = getFloatValue(config.FinishParticleSizeVariance);
        mEmitAngle = deg2rad(getFloatValue(config.angle));
        mEmitAngleVariance = deg2rad(getFloatValue(config.angleVariance));
        mStartRotation = deg2rad(getFloatValue(config.rotationStart));
        mStartRotationVariance = deg2rad(getFloatValue(config.rotationStartVariance));
        mEndRotation = deg2rad(getFloatValue(config.rotationEnd));
        mEndRotationVariance = deg2rad(getFloatValue(config.rotationEndVariance));
        mSpeed = getFloatValue(config.speed);
        mSpeedVariance = getFloatValue(config.speedVariance);
        mRadialAcceleration = getFloatValue(config.radialAcceleration);
        mRadialAccelerationVariance = getFloatValue(config.radialAccelVariance);
        mTangentialAcceleration = getFloatValue(config.tangentialAcceleration);
        mTangentialAccelerationVariance = getFloatValue(config.tangentialAccelVariance);
        mMaxRadius = getFloatValue(config.maxRadius);
        mMaxRadiusVariance = getFloatValue(config.maxRadiusVariance);
        mMinRadius = getFloatValue(config.minRadius);
        mRotatePerSecond = deg2rad(getFloatValue(config.rotatePerSecond));
        mRotatePerSecondVariance = deg2rad(getFloatValue(config.rotatePerSecondVariance));
        mStartColor = getColor(config.startColor);
        mStartColorVariance = getColor(config.startColorVariance);
        mEndColor = getColor(config.finishColor);
        mEndColorVariance = getColor(config.finishColorVariance);
        mBlendFactorSource = getBlendFunc(config.blendFuncSource);
        mBlendFactorDestination = getBlendFunc(config.blendFuncDestination);

        // compatibility with future Particle Designer versions
        // (might fix some of the uppercase/lowercase typos)

        if (isNaN(mEndSizeVariance))
            mEndSizeVariance = getFloatValue(config.finishParticleSizeVariance);
        if (isNaN(mLifespan))
            mLifespan = Math.max(0.01, getFloatValue(config.particleLifespan));
        if (isNaN(mLifespanVariance))
            mLifespanVariance = getFloatValue(config.particleLifeSpanVariance);

        function getIntValue(element:XMLList):int
        {
            return parseInt(element.attribute("value"));
        }

        function getFloatValue(element:XMLList):Number
        {
            return parseFloat(element.attribute("value"));
        }

        function getColor(element:XMLList):ColorArgb
        {
            var color:ColorArgb = new ColorArgb();
            color.red   = parseFloat(element.attribute("red"));
            color.green = parseFloat(element.attribute("green"));
            color.blue  = parseFloat(element.attribute("blue"));
            color.alpha = parseFloat(element.attribute("alpha"));
            return color;
        }

        function getBlendFunc(element:XMLList):String
        {
            var value:int = getIntValue(element);
            switch (value)
            {
                case 0:     return Context3DBlendFactor.ZERO; break;
                case 1:     return Context3DBlendFactor.ONE; break;
                case 0x300: return Context3DBlendFactor.SOURCE_COLOR; break;
                case 0x301: return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR; break;
                case 0x302: return Context3DBlendFactor.SOURCE_ALPHA; break;
                case 0x303: return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA; break;
                case 0x304: return Context3DBlendFactor.DESTINATION_ALPHA; break;
                case 0x305: return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA; break;
                case 0x306: return Context3DBlendFactor.DESTINATION_COLOR; break;
                case 0x307: return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR; break;
                default:    throw new ArgumentError("unsupported blending function: " + value);
            }
        }
    }

}
}
