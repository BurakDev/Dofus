﻿package com.ankamagames.dofus.network.messages.web.krosmaster
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class KrosmasterAuthTokenErrorMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6345;

        private var _isInitialized:Boolean = false;
        public var reason:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6345);
        }

        public function initKrosmasterAuthTokenErrorMessage(reason:uint=0):KrosmasterAuthTokenErrorMessage
        {
            this.reason = reason;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.reason = 0;
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
            this.serializeAs_KrosmasterAuthTokenErrorMessage(output);
        }

        public function serializeAs_KrosmasterAuthTokenErrorMessage(output:ICustomDataOutput):void
        {
            output.writeByte(this.reason);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_KrosmasterAuthTokenErrorMessage(input);
        }

        public function deserializeAs_KrosmasterAuthTokenErrorMessage(input:ICustomDataInput):void
        {
            this.reason = input.readByte();
            if (this.reason < 0)
            {
                throw (new Error((("Forbidden value (" + this.reason) + ") on element of KrosmasterAuthTokenErrorMessage.reason.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.web.krosmaster

