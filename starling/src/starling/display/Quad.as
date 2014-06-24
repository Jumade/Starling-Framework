// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display
{
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.core.RenderSupport;

/** A Quad represents a rectangle with a uniform color or a color gradient.
     *  
     *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
     *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
     *  another color to vertices 2 and 3. </p> 
     *
     *  <p>The indices of the vertices are arranged like this:</p>
     *  
     *  <pre>
     *  0 - 1
     *  | / |
     *  2 - 3
     *  </pre>
     * 
     *  @see Image
     */
    public class Quad extends DisplayObject
    {
        public var mTinted:Boolean;

        protected var _premultipliedAlpha:Boolean;
        protected var _color:uint;
        public var colorR:Number;
        public var colorG:Number;
        public var colorB:Number;
        private var _alpha:Number;
        protected var mWidth:Number = 0;
        protected var mHeight:Number= 0;
        public var worldWidth:Number = 0;
        public var worldHeight:Number = 0;
        public var programId:int = -1;
        public var stateId:int = -1;
        protected var stateChanged:Boolean = true;
        protected var updateSize:Boolean = true;
    protected var _brightness:Number = 1;

        protected var _clipWidth:Number = 1;
        protected var _clipHeight:Number = 1;
        protected var _clipWidthScale:Number = 1;
        protected var _clipHeightScale:Number = 1;
        /** Creates a quad with a certain size and color. The last parameter controls if the
         *  alpha value should be premultiplied into the color values on rendering, which can
         *  influence blending output. You can use the default value in most cases.  */
        public function Quad(p_width:Number, p_height:Number, p_color:uint=0xffffff,
                             premultipliedAlpha:Boolean=true)
        {
            this._premultipliedAlpha = premultipliedAlpha;
            mTinted = color != 0xffffff;
            width = p_width;
            height = p_height;
            color = p_color;


        }

        /** Call this method after manually changing the contents of 'mVertexData'. */
        protected function onVertexDataChanged():void
        {
            // override in subclasses, if necessary
        }
        public override function getCurrentTargetBound(resultRect:Rectangle):void
        {

         
            var quadPoint1x:Number = -targetBoundPivotX;
            var quadPoint1y:Number = -targetBoundPivotY;
            var quadPoint2x:Number = (mWidth * targetBoundScaleX)-targetBoundPivotX;
            var quadPoint2y:Number = -targetBoundPivotY;
            var quadPoint3x:Number = -targetBoundPivotX;
            var quadPoint3y:Number = (mHeight * targetBoundScaleY)-targetBoundPivotY;
            var quadPoint4x:Number = (mWidth * targetBoundScaleX)-targetBoundPivotX;
            var quadPoint4y:Number = (mHeight * targetBoundScaleY)-targetBoundPivotY;


            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
            if(targetBoundRotation != 0)
            {
                var sin:Number = Math.sin(targetBoundRotation);
                var cos:Number = Math.cos(targetBoundRotation);


                quadPoint1x = targetBoundX + (quadPoint1x * cos -quadPoint1y * sin);
                quadPoint1y = targetBoundY + (quadPoint1y * cos +quadPoint1x * sin);
                quadPoint2x = targetBoundX + (quadPoint2x * cos -quadPoint2y * sin);
                quadPoint2y = targetBoundY + (quadPoint2y * cos +quadPoint2x * sin);
                quadPoint3x = targetBoundX + (quadPoint3x * cos -quadPoint3y * sin);
                quadPoint3y = targetBoundY + (quadPoint3y * cos +quadPoint3x * sin);
                quadPoint4x = targetBoundX + (quadPoint4x * cos -quadPoint4y * sin);
                quadPoint4y = targetBoundY + (quadPoint4y * cos +quadPoint4x * sin);


                if (minX > quadPoint1x) minX = quadPoint1x;
                if (maxX < quadPoint1x) maxX = quadPoint1x;
                if (minY > quadPoint1y) minY = quadPoint1y;
                if (maxY < quadPoint1y) maxY = quadPoint1y;

                if (minX > quadPoint2x) minX = quadPoint2x;
                if (maxX < quadPoint2x) maxX = quadPoint2x;
                if (minY > quadPoint2y) minY = quadPoint2y;
                if (maxY < quadPoint2y) maxY = quadPoint2y;

                if (minX > quadPoint3x) minX = quadPoint3x;
                if (maxX < quadPoint3x) maxX = quadPoint3x;
                if (minY > quadPoint3y) minY = quadPoint3y;
                if (maxY < quadPoint3y) maxY = quadPoint3y;

                if (minX > quadPoint4x) minX = quadPoint4x;
                if (maxX < quadPoint4x) maxX = quadPoint4x;
                if (minY > quadPoint4y) minY = quadPoint4y;
                if (maxY < quadPoint4y) maxY = quadPoint4y;

            }
            else if(worldScaleX != 1 || worldScaleY != 1)
            {
                quadPoint1x += targetBoundX ;
                quadPoint1y += targetBoundY ;
                quadPoint2x += targetBoundX ;
                quadPoint2y += targetBoundY;
                quadPoint3x += targetBoundX;
                quadPoint3y += targetBoundY;
                quadPoint4x += targetBoundX;
                quadPoint4y += targetBoundY;

                if (minX > quadPoint1x) minX = quadPoint1x;
                if (maxX < quadPoint1x) maxX = quadPoint1x;
                if (minY > quadPoint1y) minY = quadPoint1y;
                if (maxY < quadPoint1y) maxY = quadPoint1y;

                if (minX > quadPoint2x) minX = quadPoint2x;
                if (maxX < quadPoint2x) maxX = quadPoint2x;
                if (minY > quadPoint2y) minY = quadPoint2y;
                if (maxY < quadPoint2y) maxY = quadPoint2y;

                if (minX > quadPoint3x) minX = quadPoint3x;
                if (maxX < quadPoint3x) maxX = quadPoint3x;
                if (minY > quadPoint3y) minY = quadPoint3y;
                if (maxY < quadPoint3y) maxY = quadPoint3y;

                if (minX > quadPoint4x) minX = quadPoint4x;
                if (maxX < quadPoint4x) maxX = quadPoint4x;
                if (minY > quadPoint4y) minY = quadPoint4y;
                if (maxY < quadPoint4y) maxY = quadPoint4y;
            }
            else
            {
                minX = targetBoundX + quadPoint1x;
                minY = targetBoundY + quadPoint1y;

                maxX = targetBoundX + quadPoint4x;
                maxY = targetBoundY + quadPoint4y;


            }


            if(minX < resultRect.x)
                resultRect.x = minX;
            if(minY < resultRect.y)
                resultRect.y = minY;

            if(maxX  > resultRect.width)
                resultRect.width = maxX ;

            if(maxY   > resultRect.height)
                resultRect.height = maxY;
            
          //  trace("getCurrentTargetBound min max",minX,minY,maxX,maxY)
           // trace("getCurrentTargetBound",resultRect.toString())

        }
        /** Returns the object that is found topmost beneath a point in local coordinates, or nil if
         *  the test fails. If "forTouch" is true, untouchable and invisible objects will cause
         *  the test to fail. */
        public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            // on a touch test, invisible or untouchable objects cause the test to fail
            if (forTouch && (!visible || !touchable)) return null;

            var quadPoint1x:Number = -worldPivotX;
            var quadPoint1y:Number = -worldPivotY;
            var quadPoint2x:Number = worldWidth-worldPivotX;
            var quadPoint2y:Number = -worldPivotY;
            var quadPoint3x:Number = -worldPivotX;
            var quadPoint3y:Number = worldHeight-worldPivotY;
            var quadPoint4x:Number = worldWidth-worldPivotX;
            var quadPoint4y:Number = worldHeight-worldPivotY;


            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
            if(worldRotation != 0)
            {
                var sin:Number = Math.sin(worldRotation);
                var cos:Number = Math.cos(worldRotation);


                quadPoint1x = worldX + (quadPoint1x * cos -quadPoint1y * sin);
                quadPoint1y = worldY + (quadPoint1y * cos +quadPoint1x * sin);
                quadPoint2x = worldX + (quadPoint2x * cos -quadPoint2y * sin);
                quadPoint2y = worldY + (quadPoint2y * cos +quadPoint2x * sin);
                quadPoint3x = worldX + (quadPoint3x * cos -quadPoint3y * sin);
                quadPoint3y = worldY + (quadPoint3y * cos +quadPoint3x * sin);
                quadPoint4x = worldX + (quadPoint4x * cos -quadPoint4y * sin);
                quadPoint4y = worldY + (quadPoint4y * cos +quadPoint4x * sin);


                if (minX > quadPoint1x) minX = quadPoint1x;
                if (maxX < quadPoint1x) maxX = quadPoint1x;
                if (minY > quadPoint1y) minY = quadPoint1y;
                if (maxY < quadPoint1y) maxY = quadPoint1y;

                if (minX > quadPoint2x) minX = quadPoint2x;
                if (maxX < quadPoint2x) maxX = quadPoint2x;
                if (minY > quadPoint2y) minY = quadPoint2y;
                if (maxY < quadPoint2y) maxY = quadPoint2y;

                if (minX > quadPoint3x) minX = quadPoint3x;
                if (maxX < quadPoint3x) maxX = quadPoint3x;
                if (minY > quadPoint3y) minY = quadPoint3y;
                if (maxY < quadPoint3y) maxY = quadPoint3y;

                if (minX > quadPoint4x) minX = quadPoint4x;
                if (maxX < quadPoint4x) maxX = quadPoint4x;
                if (minY > quadPoint4y) minY = quadPoint4y;
                if (maxY < quadPoint4y) maxY = quadPoint4y;

            }
            else if(worldScaleX < 0 || worldScaleY < 0)
            {
                quadPoint1x += worldX ;
                quadPoint1y += worldY ;
                quadPoint2x += worldX ;
                quadPoint2y += worldY;
                quadPoint3x += worldX;
                quadPoint3y += worldY;
                quadPoint4x += worldX;
                quadPoint4y += worldY;

                if (minX > quadPoint1x) minX = quadPoint1x;
                if (maxX < quadPoint1x) maxX = quadPoint1x;
                if (minY > quadPoint1y) minY = quadPoint1y;
                if (maxY < quadPoint1y) maxY = quadPoint1y;

                if (minX > quadPoint2x) minX = quadPoint2x;
                if (maxX < quadPoint2x) maxX = quadPoint2x;
                if (minY > quadPoint2y) minY = quadPoint2y;
                if (maxY < quadPoint2y) maxY = quadPoint2y;

                if (minX > quadPoint3x) minX = quadPoint3x;
                if (maxX < quadPoint3x) maxX = quadPoint3x;
                if (minY > quadPoint3y) minY = quadPoint3y;
                if (maxY < quadPoint3y) maxY = quadPoint3y;

                if (minX > quadPoint4x) minX = quadPoint4x;
                if (maxX < quadPoint4x) maxX = quadPoint4x;
                if (minY > quadPoint4y) minY = quadPoint4y;
                if (maxY < quadPoint4y) maxY = quadPoint4y;
            }
            else
            {
                minX = worldX + quadPoint1x;
                minY = worldY + quadPoint1y;

                maxX = worldX + quadPoint4x;
                maxY = worldY + quadPoint4y;


            }


                
            var hitRect:Rectangle = new Rectangle(minX, minY, maxX - minX, maxY - minY);
           // trace("hitTest",hitRect.toString(),localPoint.toString());
            if( hitRect.containsPoint(localPoint)) return this;
            else
                return null;
        }
        public override function setWorldBlendmode():void
        {

            if (mBlendMode == BlendMode.AUTO && mParent)
                worldBlendmode = mParent.worldBlendmode;
            else   worldBlendmode = mBlendMode;
            stateChanged = true
        }
        /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
        public function get color():uint 
        { 
            return _color
        }
        
        /** Sets the colors of all vertices to a certain value. */
        public function set color(value:uint):void 
        {
            if(_color != value)
            {
                _color = value;

                colorR = (_color >> 16 & 0xFF) / 255.0*_brightness;
                colorG = (_color >> 8 & 0xFF) / 255.0*_brightness;
                colorB = (_color & 0xFF) / 255.0*_brightness;

                mColorChanged = true
            }




        }

        public function get brightness():Number
        {
            return _brightness
        }
        public function set brightness(value:Number):void
        {
            if(_brightness != value)
            {
                _brightness = value;

                colorR = (_color >> 16 & 0xFF) / 255.0 * _brightness;
                colorG = (_color >> 8 & 0xFF) / 255.0 * _brightness;
                colorB = (_color & 0xFF) / 255.0 * _brightness;

                mColorChanged = true
            }


        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void
        {
            p_parentUpdateTransform = updateTransform(p_parentUpdateTransform);
            p_parentUpdateColor = updateColor(p_parentUpdateColor);


            if(stateChanged)
            {
                updateStateID()
                stateChanged = false;
            }

            if(p_draw && hasVisibleArea)
                 support.drawColor(this);
        }
        override public function updateColor(p_parent:Boolean):Boolean {
            if(super.updateColor(p_parent))
            {

               var t:Boolean =  (_color != 0xffffff || worldAlpha != 1.0 || _brightness != 1);
               if(mTinted != t)
               {
                   mTinted =  t;
                   stateChanged = true;
               }


               return true;
            } else return false;
        }
        override public function updateTransform(p_parent:Boolean):Boolean {

            if(super.updateTransform(p_parent))
            {
                worldWidth = mWidth * worldScaleX;
                worldHeight = mHeight * worldScaleY;
                worldPivotX = pivotX * worldScaleX;
                worldPivotY = pivotY * worldScaleY;

                return true;
            } else return false;

        }

        /** The width of the object in pixels. */
       public override function get width():Number { return mWidth; }
       public override function set width(value:Number):void
       {
           // this method calls 'this.scaleX' instead of changing mScaleX directly.
           // that way, subclasses reacting on size changes need to override only the scaleX method.
          if(mWidth != value)
          {
              mWidth = value;
            mTransformChanged = true;
              uvSizeDirty = true;
          }

       }

       /** The height of the object in pixels. */
       public override function get height():Number { return mHeight; }
       public override function set height(value:Number):void
       {
           if(mHeight != value)
           {
                mHeight = value;
                mTransformChanged = true;
               uvSizeDirty = true;
           }
       }
        /** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
        public function get tinted():Boolean { return mTinted; }
        
        /** Indicates if the rgb values are stored premultiplied with the alpha value; this can
         *  affect the rendering. (Most developers don't have to care, though.) */
        public function get premultipliedAlpha():Boolean { return _premultipliedAlpha; }
        public function set premultipliedAlpha(val:Boolean):void {_premultipliedAlpha = val; }



        protected function updateStateID():void
        {
            if(worldBlendmode == BlendMode.NORMAL)
                stateId |= 1 ;
            else if(worldBlendmode == BlendMode.ADD)
                stateId |= 1 << 1;
            else if(worldBlendmode == BlendMode.ERASE)
                stateId |= 1 << 2;
            else if(worldBlendmode == BlendMode.MULTIPLY)
                stateId |= 1 << 3;
            else if(worldBlendmode == BlendMode.NONE)
                stateId |= 1 << 4;
            else if(worldBlendmode == BlendMode.SCREEN)
                stateId |= 1 << 5;
        }


    }
}