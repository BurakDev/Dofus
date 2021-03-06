﻿package com.ankamagames.dofus.network.messages.game.inventory.exchanges
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ExchangeMountFreeFromPaddockMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6055;

        private var _isInitialized:Boolean = false;
        public var name:String = "";
        public var worldX:int = 0;
        public var worldY:int = 0;
        public var liberator:String = "";


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6055);
        }

        public function initExchangeMountFreeFromPaddockMessage(name:String="", worldX:int=0, worldY:int=0, liberator:String=""):ExchangeMountFreeFromPaddockMessage
        {
            this.name = name;
            this.worldX = worldX;
            this.worldY = worldY;
            this.liberator = liberator;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.name = "";
            this.worldX = 0;
            this.worldY = 0;
            this.liberator = "";
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
            this.serializeAs_ExchangeMountFreeFromPaddockMessage(output);
        }

        public function serializeAs_ExchangeMountFreeFromPaddockMessage(output:ICustomDataOutput):void
        {
            output.writeUTF(this.name);
            if ((((this.worldX < -255)) || ((this.worldX > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.worldX) + ") on element worldX.")));
            };
            output.writeShort(this.worldX);
            if ((((this.worldY < -255)) || ((this.worldY > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.worldY) + ") on element worldY.")));
            };
            output.writeShort(this.worldY);
            output.writeUTF(this.liberator);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ExchangeMountFreeFromPaddockMessage(input);
        }

        public function deserializeAs_ExchangeMountFreeFromPaddockMessage(input:ICustomDataInput):void
        {
            this.name = input.readUTF();
            this.worldX = input.readShort();
            if ((((this.worldX < -255)) || ((this.worldX > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.worldX) + ") on element of ExchangeMountFreeFromPaddockMessage.worldX.")));
            };
            this.worldY = input.readShort();
            if ((((this.worldY < -255)) || ((this.worldY > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.worldY) + ") on element of ExchangeMountFreeFromPaddockMessage.worldY.")));
            };
            this.liberator = input.readUTF();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.exchanges

