﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.fight
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameRolePlayRemoveChallengeMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 300;

        private var _isInitialized:Boolean = false;
        public var fightId:int = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (300);
        }

        public function initGameRolePlayRemoveChallengeMessage(fightId:int=0):GameRolePlayRemoveChallengeMessage
        {
            this.fightId = fightId;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.fightId = 0;
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
            this.serializeAs_GameRolePlayRemoveChallengeMessage(output);
        }

        public function serializeAs_GameRolePlayRemoveChallengeMessage(output:ICustomDataOutput):void
        {
            output.writeInt(this.fightId);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameRolePlayRemoveChallengeMessage(input);
        }

        public function deserializeAs_GameRolePlayRemoveChallengeMessage(input:ICustomDataInput):void
        {
            this.fightId = input.readInt();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.fight

