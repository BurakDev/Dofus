﻿package com.ankamagames.dofus.network.types.game.social
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.dofus.network.types.game.guild.GuildEmblem;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GuildInsiderFactSheetInformations extends GuildFactSheetInformations implements INetworkType 
    {

        public static const protocolId:uint = 423;

        public var leaderName:String = "";
        public var nbConnectedMembers:uint = 0;
        public var nbTaxCollectors:uint = 0;
        public var lastActivity:uint = 0;
        public var enabled:Boolean = false;


        override public function getTypeId():uint
        {
            return (423);
        }

        public function initGuildInsiderFactSheetInformations(guildId:uint=0, guildName:String="", guildEmblem:GuildEmblem=null, leaderId:uint=0, guildLevel:uint=0, nbMembers:uint=0, leaderName:String="", nbConnectedMembers:uint=0, nbTaxCollectors:uint=0, lastActivity:uint=0, enabled:Boolean=false):GuildInsiderFactSheetInformations
        {
            super.initGuildFactSheetInformations(guildId, guildName, guildEmblem, leaderId, guildLevel, nbMembers);
            this.leaderName = leaderName;
            this.nbConnectedMembers = nbConnectedMembers;
            this.nbTaxCollectors = nbTaxCollectors;
            this.lastActivity = lastActivity;
            this.enabled = enabled;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.leaderName = "";
            this.nbConnectedMembers = 0;
            this.nbTaxCollectors = 0;
            this.lastActivity = 0;
            this.enabled = false;
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_GuildInsiderFactSheetInformations(output);
        }

        public function serializeAs_GuildInsiderFactSheetInformations(output:ICustomDataOutput):void
        {
            super.serializeAs_GuildFactSheetInformations(output);
            output.writeUTF(this.leaderName);
            if (this.nbConnectedMembers < 0)
            {
                throw (new Error((("Forbidden value (" + this.nbConnectedMembers) + ") on element nbConnectedMembers.")));
            };
            output.writeVarShort(this.nbConnectedMembers);
            if (this.nbTaxCollectors < 0)
            {
                throw (new Error((("Forbidden value (" + this.nbTaxCollectors) + ") on element nbTaxCollectors.")));
            };
            output.writeByte(this.nbTaxCollectors);
            if (this.lastActivity < 0)
            {
                throw (new Error((("Forbidden value (" + this.lastActivity) + ") on element lastActivity.")));
            };
            output.writeInt(this.lastActivity);
            output.writeBoolean(this.enabled);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GuildInsiderFactSheetInformations(input);
        }

        public function deserializeAs_GuildInsiderFactSheetInformations(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.leaderName = input.readUTF();
            this.nbConnectedMembers = input.readVarUhShort();
            if (this.nbConnectedMembers < 0)
            {
                throw (new Error((("Forbidden value (" + this.nbConnectedMembers) + ") on element of GuildInsiderFactSheetInformations.nbConnectedMembers.")));
            };
            this.nbTaxCollectors = input.readByte();
            if (this.nbTaxCollectors < 0)
            {
                throw (new Error((("Forbidden value (" + this.nbTaxCollectors) + ") on element of GuildInsiderFactSheetInformations.nbTaxCollectors.")));
            };
            this.lastActivity = input.readInt();
            if (this.lastActivity < 0)
            {
                throw (new Error((("Forbidden value (" + this.lastActivity) + ") on element of GuildInsiderFactSheetInformations.lastActivity.")));
            };
            this.enabled = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.types.game.social

