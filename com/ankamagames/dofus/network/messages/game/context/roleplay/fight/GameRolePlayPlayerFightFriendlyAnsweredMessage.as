﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.fight
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameRolePlayPlayerFightFriendlyAnsweredMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5733;

        private var _isInitialized:Boolean = false;
        public var fightId:int = 0;
        public var sourceId:uint = 0;
        public var targetId:uint = 0;
        public var accept:Boolean = false;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5733);
        }

        public function initGameRolePlayPlayerFightFriendlyAnsweredMessage(fightId:int=0, sourceId:uint=0, targetId:uint=0, accept:Boolean=false):GameRolePlayPlayerFightFriendlyAnsweredMessage
        {
            this.fightId = fightId;
            this.sourceId = sourceId;
            this.targetId = targetId;
            this.accept = accept;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.fightId = 0;
            this.sourceId = 0;
            this.targetId = 0;
            this.accept = false;
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
            this.serializeAs_GameRolePlayPlayerFightFriendlyAnsweredMessage(output);
        }

        public function serializeAs_GameRolePlayPlayerFightFriendlyAnsweredMessage(output:ICustomDataOutput):void
        {
            output.writeInt(this.fightId);
            if (this.sourceId < 0)
            {
                throw (new Error((("Forbidden value (" + this.sourceId) + ") on element sourceId.")));
            };
            output.writeVarInt(this.sourceId);
            if (this.targetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.targetId) + ") on element targetId.")));
            };
            output.writeVarInt(this.targetId);
            output.writeBoolean(this.accept);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameRolePlayPlayerFightFriendlyAnsweredMessage(input);
        }

        public function deserializeAs_GameRolePlayPlayerFightFriendlyAnsweredMessage(input:ICustomDataInput):void
        {
            this.fightId = input.readInt();
            this.sourceId = input.readVarUhInt();
            if (this.sourceId < 0)
            {
                throw (new Error((("Forbidden value (" + this.sourceId) + ") on element of GameRolePlayPlayerFightFriendlyAnsweredMessage.sourceId.")));
            };
            this.targetId = input.readVarUhInt();
            if (this.targetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.targetId) + ") on element of GameRolePlayPlayerFightFriendlyAnsweredMessage.targetId.")));
            };
            this.accept = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.fight

