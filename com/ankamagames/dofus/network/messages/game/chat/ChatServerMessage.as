﻿package com.ankamagames.dofus.network.messages.game.chat
{
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ChatServerMessage extends ChatAbstractServerMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 881;

        private var _isInitialized:Boolean = false;
        public var senderId:int = 0;
        [Transient]
        public var senderName:String = "";
        public var senderAccountId:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (((super.isInitialized) && (this._isInitialized)));
        }

        override public function getMessageId():uint
        {
            return (881);
        }

        public function initChatServerMessage(channel:uint=0, content:String="", timestamp:uint=0, fingerprint:String="", senderId:int=0, senderName:String="", senderAccountId:uint=0):ChatServerMessage
        {
            super.initChatAbstractServerMessage(channel, content, timestamp, fingerprint);
            this.senderId = senderId;
            this.senderName = senderName;
            this.senderAccountId = senderAccountId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.senderId = 0;
            this.senderName = "";
            this.senderAccountId = 0;
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

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_ChatServerMessage(output);
        }

        public function serializeAs_ChatServerMessage(output:ICustomDataOutput):void
        {
            super.serializeAs_ChatAbstractServerMessage(output);
            output.writeInt(this.senderId);
            output.writeUTF(this.senderName);
            if (this.senderAccountId < 0)
            {
                throw (new Error((("Forbidden value (" + this.senderAccountId) + ") on element senderAccountId.")));
            };
            output.writeInt(this.senderAccountId);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ChatServerMessage(input);
        }

        public function deserializeAs_ChatServerMessage(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.senderId = input.readInt();
            this.senderName = input.readUTF();
            this.senderAccountId = input.readInt();
            if (this.senderAccountId < 0)
            {
                throw (new Error((("Forbidden value (" + this.senderAccountId) + ") on element of ChatServerMessage.senderAccountId.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.chat

