﻿package com.ankamagames.dofus.network.messages.game.context.fight
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameFightReadyMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 708;

        private var _isInitialized:Boolean = false;
        public var isReady:Boolean = false;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (708);
        }

        public function initGameFightReadyMessage(isReady:Boolean=false):GameFightReadyMessage
        {
            this.isReady = isReady;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.isReady = false;
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
            this.serializeAs_GameFightReadyMessage(output);
        }

        public function serializeAs_GameFightReadyMessage(output:ICustomDataOutput):void
        {
            output.writeBoolean(this.isReady);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameFightReadyMessage(input);
        }

        public function deserializeAs_GameFightReadyMessage(input:ICustomDataInput):void
        {
            this.isReady = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.fight

