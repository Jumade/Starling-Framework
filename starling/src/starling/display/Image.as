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
import flash.display.Bitmap;
import flash.display3D.Context3DTextureFormat;
import flash.geom.Rectangle;

import starling.core.RenderSupport;
import starling.core.renderer.ImageRenderer;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

/** An Image is a quad with a texture mapped onto it.
     *  
     *  <p>The Image class is the Starling equivalent of Flash's Bitmap class. Instead of 
     *  BitmapData, Starling uses textures to represent the pixels of an image. To display a 
     *  texture, you have to map it onto a quad - and that's what the Image class is for.</p>
     *  
     *  <p>As "Image" inherits from "Quad", you can give it a color. For each pixel, the resulting  
     *  color will be the result of the multiplication of the color of the texture with the color of 
     *  the quad. That way, you can easily tint textures with a certain color. Furthermore, images 
     *  allow the manipulation of texture coordinates. That way, you can move a texture inside an 
     *  image without changing any vertex coordinates of the quad. You can also use this feature
     *  as a very efficient way to create a rectangular mask.</p> 
     *  
     *  @see starling.textures.Texture
     *  @see Quad
     */ 
    public class Image extends Quad
    {
        protected var mTexture:Texture;
        private var mSmoothing:String;
        public var uvMapping:Rectangle = new Rectangle();
        public var hasFrame:Boolean = false;
        public var frameX:Number = 0;
        public var frameY:Number = 0;
        public var textureUID:uint;

        public var multiTextureBatch:Boolean = false;
        /** Creates a quad with a texture mapped onto it. */
        public function Image(p_texture:Texture)
        {
            if (p_texture)
            {
                var frame:Rectangle = p_texture.frame;
                var width:Number  = frame ? frame.width  : p_texture.width;
                var height:Number = frame ? frame.height : p_texture.height;
                var pma:Boolean = p_texture.premultipliedAlpha;
                
                super(width, height, 0xffffff, pma);

                

                mSmoothing = TextureSmoothing.BILINEAR;
                texture = p_texture;
            }
            else
            {
                throw new ArgumentError("Texture cannot be null");
            }
        }
        
        /** Creates an Image with a texture that is created from a bitmap object. */
        public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Boolean=true,
                                          scale:Number=1):Image
        {
            return new Image(Texture.fromBitmap(bitmap, generateMipMaps, false, scale));
        }
        

        /** Readjusts the dimensions of the image according to its current texture. Call this method 
         *  to synchronize image and texture size after assigning a texture with a different size.*/
        public function readjustSize():void
        {
            var frame:Rectangle = texture.frame;
            width  = frame ? frame.width  : texture.width;
            height = frame ? frame.height : texture.height;

        }




        /** The texture that is displayed on the quad. */
        public function get texture():Texture { return mTexture; }
        public function set texture(value:Texture):void 
        { 
            if (value == null)
            {
                throw new ArgumentError("Texture cannot be null");
            }
            else if (value != mTexture)
            {
                mTexture = value;
                if(value is SubTexture)
                    textureUID = SubTexture(value).parent.uid;
                else
                    textureUID = value.uid;
                stateChanged = true;
                var f:Rectangle = mTexture.originalFrame
                hasFrame = f != null;
                if(hasFrame)
                {
                    frameX = f.x;
                    frameY = f.y;
                }
               
                uvMapping.width = mTexture.uvMapping.width      * _clipWidthScale;
                uvMapping.height = mTexture.uvMapping.height    * _clipHeightScale;
                uvMapping.x = mTexture.uvMapping.x;
                uvMapping.y = mTexture.uvMapping.y;
                uvSizeDirty = true;
            }
        }
        
        /** The smoothing filter that is used for the texture. 
        *   @default bilinear
        *   @see starling.textures.TextureSmoothing */ 
        public function get smoothing():String { return mSmoothing; }
        public function set smoothing(value:String):void 
        {
            if (TextureSmoothing.isValid(value))
            {
                mSmoothing = value;
                stateChanged = true;
            }

            else
                throw new ArgumentError("Invalid smoothing m    ode: " + value);
        }

        override public function updateColor(p_parent:Boolean):Boolean {
            if(super.updateColor(p_parent))
            {
                if(_premultipliedAlpha)
                {
                  colorR = ((_color >> 16) & 0xff) / 255.0 * worldAlpha * _brightness;
                  colorG = ((_color >>  8) & 0xff) / 255.0 * worldAlpha * _brightness;
                  colorB = ( _color        & 0xff) / 255.0 * worldAlpha * _brightness;
                }
                return true;
            }else return false;
        }
        override public function updateTransform(p_parent:Boolean):Boolean {

            if(super.updateTransform(p_parent))
            {

                if(hasFrame)
                {
                    worldPivotX = (pivotX+frameX) * worldScaleX;
                    worldPivotY = (pivotY+frameY) * worldScaleY;
                    worldWidth = (mTexture.width) * worldScaleX     * _clipWidthScale;
                    worldHeight = (mTexture.height) * worldScaleY   * _clipHeightScale;


                } else
                {
                    worldPivotX = pivotX * worldScaleX;
                    worldPivotY = pivotY * worldScaleY;
                    worldWidth = mWidth * worldScaleX               * _clipWidthScale;
                    worldHeight = mHeight * worldScaleY             * _clipHeightScale;
                }

                return true;
            } else return false;

        }
        protected var currentRotationStatus:Boolean = false;
        /** @inheritDoc */
        public override function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void
        {
            p_parentUpdateTransform = updateTransform(p_parentUpdateTransform);
            p_parentUpdateColor = updateColor(p_parentUpdateColor);

            if(currentRotationStatus != isRotated)
            {
                currentRotationStatus = isRotated;
                stateChanged = true;
            }

            
            if(stateChanged)
            {
                updateStateID()
                stateChanged = false;
            }

            if(p_draw && hasVisibleArea)
            {
                if(mTinted)
                    support.drawColorImage(this);
                else if(multiTextureBatch)
                    support.drawMTBatchImage(this);
                else
                    support.drawImage(this);

            }



        }
        protected override  function updateStateID():void
        {
            stateId = 0;


            if (mTinted) stateId |= 1;
            if (mTexture.mipMapping) stateId |= 1 << 1;
            if (mTexture.repeat)
            {
                stateId |= 1 << 2;
            }
                

            if (smoothing == TextureSmoothing.NONE)
                stateId |= 1 << 3;
            else if (smoothing == TextureSmoothing.TRILINEAR)
                stateId |= 1 << 4;

            if (mTexture.format == Context3DTextureFormat.COMPRESSED)
                stateId |= 1 << 5;
            else if (mTexture.format == "compressedAlpha")
                stateId |= 1 << 6;

            if (isRotated) stateId |= 1 << 7;

            programId = stateId;


            if(worldBlendmode == BlendMode.NORMAL)
                stateId |= 1 << 8;
            else if(worldBlendmode == BlendMode.ADD)
                stateId |= 1 << 9;
            else if(worldBlendmode == BlendMode.ERASE)
                stateId |= 1 << 10;
            else if(worldBlendmode == BlendMode.MULTIPLY)
                stateId |= 1 << 11;
            else if(worldBlendmode == BlendMode.NONE)
                stateId |= 1 << 12;
            else if(worldBlendmode == BlendMode.SCREEN)
                stateId |= 1 << 13;

            if (premultipliedAlpha)
                stateId |= 1 << 14;



            if(!ImageRenderer.programs[programId])
                ImageRenderer.registerProgram(programId);

            //trace("updateStateID",programId,smoothing);
        }

        public function get clipWidth():Number {
            return _clipWidth;
        }

        public function get clipHeight():Number {
            return _clipHeight;
        }

        public function set clipWidth(p_val:Number):void {
             _clipWidth = p_val;
             _clipWidthScale = p_val / width;
            if(_clipWidthScale > 1)
                _clipWidthScale = 1;
            if(_clipWidthScale < 0)
                _clipWidthScale = 0;

            uvMapping.width = mTexture.uvMapping.width      * _clipWidthScale;
            uvSizeDirty = true;
            if(hasFrame)
            {
                worldWidth = (mTexture.width) * worldScaleX     * _clipWidthScale;
            } else
            {
                worldWidth = mWidth * worldScaleX               * _clipWidthScale;
            }

        }
        public function set clipHeight(p_val:Number):void {
                _clipHeight = height;
                _clipHeightScale = p_val / height;
            if(_clipHeightScale > 1)
                _clipHeightScale = 1;
            if(_clipHeightScale < 0)
                _clipHeightScale = 0;



            uvMapping.height = mTexture.uvMapping.height    * _clipHeightScale;
            uvSizeDirty = true;

            if(hasFrame)
            {

               worldHeight = (mTexture.height) * worldScaleY   * _clipHeightScale;

            } else
            {

               worldHeight = mHeight * worldScaleY             * _clipHeightScale;
            }
        }

    }
}