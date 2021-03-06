﻿package com.ankamagames.dofus.network.messages.game.inventory.exchanges
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ExchangeOkMultiCraftMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5768;

        private var _isInitialized:Boolean = false;
        public var initiatorId:uint = 0;
        public var otherId:uint = 0;
        public var role:int = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5768);
        }

        public function initExchangeOkMultiCraftMessage(initiatorId:uint=0, otherId:uint=0, role:int=0):ExchangeOkMultiCraftMessage
        {
            this.initiatorId = initiatorId;
            this.otherId = otherId;
            this.role = role;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.initiatorId = 0;
            this.otherId = 0;
            this.role = 0;
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
            this.serializeAs_ExchangeOkMultiCraftMessage(output);
        }

        public function serializeAs_ExchangeOkMultiCraftMessage(output:ICustomDataOutput):void
        {
            if (this.initiatorId < 0)
            {
                throw (new Error((("Forbidden value (" + this.initiatorId) + ") on element initiatorId.")));
            };
            output.writeVarInt(this.initiatorId);
            if (this.otherId < 0)
            {
                throw (new Error((("Forbidden value (" + this.otherId) + ") on element otherId.")));
            };
            output.writeVarInt(this.otherId);
            output.writeByte(this.role);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ExchangeOkMultiCraftMessage(input);
        }

        public function deserializeAs_ExchangeOkMultiCraftMessage(input:ICustomDataInput):void
        {
            this.initiatorId = input.readVarUhInt();
            if (this.initiatorId < 0)
            {
                throw (new Error((("Forbidden value (" + this.initiatorId) + ") on element of ExchangeOkMultiCraftMessage.initiatorId.")));
            };
            this.otherId = input.readVarUhInt();
            if (this.otherId < 0)
            {
                throw (new Error((("Forbidden value (" + this.otherId) + ") on element of ExchangeOkMultiCraftMessage.otherId.")));
            };
            this.role = input.readByte();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.exchanges

