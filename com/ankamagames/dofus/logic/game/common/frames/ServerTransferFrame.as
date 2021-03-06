﻿package com.ankamagames.dofus.logic.game.common.frames
{
    import com.ankamagames.jerakine.messages.RegisteringFrame;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import com.ankamagames.dofus.network.messages.connection.SelectedServerDataMessage;
    import com.ankamagames.dofus.network.messages.game.approach.HelloGameMessage;
    import com.ankamagames.dofus.network.messages.game.approach.AuthenticationTicketAcceptedMessage;
    import com.ankamagames.dofus.network.messages.game.character.choice.CharacterSelectedSuccessMessage;
    import com.ankamagames.dofus.network.messages.game.initialization.CharacterLoadingCompleteMessage;
    import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
    import com.ankamagames.jerakine.messages.Message;
    import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
    import com.ankamagames.jerakine.data.XmlConfig;
    import com.ankamagames.dofus.network.messages.game.approach.AuthenticationTicketMessage;
    import com.ankamagames.dofus.logic.game.common.misc.KoliseumMessageRouter;
    import com.ankamagames.dofus.kernel.net.ConnectionType;
    import com.ankamagames.dofus.network.messages.game.character.choice.CharactersListRequestMessage;
    import com.ankamagames.dofus.network.messages.game.context.GameContextCreateRequestMessage;

    public class ServerTransferFrame extends RegisteringFrame 
    {

        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(ServerTransferFrame));

        private var _newServerLoginTicket:String;


        override public function pushed():Boolean
        {
            return (true);
        }

        override public function pulled():Boolean
        {
            return (true);
        }

        override protected function registerMessages():void
        {
            register(SelectedServerDataMessage, this.onSelectedServerDataMessage);
            register(HelloGameMessage, this.onHelloGameMessage);
            register(AuthenticationTicketAcceptedMessage, this.onAuthenticationTicketAcceptedMessage);
            register(CharacterSelectedSuccessMessage, this.onCharacterSelectedSuccessMessage);
            register(CharacterLoadingCompleteMessage, this.onCharacterLoadingCompleteMessage);
        }

        protected function getConnectionType(msg:Message):String
        {
            return (ConnectionsHandler.getConnection().getConnectionId(msg));
        }

        private function onCharacterSelectedSuccessMessage(msg:CharacterSelectedSuccessMessage):void
        {
            PlayedCharacterManager.getInstance().infos = msg.infos;
        }

        private function onHelloGameMessage(msg:HelloGameMessage):Boolean
        {
            var lang:String = XmlConfig.getInstance().getEntry("config.lang.current");
            var authMsg:AuthenticationTicketMessage = new AuthenticationTicketMessage();
            authMsg.initAuthenticationTicketMessage(lang, this._newServerLoginTicket);
            switch (this.getConnectionType(msg))
            {
                case ConnectionType.TO_KOLI_SERVER:
                    ConnectionsHandler.getConnection().messageRouter = new KoliseumMessageRouter();
                    break;
                case ConnectionType.TO_GAME_SERVER:
                    ConnectionsHandler.getConnection().messageRouter = null;
                    break;
            };
            ConnectionsHandler.getConnection().send(authMsg);
            return (true);
        }

        private function onAuthenticationTicketAcceptedMessage(msg:AuthenticationTicketAcceptedMessage):Boolean
        {
            var _local_2:CharactersListRequestMessage;
            switch (this.getConnectionType(msg))
            {
                case ConnectionType.TO_KOLI_SERVER:
                    _local_2 = new CharactersListRequestMessage();
                    _local_2.initCharactersListRequestMessage();
                    ConnectionsHandler.getConnection().send(_local_2);
                    return (true);
            };
            return (false);
        }

        private function onCharacterLoadingCompleteMessage(msg:CharacterLoadingCompleteMessage):Boolean
        {
            var _local_2:GameContextCreateRequestMessage;
            switch (this.getConnectionType(msg))
            {
                case ConnectionType.TO_KOLI_SERVER:
                    _local_2 = new GameContextCreateRequestMessage();
                    _local_2.initGameContextCreateRequestMessage();
                    ConnectionsHandler.getConnection().send(_local_2);
                    return (true);
            };
            return (false);
        }

        private function onSelectedServerDataMessage(msg:SelectedServerDataMessage):Boolean
        {
            this._newServerLoginTicket = msg.ticket;
            ConnectionsHandler.getConnection().mainConnection.close();
            ConnectionsHandler.connectToKoliServer(msg.address, msg.port);
            return (true);
        }


    }
}//package com.ankamagames.dofus.logic.game.common.frames

