
/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 20.01.14
 * Time: 21:16
 * To change this template use File | Settings | File Templates.
 */
package starling.core.renderer {
import com.adobe.utils.AGALMiniAssembler;
import avm2.intrinsics.memory.*;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.text.TextField;
import starling.textures.TextureSmoothing;
import starling.text.GlyphImage;

public class DFGlyphRenderer {
    public static const ID:int = 3;
    private const MAX_NUM_QUADS:int = 40;
    private var _vertexBufferRegisterIndex4:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexConstants:Vector.<Number>;
    private var _vertexConstantsByte:ByteArray;
    private var _vcLength:int = 32;
    private var mNumQuads:int = 0;


    private var _drawTexture:TextureBase;
    private var _currentProgramId:int = -1;
    private var _currentStateId:int = -1;




    private static var programs:Array = [];

    private var _currentShadowSize:Number = 0;
    private var _currentShadowAlpha:Number= 0;
    private var _currentShadowSmooth:Number= 0;
    private var _drawTextureUID:uint = 0;


    private var _support:RenderSupport;
    public function DFGlyphRenderer(p_vc:ByteArray, p_support:RenderSupport) {
        _vertexConstantsByte =  p_vc;
        this._support = p_support;
        setBuffer()
    }
    public function draw(p_image:GlyphImage, p_tf:TextField):void
    {


        if(mNumQuads != 0)
        {
            if(p_image.stateId != _currentStateId )
            {
                drawGPU();
                _currentShadowSmooth = p_tf.dfSharpness/(p_image.spread*p_image.worldScaleX);
                _currentShadowSize = Math.min(p_tf.dfShadowSize/(p_image.spread*p_image.worldScaleX),.5);
                initDraw(p_image,p_tf)
            }
            else
            if( _drawTextureUID != p_image.textureUID)
            {
                drawGPU();
                _currentShadowSmooth = p_tf.dfSharpness/(p_image.spread*p_image.worldScaleX);
                _currentShadowSize = Math.min(p_tf.dfShadowSize/(p_image.spread*p_image.worldScaleX),.5);
                initDraw(p_image,p_tf)

            } else
            {

                var smooth:Number = p_tf.dfSharpness/(p_image.spread*p_image.worldScaleX);
                var shadow:Number = Math.min(p_tf.dfShadowSize/(p_image.spread*p_image.worldScaleX),.5);

                if(_currentShadowSmooth != smooth || _currentShadowSize != shadow || _currentShadowAlpha != p_tf.dfShadowAlpha)
                {

                    drawGPU();
                    _currentShadowSmooth = smooth;
                    _currentShadowSize = shadow;
                    initDraw(p_image,p_tf)
                }
            }


        }else
        {

            initDraw(p_image,p_tf)
        }


        sf32( p_image.worldX,                       _vcLength);
        _vcLength += 4
        sf32( p_image.worldY,                       _vcLength);
        _vcLength += 4
        sf32( p_image.worldWidth,                   _vcLength);
        _vcLength += 4
        sf32( p_image.worldHeight,                  _vcLength);
        _vcLength += 4

        var uvm:Rectangle = p_image.uvMapping;
        sf32(uvm.x,                   _vcLength);
        _vcLength += 4
        sf32(uvm.y,                   _vcLength);
        _vcLength += 4
        sf32(uvm.width,               _vcLength);
        _vcLength += 4
        sf32(uvm.height,              _vcLength);
        _vcLength += 4


        sf32(p_image.colorR,                     _vcLength);
        _vcLength += 4
        sf32(p_image.colorG,                     _vcLength);
        _vcLength += 4
        sf32(p_image.colorB,                     _vcLength);
        _vcLength += 4
        sf32(p_image.worldAlpha,                 _vcLength);
        _vcLength += 4

        mNumQuads++;
        if(mNumQuads ==40)
            drawGPU();

    }
    private function initDraw(p_image:GlyphImage, p_tf:TextField):void
    {
        _currentProgramId = p_image.programId;
        _currentStateId = p_image.stateId;
        _drawTexture = p_image.texture.base;
        _drawTextureUID = p_image.textureUID;
        RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);


        _currentShadowAlpha = p_tf.dfShadowAlpha;


        sf32(.5-_currentShadowSmooth,                   0);
        sf32(_currentShadowSmooth*2,                   4);

        if(p_tf.hasGlow )
        {
           sf32(.5-_currentShadowSize,                   8);
           sf32(_currentShadowSize,              12);

           sf32(_currentShadowAlpha,              16);
        }else if(p_tf.hasStroke)
        {
           sf32(.5001-_currentShadowSize,                   8);
           sf32(_currentShadowSmooth*2,              12);
           sf32(_currentShadowAlpha,              16);
        }else
        {
          sf32(0,                   8);
          sf32(0,              12);
          sf32(0,              16);
        }

    }
    public function drawGPU():void
    {
        var context:Context3D = Starling.context;

        if(!programs[_currentProgramId])
                    registerProgram(_currentProgramId);

        context.setProgram(programs[_currentProgramId]);

        context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4,2+ mNumQuads * 3, _vertexConstantsByte,0);
        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_3);
        context.setTextureAt(0, _drawTexture);


        context.drawTriangles(_indexBuffer, 0, mNumQuads * 2);



        mNumQuads = 0;
        _vcLength = 32;
        _drawTexture = null;


        context.setTextureAt(0, null);
        context.setProgram(null);
        context.setVertexBufferAt(1, null);

        _support.raiseDrawCount();
    }
    public function finishDraw():void
    {
        if(mNumQuads != 0)
            drawGPU();
        _vcLength = 32;
    }
    private function setBuffer():void
    {

        var context:Context3D = Starling.context;
        var indexData:Vector.<uint> = new <uint>[];
        var registerIndexData4:Vector.<Number> = new <Number>[];
        _vertexConstants = new <Number>[];
        _vertexConstants.length = MAX_NUM_QUADS * 16;
        _vertexConstants.fixed = true;

        var registerIndex4:int = 0;
        for(var i:int = 0; i < MAX_NUM_QUADS;i++)
        {
            indexData.push((i*4) +0);
            indexData.push((i*4) +1);
            indexData.push((i*4) +2);

            indexData.push((i*4) +1);
            indexData.push((i*4) +2);
            indexData.push((i*4) +3);

            registerIndex4 = 6+(i*3);

            registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2);
            registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2);
            registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2);
            registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2);
        }


        _indexBuffer = context.createIndexBuffer(MAX_NUM_QUADS*6);
        _indexBuffer.uploadFromVector(indexData, 0, MAX_NUM_QUADS*6);



        _vertexBufferRegisterIndex4 = context.createVertexBuffer(MAX_NUM_QUADS*4, 3);
        _vertexBufferRegisterIndex4.uploadFromVector(registerIndexData4, 0, MAX_NUM_QUADS*4);


        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_4);



    }


    public static function registerProgram(pid:int):void
    {


        var target:Starling = Starling.current;



        var assembler:AGALMiniAssembler = new AGALMiniAssembler();
        var vertexProgramCode:String;
        var fragmentProgramCode:String;


        var smoothing:String;
        var format:String;


        var mipmap:Boolean = pid >> 1 & 1;
        var repeat:Boolean = pid >> 2 & 1;

        if(pid >> 3 & 1)
            smoothing = TextureSmoothing.NONE;
        else if(pid >> 4 & 1)
            smoothing = TextureSmoothing.TRILINEAR;
        else
            smoothing = TextureSmoothing.BILINEAR;

        if(pid >> 5 & 1)
            format = Context3DTextureFormat.COMPRESSED;
        else if(pid >> 6 & 1)
            format = "compressedAlpha";
        else
            format = Context3DTextureFormat.BGRA;

        var effect:Boolean = pid >> 7 & 1;
        vertexProgramCode =
                "mov vt1, va0 \n" +
                "mul vt1.xy, vt1.xy, vc[va1.x].zw \n" +  // set width and height
                "add vt1.xy, vt1.xy, vc[va1.x].xy \n" + // add x and y position

                "m44 op, vt1, vc0 \n" + // 4x4 matrix transform to output clipspace


                "mov vt3, va0 \n" +  //copy uv data
                "mul vt3.xy, vt3.xy, vc[va1.y].zw \n" +  // set uv width and height
                "add vt3.xy, vt3.xy, vc[va1.y].xy \n" + // add uv

                "mov vt4, vt3 \n" +  //copy uv data
                "add vt4.x, vt4.x, vc5.y \n" +

                "mov v0, vt3      \n"+// pass texture coordinates to fragment program
                "mov v1, vc[va1.z]      \n"+  // passcolor to fragment program

                "mov v2, vc4      \n"+ //
                "mov v3, vc5      \n";  //


        if(effect)
        {
            fragmentProgramCode =
            "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0


            "sub ft2.x, ft0.w, v2.x \n" +	// smooth step
            "sat ft2.x, ft2.x \n" +         // set between  0-1;
            "div ft2.x, ft2.x, v2.y \n" +         // scale;

            "sub ft3.x, ft0.w, v2.z \n" +	// smooth step  ;
            "sat ft3.x, ft3.x \n" +         // set between  0-1;
            "div ft3.x, ft3.x, v2.w \n" +    // scale;
            "sat ft3.x, ft3.x \n" +         // set between  0-1;
            "mul ft3.x, ft3.x, v3.x \n" +


            "mov ft0.x, ft2.x\n" +			// place smooth alpha
            "mov ft0.y, ft2.x\n" +			// place smooth alpha
            "mov ft0.z, ft2.x\n" +			// place smooth alpha
            "mov ft0.w, ft3.x\n" +			// place smooth alpha
            "mul  oc, ft0,  v1       \n";   // multiply color with texel color
        }else
        {
            fragmentProgramCode =
            "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0


            "sub ft2.x, ft0.w, v2.x \n" +	// smooth step   dist - (0.5 - 1.0/16.0) = var $1;
            "sat ft2.x, ft2.x \n" +         // set between  0-1;
            "div ft2.x, ft2.x, v2.y \n" +         // set between  0-1;


            "mov ft0.x, ft2.x\n" +			// place smooth alpha
            "mov ft0.y, ft2.x\n" +			// place smooth alpha
           "mov ft0.z, ft2.x\n" +			// place smooth alpha
            "mov ft0.w, ft2.x\n" +			// place smooth alpha

            "mul  oc, ft0,  v1       \n";   // multiply color with texel color
        }


        var flags:String = RenderSupport.getTextureLookupFlags(format, mipmap, repeat, smoothing);

        var program:Program3D = target.context.createProgram();
        var fragmentReplaced:String =  fragmentProgramCode.replace("<???>", flags);
        program.upload(
                assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                assembler.assemble(Context3DProgramType.FRAGMENT,fragmentReplaced)
        );
        pid = 0
        pid |= 1;
        if (mipmap) pid |= 1 << 1;
        if (repeat) pid |= 1 << 2;

        if (smoothing == TextureSmoothing.NONE)
            pid |= 1 << 3;
        else if (smoothing == TextureSmoothing.TRILINEAR)
            pid |= 1 << 4;

        if (format == Context3DTextureFormat.COMPRESSED)
            pid |= 1 << 5;
        else if (format == "compressedAlpha")
            pid |= 1 << 6;

        if (effect) pid |= 1 << 7;

        programs[pid] = program;


    }


}
}


