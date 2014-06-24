/**
 * Created by IntelliJ IDEA.
 * User: julian
 * Date: 20.02.14
 * Time: 12:43
 * To change this template use File | Settings | File Templates.
 */
package starling.particles {
import starling.textures.Texture;

public class PDParticleEmitter extends ParticleEmitter{
    private const EMITTER_TYPE_GRAVITY:int = 0;
    private const EMITTER_TYPE_RADIAL:int  = 1;

    // emitter configuration                            // .pex element name
    private var mEmitterType:int;                       // emitterType
    private var mEmitterXVariance:Number;               // sourcePositionVariance x
    private var mEmitterYVariance:Number;               // sourcePositionVariance y

    // particle configuration
    private var mMaxNumParticles:int;                   // maxParticles
    private var mLifespan:Number;                       // particleLifeSpan
    private var mLifespanVariance:Number;               // particleLifeSpanVariance
    private var mStartSize:Number;                      // startParticleSize
    private var mStartSizeVariance:Number;              // startParticleSizeVariance
    private var mEndSize:Number;                        // finishParticleSize
    private var mEndSizeVariance:Number;                // finishParticleSizeVariance
    private var mEmitAngle:Number;                      // angle
    private var mEmitAngleVariance:Number;              // angleVariance
    private var mStartRotation:Number;                  // rotationStart
    private var mStartRotationVariance:Number;          // rotationStartVariance
    private var mEndRotation:Number;                    // rotationEnd
    private var mEndRotationVariance:Number;            // rotationEndVariance

    // gravity configuration
    private var mSpeed:Number;                          // speed
    private var mSpeedVariance:Number;                  // speedVariance
    private var mGravityX:Number;                       // gravity x
    private var mGravityY:Number;                       // gravity y
    private var mRadialAcceleration:Number;             // radialAcceleration
    private var mRadialAccelerationVariance:Number;     // radialAccelerationVariance
    private var mTangentialAcceleration:Number;         // tangentialAcceleration
    private var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance

    // radial configuration
    private var mMaxRadius:Number;                      // maxRadius
    private var mMaxRadiusVariance:Number;              // maxRadiusVariance
    private var mMinRadius:Number;                      // minRadius
    private var mRotatePerSecond:Number;                // rotatePerSecond
    private var mRotatePerSecondVariance:Number;        // rotatePerSecondVariance

    // color configuration
    private var mStartColor:ColorArgb;                  // startColor
    private var mStartColorVariance:ColorArgb;          // startColorVariance
    private var mEndColor:ColorArgb;                    // finishColor
    private var mEndColorVariance:ColorArgb;            // finishColorVariance
    public function PDParticleEmitter(texture:Texture, data:PDData) {
        setData(data);

        var emissionRate:Number = mMaxNumParticles / mLifespan;
        super(texture, emissionRate, mMaxNumParticles, mBlendFactorSource, mBlendFactorDestination);
    }
    protected override function createParticle():ParticleDisplay
    {
        return new PDParticleDisplay()
    }
    protected override function initParticle(aParticle:ParticleDisplay):void
    {
        var particle:PDParticleDisplay = aParticle as PDParticleDisplay;
        // for performance reasons, the random variances are calculated inline instead
        // of calling a function

        var lifespan:Number = mLifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0);

        particle.currentTime = 0.0;
        particle.totalTime = lifespan > 0.0 ? lifespan : 0.0;

        if (lifespan <= 0.0) return;

        particle.x = mEmitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
        particle.y = mEmitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
        particle.startX = mEmitterX;
        particle.startY = mEmitterY;

        var angle:Number = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
        var speed:Number = mSpeed + mSpeedVariance * (Math.random() * 2.0 - 1.0);
        particle.velocityX = speed * Math.cos(angle);
        particle.velocityY = speed * Math.sin(angle);

        particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (Math.random() * 2.0 - 1.0);
        particle.emitRadiusDelta = mMaxRadius / lifespan;
        particle.emitRotation = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
        particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (Math.random() * 2.0 - 1.0);
        particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (Math.random() * 2.0 - 1.0);
        particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);

        var startSize:Number = mStartSize + mStartSizeVariance * (Math.random() * 2.0 - 1.0);
        var endSize:Number = mEndSize + mEndSizeVariance * (Math.random() * 2.0 - 1.0);
        if (startSize < 0.1) startSize = 0.1;
        if (endSize < 0.1)   endSize = 0.1;
        particle.scale = startSize / width;
        particle.scaleDelta = ((endSize - startSize) / lifespan) / width;

        // colors

        var startColor:ColorArgb = particle.colorArgb;
        var colorDelta:ColorArgb = particle.colorArgbDelta;

        startColor.red   = mStartColor.red;
        startColor.green = mStartColor.green;
        startColor.blue  = mStartColor.blue;
        startColor.alpha = mStartColor.alpha;

        if (mStartColorVariance.red != 0)   startColor.red   += mStartColorVariance.red   * (Math.random() * 2.0 - 1.0);
        if (mStartColorVariance.green != 0) startColor.green += mStartColorVariance.green * (Math.random() * 2.0 - 1.0);
        if (mStartColorVariance.blue != 0)  startColor.blue  += mStartColorVariance.blue  * (Math.random() * 2.0 - 1.0);
        if (mStartColorVariance.alpha != 0) startColor.alpha += mStartColorVariance.alpha * (Math.random() * 2.0 - 1.0);

        var endColorRed:Number   = mEndColor.red;
        var endColorGreen:Number = mEndColor.green;
        var endColorBlue:Number  = mEndColor.blue;
        var endColorAlpha:Number = mEndColor.alpha;

        if (mEndColorVariance.red != 0)   endColorRed   += mEndColorVariance.red   * (Math.random() * 2.0 - 1.0);
        if (mEndColorVariance.green != 0) endColorGreen += mEndColorVariance.green * (Math.random() * 2.0 - 1.0);
        if (mEndColorVariance.blue != 0)  endColorBlue  += mEndColorVariance.blue  * (Math.random() * 2.0 - 1.0);
        if (mEndColorVariance.alpha != 0) endColorAlpha += mEndColorVariance.alpha * (Math.random() * 2.0 - 1.0);

        colorDelta.red   = (endColorRed   - startColor.red)   / lifespan;
        colorDelta.green = (endColorGreen - startColor.green) / lifespan;
        colorDelta.blue  = (endColorBlue  - startColor.blue)  / lifespan;
        colorDelta.alpha = (endColorAlpha - startColor.alpha) / lifespan;

        // rotation

        var startRotation:Number = mStartRotation + mStartRotationVariance * (Math.random() * 2.0 - 1.0);
        var endRotation:Number   = mEndRotation   + mEndRotationVariance   * (Math.random() * 2.0 - 1.0);

        particle.rotation = startRotation;
        particle.rotationDelta = (endRotation - startRotation) / lifespan;
    }

    protected override function advanceParticle(aParticle:ParticleDisplay, passedTime:Number):void
    {
        var particle:PDParticleDisplay = aParticle as PDParticleDisplay;

        var restTime:Number = particle.totalTime - particle.currentTime;
        passedTime = restTime > passedTime ? passedTime : restTime;
        particle.currentTime += passedTime;

        if (mEmitterType == EMITTER_TYPE_RADIAL)
        {
            particle.emitRotation += particle.emitRotationDelta * passedTime;
            particle.emitRadius   -= particle.emitRadiusDelta   * passedTime;
            particle.x = mEmitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
            particle.y = mEmitterY - Math.sin(particle.emitRotation) * particle.emitRadius;

            if (particle.emitRadius < mMinRadius)
                particle.currentTime = particle.totalTime;
        }
        else
        {
            var distanceX:Number = particle.x - particle.startX;
            var distanceY:Number = particle.y - particle.startY;
            var distanceScalar:Number = Math.sqrt(distanceX*distanceX + distanceY*distanceY);
            if (distanceScalar < 0.01) distanceScalar = 0.01;

            var radialX:Number = distanceX / distanceScalar;
            var radialY:Number = distanceY / distanceScalar;
            var tangentialX:Number = radialX;
            var tangentialY:Number = radialY;

            radialX *= particle.radialAcceleration;
            radialY *= particle.radialAcceleration;

            var newY:Number = tangentialX;
            tangentialX = -tangentialY * particle.tangentialAcceleration;
            tangentialY = newY * particle.tangentialAcceleration;

            particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
            particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
            particle.x += particle.velocityX * passedTime;
            particle.y += particle.velocityY * passedTime;
        }

        particle.scale += particle.scaleDelta * passedTime;
        particle.rotation += particle.rotationDelta * passedTime;

        particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
        particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
        particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
        particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;

        particle.color = particle.colorArgb.toRgb();
        particle.alpha = particle.colorArgb.alpha;
    }

    private function updateEmissionRate():void
    {
        emissionRate = mMaxNumParticles / mLifespan;
    }

    private function setData(config:PDData):void
    {
        mEmitterXVariance =                 config.mEmitterXVariance;
        mEmitterYVariance =                 config.mEmitterYVariance;
        mGravityX =                         config.mGravityX;
        mGravityY =                         config.mGravityY;
        mEmitterType =                      config.mEmitterType;
        mMaxNumParticles =                  config.mMaxNumParticles;
        mLifespan =                         config.mLifespan;
        mLifespanVariance =                 config.mLifespanVariance;
        mStartSize =                        config.mStartSize;
        mStartSizeVariance =                config.mStartSizeVariance;
        mEndSize =                          config.mEndSize;
        mEndSizeVariance =                  config.mEndSizeVariance;
        mEmitAngle =                        config.mEmitAngle;
        mEmitAngleVariance =                config.mEmitAngleVariance;
        mStartRotation =                    config.mStartRotation;
        mStartRotationVariance =            config.mStartRotationVariance;
        mEndRotation =                      config.mEndRotation;
        mEndRotationVariance =              config.mEndRotationVariance;
        mSpeed =                            config.mSpeed;
        mSpeedVariance =                    config.mSpeedVariance;
        mRadialAcceleration =               config.mRadialAcceleration;
        mRadialAccelerationVariance =       config.mRadialAccelerationVariance;
        mTangentialAcceleration =           config.mTangentialAcceleration;
        mTangentialAccelerationVariance =   config.mTangentialAccelerationVariance;
        mMaxRadius =                        config.mMaxRadius;
        mMaxRadiusVariance =                config.mMaxRadiusVariance;
        mMinRadius =                        config.mMinRadius;
        mRotatePerSecond =                  config.mRotatePerSecond;
        mRotatePerSecondVariance =          config.mRotatePerSecondVariance;
        mStartColor =                       config.mStartColor.clon();
        mStartColorVariance =               config.mStartColorVariance.clon();
        mEndColor =                         config.mEndColor.clon();
        mEndColorVariance =                 config.mEndColorVariance.clon();
        mBlendFactorSource =                config.mBlendFactorSource;
        mBlendFactorDestination =           config.mBlendFactorDestination;


    }

    public function get emitterType():int { return mEmitterType; }
    public function set emitterType(value:int):void { mEmitterType = value; }

    public function get emitterXVariance():Number { return mEmitterXVariance; }
    public function set emitterXVariance(value:Number):void { mEmitterXVariance = value; }

    public function get emitterYVariance():Number { return mEmitterYVariance; }
    public function set emitterYVariance(value:Number):void { mEmitterYVariance = value; }

    public function get maxNumParticles():int { return mMaxNumParticles; }
    public function set maxNumParticles(value:int):void
    {
        maxCapacity = value;
        mMaxNumParticles = maxCapacity;
        updateEmissionRate();
    }


    public function get lifespan():Number { return mLifespan; }
    public function set lifespan(value:Number):void
    {
        mLifespan = Math.max(0.01, value);
        updateEmissionRate();
    }

    public function get lifespanVariance():Number { return mLifespanVariance; }
    public function set lifespanVariance(value:Number):void { mLifespanVariance = value; }

    public function get startSize():Number { return mStartSize; }
    public function set startSize(value:Number):void { mStartSize = value; }

    public function get startSizeVariance():Number { return mStartSizeVariance; }
    public function set startSizeVariance(value:Number):void { mStartSizeVariance = value; }

    public function get endSize():Number { return mEndSize; }
    public function set endSize(value:Number):void { mEndSize = value; }

    public function get endSizeVariance():Number { return mEndSizeVariance; }
    public function set endSizeVariance(value:Number):void { mEndSizeVariance = value; }

    public function get emitAngle():Number { return mEmitAngle; }
    public function set emitAngle(value:Number):void { mEmitAngle = value; }

    public function get emitAngleVariance():Number { return mEmitAngleVariance; }
    public function set emitAngleVariance(value:Number):void { mEmitAngleVariance = value; }

    public function get startRotation():Number { return mStartRotation; }
    public function set startRotation(value:Number):void { mStartRotation = value; }

    public function get startRotationVariance():Number { return mStartRotationVariance; }
    public function set startRotationVariance(value:Number):void { mStartRotationVariance = value; }

    public function get endRotation():Number { return mEndRotation; }
    public function set endRotation(value:Number):void { mEndRotation = value; }

    public function get endRotationVariance():Number { return mEndRotationVariance; }
    public function set endRotationVariance(value:Number):void { mEndRotationVariance = value; }

    public function get speed():Number { return mSpeed; }
    public function set speed(value:Number):void { mSpeed = value; }

    public function get speedVariance():Number { return mSpeedVariance; }
    public function set speedVariance(value:Number):void { mSpeedVariance = value; }

    public function get gravityX():Number { return mGravityX; }
    public function set gravityX(value:Number):void { mGravityX = value; }

    public function get gravityY():Number { return mGravityY; }
    public function set gravityY(value:Number):void { mGravityY = value; }

    public function get radialAcceleration():Number { return mRadialAcceleration; }
    public function set radialAcceleration(value:Number):void { mRadialAcceleration = value; }

    public function get radialAccelerationVariance():Number { return mRadialAccelerationVariance; }
    public function set radialAccelerationVariance(value:Number):void { mRadialAccelerationVariance = value; }

    public function get tangentialAcceleration():Number { return mTangentialAcceleration; }
    public function set tangentialAcceleration(value:Number):void { mTangentialAcceleration = value; }

    public function get tangentialAccelerationVariance():Number { return mTangentialAccelerationVariance; }
    public function set tangentialAccelerationVariance(value:Number):void { mTangentialAccelerationVariance = value; }

    public function get maxRadius():Number { return mMaxRadius; }
    public function set maxRadius(value:Number):void { mMaxRadius = value; }

    public function get maxRadiusVariance():Number { return mMaxRadiusVariance; }
    public function set maxRadiusVariance(value:Number):void { mMaxRadiusVariance = value; }

    public function get minRadius():Number { return mMinRadius; }
    public function set minRadius(value:Number):void { mMinRadius = value; }

    public function get rotatePerSecond():Number { return mRotatePerSecond; }
    public function set rotatePerSecond(value:Number):void { mRotatePerSecond = value; }

    public function get rotatePerSecondVariance():Number { return mRotatePerSecondVariance; }
    public function set rotatePerSecondVariance(value:Number):void { mRotatePerSecondVariance = value; }

    public function get startColor():ColorArgb { return mStartColor; }
    public function set startColor(value:ColorArgb):void { mStartColor = value; }

    public function get startColorVariance():ColorArgb { return mStartColorVariance; }
    public function set startColorVariance(value:ColorArgb):void { mStartColorVariance = value; }

    public function get endColor():ColorArgb { return mEndColor; }
    public function set endColor(value:ColorArgb):void { mEndColor = value; }

    public function get endColorVariance():ColorArgb { return mEndColorVariance; }
    public function set endColorVariance(value:ColorArgb):void { mEndColorVariance = value; }
}
}
