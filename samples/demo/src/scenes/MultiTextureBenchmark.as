package scenes {
import flash.system.System;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.text.TextField;
import starling.utils.formatString;

public class MultiTextureBenchmark extends Scene {
    private var mStartButton:Button;
    private var mResultText:TextField;

    private var mContainer:Sprite;
    private var mFrameCount:int;
    private var mElapsed:Number;
    private var mStarted:Boolean;
    private var mFailCount:int;
    private var mWaitFrames:int;

    public function MultiTextureBenchmark() {
        super();

        // the container will hold all test objects
        mContainer = new Sprite();
        mContainer.touchable = false; // we do not need touch events on the test objects --
        // thus, it is more efficient to disable them.
        addChildAt(mContainer, 0);

        mStartButton = new Button(Game.assets.getTexture("button_normal"), "Start benchmark");
        mStartButton.addEventListener(Event.TRIGGERED, onStartButtonTriggered);
        mStartButton.x = Constants.CenterX - int(mStartButton.width / 2);
        mStartButton.y = 20;
        addChild(mStartButton);

        mStarted = false;
        mElapsed = 0.0;

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public override function dispose():void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        mStartButton.removeEventListener(Event.TRIGGERED, onStartButtonTriggered);
        super.dispose();
    }

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

                if (mFailCount > 20)
                    mWaitFrames = 5; // slow down creation process to be more exact
                if (mFailCount > 30)
                    mWaitFrames = 10;
                if (mFailCount == 40)
                    benchmarkComplete(); // target fps not reached for a while
            }

            mElapsed = mFrameCount = 0;
        }

        var numObjects:int = mContainer.numChildren;
        var passedTime:Number = event.passedTime;


    }

    private function onStartButtonTriggered():void {

        mStartButton.visible = false;
        mStarted = true;
        mFailCount = 0;
        mWaitFrames = 2;
        mFrameCount = 0;

        if (mResultText) {
            mResultText.removeFromParent(true);
            mResultText = null;
        }

        addTestObjects();
    }

    private function addTestObjects():void {
        var padding:int = 5;
        var numObjects:int = mFailCount > 20 ? 2 : 5;

        for (var i:int = 0; i < numObjects; ++i) {
            var egg:Image = new Image(Game.assets.getTexture("benchmark_object"));
            egg.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
            egg.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);

            egg.scaleX = egg.scaleY = .2;
            egg.multiTextureBatch = true;
            mContainer.addChild(egg);

            var egg1:Image = new Image(Game.assets.getTexture("texture"));
            egg1.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
            egg1.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);

            egg1.scaleX = egg1.scaleY = .3;
            egg1.multiTextureBatch = true;
            mContainer.addChild(egg1);
        }


    }

    private function benchmarkComplete():void {
        mStarted = false;
        mStartButton.visible = true;

        var fps:int = Starling.current.nativeStage.frameRate;

        trace("Benchmark complete!");
        trace("FPS: " + fps);
        trace("Number of objects: " + mContainer.numChildren);

        var resultString:String = formatString("Result:\n{0} objects\nwith {1} fps",
                mContainer.numChildren, fps);
        mResultText = new TextField(240, 200, resultString);
        mResultText.fontSize = 30;
        mResultText.x = Constants.CenterX - mResultText.width / 2;
        mResultText.y = Constants.CenterY - mResultText.height / 2;

        addChild(mResultText);

        mContainer.removeChildren();
        System.pauseForGCIfCollectionImminent();
    }


}
}
