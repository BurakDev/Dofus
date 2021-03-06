﻿package com.ankamagames.jerakine.entities.messages
{
    import com.ankamagames.jerakine.messages.CancelableMessage;
    import com.ankamagames.jerakine.entities.interfaces.IInteractive;

    public class EntityMouseOutMessage extends EntityInteractionMessage implements CancelableMessage 
    {

        private var _cancel:Boolean;

        public function EntityMouseOutMessage(entity:IInteractive)
        {
            super(entity);
        }

        public function set cancel(b:Boolean):void
        {
            this._cancel = b;
        }

        public function get cancel():Boolean
        {
            return (this._cancel);
        }


    }
}//package com.ankamagames.jerakine.entities.messages

