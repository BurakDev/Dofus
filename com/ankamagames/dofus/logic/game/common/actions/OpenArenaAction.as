package com.ankamagames.dofus.logic.game.common.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;


   public class OpenArenaAction extends Object implements Action
   {
         

      public function OpenArenaAction() {
         super();
      }

      public static function create() : OpenArenaAction {
         var a:OpenArenaAction = new OpenArenaAction();
         return a;
      }


   }

}