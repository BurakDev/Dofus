﻿package com.ankamagames.dofus.network.messages.debug
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class DebugInClientMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6028;

        private var _isInitialized:Boolean = false;
        public var level:uint = 0;
        public var message:String = "";


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6028);
        }

        public function initDebugInClientMessage(level:uint=0, message:String=""):DebugInClientMessage
        {
            this.level = level;
            this.message = message;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.level = 0;
            this.message = "";
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
            this.serializeAs_DebugInClientMessage(output);
        }

        public function serializeAs_DebugInClientMessage(output:ICustomDataOutput):void
        {
            output.writeByte(this.level);
            output.writeUTF(this.message);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_DebugInClientMessage(input);
        }

        public function deserializeAs_DebugInClientMessage(input:ICustomDataInput):void
        {
            this.level = input.readByte();
            if (this.level < 0)
            {
                throw (new Error((("Forbidden value (" + this.level) + ") on element of DebugInClientMessage.level.")));
            };
            this.message = input.readUTF();
        }


    }
}//package com.ankamagames.dofus.network.messages.debug

