package scenes {
import flash.system.System;

import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.particles.PDData;
import starling.particles.PDParticleEmitter;
import starling.particles.ParticleEmitter;
import starling.text.TextField;
import starling.utils.formatString;

public class ParticleScene extends Scene {
    private var _emitter:Array = [];
    private var _emitterData:PDData;

    private var _pContainer:Sprite;

    public function ParticleScene() {
        _emitterData = new PDData(Game.assets.getXml("particle1"))

        _pContainer = new Sprite();
        addChild(_pContainer)
        var black:Quad = new Quad(Constants.GameWidth - 20, Constants.GameHeight - 100, 0x000000);
               black.x = 10;
               black.y = 20;
        _pContainer.addChild(black);

        addEventListener(Event.ENTER_FRAME, onEnterFrame);

    }

    private var mFrameCount:int = 0;
    private var mElapsed:Number = 0;
    private var mWaitFrames:int = 30;
    private var mFailCount:int = 0;
    private var mStarted:Boolean = true;

    private function onEnterFrame(event:EnterFrameEvent):void {
        if (!mStarted) return;
        mElapsed += event.passedTime;
        mFrameCount++;

        if (mFrameCount % mWaitFrames == 0) {
            var fps:Number = mWaitFrames / mElapsed;
            var targetFps:int = Starling.current.nativeStage.frameRate;

            if (Math.ceil(fps) >= targetFps) {
                mFailCount = 0;
                addTestObjects();
            }
            else {
                mFailCount++;

                if (mFailCount == 5)
                    benchmarkComplete(); // target fps not reached for a while
            }

            mElapsed = mFrameCount = 0;
        }


    }

    private var mResultText:TextField;

    private function benchmarkComplete():void {
        mStarted = false;
        var particles:int = 0;
        for each(var e:ParticleEmitter in _emitter) {
            particles += e.numParticles;
            Starling.juggler.remove(e);
        }
        _pContainer.removeChildren();

        var fps:int = Starling.current.nativeStage.frameRate;


        var resultString:String = formatString("Result:\n{0} particles\n{1} emitter\nwith {2} fps",
                particles,_emitter.length, fps);
        mResultText = new TextField(240, 200, resultString);
        mResultText.fontSize = 30;
        mResultText.x = Constants.CenterX - mResultText.width / 2;
        mResultText.y = Constants.CenterY - mResultText.height / 2;
        addChild(mResultText);


        System.pauseForGCIfCollectionImminent();
    }

    private function addTestObjects():void {

        var emiter:PDParticleEmitter = new PDParticleEmitter(Game.assets.getTexture("texture"), _emitterData);

        var pos:Number = Math.random() * 255;

        emiter.x = Constants.CenterX + pos - 120;
        emiter.y = Constants.CenterY + 30;

        emiter.startColor.red = pos / 255;
        emiter.start();

        _pContainer.addChild(emiter);
        Starling.juggler.add(emiter);
        _emitter.push(emiter)

    }



    public override function dispose():void {
        super.dispose();
    }
}
}