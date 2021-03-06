﻿package com.ankamagames.dofus.network.messages.game.guild
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.context.roleplay.GuildInformations;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GuildJoinedMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5564;

        private var _isInitialized:Boolean = false;
        public var guildInfo:GuildInformations;
        public var memberRights:uint = 0;
        public var enabled:Boolean = false;

        public function GuildJoinedMessage()
        {
            this.guildInfo = new GuildInformations();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5564);
        }

        public function initGuildJoinedMessage(guildInfo:GuildInformations=null, memberRights:uint=0, enabled:Boolean=false):GuildJoinedMessage
        {
            this.guildInfo = guildInfo;
            this.memberRights = memberRights;
            this.enabled = enabled;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.guildInfo = new GuildInformations();
            this.enabled = false;
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
            this.serializeAs_GuildJoinedMessage(output);
        }

        public function serializeAs_GuildJoinedMessage(output:ICustomDataOutput):void
        {
            this.guildInfo.serializeAs_GuildInformations(output);
            if (this.memberRights < 0)
            {
                throw (new Error((("Forbidden value (" + this.memberRights) + ") on element memberRights.")));
            };
            output.writeVarInt(this.memberRights);
            output.writeBoolean(this.enabled);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GuildJoinedMessage(input);
        }

        public function deserializeAs_GuildJoinedMessage(input:ICustomDataInput):void
        {
            this.guildInfo = new GuildInformations();
            this.guildInfo.deserialize(input);
            this.memberRights = input.readVarUhInt();
            if (this.memberRights < 0)
            {
                throw (new Error((("Forbidden value (" + this.memberRights) + ") on element of GuildJoinedMessage.memberRights.")));
            };
            this.enabled = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.guild

