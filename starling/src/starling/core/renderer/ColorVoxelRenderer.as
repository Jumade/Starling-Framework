/**
 * Created with IntelliJ IDEA.
 * User: julian
 * Date: 13.07.14
 * Time: 11:59
 * To change this template use File | Settings | File Templates.
 */
package starling.core.renderer {
import com.adobe.utils.AGALMiniAssembler;

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
import starling.display.ColorVoxel;
import avm2.intrinsics.memory.*;

public class ColorVoxelRenderer {
    public static const ID:int = 7;
     private const MAX_NUM_QUADS:int = 60;
     private var _vertexBufferRegisterIndex4:VertexBuffer3D;
     private var _indexBuffer:IndexBuffer3D;
     private var _vertexConstantsByte:ByteArray;
     private var _vcLength:int = 0;
     private var mNumQuads:int = 0;

     private var _currentStateId:int = -1;




     private static var program:Program3D;
     private var _support:RenderSupport;
    private var _fragmentConstants:Vector.<Number>;

     public function ColorVoxelRenderer(p_vc:ByteArray, p_support:RenderSupport) {

         _vertexConstantsByte =  p_vc;
         _fragmentConstants = new Vector.<Number>();
         _fragmentConstants[0] = .5; // center
         _fragmentConstants[1] = .2; // size
         _fragmentConstants[2] = .1;
         _fragmentConstants[3] = 1.1;
         this._support = p_support;
         ApplicationDomain.currentDomain.domainMemory = _vertexConstantsByte;
         registerPrograms()
         setBuffer()
     }
     public function draw(p_quad:ColorVoxel):void
     {

        sf32( p_quad.worldX,                       _vcLength);
         _vcLength += 4
         sf32( p_quad.worldY,                       _vcLength);
         _vcLength += 4
         sf32( p_quad.worldZ,                   _vcLength);
         _vcLength += 4
         sf32( p_quad.worldWidth,                  _vcLength);
         _vcLength += 4


         sf32(p_quad.colorR,                     _vcLength);
         _vcLength += 4
         sf32(p_quad.colorG,                     _vcLength);
         _vcLength += 4
         sf32(p_quad.colorB,                     _vcLength);
         _vcLength += 4
         sf32(p_quad.worldAlpha,                 _vcLength);
         _vcLength += 4


         mNumQuads++;
         if(mNumQuads ==60)
             drawGPU();


     }
     public function drawGPU():void
     {
         _support.set3DBuffer()
         var context:Context3D = Starling.context;


         context.setProgram(program);

         context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 5, mNumQuads * 2, _vertexConstantsByte,0);
         context.setVertexBufferAt(3, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_2);
         context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_fragmentConstants);
         context.drawTriangles(_indexBuffer, 0, mNumQuads * 2*6);

         context.setVertexBufferAt(1, null);
         context.setProgram(null);

         mNumQuads = 0;
         _vcLength = 0;

         _support.raiseDrawCount();
          _support.set2DBuffer()
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

             //front
             indexData.push((i*24) +0);
             indexData.push((i*24) +1);
             indexData.push((i*24) +2);

             indexData.push((i*24) +1);
             indexData.push((i*24) +3);
             indexData.push((i*24) +2);

                //back
            indexData.push((i*24) +6);
            indexData.push((i*24) +5);
            indexData.push((i*24) +4);

            indexData.push((i*24) +7);
            indexData.push((i*24) +5);
            indexData.push((i*24) +6);


                //top
            indexData.push((i*24) +4+8);
            indexData.push((i*24) +5+8);
            indexData.push((i*24) +0+8);

            indexData.push((i*24) +5+8);
            indexData.push((i*24) +1+8);
            indexData.push((i*24) +0+8);
                //down
            indexData.push((i*24) +2+8);
            indexData.push((i*24) +3+8);
            indexData.push((i*24) +6+8);

            indexData.push((i*24) +3+8);
            indexData.push((i*24) +7+8);
            indexData.push((i*24) +6+8);

             //left
             indexData.push((i*24) +4 +16);
             indexData.push((i*24) +0 +16);
             indexData.push((i*24) +6 +16);

             indexData.push((i*24) +0 +16);
             indexData.push((i*24) +2 +16);
             indexData.push((i*24) +6 +16);

             //right
            indexData.push((i*24) +1+16);
            indexData.push((i*24) +5+16);
            indexData.push((i*24) +3+16);

            indexData.push((i*24) +5+16);
            indexData.push((i*24) +7+16);
            indexData.push((i*24) +3+16);



             registerIndex4 = 5+(i*2);


             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);


             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);

             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
             registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);
            registerIndexData4.push(registerIndex4,registerIndex4+1);

         }


         _indexBuffer = context.createIndexBuffer(MAX_NUM_QUADS*6*6);
         _indexBuffer.uploadFromVector(indexData, 0, MAX_NUM_QUADS*6*6);



         _vertexBufferRegisterIndex4 = context.createVertexBuffer(MAX_NUM_QUADS*8*3, 2);
         _vertexBufferRegisterIndex4.uploadFromVector(registerIndexData4, 0, MAX_NUM_QUADS*8*3);




     }

     private static function registerPrograms():void
     {
         var target:Starling = Starling.current;

         var assembler:AGALMiniAssembler = new AGALMiniAssembler();
         var vertexProgramCode:String;
         var fragmentProgramCode:String;

         vertexProgramCode =
         "mov vt1, va0 \n" +
             "mul vt1.xyz, vt1.xyz, vc[va3.x].w \n" +  // set width and height


             "add vt1.xyz, vt1.xyz, vc[va3.x].xyz \n" + // add x and y position

             "m44 op, vt1, vc0 \n" + // 4x4 matrix transform to output clipspace

             "mov vt2, va1 \n"+
            // "nrm vt2.xyz, vt2 \n"+

             "dp3 vt2, vt2, vc4 \n"+
             "sat vt2, vt2 \n"+
             "add vt2, vt2, vc4.w \n"+
             "mov vt3, vc[va3.y]      \n"+
             "mul vt3.xyz, vt3.xyz, vt2      \n"+
             "mov v0, vt3     \n"+   // passcolor to fragment program
             "mov v1, va2     \n";



         fragmentProgramCode =
                 "mov  ft0, v0 \n"+
                 "mov  ft1, v1 \n"+
                 "sub  ft1.xy, ft1.xy, fc0.xx \n"+
                 "abs  ft1.xy, ft1.xy \n"+
                 "sub  ft1.xy, fc0.xx,ft1.xy \n"+
                 "div  ft1.xy, ft1.xy,fc0.yy \n"+
                 "min  ft1.x, ft1.y ,ft1.x\n"+
                 "sat  ft1.xy, ft1.xy \n"+
                 "mul  ft1.xy, ft1.xy, fc0.zz \n"+
                 "add  ft1.xy, ft1.xy, fc0.ww \n"+
                 "mul  ft0.xyz,ft0.xyz, ft1.x \n"+

                 "mov  oc, ft0 \n";



        program = target.context.createProgram();
        program.upload(
                                 assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                                 assembler.assemble(Context3DProgramType.FRAGMENT,fragmentProgramCode)
        );


     }


 }
 }
