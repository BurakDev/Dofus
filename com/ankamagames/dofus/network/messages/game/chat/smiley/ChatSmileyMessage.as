﻿package com.ankamagames.dofus.network.messages.game.chat.smiley
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ChatSmileyMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 801;

        private var _isInitialized:Boolean = false;
        public var entityId:int = 0;
        public var smileyId:uint = 0;
        public var accountId:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (801);
        }

        public function initChatSmileyMessage(entityId:int=0, smileyId:uint=0, accountId:uint=0):ChatSmileyMessage
        {
            this.entityId = entityId;
            this.smileyId = smileyId;
            this.accountId = accountId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.entityId = 0;
            this.smileyId = 0;
            this.accountId = 0;
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
            this.serializeAs_ChatSmileyMessage(output);
        }

        public function serializeAs_ChatSmileyMessage(output:ICustomDataOutput):void
        {
            output.writeInt(this.entityId);
            if (this.smileyId < 0)
            {
                throw (new Error((("Forbidden value (" + this.smileyId) + ") on element smileyId.")));
            };
            output.writeByte(this.smileyId);
            if (this.accountId < 0)
            {
                throw (new Error((("Forbidden value (" + this.accountId) + ") on element accountId.")));
            };
            output.writeInt(this.accountId);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ChatSmileyMessage(input);
        }

        public function deserializeAs_ChatSmileyMessage(input:ICustomDataInput):void
        {
            this.entityId = input.readInt();
            this.smileyId = input.readByte();
            if (this.smileyId < 0)
            {
                throw (new Error((("Forbidden value (" + this.smileyId) + ") on element of ChatSmileyMessage.smileyId.")));
            };
            this.accountId = input.readInt();
            if (this.accountId < 0)
            {
                throw (new Error((("Forbidden value (" + this.accountId) + ") on element of ChatSmileyMessage.accountId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.chat.smiley

