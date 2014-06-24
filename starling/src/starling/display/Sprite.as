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
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.utils.RectangleUtil;

/** Dispatched on all children when the object is flattened. */
    [Event(name="flatten", type="starling.events.Event")]
    
    /** A Sprite is the most lightweight, non-abstract container class.
     *  <p>Use it as a simple means of grouping objects together in one coordinate system, or
     *  as the base class for custom display objects.</p>
     *
     *  <strong>Flattened Sprites</strong>
     * 
     *  <p>The <code>flatten</code>-method allows you to optimize the rendering of static parts of 
     *  your display list.</p>
     *
     *  <p>It analyzes the tree of children attached to the sprite and optimizes the rendering calls 
     *  in a way that makes rendering extremely fast. The speed-up comes at a price, though: you 
     *  will no longer see any changes in the properties of the children (position, rotation, 
     *  alpha, etc.). To update the object after changes have happened, simply call 
     *  <code>flatten</code> again, or <code>unflatten</code> the object.</p>
     *  
     *  <strong>Clipping Rectangle</strong>
     * 
     *  <p>The <code>clipRect</code> property allows you to clip the visible area of the sprite
     *  to a rectangular region. Only pixels inside the rectangle will be displayed. This is a very
     *  fast way to mask objects. However, there is one limitation: the <code>clipRect</code>
     *  only works with stage-aligned rectangles, i.e. you cannot rotate or skew the rectangle.
     *  This limitation is inherited from the underlying "scissoring" technique that is used
     *  internally.</p>
     *  
     *  @see DisplayObject
     *  @see DisplayObjectContainer
     */
    public class Sprite extends DisplayObjectContainer
    {
        private var mClipRect:Rectangle;
        private var mHasClipRect:Boolean = false;
        
        /** Helper objects. */
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sHelperPoint:Point = new Point();
        private static var sHelperRect:Rectangle = new Rectangle();
        
        /** Creates an empty sprite. */
        public function Sprite()
        {
            super();
        }
        
        /** @inheritDoc */
        public override function dispose():void
        {
            disposeFlattenedContents();
            super.dispose();
        }
        
        private function disposeFlattenedContents():void
        {

        }
        
        /** Optimizes the sprite for optimal rendering performance. Changes in the
         *  children of a flattened sprite will not be displayed any longer. For this to happen,
         *  either call <code>flatten</code> again, or <code>unflatten</code> the sprite. 
         *  Beware that the actual flattening will not happen right away, but right before the
         *  next rendering. 
         * 
         *  <p>When you flatten a sprite, the result of all matrix operations that are otherwise
         *  executed during rendering are cached. For this reason, a flattened sprite can be
         *  rendered with much less strain on the CPU. However, a flattened sprite will always
         *  produce at least one draw call; if it were merged together with other objects, this
         *  would cause additional matrix operations, and the optimization would have been in vain.
         *  Thus, don't just blindly flatten all your sprites, but reserve flattening for sprites
         *  with a big number of children.</p> 
         */
        public function flatten():void
        {
        }
        
        /** Removes the rendering optimizations that were created when flattening the sprite.
         *  Changes to the sprite's children will immediately become visible again. */ 
        public function unflatten():void
        {
        }
        
        /** Indicates if the sprite was flattened. */
        public function get isFlattened():Boolean 
        { 
            return false;
        }
        
        /** The object's clipping rectangle in its local coordinate system.
         *  Only pixels within that rectangle will be drawn. 
         *  <strong>Note:</strong> clip rects are axis aligned with the screen, so they
         *  will not be rotated or skewed if the Sprite is. */
        public function get clipRect():Rectangle { return mClipRect; }
        public function set clipRect(value:Rectangle):void 
        {
            if (mClipRect && value) mClipRect.copyFrom(value);
            else mClipRect = (value ? value.clone() : null);

            mHasClipRect = mHasClipRect != null;
        }

        /** Returns the bounds of the container's clipRect in the given coordinate space, or
         *  null if the sprite doens't have a clipRect. */ 
        public function getClipRect(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (mClipRect == null) return null;
            if (resultRect == null) resultRect = new Rectangle();
            
            var pos:Point = new Point()
            var minX:Number =  Number.MAX_VALUE;
            var maxX:Number = -Number.MAX_VALUE;
            var minY:Number =  Number.MAX_VALUE;
            var maxY:Number = -Number.MAX_VALUE;

            for (var i:int=0; i<4; ++i)
            {
                switch(i)
                {
                    case 0: pos.x = mClipRect.left;  pos.y = mClipRect.top;    break;
                    case 1: pos.x = mClipRect.left;  pos.y = mClipRect.bottom; break;
                    case 2: pos.x = mClipRect.right; pos.y = mClipRect.top;    break;
                    case 3: pos.x = mClipRect.right; pos.y = mClipRect.bottom; break;
                }
                localToGlobal(pos,sHelperPoint)

                
                if (minX > sHelperPoint.x) minX = sHelperPoint.x;
                if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
                if (minY > sHelperPoint.y) minY = sHelperPoint.y;
                if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
            }
            
            resultRect.setTo(minX, minY, maxX-minX, maxY-minY);
            return resultRect;
        }


        override public function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void {

            if(mHasClipRect)
            {
                //trace("render cliped",mClipRect.toString(),worldScaleX,worldScaleY)

                var clipRect:Rectangle = support.pushClipRect(getClipRect(stage, sHelperRect));
                //trace(clipRect.toString())
                if (clipRect.isEmpty())
                {
                    // empty clipping bounds - no need to render children.
                    support.popClipRect();
                    return;
                }
                super.render(support, p_parentUpdateTransform, p_parentUpdateColor, p_draw);
                support.popClipRect();
            } else
                super.render(support, p_parentUpdateTransform, p_parentUpdateColor, p_draw);
            

        }

        override public function getCurrentTargetBound(resultRect:Rectangle):void {

            if (mHasClipRect)
            {
                if(mClipRect.x < resultRect.x)
                    resultRect.x = mClipRect.x;
                if(mClipRect.y < resultRect.y)
                    resultRect.y = mClipRect.y;
                if(mClipRect.width > resultRect.width)
                    resultRect.width = mClipRect.width;
                if(mClipRect.height > resultRect.height)
                    resultRect.height = mClipRect.height;


            }else
            {
                super.getCurrentTargetBound(resultRect);
            }
       
            
        }

        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            var bounds:Rectangle = super.getBounds(targetSpace, resultRect);

            // if we have a scissor rect, intersect it with our bounds
            if (mHasClipRect)
                RectangleUtil.intersect(bounds, getClipRect(targetSpace, sHelperRect),
                                        bounds);

            return bounds;
        }

        /** @inheritDoc */
        public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            if (mHasClipRect)
            {
                var clipRect:Rectangle = getClipRect(stage, sHelperRect);

                if(clipRect.containsPoint(localPoint))
                    return super.hitTest(localPoint, forTouch);
                else
                    return null
            }
            else
                return super.hitTest(localPoint, forTouch);
        }

        /** @inheritDoc */

    }
}