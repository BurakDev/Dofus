﻿package com.ankamagames.berilia.managers
{
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
    import com.ankamagames.jerakine.utils.errors.SingletonError;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
    import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
    import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
    import com.ankamagames.jerakine.managers.StoreDataManager;
    import com.ankamagames.berilia.BeriliaConstants;
    import com.ankamagames.jerakine.types.Uri;
    import com.ankamagames.jerakine.types.Callback;
    import com.ankamagames.berilia.types.data.ExtendedStyleSheet;
    import flash.text.StyleSheet;
    import com.ankamagames.berilia.types.event.CssEvent;
    import com.ankamagames.jerakine.managers.ErrorManager;

    public class CssManager 
    {

        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(CssManager));
        private static const CSS_ARRAY_KEY:String = "cssFilesContents";
        private static var _self:CssManager;
        private static var _useCache:Boolean = true;

        private var _aCss:Array;
        private var _aWaiting:Array;
        private var _aMultiWaiting:Array;
        private var _loader:IResourceLoader;
        private var _aLoadingFile:Array;

        public function CssManager()
        {
            if (_self)
            {
                throw (new SingletonError());
            };
            this._aCss = new Array();
            this._aWaiting = new Array();
            this._aMultiWaiting = new Array();
            this._aLoadingFile = new Array();
            this._loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
            this._loader.addEventListener(ResourceLoadedEvent.LOADED, this.complete);
            this._loader.addEventListener(ResourceErrorEvent.ERROR, this.error);
        }

        public static function getInstance():CssManager
        {
            if (!(_self))
            {
                _self = new (CssManager)();
            };
            return (_self);
        }

        public static function set useCache(b:Boolean):void
        {
            _useCache = b;
            if (!(b))
            {
                clear();
            };
        }

        public static function get useCache():Boolean
        {
            return (_useCache);
        }

        public static function clear():void
        {
            StoreDataManager.getInstance().clear(BeriliaConstants.DATASTORE_UI_CSS);
        }


        public function getLoadedCss():Array
        {
            return (this._aCss);
        }

        public function load(oFile:*):void
        {
            var uri:Uri;
            var i:uint;
            var aQueue:Array = new Array();
            if ((oFile is String))
            {
                uri = new Uri(oFile);
                if (((!(this.exists(uri.uri))) && (!(this.inQueue(uri.uri)))))
                {
                    aQueue.push(uri);
                    this._aLoadingFile[uri.uri] = true;
                };
            }
            else
            {
                if ((oFile is Array))
                {
                    i = 0;
                    while (i < (oFile as Array).length)
                    {
                        uri = new Uri(oFile[i]);
                        if (((!(this.exists(uri.uri))) && (!(this.inQueue(uri.uri)))))
                        {
                            this._aLoadingFile[uri.uri] = true;
                            aQueue.push(uri);
                        };
                        i++;
                    };
                };
            };
            if (aQueue.length)
            {
                this._loader.load(aQueue);
            };
        }

        public function exists(sUrl:String):Boolean
        {
            var uri:Uri = new Uri(sUrl);
            return (!((this._aCss[uri.uri] == null)));
        }

        public function inQueue(sUrl:String):Boolean
        {
            return (this._aLoadingFile[sUrl]);
        }

        public function askCss(sUrl:String, callback:Callback):void
        {
            var _local_3:Uri;
            var files:Array;
            if (this.exists(sUrl))
            {
                callback.exec();
            }
            else
            {
                _local_3 = new Uri(sUrl);
                if (!(this._aWaiting[_local_3.uri]))
                {
                    this._aWaiting[_local_3.uri] = new Array();
                };
                this._aWaiting[_local_3.uri].push(callback);
                if (sUrl.indexOf(",") != -1)
                {
                    files = sUrl.split(",");
                    this._aMultiWaiting[_local_3.uri] = files;
                    this.load(files);
                }
                else
                {
                    this.load(sUrl);
                };
            };
        }

        public function preloadCss(sUrl:String):void
        {
            if (!(this.exists(sUrl)))
            {
                this.load(sUrl);
            };
        }

        public function getCss(sUrl:String):ExtendedStyleSheet
        {
            var uri:Uri = new Uri(sUrl);
            return (this._aCss[uri.uri]);
        }

        public function merge(aStyleSheet:Array):ExtendedStyleSheet
        {
            var newCssName:String = "";
            var j:uint;
            while (j < aStyleSheet.length)
            {
                newCssName = (newCssName + (((j) ? "," : "") + aStyleSheet[j].url));
                j++;
            };
            if (this.exists(newCssName))
            {
                return (this.getCss(newCssName));
            };
            var newEss:ExtendedStyleSheet = new ExtendedStyleSheet(newCssName);
            var i:uint = (aStyleSheet.length - 1);
            while ((i - 1) > -1)
            {
                newEss.merge((aStyleSheet[i] as ExtendedStyleSheet));
                i--;
            };
            this._aCss[newCssName] = newEss;
            return (newEss);
        }

        protected function init():void
        {
            var aSavedCss:Array;
            var file:String;
            if (_useCache)
            {
                aSavedCss = StoreDataManager.getInstance().getSetData(BeriliaConstants.DATASTORE_UI_CSS, CSS_ARRAY_KEY, new Array());
                for (file in aSavedCss)
                {
                    this.parseCss(file, aSavedCss[file]);
                };
            };
        }

        private function parseCss(sUrl:String, content:String):void
        {
            var uri:Uri = new Uri(sUrl);
            var styleSheet:StyleSheet = new ExtendedStyleSheet(uri.uri);
            this._aCss[uri.uri] = styleSheet;
            styleSheet.addEventListener(CssEvent.CSS_PARSED, this.onCssParsed);
            styleSheet.parseCSS(content);
        }

        private function updateWaitingMultiUrl(loadedUrl:String):void
        {
            var ok:Boolean;
            var url:String;
            var i:uint;
            var files:Array;
            var sse:Array;
            var k:uint;
            for (url in this._aMultiWaiting)
            {
                if (this._aMultiWaiting[url])
                {
                    ok = true;
                    i = 0;
                    while (i < this._aMultiWaiting[url].length)
                    {
                        if (this._aMultiWaiting[url][i] == loadedUrl)
                        {
                            this._aMultiWaiting[url][i] = true;
                        };
                        ok = ((ok) && ((this._aMultiWaiting[url][i] === true)));
                        i++;
                    };
                    if (ok)
                    {
                        delete this._aMultiWaiting[url];
                        files = url.split(",");
                        sse = new Array();
                        k = 0;
                        while (k < files.length)
                        {
                            sse.push(this.getCss(files[k]));
                            k++;
                        };
                        this.merge(sse);
                        this.dispatchWaitingCallbabk(url);
                    };
                };
            };
        }

        private function dispatchWaitingCallbabk(url:String):void
        {
            var i:uint;
            if (this._aWaiting[url])
            {
                i = 0;
                while (i < this._aWaiting[url].length)
                {
                    Callback(this._aWaiting[url][i]).exec();
                    i++;
                };
                delete this._aWaiting[url];
            };
        }

        protected function complete(e:ResourceLoadedEvent):void
        {
            var aSavedCss:Array;
            if (_useCache)
            {
                aSavedCss = StoreDataManager.getInstance().getSetData(BeriliaConstants.DATASTORE_UI_CSS, CSS_ARRAY_KEY, new Array());
                aSavedCss[e.uri.uri] = e.resource;
                StoreDataManager.getInstance().setData(BeriliaConstants.DATASTORE_UI_CSS, CSS_ARRAY_KEY, aSavedCss);
            };
            this._aLoadingFile[e.uri.uri] = false;
            this.parseCss(e.uri.uri, e.resource);
        }

        protected function error(e:ResourceErrorEvent):void
        {
            ErrorManager.addError((("Impossible de trouver la feuille de style (url: " + e.uri) + ")"));
            this._aLoadingFile[e.uri.uri] = false;
            delete this._aWaiting[e.uri.uri];
        }

        private function onCssParsed(e:CssEvent):void
        {
            e.stylesheet.removeEventListener(CssEvent.CSS_PARSED, this.onCssParsed);
            var uri:Uri = new Uri(e.stylesheet.url);
            this.dispatchWaitingCallbabk(uri.uri);
            this.updateWaitingMultiUrl(uri.uri);
        }


    }
}//package com.ankamagames.berilia.managers

