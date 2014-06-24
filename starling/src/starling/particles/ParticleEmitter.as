

// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.particles
{
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DTextureFormat;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;

import starling.animation.IAnimatable;
import starling.core.RenderSupport;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

/** Dispatched when emission of particles is finished. */
[Event(name="complete", type="starling.events.Event")]

public class ParticleEmitter extends Image implements IAnimatable
{
    protected var mParticles:Array
    protected var mFrameTime:Number;


    protected var mNumParticles:int;
    protected var mMaxCapacity:int;
    protected var mEmissionRate:Number; // emitted particles per second
    protected var mEmissionTime:Number;

    /** Helper objects. */
    protected var mEmitterX:Number;
    protected var mEmitterY:Number;
    protected var mPremultipliedAlpha:Boolean;
    protected var mBlendFactorSource:String;
    protected var mBlendFactorDestination:String;
    protected var mSmoothing:String;

    public function ParticleEmitter(texture:Texture, emissionRate:Number,maxCapacity:int=8192,
                                   blendFactorSource:String=null, blendFactorDest:String=null)
    {

        super(texture);
        projectionMatrix = new Matrix();
        projectionMatrix3D = new Matrix3D;

        mPremultipliedAlpha = texture.premultipliedAlpha;
        mParticles = []
        mEmissionRate = emissionRate;
        mEmissionTime = 0.0;
        mFrameTime = 0.0;
        mEmitterX = mEmitterY = 0;
        mMaxCapacity =  maxCapacity;
        mSmoothing = TextureSmoothing.BILINEAR;

        mBlendFactorDestination = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
        mBlendFactorSource = blendFactorSource ||
                (mPremultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);


      
    }

   

    protected function createParticle():ParticleDisplay
    {
        return new ParticleDisplay();
    }

    protected function initParticle(particle:ParticleDisplay):void
    {
        particle.pma = mTexture.premultipliedAlpha
        particle.x = mEmitterX;
        particle.y = mEmitterY;
        particle.currentTime = 0;
        particle.totalTime = 1;
        //particle.color = Math.random() * 0xffffff;
    }

    protected function advanceParticle(particle:ParticleDisplay, passedTime:Number):void
    {
        particle.y += passedTime * 250;
        particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
        particle.scale = 1.0 - particle.alpha;
        particle.currentTime += passedTime;
    }

  
    /** Starts the emitter for a certain time. @default infinite time */
    public function start(duration:Number=Number.MAX_VALUE):void
    {
        if (mEmissionRate != 0)
            mEmissionTime = duration;
    }

    /** Stops emitting new particles. Depending on 'clearParticles', the existing particles
     *  will either keep animating until they die or will be removed right away. */
    public function stop(clearParticles:Boolean=false):void
    {
        mEmissionTime = 0.0;
        if (clearParticles) clear();
    }

    /** Removes all currently active particles. */
    public function clear():void
    {
        mNumParticles = 0;
        dispatchEvent(new Event(Event.COMPLETE));
    }

    /** Returns an empty rectangle at the particle system's position. Calculating the
     *  actual bounds would be too expensive. */
    public override function getBounds(targetSpace:DisplayObject,
                                       resultRect:Rectangle=null):Rectangle
    {
        if (resultRect == null) resultRect = new Rectangle();

       
        resultRect.x = 0;
        resultRect.y = 0;
        resultRect.width = resultRect.height = 0;

        return resultRect;
    }
    public function advanceTime(passedTime:Number):void
    {
        var particleIndex:int = 0;
        var particle:ParticleDisplay;

        // advance existing particles

        while (particleIndex < mNumParticles)
        {
            particle = mParticles[particleIndex] as ParticleDisplay;

            if (particle.currentTime < particle.totalTime)
            {
                advanceParticle(particle, passedTime);
                ++particleIndex;
            }
            else
            {
                if (particleIndex != mNumParticles - 1)
                {
                    var nextParticle:ParticleDisplay = mParticles[int(mNumParticles-1)] as ParticleDisplay;
                    mParticles[int(mNumParticles-1)] = particle;
                    mParticles[particleIndex] = nextParticle;
                }

                --mNumParticles;

                if (mNumParticles == 0 && mEmissionTime == 0)
                    dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        // create and advance new particles

        if (mEmissionTime > 0)
        {
            var timeBetweenParticles:Number = 1.0 / mEmissionRate;
            mFrameTime += passedTime;

            while (mFrameTime > 0)
            {
                if (mNumParticles < mMaxCapacity)
                {
                   
                    particle = mParticles[mNumParticles] as ParticleDisplay;
                    
                    if(!particle)
                    {
                        particle = createParticle()
                        mParticles[mNumParticles] =  particle;
                    }
                    
                    initParticle(particle);

                    // particle might be dead at birth
                    if (particle.totalTime > 0.0)
                    {
                        advanceParticle(particle, mFrameTime);
                        ++mNumParticles
                    }
                }

                mFrameTime -= timeBetweenParticles;
            }

            if (mEmissionTime != Number.MAX_VALUE)
                mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
        }

    }
    private var projectionMatrix3D:Matrix3D;
    private var projectionMatrix:Matrix;
    public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void
    {
        if (mNumParticles == 0) return;



        updateTransform(p_parentUpdateTransform);

        if(stateChanged)
        {
            updateStateID()
            stateChanged = false;
        }


        for(var i:int = 0; i < mNumParticles; i++) 
            support.drawParticle(this,mParticles[i]);
        
       // support.finishQuadBatch();

       // support.setProjectionMatrix()
       // support.setQuadVertex();
    }
    protected override  function updateStateID():void
    {
        stateId = 0;


       stateId |= 1;
        if (mTexture.mipMapping) stateId |= 1 << 1;
        if (mTexture.repeat) stateId |= 1 << 2;

        if (smoothing == TextureSmoothing.NONE)
            stateId |= 1 << 3;
        else if (smoothing == TextureSmoothing.TRILINEAR)
            stateId |= 1 << 4;

        if (mTexture.format == Context3DTextureFormat.COMPRESSED)
            stateId |= 1 << 5;
        else if (mTexture.format == "compressedAlpha")
            stateId |= 1 << 6;

        programId = stateId;


        if(worldBlendmode == BlendMode.NORMAL)
            stateId |= 1 << 7;
        else if(worldBlendmode == BlendMode.ADD)
            stateId |= 1 << 8;
        else if(worldBlendmode == BlendMode.ERASE)
            stateId |= 1 << 9;
        else if(worldBlendmode == BlendMode.MULTIPLY)
            stateId |= 1 << 10;
        else if(worldBlendmode == BlendMode.NONE)
            stateId |= 1 << 11;
        else if(worldBlendmode == BlendMode.SCREEN)
            stateId |= 1 << 12;

        if (premultipliedAlpha)
            stateId |= 1 << 13;

        //trace("updateStateID",programId,smoothing);
    }
 
   

    public function get isEmitting():Boolean { return mEmissionTime > 0 && mEmissionRate > 0; }
    public function get numParticles():int { return mNumParticles; }

    public function get maxCapacity():int { return mMaxCapacity; }
    public function set maxCapacity(value:int):void { mMaxCapacity = Math.min(8192, value); }

    public function get emissionRate():Number { return mEmissionRate; }
    public function set emissionRate(value:Number):void { mEmissionRate = value; }

    public function get emitterX():Number { return mEmitterX; }
    public function set emitterX(value:Number):void { mEmitterX = value; }

    public function get emitterY():Number { return mEmitterY; }
    public function set emitterY(value:Number):void { mEmitterY = value; }

    public function get blendFactorSource():String { return mBlendFactorSource; }
    public function set blendFactorSource(value:String):void { mBlendFactorSource = value; }

    public function get blendFactorDestination():String { return mBlendFactorDestination; }
    public function set blendFactorDestination(value:String):void { mBlendFactorDestination = value; }


}
}

