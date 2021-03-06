﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.treasureHunt
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class TreasureHuntDigRequestMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6485;

        private var _isInitialized:Boolean = false;
        public var questType:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6485);
        }

        public function initTreasureHuntDigRequestMessage(questType:uint=0):TreasureHuntDigRequestMessage
        {
            this.questType = questType;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.questType = 0;
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
            this.serializeAs_TreasureHuntDigRequestMessage(output);
        }

        public function serializeAs_TreasureHuntDigRequestMessage(output:ICustomDataOutput):void
        {
            output.writeByte(this.questType);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_TreasureHuntDigRequestMessage(input);
        }

        public function deserializeAs_TreasureHuntDigRequestMessage(input:ICustomDataInput):void
        {
            this.questType = input.readByte();
            if (this.questType < 0)
            {
                throw (new Error((("Forbidden value (" + this.questType) + ") on element of TreasureHuntDigRequestMessage.questType.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.treasureHunt

