﻿package com.ankamagames.dofus.logic.game.roleplay.actions
{
    import com.ankamagames.jerakine.handlers.messages.Action;

    public class TeleportRequestAction implements Action 
    {

        public var mapId:uint;
        public var teleportType:uint;
        public var cost:uint;


        public static function create(teleportType:uint, mapId:uint, cost:uint):TeleportRequestAction
        {
            var action:TeleportRequestAction = new (TeleportRequestAction)();
            action.teleportType = teleportType;
            action.mapId = mapId;
            action.cost = cost;
            return (action);
        }


    }
}//package com.ankamagames.dofus.logic.game.roleplay.actions

