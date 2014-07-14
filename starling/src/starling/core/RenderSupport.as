// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.core
{
import com.adobe.utils.AGALMiniAssembler;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.Endian;

import starling.core.renderer.ColorRenderer;
import starling.core.renderer.ColorVoxelRenderer;
import starling.core.renderer.DFGlyphRenderer;
import starling.core.renderer.ImageRenderer;
import starling.core.renderer.MultiTextureImageRenderer;
import starling.core.renderer.ParticleRenderer;
import starling.core.renderer.TintedImageRenderer;
import starling.display.BlendMode;
import starling.display.ColorVoxel;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.errors.MissingContextError;
import starling.particles.ParticleDisplay;
import starling.particles.ParticleEmitter;
import starling.text.GlyphImage;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Color;
import starling.utils.MatrixUtil;
import starling.utils.RectangleUtil;

/** A class that contains helper methods simplifying Stage3D rendering.
     *
     *  A RenderSupport instance is passed to any "render" method of display objects. 
     *  It allows manipulation of the current transformation matrix (similar to the matrix 
     *  manipulation methods of OpenGL 1.x) and other helper methods.
     */
    public class RenderSupport
    {
        // members


        private var mProjectionMatrix:Matrix;
        public var projectionMatrix3D:Matrix3D;
        private var mModelViewMatrix:Matrix;
        private var mMvpMatrix:Matrix;
        private var mMvpMatrix3D:Matrix3D;
        private var mMatrixStack:Vector.<Matrix>;
        private var mMatrixStackSize:int;
        
        private var mDrawCount:int;
        private var mBlendMode:String;
        private var mRenderTarget:Texture;
        
        private var mClipRectStack:Vector.<Rectangle>;
        private var mClipRectStackSize:int;
        
        private var mImageRenderer:ImageRenderer;
        private var mTintedImageRenderer:TintedImageRenderer;
        private var mMTBatchImageRenderer:MultiTextureImageRenderer;
        private var mColorRenderer:ColorRenderer;
        private var mColorVoxelRenderer:ColorVoxelRenderer;
        private var mParticleRenderer:ParticleRenderer;
        private var mGlyphRenderer:DFGlyphRenderer;
        private var _currentRenderer:int = -1;

        /** helper objects */
        private static var sPoint:Point = new Point();
        private static var sClipRect:Rectangle = new Rectangle();
        private static var sBufferRect:Rectangle = new Rectangle();
        private static var sScissorRect:Rectangle = new Rectangle();
        private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();



        
        // construction
        
        /** Creates a new RenderSupport object with an empty matrix stack. */
        public function RenderSupport()
        {
            projectionMatrix3D = new Matrix3D;
            mProjectionMatrix = new Matrix();
            mModelViewMatrix = new Matrix();
            mMvpMatrix = new Matrix();
            mMvpMatrix3D = new Matrix3D();
            mMatrixStack = new <Matrix>[];
            mMatrixStackSize = 0;
            mDrawCount = 0;
            mRenderTarget = null;
            mBlendMode = BlendMode.NORMAL;
            mClipRectStack = new <Rectangle>[];


            loadIdentity();
            setOrthographicProjection(0, 0, 400, 300);
        }
        private var _vertexBuffer:VertexBuffer3D;
        private var _vertexBuffer3D:VertexBuffer3D;
        private var _vertexNormalBuffer3D:VertexBuffer3D;
        private var _vertexUVBuffer3D:VertexBuffer3D;
        private var _vertexConstantsByte:ByteArray;
        private var orthographicProjectionWidth:Number;
        private var orthographicProjectionHeight:Number;
        private var orthographicProjectionScaleX:Number;
        private var orthographicProjectionScaleY:Number;
        private var orthographicProjectionX:Number;
        private var orthographicProjectionY:Number;
        public function init():void
        {
            var _quadVertexData:Vector.<Number> = new <Number>[0  , 0 ,0,
                                                              0  , 1.0, 0,
                                                              1.0, 0  , 0,
                                                              1.0, 1.0, 0];
            var context:Context3D = Starling.context;
            var vertexData:Vector.<Number> = new <Number>[];
            for(var i:int = 0; i < 60;i++) // overall max buffer sice
            {

                vertexData = vertexData.concat(_quadVertexData);

            }

            //Context3DBufferUsage

            _vertexBuffer = context.createVertexBuffer(60*4, 3);
            _vertexBuffer.uploadFromVector(vertexData, 0, 60*4);





            var _voxelVertexData:Vector.<Number> = new <Number>[        0  , 0 ,0,
                                                                        0  , 1.0, 0,
                                                                        1.0, 0  , 0,
                                                                        1.0, 1.0, 0,
                                                                          0  , 0 ,-1.0,
                                                                          0  , 1.0, -1.0,
                                                                          1.0, 0  , -1.0,
                                                                          1.0, 1.0, -1.0];
            var vertexData3D:Vector.<Number> = new <Number>[];
            for(var i:int = 0; i < 60;i++) // overall max buffer sice
            {

                vertexData3D = vertexData3D.concat(_voxelVertexData);
                vertexData3D = vertexData3D.concat(_voxelVertexData);
                vertexData3D = vertexData3D.concat(_voxelVertexData);


            }

            //Context3DBufferUsage

            _vertexBuffer3D = context.createVertexBuffer(60*8*3, 3);
            _vertexBuffer3D.uploadFromVector(vertexData3D, 0, 60*8*3);



            var _normmalFrontBack:Vector.<Number> = new <Number>[   0  , 0 ,-1.0,
                                                                    0  , 0 ,-1.0,
                                                                    0  , 0 ,-1.0,
                                                                    0  , 0 ,-1.0,
                                                                    0  , 0 ,1.0,
                                                                    0  , 0 ,1.0,
                                                                    0  , 0 ,1.0,
                                                                    0  , 0 ,1.0];



            var _normmalUpDown:Vector.<Number> = new <Number>[      0  , -1.0 ,0,
                                                                    0  , 1.0 ,0,
                                                                    0  , -1.0 ,0,
                                                                    0  , 1.0 ,0,
                                                                    0  , -1.0 ,0,
                                                                    0  , 1.0 ,0,
                                                                    0  , -1.0 ,0,
                                                                    0  , 1.0 ,0];

            var _normmalLeftRight:Vector.<Number> = new <Number>[   -1.0  , 0 ,0,
                                                                   -1.0  , 0 ,0,
                                                                    1.0  , 0 ,0,
                                                                    1.0  , 0 ,0,
                                                                    -1.0  , 0 ,0,
                                                                    -1.0  , 0 ,0,
                                                                    1.0  , 0 ,0,
                                                                    1.0  , 0 ,0];

            var vertexNormalData3D:Vector.<Number> = new <Number>[];
            for(var i:int = 0; i < 60;i++) // overall max buffer sice
            {

                vertexNormalData3D = vertexNormalData3D.concat(_normmalFrontBack);

                vertexNormalData3D = vertexNormalData3D.concat(_normmalLeftRight);
                vertexNormalData3D = vertexNormalData3D.concat(_normmalUpDown);

            }

            //Context3DBufferUsage

            _vertexNormalBuffer3D = context.createVertexBuffer(60*8*3, 3);
            _vertexNormalBuffer3D.uploadFromVector(vertexNormalData3D, 0, 60*8*3);



            var _voxelUVData:Vector.<Number> = new <Number>[0  , 0 ,
                                                             0  , 1.0,
                                                             1.0, 0  ,
                                                             1.0, 1.0,
                                                             0  , 1.0,
                                                             0  , 0 ,
                                                             1.0, 1.0,
                                                             1.0, 0];

            var _voxelUVData2:Vector.<Number> = new <Number>[ 1, 0,
                                                              1, 1,
                                                              0, 0,
                                                              0, 1,
                                                              0, 0,
                                                              0, 1,
                                                              1, 0 ,
                                                              1, 1];
            var _voxelUVData3:Vector.<Number> = new <Number>[ 0, 1,
                                                              0, 0,
                                                              1, 1,
                                                              1, 0,
                                                              0, 0,
                                                              0, 1,
                                                              1, 0,
                                                              1, 1];


            var vertexUVData3D:Vector.<Number> = new <Number>[];
            for(var i:int = 0; i < 60;i++) // overall max buffer sice
            {

                vertexUVData3D = vertexUVData3D.concat(_voxelUVData);
                vertexUVData3D = vertexUVData3D.concat(_voxelUVData2);
                vertexUVData3D = vertexUVData3D.concat(_voxelUVData3);

            }

            //Context3DBufferUsage

            _vertexUVBuffer3D = context.createVertexBuffer(60*8*3, 2);
            _vertexUVBuffer3D.uploadFromVector(vertexUVData3D, 0, 60*8*3);


            set2DBuffer()


            _vertexConstantsByte= new ByteArray();
            _vertexConstantsByte.length = 31*16*4;
            _vertexConstantsByte.endian = Endian.LITTLE_ENDIAN;
            ApplicationDomain.currentDomain.domainMemory = _vertexConstantsByte;

            mColorRenderer = new ColorRenderer(_vertexConstantsByte, this);
            mColorVoxelRenderer = new ColorVoxelRenderer(_vertexConstantsByte, this);
            mMTBatchImageRenderer = new MultiTextureImageRenderer(_vertexConstantsByte, this);
            mImageRenderer = new ImageRenderer(_vertexConstantsByte, this);
            mTintedImageRenderer = new TintedImageRenderer(_vertexConstantsByte, this)
            mParticleRenderer = new ParticleRenderer(_vertexConstantsByte, this);
            mGlyphRenderer = new DFGlyphRenderer(_vertexConstantsByte, this);
        }
    public function set2DBuffer():void
    {
        var context:Context3D = Starling.context;
        context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        context.setVertexBufferAt(1,null);
        context.setVertexBufferAt(2,null);
        context.setVertexBufferAt(3,null);
    }
    public function set3DBuffer():void
       {
           var context:Context3D = Starling.context;
           context.setVertexBufferAt(0, _vertexBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_3);
           context.setVertexBufferAt(1, _vertexNormalBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_3);
           context.setVertexBufferAt(2, _vertexUVBuffer3D, 0, Context3DVertexBufferFormat.FLOAT_2);



       }
        public function setQuadVertex():void
        {
            Starling.context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        }
        /** Disposes all quad batches. */
        public function dispose():void
        {

        }
        
        // matrix manipulation
        
        /** Sets up the projection matrix for ortographic 2D rendering. */
        public function setOrthographicProjection(x:Number, y:Number, width:Number, height:Number):void
        {
            orthographicProjectionWidth = width;
            orthographicProjectionHeight = height;
            orthographicProjectionX = x;
            orthographicProjectionY = y;


            //mProjectionMatrix.identity();
            //applyClipRect();
        }
        public function setProjectionPosition(x:Number, y:Number):void
        {
            orthographicProjectionX = x;
            orthographicProjectionY = y;
        }
        public function setProjectionScale(x:Number, y:Number):void
        {
            orthographicProjectionScaleX = x;
            orthographicProjectionScaleY = y;
        }
        
        /** Changes the modelview matrix to the identity matrix. */
        public function loadIdentity():void
        {
            mModelViewMatrix.identity();
        }
        
        /** Prepends a translation to the modelview matrix. */
        public function translateMatrix(dx:Number, dy:Number):void
        {
            MatrixUtil.prependTranslation(mModelViewMatrix, dx, dy);
        }
        
        /** Prepends a rotation (angle in radians) to the modelview matrix. */
        public function rotateMatrix(angle:Number):void
        {
            MatrixUtil.prependRotation(mModelViewMatrix, angle);
        }
        
        /** Prepends an incremental scale change to the modelview matrix. */
        public function scaleMatrix(sx:Number, sy:Number):void
        {
            MatrixUtil.prependScale(mModelViewMatrix, sx, sy);
        }
        
        /** Prepends a matrix to the modelview matrix by multiplying it with another matrix. */
        public function prependMatrix(matrix:Matrix):void
        {
            MatrixUtil.prependMatrix(mModelViewMatrix, matrix);
        }
        
        /** Prepends translation, scale and rotation of an object to the modelview matrix. */
        public function transformMatrix(object:DisplayObject):void
        {
            MatrixUtil.prependMatrix(mModelViewMatrix, object.transformationMatrix);
        }
        
        /** Pushes the current modelview matrix to a stack from which it can be restored later. */
        public function pushMatrix():void
        {
            if (mMatrixStack.length < mMatrixStackSize + 1)
                mMatrixStack.push(new Matrix());
            
            mMatrixStack[int(mMatrixStackSize++)].copyFrom(mModelViewMatrix);
        }
        
        /** Restores the modelview matrix that was last pushed to the stack. */
        public function popMatrix():void
        {
            mModelViewMatrix.copyFrom(mMatrixStack[int(--mMatrixStackSize)]);
        }
        
        /** Empties the matrix stack, resets the modelview matrix to the identity matrix. */
        public function resetMatrix():void
        {
            mMatrixStackSize = 0;
            loadIdentity();
        }
        
        /** Prepends translation, scale and rotation of an object to a custom matrix. */
        public static function transformMatrixForObject(matrix:Matrix, object:DisplayObject):void
        {
            MatrixUtil.prependMatrix(matrix, object.transformationMatrix);
        }
        
        /** Calculates the product of modelview and projection matrix. 
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get mvpMatrix():Matrix
        {

            return mMvpMatrix;
        }
        
        /** Calculates the product of modelview and projection matrix and saves it in a 3D matrix. 
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get mvpMatrix3D():Matrix3D
        {
            return MatrixUtil.convertTo3D(mvpMatrix, mMvpMatrix3D);
        }
        
        /** Returns the current modelview matrix.
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get modelViewMatrix():Matrix { return mModelViewMatrix; }
        
        /** Returns the current projection matrix.
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get projectionMatrix():Matrix { return null; }
        public function set projectionMatrix(value:Matrix):void 
        {

        }
        
        // blending
        
        /** Activates the current blend mode on the active rendering context. */
        public function applyBlendMode(premultipliedAlpha:Boolean):void
        {
            setBlendFactors(premultipliedAlpha, mBlendMode);
        }
        
        /** The blend mode to be used on rendering. To apply the factor, you have to manually call
         *  'applyBlendMode' (because the actual blend factors depend on the PMA mode). */
        public function get blendMode():String { return mBlendMode; }
        public function set blendMode(value:String):void
        {
            if (value != BlendMode.AUTO) mBlendMode = value;
        }
        
        // render targets
        
        /** The texture that is currently being rendered into, or 'null' to render into the 
         *  back buffer. If you set a new target, it is immediately activated. */
        public function get renderTarget():Texture { return mRenderTarget; }
        public function set renderTarget(target:Texture):void 
        {
            mRenderTarget = target;
            applyClipRect();
            
            if (target) Starling.context.setRenderToTexture(target.base);
            else        Starling.context.setRenderToBackBuffer();
        }
        
        // clipping
        
        /** The clipping rectangle can be used to limit rendering in the current render target to
         *  a certain area. This method expects the rectangle in stage coordinates. Internally,
         *  it uses the 'scissorRectangle' of stage3D, which works with pixel coordinates. 
         *  Any pushed rectangle is intersected with the previous rectangle; the method returns
         *  that intersection. */ 
        public function pushClipRect(rectangle:Rectangle):Rectangle
        {
            if (mClipRectStack.length < mClipRectStackSize + 1)
                mClipRectStack.push(new Rectangle());
            
            mClipRectStack[mClipRectStackSize].copyFrom(rectangle);
            rectangle = mClipRectStack[mClipRectStackSize];
            
            // intersect with the last pushed clip rect
            if (mClipRectStackSize > 0)
                RectangleUtil.intersect(rectangle, mClipRectStack[mClipRectStackSize-1], 
                                        rectangle);
            
            ++mClipRectStackSize;
            applyClipRect();
            
            // return the intersected clip rect so callers can skip draw calls if it's empty
            return rectangle;
        }
        
        /** Restores the clipping rectangle that was last pushed to the stack. */
        public function popClipRect():void
        {
            if (mClipRectStackSize > 0)
            {
                --mClipRectStackSize;
                applyClipRect();
            }
        }
        
        /** Updates the context3D scissor rectangle using the current clipping rectangle. This
         *  method is called automatically when either the render target, the projection matrix,
         *  or the clipping rectangle changes. */
        public function applyClipRect():void
        {
            finishQuadBatch();
            
            var context:Context3D = Starling.context;
            if (context == null) return;
            
            if (mClipRectStackSize > 0)
            {
                var width:int, height:int;
                var rect:Rectangle = mClipRectStack[mClipRectStackSize-1];
                
                if (mRenderTarget)
                {
                    width  = mRenderTarget.root.nativeWidth;
                    height = mRenderTarget.root.nativeHeight;
                }
                else
                {
                    width  = Starling.current.backBufferWidth;
                    height = Starling.current.backBufferHeight;
                }
                
                // convert to pixel coordinates (matrix transformation ends up in range [-1, 1])
                MatrixUtil.transformCoords(mProjectionMatrix, rect.x, rect.y, sPoint);
                sClipRect.x = (sPoint.x * 0.5 + 0.5) * width;
                sClipRect.y = (0.5 - sPoint.y * 0.5) * height;
                
                MatrixUtil.transformCoords(mProjectionMatrix, rect.right, rect.bottom, sPoint);
                sClipRect.right  = (sPoint.x * 0.5 + 0.5) * width;
                sClipRect.bottom = (0.5 - sPoint.y * 0.5) * height;
                
                sBufferRect.setTo(0, 0, width, height);
                RectangleUtil.intersect(sClipRect, sBufferRect, sScissorRect);
                
                // an empty rectangle is not allowed, so we set it to the smallest possible size
                if (sScissorRect.width < 1 || sScissorRect.height < 1)
                    sScissorRect.setTo(0, 0, 1, 1);
                
                context.setScissorRectangle(sScissorRect);
            }
            else
            {
                context.setScissorRectangle(null);
            }
        }

        public function drawColorImage(image:Image):void
        {
           if(_currentRenderer != MultiTextureImageRenderer.ID)
           {
               finishDraw();
               _currentRenderer = MultiTextureImageRenderer.ID;
           }

            mTintedImageRenderer.draw(image)
        }
        public function drawImage(image:Image):void
        {
            if(_currentRenderer != ImageRenderer.ID)
            {
                finishDraw();
                _currentRenderer = ImageRenderer.ID;
            }

             mImageRenderer.draw(image)
        }
        public function drawMTBatchImage(image:Image):void
        {
           if(_currentRenderer != MultiTextureImageRenderer.ID)
           {
               finishDraw();
               _currentRenderer = MultiTextureImageRenderer.ID;
           }

            mMTBatchImageRenderer.draw(image)
        }
        public function drawColor(quad:Quad):void
        {
            if(_currentRenderer != ColorRenderer.ID)
            {
                finishDraw();
                _currentRenderer = ColorRenderer.ID;
            }

           mColorRenderer.draw(quad);
        }
    public function drawColorVoxel(quad:ColorVoxel):void
            {
                if(_currentRenderer != ColorVoxelRenderer.ID)
                {
                    finishDraw();
                    _currentRenderer = ColorVoxelRenderer.ID;
                }

               mColorVoxelRenderer.draw(quad);
            }
        public function drawParticle(e:ParticleEmitter,p:ParticleDisplay):void
        {
            if(_currentRenderer != ParticleRenderer.ID)
            {
                finishDraw();
                _currentRenderer = ParticleRenderer.ID;
            }

            mParticleRenderer.draw(e,p);
        }
        public function drawGlyph(image:GlyphImage, p_tf:TextField):void
        {
            if(_currentRenderer != DFGlyphRenderer.ID)
            {
                finishDraw();
                _currentRenderer = DFGlyphRenderer.ID;
            }
            mGlyphRenderer.draw(image, p_tf);

        }
        public function finishDraw():void
        {
            mImageRenderer.finishDraw();
            mColorRenderer.finishDraw();
            mParticleRenderer.finishDraw();
            mGlyphRenderer.finishDraw();
            mMTBatchImageRenderer.finishDraw();
            mTintedImageRenderer.finishDraw();
            mColorVoxelRenderer.finishDraw();
        }
        // optimized quad rendering
        
        /** Adds a quad to the current batch of unrendered quads. If there is a state change,
         *  all previous quads are rendered at once, and the batch is reset. */
        public function batchQuad(quad:Quad, parentAlpha:Number, 
                                  texture:Texture=null, smoothing:String=null):void
        {

        }
        

        /** Renders the current quad batch and resets it. */
        public function finishQuadBatch():void
        {
            finishDraw()
        }

        /** Resets matrix stack, blend mode, quad batch index, and draw count. */
        public function nextFrame():void
        {
            resetMatrix();

            mBlendMode = BlendMode.NORMAL;
            mDrawCount = 0;

        }
        private static var matrix3DRawData:Vector.<Number> =
                new <Number>[   1, 0, 0, 0,
                                0, 1, 0, 0,
                                0, 0, 1, 0,
                                0, 0, 0, 1];
        public function setProjectionMatrix():void
        {

            matrix3DRawData[0] = 2.0/orthographicProjectionWidth;
            matrix3DRawData[5] = -2.0/orthographicProjectionHeight
            matrix3DRawData[3] =  -(2*orthographicProjectionX + orthographicProjectionWidth) / orthographicProjectionWidth
            matrix3DRawData[7] = (2*orthographicProjectionY + orthographicProjectionHeight) / orthographicProjectionHeight

            mProjectionMatrix.setTo(matrix3DRawData[0], 0, 0, matrix3DRawData[5],
                    matrix3DRawData[3], matrix3DRawData[7]);
           // trace("setProjectionMatrix",orthographicProjectionWidth,orthographicProjectionHeight,orthographicProjectionX,orthographicProjectionY);
            //projectionMatrix3D.copyRawDataFrom(matrix3DRawData);

            //Starling.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0,projectionMatrix3D,false);
            Starling.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,matrix3DRawData,4);
        }
        // other helper methods
        
        /** Deprecated. Call 'setBlendFactors' instead. */
        public static function setDefaultBlendFactors(premultipliedAlpha:Boolean):void
        {
            setBlendFactors(premultipliedAlpha);
        }
        
        private static var currentBlendPMA:Boolean;
        private static var currentBlend:String;
        /** Sets up the blending factors that correspond with a certain blend mode. */
        public static function setBlendFactors(premultipliedAlpha:Boolean, blendMode:String="normal"):void
        {
            if(blendMode != currentBlend || premultipliedAlpha != currentBlendPMA)
            {
                if(blendMode == BlendMode.AUTO)
                    blendMode = BlendMode.NORMAL;
                
                var blendFactors:Array = BlendMode.getBlendFactors(blendMode, premultipliedAlpha);
                Starling.context.setBlendFactors(blendFactors[0], blendFactors[1]);
                currentBlend = blendMode;
                currentBlendPMA = premultipliedAlpha;
            }

        }
        public static function blendChanged():void
        {
            currentBlend = "c";
        }
        
        /** Clears the render context with a certain color and alpha value. */
        public static function clear(rgb:uint=0, alpha:Number=0.0):void
        {
            Starling.context.clear(
                Color.getRed(rgb)   / 255.0, 
                Color.getGreen(rgb) / 255.0, 
                Color.getBlue(rgb)  / 255.0,
                alpha);
        }
        
        /** Clears the render context with a certain color and alpha value. */
        public function clear(rgb:uint=0, alpha:Number=0.0):void
        {
            RenderSupport.clear(rgb, alpha);
        }
        
        /** Assembles fragment- and vertex-shaders, passed as Strings, to a Program3D. If you
         *  pass a 'resultProgram', it will be uploaded to that program; otherwise, a new program
         *  will be created on the current Stage3D context. */ 
        public static function assembleAgal(vertexShader:String, fragmentShader:String,
                                            resultProgram:Program3D=null):Program3D
        {
            if (resultProgram == null) 
            {
                var context:Context3D = Starling.context;
                if (context == null) throw new MissingContextError();
                resultProgram = context.createProgram();
            }
            
            resultProgram.upload(
                sAssembler.assemble(Context3DProgramType.VERTEX, vertexShader),
                sAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader));
            
            return resultProgram;
        }
        
        /** Returns the flags that are required for AGAL texture lookup, 
         *  including the '&lt;' and '&gt;' delimiters. */
        public static function getTextureLookupFlags(format:String, mipMapping:Boolean,
                                                     repeat:Boolean=false,
                                                     smoothing:String="bilinear"):String
        {
            var options:Array = ["2d", repeat ? "repeat" : "clamp"];
            
            if (format == Context3DTextureFormat.COMPRESSED)
                options.push("dxt1");
            else if (format == "compressedAlpha")
                options.push("dxt5");
            
            if (smoothing == TextureSmoothing.NONE)
                options.push("nearest", mipMapping ? "mipnearest" : "mipnone");
            else if (smoothing == TextureSmoothing.BILINEAR)
                options.push("linear", mipMapping ? "mipnearest" : "mipnone");
            else
                options.push("linear", mipMapping ? "miplinear" : "mipnone");
            
            return "<" + options.join() + ">";
        }
        
        // statistics
        
        /** Raises the draw count by a specific value. Call this method in custom render methods
         *  to keep the statistics display in sync. */
        public function raiseDrawCount(value:uint=1):void { mDrawCount += value; }
        
        /** Indicates the number of stage3D draw calls. */
        public function get drawCount():int { return mDrawCount; }
    }
}