﻿package makers
{
    import blocks.ChallengeTooltipBlock;
    import d2hooks.*;

    public class ChallengeTooltipMaker 
    {


        public function createTooltip(data:*, param:Object):Object
        {
            var tooltip:Object = Api.tooltip.createTooltip("chunks/base/baseWithBackground.txt", "chunks/base/container.txt", "chunks/base/separator.txt");
            tooltip.addBlock(new ChallengeTooltipBlock(data).block);
            return (tooltip);
        }


    }
}//package makers

