﻿package com.ankamagames.dofus.network.messages.game.inventory.exchanges
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import __AS3__.vec.Vector;
    import com.ankamagames.dofus.network.types.game.data.items.ObjectItemToSell;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import __AS3__.vec.*;

    [Trusted]
    public class ExchangeShopStockMultiMovementUpdatedMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6038;

        private var _isInitialized:Boolean = false;
        public var objectInfoList:Vector.<ObjectItemToSell>;

        public function ExchangeShopStockMultiMovementUpdatedMessage()
        {
            this.objectInfoList = new Vector.<ObjectItemToSell>();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6038);
        }

        public function initExchangeShopStockMultiMovementUpdatedMessage(objectInfoList:Vector.<ObjectItemToSell>=null):ExchangeShopStockMultiMovementUpdatedMessage
        {
            this.objectInfoList = objectInfoList;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.objectInfoList = new Vector.<ObjectItemToSell>();
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
            this.serializeAs_ExchangeShopStockMultiMovementUpdatedMessage(output);
        }

        public function serializeAs_ExchangeShopStockMultiMovementUpdatedMessage(output:ICustomDataOutput):void
        {
            output.writeShort(this.objectInfoList.length);
            var _i1:uint;
            while (_i1 < this.objectInfoList.length)
            {
                (this.objectInfoList[_i1] as ObjectItemToSell).serializeAs_ObjectItemToSell(output);
                _i1++;
            };
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ExchangeShopStockMultiMovementUpdatedMessage(input);
        }

        public function deserializeAs_ExchangeShopStockMultiMovementUpdatedMessage(input:ICustomDataInput):void
        {
            var _item1:ObjectItemToSell;
            var _objectInfoListLen:uint = input.readUnsignedShort();
            var _i1:uint;
            while (_i1 < _objectInfoListLen)
            {
                _item1 = new ObjectItemToSell();
                _item1.deserialize(input);
                this.objectInfoList.push(_item1);
                _i1++;
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.exchanges

