﻿package com.ankamagames.dofus.internalDatacenter.communication
{
    import com.ankamagames.jerakine.interfaces.IDataCenter;

    public class DelayedActionItem implements IDataCenter 
    {

        public var playerId:uint;
        public var type:uint;
        public var dataId:int;
        public var endTime:Number;

        public function DelayedActionItem(pPlayerId:uint, type:uint, dataId:int, endTime:Number)
        {
            this.playerId = pPlayerId;
            this.type = type;
            this.dataId = dataId;
            this.endTime = endTime;
        }

    }
}//package com.ankamagames.dofus.internalDatacenter.communication

