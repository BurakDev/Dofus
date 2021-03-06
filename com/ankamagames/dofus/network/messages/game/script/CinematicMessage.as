﻿package com.ankamagames.dofus.network.messages.game.script
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class CinematicMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6053;

        private var _isInitialized:Boolean = false;
        public var cinematicId:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6053);
        }

        public function initCinematicMessage(cinematicId:uint=0):CinematicMessage
        {
            this.cinematicId = cinematicId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.cinematicId = 0;
            this._isInitialized = false;
        }

        override public function pack(output:ICustomDataOutput):void
        {
            var data:ByteArray = new ByteArray();
            this.serialize(new CustomDataWrapper(data));
            writePacket(output, this.getMessageId(), data);
        }

        override public function unpack(input:ICustomDataInput, length:uint):void
        {
            this.deserialize(input);
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_CinematicMessage(output);
        }

        public function serializeAs_CinematicMessage(output:ICustomDataOutput):void
        {
            if (this.cinematicId < 0)
            {
                throw (new Error((("Forbidden value (" + this.cinematicId) + ") on element cinematicId.")));
            };
            output.writeVarShort(this.cinematicId);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_CinematicMessage(input);
        }

        public function deserializeAs_CinematicMessage(input:ICustomDataInput):void
        {
            this.cinematicId = input.readVarUhShort();
            if (this.cinematicId < 0)
            {
                throw (new Error((("Forbidden value (" + this.cinematicId) + ") on element of CinematicMessage.cinematicId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.script

