/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 02.07.14
 * Time: 17:58
 * To change this template use File | Settings | File Templates.
 */
package scenes {
import flash.system.System;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.utils.formatString;

public class TextBenchmarkScene extends Scene
    {
        private var mStartButton:Button;
        private var mStartButtonDF:Button;
        private var mResultText:TextField;

        private var mContainer:Sprite;
        private var mFrameCount:int;
        private var mElapsed:Number;
        private var mStarted:Boolean;
        private var mFailCount:int;
        private var mWaitFrames:int;
        private var _addDFFonts:Boolean;

        public function TextBenchmarkScene()
        {
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

            mStartButtonDF = new Button(Game.assets.getTexture("button_normal"), "Start DF benchmark");
            mStartButtonDF.addEventListener(Event.TRIGGERED, onStartDFButtonTriggered);
            mStartButtonDF.x = Constants.CenterX - int(mStartButton.width / 2);
            mStartButtonDF.y = 70;
            addChild(mStartButtonDF);

            mStarted = false;
            mElapsed = 0.0;

            var bmFont: BitmapFont = new BitmapFont(Game.assets.getTexture("segoe_texture"),Game.assets.getByteArray("segoe"))
            bmFont.distanceFieldFont = true
            bmFont.dfSpread = 3
            TextField.registerBitmapFont(bmFont,"segoe_df");

            var bmFont: BitmapFont = new BitmapFont(Game.assets.getTexture("segoe_texture"),Game.assets.getByteArray("segoe"))
           TextField.registerBitmapFont(bmFont,"segoe");

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        public override function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            mStartButton.removeEventListener(Event.TRIGGERED, onStartButtonTriggered);
            mStartButtonDF.removeEventListener(Event.TRIGGERED, onStartDFButtonTriggered);
            super.dispose();
        }

        private function onEnterFrame(event:EnterFrameEvent):void
        {
            if (!mStarted) return;

            mElapsed += event.passedTime;
            mFrameCount++;

            if (mFrameCount % mWaitFrames == 0)
            {
                var fps:Number = mWaitFrames / mElapsed;
                var targetFps:int = Starling.current.nativeStage.frameRate;

                if (Math.ceil(fps) >= targetFps)
                {
                    mFailCount = 0;
                    addTestObjects();
                }
                else
                {
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
        private function onStartDFButtonTriggered():void
        {
            _addDFFonts = true;
            onStartButtonTriggered();
        }
        private function onStartButtonTriggered():void
        {
            trace("Starting benchmark");

            mStartButton.visible = false;
            mStartButtonDF.visible = false;
            mStarted = true;
            mFailCount = 0;
            mWaitFrames = 2;
            mFrameCount = 0;

            if (mResultText)
            {
                mResultText.removeFromParent(true);
                mResultText = null;
            }

            addTestObjects();
        }

        private function addTestObjects():void
        {
            var padding:int = 45;


            if(_addDFFonts)
            {
                var textField1:TextField = new TextField(300,100,"HelloHelloHelloHello", "segoe_df",20,0xffffff);
               textField1.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
               textField1.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);
               textField1.centerPivot();
               textField1.touchable = false;

               textField1.dfSharpness = .4;
               textField1.dfShadowSize = 3;
               textField1.dfShadowAlpha = 1;
               textField1.dfEffect = TextField.DF_EFFECT_GLOW;
               addChild(textField1);

               mContainer.addChild(textField1);
            } else
            {
                var textField1:TextField = new TextField(300,100,"HelloHelloHelloHello", "segoe",20,0xffffff);
                 textField1.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
                 textField1.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);
                 textField1.centerPivot();
                 textField1.touchable = false;
                 addChild(textField1);

                 mContainer.addChild(textField1);
            }

        }

        private function benchmarkComplete():void
        {
            mStarted = false;
            mStartButton.visible = true;
            mStartButtonDF.visible = true;

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