﻿package com.ankamagames.berilia.components
{
    import com.ankamagames.berilia.types.graphic.GraphicContainer;
    import com.ankamagames.berilia.FinalizableUIComponent;
    import com.ankamagames.berilia.types.graphic.TimeoutHTMLLoader;
    import flash.utils.Timer;
    import flash.utils.Dictionary;
    import flash.display.NativeWindow;
    import com.ankamagames.jerakine.utils.system.AirScanner;
    import flash.events.TimerEvent;
    import com.ankamagames.jerakine.utils.display.StageShareManager;
    import flash.events.Event;
    import com.ankamagames.jerakine.types.Uri;
    import flash.display.DisplayObject;
    import com.ankamagames.jerakine.handlers.messages.keyboard.KeyboardMessage;
    import com.ankamagames.berilia.types.shortcut.Bind;
    import com.ankamagames.jerakine.handlers.messages.mouse.MouseWheelMessage;
    import com.ankamagames.jerakine.handlers.messages.keyboard.KeyboardKeyUpMessage;
    import com.ankamagames.jerakine.handlers.messages.keyboard.KeyboardKeyDownMessage;
    import com.ankamagames.berilia.managers.BindsManager;
    import com.ankamagames.jerakine.handlers.FocusHandler;
    import com.ankamagames.jerakine.messages.Message;
    import flash.utils.clearTimeout;
    import flash.net.URLRequest;
    import com.ankamagames.jerakine.utils.misc.CopyObject;
    import flash.utils.setTimeout;
    import com.ankamagames.berilia.Berilia;
    import com.ankamagames.berilia.components.messages.BrowserDomReady;
    import flash.display.InteractiveObject;
    import flash.net.navigateToURL;
    import com.ankamagames.berilia.components.messages.BrowserSessionTimeout;

    public class WebBrowser extends GraphicContainer implements FinalizableUIComponent 
    {

        private var _finalized:Boolean;
        private var _htmlLoader:TimeoutHTMLLoader;
        private var _resizeTimer:Timer;
        private var _vScrollBar:ScrollBar;
        private var _scrollTopOffset:int = 0;
        private var _cacheId:String;
        private var _cacheLife:Number = 15;
        private var _lifeTimer:Timer;
        private var _linkList:Array;
        private var _inputList:Array;
        private var _inputFocus:Boolean;
        private var _displayScrollBar:Boolean = true;
        private var _manualExternalLink:Dictionary;
        private var _transparentBackground:Boolean;
        private var _timeoutId:uint;
        private var _domInit:Boolean;

        public function WebBrowser()
        {
            var _local_1:NativeWindow;
            this._resizeTimer = new Timer(200);
            this._linkList = [];
            this._inputList = [];
            this._manualExternalLink = new Dictionary();
            super();
            this._vScrollBar = new ScrollBar();
            if (!(AirScanner.hasAir()))
            {
                _log.error("Can't create a WebBrowser object without AIR support");
                this._vScrollBar.visible = false;
            }
            else
            {
                this._resizeTimer.addEventListener(TimerEvent.TIMER, this.onResizeEnd);
                _local_1 = StageShareManager.stage.nativeWindow;
                _local_1.addEventListener(Event.RESIZE, this.onResize);
                this._vScrollBar.min = 1;
                this._vScrollBar.max = 1;
                this._vScrollBar.width = 16;
                this._vScrollBar.addEventListener(Event.CHANGE, this.onScroll);
            };
        }

        public function get cacheLife():Number
        {
            return (this._cacheLife);
        }

        public function set cacheLife(value:Number):void
        {
            this._cacheLife = Math.max(1, value);
            if (this._htmlLoader)
            {
                this._htmlLoader.life = value;
            };
        }

        public function get cacheId():String
        {
            return (this._cacheId);
        }

        public function set cacheId(value:String):void
        {
            this._cacheId = value;
        }

        public function set scrollCss(sUrl:Uri):void
        {
            this._vScrollBar.css = sUrl;
        }

        public function get scrollCss():Uri
        {
            return (this._vScrollBar.css);
        }

        public function set displayScrollBar(b:Boolean):void
        {
            this._vScrollBar.width = ((b) ? 16 : 0);
            this.onResizeEnd(null);
        }

        public function get displayScrollBar():Boolean
        {
            return (this._displayScrollBar);
        }

        public function set scrollTopOffset(v:int):void
        {
            this._scrollTopOffset = v;
            this._vScrollBar.y = v;
            if (height)
            {
                this._vScrollBar.height = (height - this._scrollTopOffset);
            };
        }

        public function get finalized():Boolean
        {
            return (this._finalized);
        }

        public function set finalized(b:Boolean):void
        {
            this._finalized = b;
        }

        override public function set width(nW:Number):void
        {
            super.width = nW;
            if (this._htmlLoader)
            {
                this._htmlLoader.width = (nW - this._vScrollBar.width);
                this._vScrollBar.x = (this._htmlLoader.x + this._htmlLoader.width);
            };
        }

        override public function set height(nH:Number):void
        {
            super.height = nH;
            if (this._htmlLoader)
            {
                this._htmlLoader.height = nH;
            };
            this.scrollTopOffset = this._scrollTopOffset;
        }

        public function get fromCache():Boolean
        {
            return (this._htmlLoader.fromCache);
        }

        public function get location():String
        {
            return (this._htmlLoader.location);
        }

        public function set transparentBackground(pValue:Boolean):void
        {
            this._transparentBackground = pValue;
            if (this._htmlLoader)
            {
                this._htmlLoader.paintsDefaultBackground = !(this._transparentBackground);
            };
        }

        public function finalize():void
        {
            if (!(AirScanner.hasAir()))
            {
                this._finalized = true;
                return;
            };
            addChild(this._vScrollBar);
            this._vScrollBar.finalize();
            if (!(this._htmlLoader))
            {
                this._htmlLoader = TimeoutHTMLLoader.getLoader(this.cacheId);
                if (this._htmlLoader.fromCache)
                {
                    this.onDomReady(null);
                };
                this._htmlLoader.life = this.cacheLife;
                this._htmlLoader.addEventListener(Event["HTML_RENDER"], this.onDomReady);
                this._htmlLoader.addEventListener(Event["HTML_BOUNDS_CHANGE"], this.onBoundsChange);
                this._htmlLoader.addEventListener(TimeoutHTMLLoader.TIMEOUT, this.onSessionTimeout);
                this._htmlLoader.addEventListener(Event["LOCATION_CHANGE"], this.onLocationChange);
                this._htmlLoader.paintsDefaultBackground = !(this._transparentBackground);
            };
            this.width = width;
            this.height = height;
            this.updateScrollbar();
            if (this._htmlLoader.fromCache)
            {
                this._vScrollBar.value = this._htmlLoader.scrollV;
            };
            addChild(this._htmlLoader);
            this.onResizeEnd(null);
            this._finalized = true;
        }

        public function setBlankLink(linkPattern:String, blank:Boolean):void
        {
            if (blank)
            {
                this._manualExternalLink[linkPattern] = new RegExp(linkPattern);
            }
            else
            {
                delete this._manualExternalLink[linkPattern];
            };
            this.modifyDOM(this._htmlLoader.window.document);
        }

        [HideInFakeClass]
        override public function process(msg:Message):Boolean
        {
            var currentDo:DisplayObject;
            var kbmsg:KeyboardMessage;
            var allowedShorcut:Boolean;
            var sShortcut:String;
            var bind:Bind;
            if ((msg is MouseWheelMessage))
            {
                currentDo = MouseWheelMessage(msg).target;
                while (((((!((currentDo == this._htmlLoader))) && (currentDo))) && (currentDo.parent)))
                {
                    currentDo = currentDo.parent;
                };
                if (currentDo == this._htmlLoader)
                {
                    this._vScrollBar.value = this._htmlLoader.scrollV;
                };
            };
            if ((((msg is KeyboardKeyDownMessage)) || ((msg is KeyboardKeyUpMessage))))
            {
                kbmsg = (msg as KeyboardMessage);
                sShortcut = BindsManager.getInstance().getShortcutString(kbmsg.keyboardEvent.keyCode, this.getCharCode(kbmsg));
                bind = BindsManager.getInstance().getBind(new Bind(sShortcut, "", kbmsg.keyboardEvent.altKey, kbmsg.keyboardEvent.ctrlKey, kbmsg.keyboardEvent.shiftKey));
                if (((bind) && ((((bind.targetedShortcut == "closeUi")) || ((bind.targetedShortcut == "toggleFullscreen"))))))
                {
                    allowedShorcut = true;
                };
                if (!(allowedShorcut))
                {
                    currentDo = FocusHandler.getInstance().getFocus();
                    while (((((!((currentDo == this._htmlLoader))) && (currentDo))) && (currentDo.parent)))
                    {
                        currentDo = currentDo.parent;
                    };
                    return ((currentDo == this._htmlLoader));
                };
            };
            return (false);
        }

        override public function remove():void
        {
            this.removeHtmlEvent();
            StageShareManager.stage.removeEventListener(Event.RESIZE, this.onResize);
            if (this._htmlLoader)
            {
                this._htmlLoader.removeEventListener(Event["HTML_RENDER"], this.onDomReady);
                this._htmlLoader.removeEventListener(Event["HTML_BOUNDS_CHANGE"], this.onBoundsChange);
                if (contains(this._htmlLoader))
                {
                    removeChild(this._htmlLoader);
                };
            };
            if (this._timeoutId)
            {
                clearTimeout(this._timeoutId);
            };
            super.remove();
        }

        public function hasContent():Boolean
        {
            var a:Object = this._htmlLoader.window.document.getElementsByTagName("body");
            if (((!(a[0])) || ((a[0].firstChild == null))))
            {
                return (false);
            };
            if (((a[0].getElementsByTagName("h1")) && ((a[0].getElementsByTagName("h1").length > 0))))
            {
                return (true);
            };
            return (false);
        }

        public function load(urlRequest:URLRequest):void
        {
            var clone:URLRequest;
            if (getUi().uiModule.trusted)
            {
                clone = new URLRequest();
                CopyObject.copyObject(urlRequest, null, clone);
                this._htmlLoader.load(clone);
            }
            else
            {
                throw (new SecurityError("Only trusted module can use WebBroswer"));
            };
        }

        public function javascriptSetVar(varName:String, value:*):void
        {
            var path:Array;
            var len:int;
            var htmlVar:Object;
            var i:int;
            try
            {
                path = varName.split(".");
                len = path.length;
                htmlVar = this._htmlLoader.window;
                i = 0;
                while (i < len)
                {
                    if (i < (len - 1))
                    {
                        htmlVar = htmlVar[path[i]];
                    }
                    else
                    {
                        htmlVar[path[i]] = value;
                    };
                    i++;
                };
            }
            catch(e:Error)
            {
            };
        }

        public function javascriptCall(fctName:String, ... params):void
        {
            var path:Array;
            var len:int;
            var htmlFunction:Object;
            var i:int;
            try
            {
                path = fctName.split(".");
                len = path.length;
                htmlFunction = this._htmlLoader.window;
                i = 0;
                while (i < len)
                {
                    htmlFunction = htmlFunction[path[i]];
                    i++;
                };
                (htmlFunction as Function).apply(null, params);
            }
            catch(e:Error)
            {
            };
        }

        private function removeHtmlEvent():void
        {
            var link:Object;
            var input:Object;
            for each (link in this._linkList)
            {
                try
                {
                    link.removeEventListener("click", this.onLinkClick);
                }
                catch(e:Error)
                {
                };
            };
            for each (input in this._inputList)
            {
                try
                {
                    input.removeEventListener("focus", this.onInputFocus);
                    input.removeEventListener("blur", this.onInputBlur);
                }
                catch(e:Error)
                {
                };
            };
        }

        private function getCharCode(pKeyboardMessage:KeyboardMessage):int
        {
            var charCode:int;
            if (((pKeyboardMessage.keyboardEvent.shiftKey) && ((pKeyboardMessage.keyboardEvent.keyCode == 52))))
            {
                charCode = 39;
            }
            else
            {
                if (((pKeyboardMessage.keyboardEvent.shiftKey) && ((pKeyboardMessage.keyboardEvent.keyCode == 54))))
                {
                    charCode = 45;
                }
                else
                {
                    charCode = pKeyboardMessage.keyboardEvent.charCode;
                };
            };
            return (charCode);
        }

        private function onResize(e:Event):void
        {
            this._resizeTimer.reset();
            this._resizeTimer.start();
        }

        private function onResizeEnd(e:Event):void
        {
            this._resizeTimer.stop();
            var scale:Number = StageShareManager.windowScale;
            if (this._htmlLoader)
            {
                this._htmlLoader.width = ((width * scale) - this._vScrollBar.width);
                this._htmlLoader.height = (height * scale);
                this._htmlLoader.scaleX = (1 / scale);
                this._htmlLoader.scaleY = (1 / scale);
            };
        }

        private function onDomReady(e:Event):void
        {
            if (!(this._htmlLoader.window.document.body))
            {
                this._domInit = false;
                if (!(this._timeoutId))
                {
                    this._timeoutId = setTimeout(this.onDomReady, 100, null);
                };
                return;
            };
            if (this._timeoutId)
            {
                clearTimeout(this._timeoutId);
                this._timeoutId = 0;
            };
            this.modifyDOM(this._htmlLoader.window.document);
            if (this._domInit)
            {
                return;
            };
            this._domInit = true;
            this.updateScrollbar();
            this.onResizeEnd(null);
            Berilia.getInstance().handler.process(new BrowserDomReady(InteractiveObject(this)));
        }

        private function isManualExternalLink(link:String):Boolean
        {
            var pattern:RegExp;
            for each (pattern in this._manualExternalLink)
            {
                if (link.match(pattern).length)
                {
                    return (true);
                };
            };
            return (false);
        }

        private function modifyDOM(target:Object):void
        {
            var i:uint;
            var a:Object;
            try
            {
                a = target.getElementsByTagName("a");
                i = 0;
                while (i < a.length)
                {
                    if ((((a[i].target == "_blank")) || (this.isManualExternalLink(a[i].href))))
                    {
                        a[i].addEventListener("click", this.onLinkClick, false);
                        if (this._linkList.indexOf(a[i]) == -1)
                        {
                            this._linkList.push(a[i]);
                        };
                    };
                    i++;
                };
            }
            catch(e:Error)
            {
                _log.error("Erreur lors de l'ajout des lien blank");
            };
        }

        private function onLinkClick(e:*):void
        {
            var target:Object = e.target;
            if (target.tagName == "IMG")
            {
                target = target.parentElement;
            };
            if ((((target.target == "_blank")) || (this.isManualExternalLink(target.href))))
            {
                e.preventDefault();
                navigateToURL(new URLRequest(target.href));
            };
        }

        private function onInputFocus(e:*):void
        {
            this._inputFocus = true;
        }

        private function onInputBlur(e:*):void
        {
            this._inputFocus = false;
        }

        private function onScroll(e:Event):void
        {
            this._htmlLoader.scrollV = this._vScrollBar.value;
        }

        private function onBoundsChange(e:Event):void
        {
            this.updateScrollbar();
        }

        private function updateScrollbar():void
        {
            var heightDiff:int = (this._htmlLoader.contentHeight - this._htmlLoader.height);
            if (((!((this._vScrollBar.max == heightDiff))) && ((heightDiff > 0))))
            {
                this._vScrollBar.min = 0;
                this._vScrollBar.max = heightDiff;
            };
        }

        private function onSessionTimeout(e:Event):void
        {
            Berilia.getInstance().handler.process(new BrowserSessionTimeout(InteractiveObject(this)));
        }

        private function onLocationChange(e:Event):void
        {
            _log.trace(("Load " + this._htmlLoader.location));
            this.removeHtmlEvent();
            this._inputFocus = false;
            this._domInit = false;
        }


    }
}//package com.ankamagames.berilia.components

