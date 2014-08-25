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

import starling.view.VoxelView;

public class ColorVoxelRenderer {
    public static const ID:int = 7;
     private const MAX_NUM_QUADS:int = 60;
     private const CONSTANTS_START_INDEX:int = 6;
     private var _vertexBufferRegisterIndex4:VertexBuffer3D;
     private var _indexBuffer:IndexBuffer3D;
     private var _vertexConstantsByte:ByteArray;
     private var _vcLength:int = 0;
     private var mNumQuads:int = 0;

     private var _currentStateId:int = -1;




     private static var programs:Array = [];
     private var _support:RenderSupport;
    private var _currentProgramId:int = -1;


     public function ColorVoxelRenderer(p_vc:ByteArray, p_support:RenderSupport) {

         _vertexConstantsByte =  p_vc;

         this._support = p_support;
         ApplicationDomain.currentDomain.domainMemory = _vertexConstantsByte;
         setBuffer()
     }
    public function setProgram(p_id:int):void
    {
         if(_currentProgramId != p_id)
         {
             if(mNumQuads != 0)
                drawGPU();
             _currentProgramId = p_id;
             if(!programs[_currentProgramId])
                registerProgram(_currentProgramId);

         }
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



        context.setProgram(programs[_currentProgramId]);

         context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, CONSTANTS_START_INDEX, mNumQuads * 2, _vertexConstantsByte,0);
         context.setVertexBufferAt(3, _vertexBufferRegisterIndex4, 0, Context3DVertexBufferFormat.FLOAT_2);

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



             registerIndex4 = CONSTANTS_START_INDEX+(i*2);


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

     private static function registerProgram(pid:int):void
     {
         var target:Starling = Starling.current;



        var pointCount:int = 0;

        if(pid >> 0 & 1)
             pointCount =1;
        else if(pid >> 1 & 1)
             pointCount =2;
        else
             pointCount =0;




         var assembler:AGALMiniAssembler = new AGALMiniAssembler();
         var vertexProgramCode:String;
         var fragmentProgramCode:String;

         vertexProgramCode =
         "mov vt1, va0 \n" +
         "mul vt1.xyz, vt1.xyz, vc[va3.x].w \n" +  // set width and height

         "add vt1.xyz, vt1.xyz, vc[va3.x].xyz \n" + // add x and y position

         // Directional light
         "dp3 vt2, va1, vc4 \n"+
         "sat vt2,vt2  \n"+
         "mul vt2, vt2, vc4.w  \n"+
         "add vt2, vt2, vc5.w  \n"+

         "mul v0,  vc[va3.y].xyz, vt2  \n"+
         "mov v0.w,  vc[va3.y].w  \n"+

         "m44 op, vt1, vc0 \n"+ // 4x4 matrix transform to output clipspace
         "mov v2, va2     \n"+
         "mov v3, va1     \n"+
         "mov  v1, vt1 \n";


        if(pointCount == 0)
        {
            fragmentProgramCode ="mov  oc, v0 \n";
        }else
        {
            fragmentProgramCode ="mov  ft0, v0 \n";
            for(var l:int = 0; l < pointCount; l++)
            {
                var posFC:String = "fc"+(l*2);
                var colorFC:String = "fc"+(l*2+1);


                 // Light Diff
                fragmentProgramCode +="sub ft1 ,v1.xyz, "+posFC+".xyz   \n"+


                // Point light distance
                "dp3 ft2,ft1, ft1  \n"+
                "sqt  ft2,ft2  \n"+
                "mul ft2,"+posFC+".w, ft2  \n"+
                "rcp ft2,ft2  \n"+

               // Point light normal
               "nrm ft1.xyz, ft1  \n"+
               "dp3 ft3,v3, ft1  \n"+
               "max ft3,ft3, fc1.w  \n"+



               // Merge lights
               "mul ft2, ft2, ft3  \n"+
               //"sat ft2,ft2  \n"+
               "mul ft2.xyz, "+colorFC+".xyz, ft2  \n"+
               "add ft0.xyz,  ft0.xyz, ft2.xyz  \n";

            }
            fragmentProgramCode +=  "mov  oc, ft0 \n";
        }

        var program:Program3D = target.context.createProgram();
        program.upload(      assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
                                 assembler.assemble(Context3DProgramType.FRAGMENT,fragmentProgramCode)
        );
         programs[pid] = program;

     }


 }
 }
