/**
 * Created by IntelliJ IDEA.
 * User: julian
 * Date: 17.02.14
 * Time: 09:59
 * To change this template use File | Settings | File Templates.
 */
package starling.core.renderer {
import com.adobe.utils.AGALMiniAssembler;
import avm2.intrinsics.memory.*;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.Quad;

public class ColorRenderer {
    public static const ID:int = 2;
    private const MAX_NUM_QUADS:int = 40;
    private var _vertexBufferRegisterIndex4:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexConstantsByte:ByteArray;
    private var _vcLength:int = 0;
    private var mNumQuads:int = 0;

    private var _currentStateId:int = -1;




    private static var program:Program3D;
    private var _support:RenderSupport;

    public function ColorRenderer(p_vc:ByteArray, p_support:RenderSupport) {

        _vertexConstantsByte =  p_vc;
        this._support = p_support;
        ApplicationDomain.currentDomain.domainMemory = _vertexConstantsByte;
        registerPrograms()
        setBuffer()
    }
    public function draw(p_quad:Quad):void
    {


        if(mNumQuads != 0)
        {
            if(p_quad.stateId != _currentStateId )
            {
                drawGPU();
                _currentStateId = p_quad.stateId;
                RenderSupport.setBlendFactors(false, p_quad.worldBlendmode);
            }

        }
        else{
            _currentStateId = p_quad.stateId;
            RenderSupport.setBlendFactors(false, p_quad.worldBlendmode);

        }
       sf32( p_quad.worldX,                       _vcLength);
        _vcLength += 4
        sf32( p_quad.worldY,                       _vcLength);
        _vcLength += 4
        sf32( p_quad.worldWidth,                   _vcLength);
        _vcLength += 4
        sf32( p_quad.worldHeight,                  _vcLength);
        _vcLength += 4

        sf32(p_quad.worldRotation,                 _vcLength);
        _vcLength += 4
        sf32(p_quad.worldPivotX,                   _vcLength);
        _vcLength += 4
        sf32(p_quad.worldPivotY,                   _vcLength);
        _vcLength += 8

        sf32(p_quad.colorR,                     _vcLength);
        _vcLength += 4
        sf32(p_quad.colorG,                     _vcLength);
        _vcLength += 4
        sf32(p_quad.colorB,                     _vcLength);
        _vcLength += 4
        sf32(p_quad.worldAlpha,                 _vcLength);
        _vcLength += 4


        mNumQuads++;
        if(mNumQuads ==41)
            drawGPU();


    }
    public function drawGPU():void
    {
        var context:Context3D = Starling.context;


        context.setProgram(program);

        context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 4, mNumQuads * 3, _vertexConstantsByte,0);
        context.setVertexBufferAt(1, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_3);

        context.drawTriangles(_indexBuffer, 0, mNumQuads * 2);

        context.setVertexBufferAt(1, null);
        context.setProgram(null);

        mNumQuads = 0;
        _vcLength = 0;

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




    }

    private static function registerPrograms():void
    {
        var target:Starling = Starling.current;

        var assembler:AGALMiniAssembler = new AGALMiniAssembler();
        var vertexProgramCode:String;
        var fragmentProgramCode:String;

        vertexProgramCode =
        "mov vt1, va0 \n" +
            "mul vt1.xy, vt1.xy, vc[va1.x].zw \n" +  // set width and height
            "sub vt1.xy, vt1.xy, vc[va1.y].yz \n" +  // set pivot

            "mov vt2.x, vc[va1.y].x \n" +   //  get rotation
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

            "mov v0, vc[va1.z]      \n";  // passcolor to fragment program


        fragmentProgramCode =
                "mov  oc, v0 \n";  // sample texture 0



       program = target.context.createProgram();
       program.upload(
                                assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                                assembler.assemble(Context3DProgramType.FRAGMENT,fragmentProgramCode)
       );


    }


}
}
