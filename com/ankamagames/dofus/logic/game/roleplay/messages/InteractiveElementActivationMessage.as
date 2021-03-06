﻿package com.ankamagames.dofus.logic.game.roleplay.messages
{
    import com.ankamagames.jerakine.messages.Message;
    import com.ankamagames.dofus.network.types.game.interactive.InteractiveElement;
    import com.ankamagames.jerakine.types.positions.MapPoint;

    public class InteractiveElementActivationMessage implements Message 
    {

        private var _ie:InteractiveElement;
        private var _position:MapPoint;
        private var _skillInstanceId:uint;

        public function InteractiveElementActivationMessage(ie:InteractiveElement, position:MapPoint, skillInstanceId:uint)
        {
            this._ie = ie;
            this._position = position;
            this._skillInstanceId = skillInstanceId;
        }

        public function get interactiveElement():InteractiveElement
        {
            return (this._ie);
        }

        public function get position():MapPoint
        {
            return (this._position);
        }

        public function get skillInstanceId():uint
        {
            return (this._skillInstanceId);
        }


    }
}//package com.ankamagames.dofus.logic.game.roleplay.messages

