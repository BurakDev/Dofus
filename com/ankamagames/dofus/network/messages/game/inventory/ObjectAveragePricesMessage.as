﻿package com.ankamagames.dofus.network.messages.game.inventory
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import __AS3__.vec.Vector;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import __AS3__.vec.*;

    [Trusted]
    public class ObjectAveragePricesMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6335;

        private var _isInitialized:Boolean = false;
        public var ids:Vector.<uint>;
        public var avgPrices:Vector.<uint>;

        public function ObjectAveragePricesMessage()
        {
            this.ids = new Vector.<uint>();
            this.avgPrices = new Vector.<uint>();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6335);
        }

        public function initObjectAveragePricesMessage(ids:Vector.<uint>=null, avgPrices:Vector.<uint>=null):ObjectAveragePricesMessage
        {
            this.ids = ids;
            this.avgPrices = avgPrices;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.ids = new Vector.<uint>();
            this.avgPrices = new Vector.<uint>();
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
            this.serializeAs_ObjectAveragePricesMessage(output);
        }

        public function serializeAs_ObjectAveragePricesMessage(output:ICustomDataOutput):void
        {
            output.writeShort(this.ids.length);
            var _i1:uint;
            while (_i1 < this.ids.length)
            {
                if (this.ids[_i1] < 0)
                {
                    throw (new Error((("Forbidden value (" + this.ids[_i1]) + ") on element 1 (starting at 1) of ids.")));
                };
                output.writeVarShort(this.ids[_i1]);
                _i1++;
            };
            output.writeShort(this.avgPrices.length);
            var _i2:uint;
            while (_i2 < this.avgPrices.length)
            {
                if (this.avgPrices[_i2] < 0)
                {
                    throw (new Error((("Forbidden value (" + this.avgPrices[_i2]) + ") on element 2 (starting at 1) of avgPrices.")));
                };
                output.writeVarInt(this.avgPrices[_i2]);
                _i2++;
            };
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ObjectAveragePricesMessage(input);
        }

        public function deserializeAs_ObjectAveragePricesMessage(input:ICustomDataInput):void
        {
            var _val1:uint;
            var _val2:uint;
            var _idsLen:uint = input.readUnsignedShort();
            var _i1:uint;
            while (_i1 < _idsLen)
            {
                _val1 = input.readVarUhShort();
                if (_val1 < 0)
                {
                    throw (new Error((("Forbidden value (" + _val1) + ") on elements of ids.")));
                };
                this.ids.push(_val1);
                _i1++;
            };
            var _avgPricesLen:uint = input.readUnsignedShort();
            var _i2:uint;
            while (_i2 < _avgPricesLen)
            {
                _val2 = input.readVarUhInt();
                if (_val2 < 0)
                {
                    throw (new Error((("Forbidden value (" + _val2) + ") on elements of avgPrices.")));
                };
                this.avgPrices.push(_val2);
                _i2++;
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory

