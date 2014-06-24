/**
 * Created by IntelliJ IDEA.
 * User: julian
 * Date: 19.03.14
 * Time: 12:45
 * To change this template use File | Settings | File Templates.
 */
package starling.text {
import flash.display3D.Context3DTextureFormat;

import starling.core.RenderSupport;
import starling.display.BlendMode;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

public class GlyphImage extends Image{

    public var spread:Number;


    public function GlyphImage(p_texture:Texture) {

        super(p_texture);
    }


    override public function render(support:RenderSupport, p_parentUpdateTransform:Boolean, p_parentUpdateColor:Boolean, p_draw:Boolean):void {
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
            support.drawGlyph(this,parent as TextField);

    }

    protected override  function updateStateID():void
    {
        stateId = 0;


        stateId |= 1;
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

        var pTextField:TextField =  parent as TextField
        if(pTextField)
        {
            if(pTextField.hasGlow || pTextField.hasStroke)
               stateId |= 1 << 7;

        }


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

        if(pTextField)
        {
          if(pTextField.hasGlow )
             stateId |= 1 << 15;

        }



        //trace("updateStateID",programId,smoothing);
    }

}
}
