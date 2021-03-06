﻿package com.ankamagames.dofus.network.messages.game.context.roleplay.npc
{
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.context.roleplay.BasicGuildInformations;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class TaxCollectorDialogQuestionExtendedMessage extends TaxCollectorDialogQuestionBasicMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5615;

        private var _isInitialized:Boolean = false;
        public var maxPods:uint = 0;
        public var prospecting:uint = 0;
        public var wisdom:uint = 0;
        public var taxCollectorsCount:uint = 0;
        public var taxCollectorAttack:int = 0;
        public var kamas:uint = 0;
        public var experience:Number = 0;
        public var pods:uint = 0;
        public var itemsValue:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (((super.isInitialized) && (this._isInitialized)));
        }

        override public function getMessageId():uint
        {
            return (5615);
        }

        public function initTaxCollectorDialogQuestionExtendedMessage(guildInfo:BasicGuildInformations=null, maxPods:uint=0, prospecting:uint=0, wisdom:uint=0, taxCollectorsCount:uint=0, taxCollectorAttack:int=0, kamas:uint=0, experience:Number=0, pods:uint=0, itemsValue:uint=0):TaxCollectorDialogQuestionExtendedMessage
        {
            super.initTaxCollectorDialogQuestionBasicMessage(guildInfo);
            this.maxPods = maxPods;
            this.prospecting = prospecting;
            this.wisdom = wisdom;
            this.taxCollectorsCount = taxCollectorsCount;
            this.taxCollectorAttack = taxCollectorAttack;
            this.kamas = kamas;
            this.experience = experience;
            this.pods = pods;
            this.itemsValue = itemsValue;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.maxPods = 0;
            this.prospecting = 0;
            this.wisdom = 0;
            this.taxCollectorsCount = 0;
            this.taxCollectorAttack = 0;
            this.kamas = 0;
            this.experience = 0;
            this.pods = 0;
            this.itemsValue = 0;
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
            this.serializeAs_TaxCollectorDialogQuestionExtendedMessage(output);
        }

        public function serializeAs_TaxCollectorDialogQuestionExtendedMessage(output:ICustomDataOutput):void
        {
            super.serializeAs_TaxCollectorDialogQuestionBasicMessage(output);
            if (this.maxPods < 0)
            {
                throw (new Error((("Forbidden value (" + this.maxPods) + ") on element maxPods.")));
            };
            output.writeVarShort(this.maxPods);
            if (this.prospecting < 0)
            {
                throw (new Error((("Forbidden value (" + this.prospecting) + ") on element prospecting.")));
            };
            output.writeVarShort(this.prospecting);
            if (this.wisdom < 0)
            {
                throw (new Error((("Forbidden value (" + this.wisdom) + ") on element wisdom.")));
            };
            output.writeVarShort(this.wisdom);
            if (this.taxCollectorsCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.taxCollectorsCount) + ") on element taxCollectorsCount.")));
            };
            output.writeByte(this.taxCollectorsCount);
            output.writeInt(this.taxCollectorAttack);
            if (this.kamas < 0)
            {
                throw (new Error((("Forbidden value (" + this.kamas) + ") on element kamas.")));
            };
            output.writeVarInt(this.kamas);
            if ((((this.experience < 0)) || ((this.experience > 9007199254740992))))
            {
                throw (new Error((("Forbidden value (" + this.experience) + ") on element experience.")));
            };
            output.writeVarLong(this.experience);
            if (this.pods < 0)
            {
                throw (new Error((("Forbidden value (" + this.pods) + ") on element pods.")));
            };
            output.writeVarInt(this.pods);
            if (this.itemsValue < 0)
            {
                throw (new Error((("Forbidden value (" + this.itemsValue) + ") on element itemsValue.")));
            };
            output.writeVarInt(this.itemsValue);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_TaxCollectorDialogQuestionExtendedMessage(input);
        }

        public function deserializeAs_TaxCollectorDialogQuestionExtendedMessage(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.maxPods = input.readVarUhShort();
            if (this.maxPods < 0)
            {
                throw (new Error((("Forbidden value (" + this.maxPods) + ") on element of TaxCollectorDialogQuestionExtendedMessage.maxPods.")));
            };
            this.prospecting = input.readVarUhShort();
            if (this.prospecting < 0)
            {
                throw (new Error((("Forbidden value (" + this.prospecting) + ") on element of TaxCollectorDialogQuestionExtendedMessage.prospecting.")));
            };
            this.wisdom = input.readVarUhShort();
            if (this.wisdom < 0)
            {
                throw (new Error((("Forbidden value (" + this.wisdom) + ") on element of TaxCollectorDialogQuestionExtendedMessage.wisdom.")));
            };
            this.taxCollectorsCount = input.readByte();
            if (this.taxCollectorsCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.taxCollectorsCount) + ") on element of TaxCollectorDialogQuestionExtendedMessage.taxCollectorsCount.")));
            };
            this.taxCollectorAttack = input.readInt();
            this.kamas = input.readVarUhInt();
            if (this.kamas < 0)
            {
                throw (new Error((("Forbidden value (" + this.kamas) + ") on element of TaxCollectorDialogQuestionExtendedMessage.kamas.")));
            };
            this.experience = input.readVarUhLong();
            if ((((this.experience < 0)) || ((this.experience > 9007199254740992))))
            {
                throw (new Error((("Forbidden value (" + this.experience) + ") on element of TaxCollectorDialogQuestionExtendedMessage.experience.")));
            };
            this.pods = input.readVarUhInt();
            if (this.pods < 0)
            {
                throw (new Error((("Forbidden value (" + this.pods) + ") on element of TaxCollectorDialogQuestionExtendedMessage.pods.")));
            };
            this.itemsValue = input.readVarUhInt();
            if (this.itemsValue < 0)
            {
                throw (new Error((("Forbidden value (" + this.itemsValue) + ") on element of TaxCollectorDialogQuestionExtendedMessage.itemsValue.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context.roleplay.npc

