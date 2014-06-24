

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

public class MultiTextureImageRenderer {
    public static const ID:int = 5;
    private const MAX_NUM_QUADS:int = 30;
    private var _vertexBufferRegisterIndex4:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexConstants:Vector.<Number>;
    private var _vertexConstantsByte:ByteArray;
    private var _vcLength:int = 0;
    private var mNumQuads:int = 0;


    private var _drawTexture1:TextureBase;
    private var _drawTexture2:TextureBase;
    private var _drawTexture3:TextureBase;
    private var _drawTexture4:TextureBase;


    private var _drawTextureUID1:uint = 0;
    private var _drawTextureUID2:uint = 0;
    private var _drawTextureUID3:uint = 0;
    private var _drawTextureUID4:uint = 0;

    private var _drawTextureCount:int = 0;
    private var _currentProgramId:int = -1;
    private var _currentStateId:int = -1;




    public static var programs:Array = [];

    private var _currentTextureID:uint = 0;
    private var _support:RenderSupport;

    public function MultiTextureImageRenderer(p_vc:ByteArray, p_support:RenderSupport) {
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



        if(mNumQuads != 0)
        {
           if(p_image.stateId != _currentStateId )
           {
               drawGPU();
               _drawTexture1 = p_image.texture.base;
               _drawTextureUID1 = p_image.textureUID;
               _drawTextureCount = 1;
               _currentTextureID = 0;
               _currentProgramId = p_image.programId;
               _currentStateId = p_image.stateId;

               RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);
           }
          else if(_drawTextureUID1 == p_image.textureUID)
               _currentTextureID = 0;
           else  if(_drawTextureUID2 == p_image.textureUID)
               _currentTextureID = 1;
           else  if(_drawTextureUID3 == p_image.textureUID)
               _currentTextureID = 2;
           else  if(_drawTextureUID4 == p_image.textureUID)
               _currentTextureID = 3;
           else
           {
               if(_drawTextureCount < 4)
               {
                   _currentTextureID = _drawTextureCount;
                   _drawTextureCount++;

                   if(_drawTextureCount == 1)
                   {
                       _drawTexture1 =  p_image.texture.base;
                       _drawTextureUID1 =  p_image.textureUID;
                   }
                   else if(_drawTextureCount == 2)
                   {
                      _drawTexture2 =  p_image.texture.base;
                      _drawTextureUID2 =  p_image.textureUID;
                  }
                   else if(_drawTextureCount == 3)
                   {
                      _drawTexture3 =  p_image.texture.base;
                      _drawTextureUID3 =  p_image.textureUID;
                  }
                   else if(_drawTextureCount == 4)
                   {
                      _drawTexture4 =  p_image.texture.base;
                      _drawTextureUID4 =  p_image.textureUID;
                  }


               }else
               {
                   drawGPU();
                   _drawTexture1 = p_image.texture.base;
                 _drawTextureUID1 = p_image.textureUID;
                 _drawTextureCount = 1;
                   _currentTextureID = 0;
                 _currentProgramId = p_image.programId;
                 _currentStateId = p_image.stateId;

                 RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);
               }

           }



        }else
        {
            _drawTexture1 = p_image.texture.base;
                _drawTextureUID1 = p_image.textureUID;
                _drawTextureCount = 1;
                _currentProgramId = p_image.programId;
                _currentStateId = p_image.stateId;

                RenderSupport.setBlendFactors(p_image.premultipliedAlpha, p_image.worldBlendmode);
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


        sf32(p_image.worldRotation,                 _vcLength);
        _vcLength += 4
        sf32(p_image.worldPivotX,                   _vcLength);
        _vcLength += 4
        sf32(p_image.worldPivotY,                   _vcLength);
        _vcLength += 8




        sf32((_currentTextureID == 0)?1:0,       _vcLength);
        _vcLength += 4
        sf32((_currentTextureID == 1)?1:0,       _vcLength);
        _vcLength += 4
        sf32((_currentTextureID == 2)?1:0,       _vcLength);
        _vcLength += 4
        sf32((_currentTextureID == 3)?1:0,       _vcLength);
        _vcLength += 4


        mNumQuads++;
        if(mNumQuads ==30)
            drawGPU();

    }
    public function drawGPU():void
    {
        var context:Context3D = Starling.context;
        if(!programs[_currentProgramId])
                registerProgram(_currentProgramId);

        context.setProgram(programs[_currentProgramId][_drawTextureCount-1]);

        context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4, mNumQuads * 4, _vertexConstantsByte,0);
        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_4);
        if(_drawTexture1)
            context.setTextureAt(0, _drawTexture1);
        if(_drawTexture2)
            context.setTextureAt(1, _drawTexture2);
        if(_drawTexture3)
            context.setTextureAt(2, _drawTexture3);
        if(_drawTexture4)
            context.setTextureAt(3, _drawTexture4);


        context.drawTriangles(_indexBuffer, 0, mNumQuads * 2);



        mNumQuads = 0;
        _vcLength = 0;
        _drawTextureCount = 0;
        _drawTexture1 = null;
        _drawTexture2 = null;
        _drawTexture3 = null;
        _drawTexture4 = null;
        _drawTextureUID1 = 0;
        _drawTextureUID2 = 0;
        _drawTextureUID3 = 0;
        _drawTextureUID4 = 0;

        context.setTextureAt(0, null);
        context.setTextureAt(1, null);
        context.setTextureAt(2, null);
        context.setTextureAt(3, null);
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
           indexData.push((i*4) + 0);
           indexData.push((i*4) +1);
           indexData.push((i*4) +2);

           indexData.push((i*4) +1);
           indexData.push((i*4) +2);
           indexData.push((i*4) +3);

           registerIndex4 = 4+(i*4);


          registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2,registerIndex4+3);
          registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2,registerIndex4+3);
          registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2,registerIndex4+3);
          registerIndexData4.push(registerIndex4,registerIndex4+1,registerIndex4+2,registerIndex4+3);
       }


       _indexBuffer = context.createIndexBuffer(MAX_NUM_QUADS*6);
       _indexBuffer.uploadFromVector(indexData, 0, MAX_NUM_QUADS*6);



       _vertexBufferRegisterIndex4 = context.createVertexBuffer(MAX_NUM_QUADS*4, 4);
       _vertexBufferRegisterIndex4.uploadFromVector(registerIndexData4, 0, MAX_NUM_QUADS*4);


        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_4);
        //context.setVertexBufferAt(1, _vertexBufferRegisterIndex3, 0, Context3DVertexBufferFormat.FLOAT_3);
        //context.setVertexBufferAt(3, _vertexBufferRegisterIndex2, 0, Context3DVertexBufferFormat.FLOAT_2);

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

        var tinted:Boolean = pid & 1;
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
        //00100000

        var tc:int = 4

       for(var t:int = 0; t < tc; t++)
       {

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

           if( t > 0)
              vertexProgramCode +="mov v1, vc[va1.w]      \n";  // passcolor to fragment program


            if(t == 0)
            {

                fragmentProgramCode =
                "tex  oc,  v0, fs0 <???> \n";  // sample texture 0


            }
            else if(t == 1)
            {
                fragmentProgramCode =
                "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0
                "mul ft0, ft0, v1.xxxx \n" +
                "tex  ft1,  v0, fs1 <???> \n" + // sample texture 1
                "mul ft1, ft1, v1.yyyy \n" +
                "add ft0, ft0, ft1 \n" +
                "mov  oc, ft0  \n";
            }
           else if(t == 2)
            {
                fragmentProgramCode =
                "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0
                "mul ft0, ft0, v1.xxxx \n" +
                "tex  ft1,  v0, fs1 <???> \n" + // sample texture 1
                "mul ft1, ft1, v1.yyyy \n" +
                "tex  ft2,  v0, fs2 <???> \n" + // sample texture 2
                "mul ft2, ft2, v1.zzzz \n" +
                "add ft0, ft0, ft1 \n" +
                "add ft0, ft0, ft2 \n" +
                "mov  oc, ft0  \n";
            }
           else if(t == 3)
            {


                fragmentProgramCode =
                "tex  ft0,  v0, fs0 <???> \n" + // sample texture 0
                "mul ft0, ft0, v1.xxxx \n" +
                "tex  ft1,  v0, fs1 <???> \n" + // sample texture 1
                "mul ft1, ft1, v1.yyyy \n" +
                "tex  ft2,  v0, fs2 <???> \n" + // sample texture 2
                "mul ft2, ft2, v1.zzzz \n" +
                "tex  ft3,  v0, fs3 <???> \n" + // sample texture 3
                "mul ft3, ft3, v1.wwww \n" +
                "add ft0, ft0, ft1 \n" +
                "add ft0, ft0, ft2 \n" +
                "add ft0, ft0, ft3 \n" +
                "mov  oc, ft0  \n";
            }


            var flags:String = RenderSupport.getTextureLookupFlags(format, mipmap, repeat, smoothing);

            var program:Program3D = target.context.createProgram();

            var fragmentReplaced:String =  fragmentProgramCode.replace("<???>", flags);
            fragmentReplaced =  fragmentReplaced.replace("<???>", flags);
            fragmentReplaced =  fragmentReplaced.replace("<???>", flags);
            fragmentReplaced =  fragmentReplaced.replace("<???>", flags);
            program.upload(
                    assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                    assembler.assemble(Context3DProgramType.FRAGMENT,fragmentReplaced)
            );


            if(!programs[pid])
                programs[pid] = [];
            programs[pid][t] = program;



        }

    }


}
}

