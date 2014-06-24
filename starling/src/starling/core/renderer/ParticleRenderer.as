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
import flash.utils.ByteArray;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.particles.ParticleDisplay;
import starling.particles.ParticleEmitter;
import starling.textures.TextureSmoothing;

public class ParticleRenderer {
    public static const ID:int = 4;
    private const MAX_NUM_QUADS:int = 60;
    private var _vertexBufferRegisterIndex4:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexConstants:Vector.<Number>;
    private var _vertexConstantsByte:ByteArray;
    private var _vcLength:int = 32;
    private var mNumQuads:int = 0;


    private var _drawTexture:TextureBase;
    private var _currentProgramId:int = -1;
    private var _currentStateId:int = -1;
    private var _drawTextureUID:uint = 0;



    private static var programs:Array = [];

    private var _support:RenderSupport;
    public function ParticleRenderer(p_vc:ByteArray, p_support:RenderSupport) {
        _vertexConstantsByte =  p_vc;
        this._support = p_support;

        setBuffer()
    }
    public function draw(p_emiter:ParticleEmitter,pd:ParticleDisplay):void
    {


        if(mNumQuads != 0)
        {
            if(p_emiter.stateId != _currentStateId )
            {
                drawGPU();
                initDraw(p_emiter)
            }
            else
            if( _drawTextureUID != p_emiter.textureUID)
            {
                drawGPU();
                initDraw(p_emiter)

            }


        }else
        {

            initDraw(p_emiter);
        }


        sf32( (pd.x*p_emiter.worldScaleX) + p_emiter.worldX,                       _vcLength);
        _vcLength += 4
        sf32( (pd.y*p_emiter.worldScaleY)  + p_emiter.worldY,                       _vcLength);
        _vcLength += 4
        sf32( pd.scale*p_emiter.worldScaleX,                   _vcLength);
        _vcLength += 4
        sf32( pd.rotation,                  _vcLength);
        _vcLength += 4

        sf32(pd.colorR,                     _vcLength);
        _vcLength += 4
        sf32(pd.colorG,                     _vcLength);
        _vcLength += 4
        sf32(pd.colorB,                     _vcLength);
        _vcLength += 4
        sf32(pd.alpha,                 _vcLength);
        _vcLength += 4


        mNumQuads++;
        if(mNumQuads ==60)
            drawGPU();

    }
    private function initDraw(p_emiter:ParticleEmitter):void
    {
        _drawTexture = p_emiter.texture.base;
        _drawTextureUID = p_emiter.textureUID;
        _currentProgramId = p_emiter.programId;
        _currentStateId = p_emiter.stateId;



        Starling.context.setBlendFactors(p_emiter.blendFactorSource,p_emiter.blendFactorDestination);
        RenderSupport.blendChanged();
        sf32(p_emiter.uvMapping.x,                   0);
        sf32(p_emiter.uvMapping.y,                   4);
        sf32(p_emiter.uvMapping.width,               8);
        sf32(p_emiter.uvMapping.height,              12);

        sf32(p_emiter.width*.5,                   16);
        sf32(p_emiter.width*.5,                   20);
        sf32(p_emiter.width,                         24);
        sf32(p_emiter.height,                         28);
   }
    public function drawGPU():void
    {
        var context:Context3D = Starling.context;
        if(!programs[_currentProgramId])
                     registerProgram(_currentProgramId);

        context.setProgram(programs[_currentProgramId]);

        context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4,2+ mNumQuads * 2, _vertexConstantsByte,0);
        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_2);
        context.setTextureAt(0, _drawTexture);




         context.drawTriangles(_indexBuffer, 0, mNumQuads * 2);


       // trace("rParticle",mNumQuads);
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

            registerIndex4 = 6+(i*2);

            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
        }


        _indexBuffer = context.createIndexBuffer(MAX_NUM_QUADS*6);
        _indexBuffer.uploadFromVector(indexData, 0, MAX_NUM_QUADS*6);



        _vertexBufferRegisterIndex4 = context.createVertexBuffer(MAX_NUM_QUADS*4, 2);
        _vertexBufferRegisterIndex4.uploadFromVector(registerIndexData4, 0, MAX_NUM_QUADS*4);


        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_4);

    }


    public static function registerProgram(pid:int):void
    {

       trace("add program with id:",pid);


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



        vertexProgramCode =
                "mov vt1, va0 \n" +
                "mul vt1.xy, vt1.xy, vc5.zw \n" +  // set width and height
                "mul vt1.xy, vt1.xy, vc[va1.x].z \n" +  // set scale

                "mov vt3, vc5 \n" +
                "mul vt3.xy, vt3.xy, vc[va1.x].z \n" +  // set scale

                "sub vt1.xy, vt1.xy, vt3.xy \n" +  // set pivot

                "mov vt2.x, vc[va1.x].w \n" +   //  get rotation
                "sin vt3.x, vt2.x \n" +
                "cos vt3.y, vt2.x \n" +

                //apply rotation
               "mul vt4.xy, vt1.xy, vt3.yx \n" +
               "sub vt2.x, vt4.x, vt4.y \n" +
               "mul vt5.xy, vt1.yx, vt3.yx \n" +
               "add vt2.y, vt5.x, vt5.y \n" +
                //apply rotation

                "add vt1.xy, vt2.xy, vc[va1.x].xy \n" + // add x and y position
                "m44 op, vt1, vc0 \n" + // 4x4 matrix transform to output clipspace


                "mov vt3, va0 \n" +  //copy uv data
                "mul vt3.xy, vt3.xy, vc4.zw \n" +  // set uv width and height
                "add vt3.xy, vt3.xy, vc4.xy \n" + // add uv

                "mov v0, vt3      \n"+// pass texture coordinates to fragment program
                "mov v1, vc[va1.y]      \n";  // passcolor to fragment program

            fragmentProgramCode =
                 "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0
                 "mul  oc, ft0,  v1       \n";   // multiply color with texel color



        var flags:String = RenderSupport.getTextureLookupFlags(format, mipmap, repeat, smoothing);

        var program:Program3D = target.context.createProgram();
        var fragmentReplaced:String =  fragmentProgramCode.replace("<???>", flags);
        program.upload(
                assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                assembler.assemble(Context3DProgramType.FRAGMENT,fragmentReplaced)
        );

        programs[pid] = program;



    }


}
}

