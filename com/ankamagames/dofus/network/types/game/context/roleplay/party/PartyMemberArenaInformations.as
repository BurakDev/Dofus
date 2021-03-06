﻿package com.ankamagames.dofus.network.types.game.context.roleplay.party
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.dofus.network.types.game.look.EntityLook;
    import com.ankamagames.dofus.network.types.game.character.status.PlayerStatus;
    import __AS3__.vec.Vector;
    import com.ankamagames.dofus.network.types.game.context.roleplay.party.companion.PartyCompanionMemberInformations;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class PartyMemberArenaInformations extends PartyMemberInformations implements INetworkType 
    {

        public static const protocolId:uint = 391;

        public var rank:uint = 0;


        override public function getTypeId():uint
        {
            return (391);
        }

        public function initPartyMemberArenaInformations(id:uint=0, level:uint=0, name:String="", entityLook:EntityLook=null, breed:int=0, sex:Boolean=false, lifePoints:uint=0, maxLifePoints:uint=0, prospecting:uint=0, regenRate:uint=0, initiative:uint=0, alignmentSide:int=0, worldX:int=0, worldY:int=0, mapId:int=0, subAreaId:uint=0, status:PlayerStatus=null, companions:Vector.<PartyCompanionMemberInformations>=null, rank:uint=0):PartyMemberArenaInformations
        {
            super.initPartyMemberInformations(id, level, name, entityLook, breed, sex, lifePoints, maxLifePoints, prospecting, regenRate, initiative, alignmentSide, worldX, worldY, mapId, subAreaId, status, companions);
            this.rank = rank;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.rank = 0;
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_PartyMemberArenaInformations(output);
        }

        public function serializeAs_PartyMemberArenaInformations(output:ICustomDataOutput):void
        {
            super.serializeAs_PartyMemberInformations(output);
            if ((((this.rank < 0)) || ((this.rank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.rank) + ") on element rank.")));
            };
            output.writeVarShort(this.rank);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_PartyMemberArenaInformations(input);
        }

        public function deserializeAs_PartyMemberArenaInformations(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.rank = input.readVarUhShort();
            if ((((this.rank < 0)) || ((this.rank > 2300))))
            {
                throw (new Error((("Forbidden value (" + this.rank) + ") on element of PartyMemberArenaInformations.rank.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.roleplay.party

