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
import flash.utils.setTimeout;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.TextureSmoothing;

public class ImageRenderer {
    public static const ID:int = 1;
    private const MAX_NUM_QUADS:int = 41;
    private var _vertexBufferRegisterIndex4:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexConstants:Vector.<Number>;
    private var _vertexConstantsByte:ByteArray;
    private var _vcLength:int = 0;
    private var mNumQuads:int = 0;


    private var _drawTexture:TextureBase;
    private var _drawTextureUID:uint = 0;

    private var _currentProgramId:int = -1;
    private var _currentStateId:int = -1;




    public static var programs:Array = [];

    private var _support:RenderSupport;

    public function ImageRenderer(p_vc:ByteArray, p_support:RenderSupport) {
        _vertexConstantsByte =  p_vc;
        this._support = p_support;
        setBuffer()
        setTimeout(preloadProgramms,100);
    }

    public function preloadProgramms():void
    {
        programs = [];
        registerProgram(0);
        registerProgram(1);
        registerProgram(2);
        registerProgram(3);
        registerProgram(128);
        registerProgram(129);
        registerProgram(33);
        registerProgram(131);
        registerProgram(32);
        registerProgram(130);

        registerProgram(8);
        registerProgram(36);
        registerProgram(37);


    }


    public function draw(p_image:Image):void
    {
       // trace("render Image",mNumQuads)

        if(mNumQuads != 0)
        {
            if(p_image.stateId != _currentStateId )
            {
                drawGPU();
                _drawTexture = p_image.texture.base;
                _drawTextureUID = p_image.textureUID;
                _currentProgramId = p_image.programId;
                _currentStateId = p_image.stateId;

                RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);
            }
            else
            if( _drawTextureUID != p_image.textureUID)
            {
                drawGPU();
                _drawTexture = p_image.texture.base;
                _drawTextureUID = p_image.textureUID;
               _currentProgramId = p_image.programId;
               _currentStateId = p_image.stateId;

               RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);

            }


        }else
        {
            _drawTexture = p_image.texture.base;
            _drawTextureUID = p_image.textureUID;
            _currentProgramId = p_image.programId;
            _currentStateId = p_image.stateId;

            RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);
        }



            sf32( p_image.worldX,                       _vcLength);
            _vcLength += 4;
           sf32( p_image.worldY,                       _vcLength);
            _vcLength += 4;
           sf32( p_image.worldWidth,                   _vcLength);
            _vcLength += 4;
           sf32( p_image.worldHeight,                  _vcLength);
            _vcLength += 4;

           var uvm:Rectangle = p_image.uvMapping;
           sf32(uvm.x,                   _vcLength);
            _vcLength += 4;
           sf32(uvm.y,                   _vcLength);
            _vcLength += 4;
           sf32(uvm.width,               _vcLength);
            _vcLength += 4;
           sf32(uvm.height,              _vcLength);
            _vcLength += 4;


           sf32(p_image.worldRotation,                 _vcLength);
            _vcLength += 4;
           sf32(p_image.worldPivotX,                   _vcLength);
            _vcLength += 4;
           sf32(p_image.worldPivotY,                   _vcLength);
            _vcLength += 8;

        mNumQuads++;
        if(mNumQuads ==41)
            drawGPU();


    }
    public function drawGPU():void
    {
        var context:Context3D = Starling.context;
        if(!programs[_currentProgramId])
                registerProgram(_currentProgramId);

        context.setProgram(programs[_currentProgramId]);

        context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4, mNumQuads * 3, _vertexConstantsByte,0);
        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_3);
        if(_drawTexture)
            context.setTextureAt(0, _drawTexture);


        context.drawTriangles(_indexBuffer, 0, mNumQuads * 2);

        mNumQuads = 0;
        _vcLength = 0;
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
        _vcLength = 0;
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

            registerIndex4 = 4+(i*3);

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

        var transformed:Boolean = pid >> 7 & 1;

         vertexProgramCode =
           "mov vt1, va0 \n" +
           "mul vt1.xy, vt1.xy, vc[va1.x].zw \n" +  // set width and height
           "sub vt1.xy, vt1.xy, vc[va1.z].yz \n";  // set pivot

           if(transformed)
           {
               vertexProgramCode += "mov vt2.x, vc[va1.z].x \n" +   //  get rotation
               "sin vt3.x, vt2.x \n" +
               "cos vt3.y, vt2.x \n" +

                 //apply rotation
               "mul vt4.xy, vt1.xy, vt3.yx \n" +
               "sub vt2.x, vt4.x, vt4.y \n" +
               "mul vt5.xy, vt1.yx, vt3.yx \n" +
               "add vt2.y, vt5.x, vt5.y \n" +
                //apply rotation

               "add vt1.xy, vt2.xy, vc[va1.x].xy \n"; // add x and y position
           }else
           {
               vertexProgramCode += "add vt1.xy, vt1.xy, vc[va1.x].xy \n";  // add x and y position
           }


           vertexProgramCode += "m44 op, vt1, vc0 \n" + // 4x4 matrix transform to output clipspace


           "mov vt3, va0 \n" +  //copy uv data
           "mul vt3.xy, vt3.xy, vc[va1.y].zw \n" +  // set uv width and height
           "add vt3.xy, vt3.xy, vc[va1.y].xy \n" + // add uv

           "mov v0, vt3      \n";// pass texture coordinates to fragment program

            fragmentProgramCode =
                    "tex  oc,  v0, fs0 <???> \n";  // sample texture 0




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
