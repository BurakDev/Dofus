﻿package 
{
    import flash.display.Sprite;
    import com.ankamagames.jerakine.utils.display.IFramerateListener;
    import com.ankamagames.berilia.interfaces.IApplicationContainer;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import flash.text.TextField;
    import com.ankamagames.dofus.types.DofusOptions;
    import com.ankamagames.berilia.components.MapViewer;
    import com.ankamagames.dofus.misc.utils.EmbedAssets;
    import flash.display.Stage;
    import com.ankamagames.jerakine.utils.system.AirScanner;
    import flash.system.Security;
    import com.ankamagames.dofus.misc.utils.errormanager.DofusErrorHandler;
    import com.ankamagames.jerakine.managers.ErrorManager;
    import com.ankamagames.dofus.misc.interClient.AppIdModifier;
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.events.InvokeEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.events.FullScreenEvent;
    import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.utils.ByteArray;
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import com.ankamagames.dofus.network.types.updater.ContentPart;
    import com.ankamagames.jerakine.utils.system.CommandLineArguments;
    import com.ankamagames.dofus.logic.game.approach.managers.PartManager;
    import com.ankamagames.dofus.network.enums.PartStateEnum;
    import com.ankamagames.dofus.BuildInfos;
    import com.ankamagames.jerakine.types.Version;
    import com.ankamagames.dofus.network.enums.BuildTypeEnum;
    import com.ankamagames.jerakine.types.Uri;
    import flash.system.ApplicationDomain;
    import com.ankamagames.jerakine.types.CustomSharedObject;
    import flash.display.NativeWindowDisplayState;
    import com.ankamagames.jerakine.managers.OptionManager;
    import com.ankamagames.jerakine.utils.display.StageShareManager;
    import flash.display.NativeWindow;
    import com.ankamagames.jerakine.utils.system.SystemManager;
    import flash.display.StageDisplayState;
    import com.ankamagames.jerakine.enum.OperatingSystem;
    import flash.display.Screen;
    import flash.display.DisplayObjectContainer;
    import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
    import com.ankamagames.jerakine.resources.adapters.impl.SignedFileAdapter;
    import com.ankamagames.jerakine.utils.crypto.SignatureKey;
    import com.ankamagames.dofus.Constants;
    import com.ankamagames.tiphon.engine.TiphonEventsManager;
    import com.ankamagames.tiphon.engine.Tiphon;
    import com.ankamagames.tiphon.events.TiphonEvent;
    import com.ankamagames.dofus.kernel.sound.SoundManager;
    import com.ankamagames.dofus.kernel.sound.manager.RegSoundManager;
    import com.ankamagames.atouin.Atouin;
    import flash.display.DisplayObject;
    import com.ankamagames.dofus.misc.utils.errormanager.WebServiceDataHandler;
    import com.ankamagames.dofus.kernel.sound.manager.RegConnectionManager;
    import com.ankamagames.jerakine.protocolAudio.ProtocolEnum;
    import com.ankamagames.dofus.misc.interClient.InterClientManager;
    import com.ankamagames.jerakine.managers.StoreDataManager;
    import com.ankamagames.jerakine.utils.files.FileUtils;
    import flash.external.ExternalInterface;
    import com.ankamagames.dofus.kernel.Kernel;
    import com.ankamagames.jerakine.messages.Worker;
    import com.ankamagames.jerakine.managers.LangManager;
    import com.ankamagames.jerakine.managers.FontManager;
    import com.ankamagames.berilia.Berilia;
    import flash.system.LoaderContext;
    import com.ankamagames.berilia.managers.UiModuleManager;
    import com.ankamagames.berilia.components.EntityDisplayer;
    import com.ankamagames.dofus.logic.game.fight.miscs.CustomAnimStatiqueAnimationModifier;
    import com.ankamagames.dofus.types.entities.BreedSkinModifier;
    import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
    import com.ankamagames.dofus.types.entities.AnimStatiqueSubEntityBehavior;
    import com.ankamagames.dofus.types.entities.RiderBehavior;
    import com.ankamagames.berilia.components.CharacterWheel;
    import com.ankamagames.dofus.misc.EntityLookAdapter;
    import com.ankamagames.jerakine.utils.display.FramerateCounter;
    import com.ankamagames.dofus.misc.BuildTypeParser;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.filters.DropShadowFilter;
    import com.ankamagames.dofus.console.moduleLogger.Console;
    import com.ankamagames.dofus.console.moduleLUA.ConsoleLUA;
    import com.ankamagames.berilia.utils.web.HttpServer;
    import flash.display.StageQuality;
    import com.ankamagames.tiphon.display.RasterizedAnimation;
    import com.ankamagames.jerakine.utils.memory.Memory;

    [SWF(backgroundColor="#111111", frameRate="50", width="1280", height="1024")]
    public class Dofus extends Sprite implements IFramerateListener, IApplicationContainer 
    {

        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Dofus));
        private static var _self:Dofus;

        private var _uiContainer:Sprite;
        private var _worldContainer:Sprite;
        private var _fpsDisplay:TextField;
        private var _buildType:String;
        private var _instanceId:uint;
        private var _doOptions:DofusOptions;
        private var _blockLoading:Boolean;
        private var _initialized:Boolean = false;
        private var _forcedLang:String;
        private var _stageWidth:int;
        private var _stageHeight:int;
        private var _displayState:String;
        private var _returnCode:int;
        public var REG_LOCAL_CONNECTION_ID:uint = 0;
        public var strProgress:Number = 0;
        public var strComplete:Boolean = false;

        public function Dofus()
        {
            super();
            var i:uint;
            while (i < numChildren)
            {
                getChildAt(i).visible = false;
                i++;
            };
            MapViewer.FLAG_CURSOR = EmbedAssets.getClass("FLAG_CURSOR");
            var stage:Stage = this.stage;
            if (!(stage))
            {
                stage = loaderInfo.loader.stage;
                AirScanner.init((getQualifiedClassName(loaderInfo.loader.parent) == "DofusLoader"));
            }
            else
            {
                AirScanner.init(false);
            };
            _self = this;
            var hasAir:Boolean = AirScanner.hasAir();
            if (!(hasAir))
            {
                stage.showDefaultContextMenu = false;
                Security.allowDomain("*");
                new DofusErrorHandler();
            };
            if (hasAir)
            {
                this._blockLoading = !((name == "root1"));
            };
            ErrorManager.registerLoaderInfo(loaderInfo);
            mouseEnabled = false;
            tabChildren = false;
            if (hasAir)
            {
                try
                {
                    new AppIdModifier();
                }
                catch(e:Error)
                {
                    trace(("Erreur sur la gestion du multicompte :\n" + e.getStackTrace()));
                };
            };
            if (hasAir)
            {
                NativeApplication.nativeApplication.addEventListener(Event.EXITING, this.onExiting);
                NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, this.onCall);
                stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, this.onResize);
            }
            else
            {
                if (AirScanner.isStreamingVersion())
                {
                    stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.onFullScreen);
                };
            };
        }

        public static function getInstance():Dofus
        {
            return (_self);
        }


        public function getRawSignatureData():ByteArray
        {
            var fs:FileStream = new FileStream();
            var f:File = File.applicationDirectory.resolvePath("DofusInvoker.d2sf");
            fs.open(f, FileMode.READ);
            var rawData:ByteArray = new ByteArray();
            fs.readBytes(rawData);
            fs.close();
            return (rawData);
        }

        private function onCall(e:InvokeEvent):void
        {
            var file:File;
            var stream:FileStream;
            var content:String;
            var xml:XMLDocument;
            var gameNode:XMLNode;
            var upperVersion:String;
            var configNode:XMLNode;
            var versionSplitted:Array;
            var version:String;
            var part:ContentPart;
            if (!(this._initialized))
            {
                CommandLineArguments.getInstance().setArguments(e.arguments);
                new DofusErrorHandler();
                this.initWindow();
                try
                {
                    file = new File(((File.applicationDirectory.nativePath + File.separator) + "uplauncherComponents.xml"));
                    if (file.exists)
                    {
                        PartManager.getInstance().createEmptyPartList();
                        stream = new FileStream();
                        stream.open(file, FileMode.READ);
                        content = stream.readMultiByte(file.size, "utf-8");
                        xml = new XMLDocument();
                        xml.ignoreWhite = true;
                        xml.parseXML(content);
                        gameNode = xml.firstChild;
                        upperVersion = null;
                        for each (configNode in gameNode.childNodes)
                        {
                            version = configNode.attributes["version"];
                            part = new ContentPart();
                            part.id = configNode.attributes["name"];
                            part.state = ((version) ? PartStateEnum.PART_UP_TO_DATE : PartStateEnum.PART_NOT_INSTALLED);
                            PartManager.getInstance().updatePart(part);
                            if (((((version) && ((upperVersion == null)))) || ((version > upperVersion))))
                            {
                                upperVersion = version;
                            };
                        };
                        versionSplitted = upperVersion.split(".");
                        if (versionSplitted.length >= 5)
                        {
                            BuildInfos.BUILD_VERSION = new Version(versionSplitted[0], versionSplitted[1], versionSplitted[2]);
                            BuildInfos.BUILD_VERSION.revision = versionSplitted[3];
                            BuildInfos.BUILD_REVISION = versionSplitted[3];
                            BuildInfos.BUILD_VERSION.patch = versionSplitted[4];
                            BuildInfos.BUILD_PATCH = versionSplitted[4];
                        };
                    }
                    else
                    {
                        file = new File(((File.applicationDirectory.nativePath + File.separator) + "games_base.xml"));
                        if (file.exists)
                        {
                            stream = new FileStream();
                            stream.open(file, FileMode.READ);
                            content = stream.readMultiByte(file.size, "utf-8");
                            xml = new XMLDocument();
                            xml.ignoreWhite = true;
                            xml.parseXML(content);
                            gameNode = xml.firstChild.firstChild;
                            for each (configNode in gameNode.childNodes)
                            {
                                if (configNode.nodeName == "version")
                                {
                                    version = configNode.firstChild.nodeValue;
                                    version = version.split("_")[0];
                                    versionSplitted = version.split(".");
                                    if (versionSplitted.length >= 5)
                                    {
                                        BuildInfos.BUILD_VERSION = new Version(versionSplitted[0], versionSplitted[1], versionSplitted[2]);
                                        BuildInfos.BUILD_VERSION.revision = versionSplitted[3];
                                        BuildInfos.BUILD_REVISION = versionSplitted[3];
                                        BuildInfos.BUILD_VERSION.patch = versionSplitted[4];
                                        BuildInfos.BUILD_PATCH = versionSplitted[4];
                                    };
                                };
                            };
                        }
                        else
                        {
                            BuildInfos.BUILD_VERSION.revision = BuildInfos.BUILD_REVISION;
                            BuildInfos.BUILD_VERSION.patch = BuildInfos.BUILD_PATCH;
                        };
                    };
                }
                catch(e:Error)
                {
                    trace(e.toString());
                    BuildInfos.BUILD_VERSION.revision = BuildInfos.BUILD_REVISION;
                    BuildInfos.BUILD_VERSION.patch = BuildInfos.BUILD_PATCH;
                };
                trace(((((((((("Version : " + BuildInfos.BUILD_VERSION.major) + ".") + BuildInfos.BUILD_VERSION.minor) + ".") + BuildInfos.BUILD_VERSION.release) + ".") + BuildInfos.BUILD_REVISION) + ".") + BuildInfos.BUILD_PATCH));
                if (BuildInfos.BUILD_TYPE < BuildTypeEnum.INTERNAL)
                {
                    Uri.enableSecureURI();
                };
                if (this.stage)
                {
                    this.init(this.stage);
                };
                _log.debug(("Support des Workers : " + ApplicationDomain.currentDomain.hasDefinition("flash.system::Worker")));
                try
                {
                    file = new File(((CustomSharedObject.getCustomSharedObjectDirectory() + File.separator) + "path.d2p"));
                    if (!(file.exists))
                    {
                        stream = new FileStream();
                        stream.open(file, FileMode.WRITE);
                        stream.writeUTF(File.applicationDirectory.nativePath);
                        stream.close();
                    };
                }
                catch(e:Error)
                {
                };
                this._initialized = true;
            };
        }

        private function onResize(e:NativeWindowBoundsEvent):void
        {
            this._displayState = stage.nativeWindow.displayState;
            if (this._displayState != NativeWindowDisplayState.MAXIMIZED)
            {
                this._stageHeight = stage.nativeWindow.height;
                this._stageWidth = stage.nativeWindow.width;
            };
        }

        private function onFullScreen(e:FullScreenEvent):void
        {
            var fullScreenOption:Boolean = OptionManager.getOptionManager("dofus").fullScreen;
            if (fullScreenOption != e.fullScreen)
            {
                OptionManager.getOptionManager("dofus").fullScreen = e.fullScreen;
            };
            StageShareManager.justExitFullScreen = !(e.fullScreen);
        }

        private function initWindow():void
        {
            var r:Number = (stage.stageWidth / stage.stageHeight);
            var mainWindow:NativeWindow = stage.nativeWindow;
            var chromeWidth:Number = (mainWindow.width - stage.stageWidth);
            var chromeHeight:Number = (mainWindow.height - stage.stageHeight);
            StageShareManager.chrome.x = chromeWidth;
            StageShareManager.chrome.y = chromeHeight;
            var clientDimentionSo:CustomSharedObject = CustomSharedObject.getLocal("clientData");
            var os:String = SystemManager.getSingleton().os;
            var sizeInitialised:Boolean;
            if (((!((clientDimentionSo.data == null))) && ((((clientDimentionSo.data.width > 0)) && ((clientDimentionSo.data.height > 0))))))
            {
                if ((((((clientDimentionSo.data.displayState == NativeWindowDisplayState.MAXIMIZED)) && ((os == OperatingSystem.WINDOWS)))) && (!((stage.displayState == StageDisplayState["FULL_SCREEN_INTERACTIVE"])))))
                {
                    stage.nativeWindow.maximize();
                    this._displayState = NativeWindowDisplayState.MAXIMIZED;
                };
                if ((((clientDimentionSo.data.width > 0)) && ((clientDimentionSo.data.height > 0))))
                {
                    mainWindow.width = clientDimentionSo.data.width;
                    if (os == OperatingSystem.LINUX)
                    {
                        mainWindow.height = (clientDimentionSo.data.height - 28);
                    }
                    else
                    {
                        mainWindow.height = clientDimentionSo.data.height;
                    };
                    this._stageWidth = mainWindow.width;
                    this._stageHeight = mainWindow.height;
                    sizeInitialised = true;
                };
            };
            if (!(sizeInitialised))
            {
                if (Screen.mainScreen.visibleBounds.width > Screen.mainScreen.visibleBounds.height)
                {
                    if (os == OperatingSystem.WINDOWS)
                    {
                        mainWindow.height = ((Screen.mainScreen.visibleBounds.height * 0.8) + chromeHeight);
                        mainWindow.width = ((r * (mainWindow.height - chromeHeight)) + chromeWidth);
                    }
                    else
                    {
                        mainWindow.height = (Screen.mainScreen.visibleBounds.height * 0.8);
                        mainWindow.width = (r * (mainWindow.height - chromeHeight));
                    };
                }
                else
                {
                    if (os == OperatingSystem.WINDOWS)
                    {
                        mainWindow.width = ((Screen.mainScreen.visibleBounds.width * 0.8) + chromeWidth);
                        mainWindow.height = (((mainWindow.width - chromeWidth) / r) + chromeHeight);
                    }
                    else
                    {
                        mainWindow.width = (Screen.mainScreen.visibleBounds.width * 0.8);
                        mainWindow.height = (mainWindow.width / r);
                    };
                };
                this._stageHeight = stage.nativeWindow.height;
                this._stageWidth = stage.nativeWindow.width;
            };
            mainWindow.x = (((Screen.mainScreen.visibleBounds.width - mainWindow.width) / 2) + Screen.mainScreen.visibleBounds.x);
            mainWindow.y = (((Screen.mainScreen.visibleBounds.height - mainWindow.height) / 2) + Screen.mainScreen.visibleBounds.y);
            mainWindow.visible = true;
        }

        public function getUiContainer():DisplayObjectContainer
        {
            return (this._uiContainer);
        }

        public function getWorldContainer():DisplayObjectContainer
        {
            return (this._worldContainer);
        }

        public function get options():DofusOptions
        {
            return (this._doOptions);
        }

        public function get instanceId():uint
        {
            return (this._instanceId);
        }

        public function get forcedLang():String
        {
            return (this._forcedLang);
        }

        public function setDisplayOptions(opt:DofusOptions):void
        {
            this._doOptions = opt;
            this._doOptions.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED, this.onOptionChange);
            this._doOptions.flashQuality = this._doOptions.flashQuality;
            this._doOptions.fullScreen = this._doOptions.fullScreen;
        }

        public function init(rootClip:DisplayObject, instanceId:uint=0, forcedLang:String=null, args:Array=null):void
        {
            if (args)
            {
                CommandLineArguments.getInstance().setArguments(args);
            };
            this._instanceId = instanceId;
            this._forcedLang = forcedLang;
            var catchMouseEventCtr:Sprite = new Sprite();
            catchMouseEventCtr.name = "catchMouseEventCtr";
            catchMouseEventCtr.graphics.beginFill(0);
            catchMouseEventCtr.graphics.drawRect(0, 0, StageShareManager.startWidth, StageShareManager.startHeight);
            catchMouseEventCtr.graphics.endFill();
            addChild(catchMouseEventCtr);
            var so:CustomSharedObject = CustomSharedObject.getLocal("appVersion");
            if (((!(so.data.lastBuildVersion)) || (((!((so.data.lastBuildVersion == BuildInfos.BUILD_REVISION))) && ((BuildInfos.BUILD_TYPE < BuildTypeEnum.INTERNAL))))))
            {
                this.clearCache(true);
            };
            so = CustomSharedObject.getLocal("appVersion");
            so.data.lastBuildVersion = BuildInfos.BUILD_REVISION;
            so.flush();
            so.close();
            SignedFileAdapter.defaultSignatureKey = SignatureKey.fromByte((new (Constants.SIGNATURE_KEY_DATA)() as ByteArray));
            this.initKernel(this.stage, rootClip);
            this.initWorld();
            this.initUi();
            if (BuildInfos.BUILD_TYPE > BuildTypeEnum.ALPHA)
            {
                this.initDebug();
            };
            if (AirScanner.hasAir())
            {
                stage["nativeWindow"].addEventListener(Event.CLOSE, this.onClosed);
            };
            TiphonEventsManager.addListener(Tiphon.getInstance(), TiphonEvent.EVT_EVENT);
            SoundManager.getInstance().manager = new RegSoundManager();
            (SoundManager.getInstance().manager as RegSoundManager).forceSoundsDebugMode = true;
            Atouin.getInstance().addListener(SoundManager.getInstance().manager);
        }

        private function onExiting(pEvt:Event):void
        {
            this.saveClientSize();
            if (WebServiceDataHandler.getInstance().quit())
            {
                pEvt.preventDefault();
                pEvt.stopPropagation();
                WebServiceDataHandler.getInstance().addEventListener(WebServiceDataHandler.ALL_DATA_SENT, this.quitHandler);
            };
        }

        public function quit(returnCode:int=0):void
        {
            this._returnCode = returnCode;
            if (!(WebServiceDataHandler.getInstance().quit()))
            {
                this.quitHandler();
            }
            else
            {
                _log.trace("We have data to send to the webservice. waiting...");
                WebServiceDataHandler.getInstance().addEventListener(WebServiceDataHandler.ALL_DATA_SENT, this.quitHandler);
                WebServiceDataHandler.getInstance().sendWaitingException();
            };
        }

        private function quitHandler(pEvt:Event=null):void
        {
            if (pEvt != null)
            {
                pEvt.currentTarget.removeEventListener(WebServiceDataHandler.ALL_DATA_SENT, this.quitHandler);
                _log.trace("Data sent. Good to go. Bye bye");
            };
            if (Constants.EVENT_MODE)
            {
                this.reboot();
            }
            else
            {
                if (AirScanner.hasAir())
                {
                    stage.nativeWindow.close();
                    if (NativeApplication.nativeApplication.openedWindows.length == 0)
                    {
                        NativeApplication.nativeApplication.exit(this._returnCode);
                    };
                };
            };
        }

        public function onClose():void
        {
            RegConnectionManager.getInstance().send(ProtocolEnum.SAY_GOODBYE, RegConnectionManager.getInstance().socketClientID);
            InterClientManager.destroy();
        }

        public function clearCache(selective:Boolean=false, reboot:Boolean=false):void
        {
            var soList:Array;
            var file:File;
            var fileName:String;
            StoreDataManager.getInstance().reset();
            var soFolder:File = new File(CustomSharedObject.getCustomSharedObjectDirectory());
            if (((soFolder) && (soFolder.exists)))
            {
                CustomSharedObject.closeAll();
                soList = soFolder.getDirectoryListing();
                for each (file in soList)
                {
                    fileName = FileUtils.getFileStartName(file.name);
                    if (fileName == "Dofus_Guest")
                    {
                    }
                    else
                    {
                        if (selective)
                        {
                            switch (true)
                            {
                                case (fileName.indexOf("Module_") == 0):
                                case (fileName == "dofus"):
                                case (fileName.indexOf("Dofus_") == 0):
                                case (fileName == "atouin"):
                                case (fileName == "berilia"):
                                case (fileName == "chat"):
                                case (fileName == "tiphon"):
                                case (fileName == "tubul"):
                                case (fileName.indexOf("externalNotifications_") == 0):
                                case (fileName == "averagePrices"):
                                case (fileName == "Berilia_binds"):
                                case (fileName == "maps"):
                                case (fileName == "logs"):
                                case (fileName == "uid"):
                                case (fileName == "appVersion"):
                                    continue;
                            };
                        };
                        try
                        {
                            if (file.isDirectory)
                            {
                                file.deleteDirectory(true);
                            }
                            else
                            {
                                file.deleteFile();
                            };
                        }
                        catch(e:Error)
                        {
                            trace(("ClearCache method cannot delete " + file.nativePath));
                        };
                    };
                };
            };
            if (reboot)
            {
                if (AirScanner.hasAir())
                {
                    AppIdModifier.getInstance().invalideCache();
                    this.reboot();
                }
                else
                {
                    if (ExternalInterface.available)
                    {
                        ExternalInterface.call("eval", "window.location.reload()");
                    };
                };
            };
        }

        public function reboot():void
        {
            this.saveClientSize();
            var w:Worker = Kernel.getWorker();
            if (w)
            {
                w.clear();
            };
            _log.fatal("REBOOT");
            if (AirScanner.hasAir())
            {
                var _local_2 = NativeApplication.nativeApplication;
                (_local_2["exit"](42));
            }
            else
            {
                throw (new Error("Reboot not implemented with flash"));
            };
        }

        public function renameApp(name:String):void
        {
            if (AirScanner.hasAir())
            {
                stage["nativeWindow"].title = name;
            };
        }

        private function initKernel(stage:Stage, rootClip:DisplayObject):void
        {
            Kernel.getInstance().init(stage, rootClip);
            LangManager.getInstance().handler = Kernel.getWorker();
            FontManager.getInstance().handler = Kernel.getWorker();
            Berilia.getInstance().handler = Kernel.getWorker();
            LangManager.getInstance().lang = "frFr";
        }

        private function initWorld():void
        {
            if (this._worldContainer)
            {
                removeChild(this._worldContainer);
            };
            this._worldContainer = new Sprite();
            addChild(this._worldContainer);
            this._worldContainer.mouseEnabled = false;
        }

        private function initUi():void
        {
            if (this._uiContainer)
            {
                removeChild(this._uiContainer);
            };
            this._uiContainer = new Sprite();
            addChild(this._uiContainer);
            this._uiContainer.mouseEnabled = false;
            var isDebugMode:Boolean = (BuildInfos.BUILD_TYPE == BuildTypeEnum.DEBUG);
            Berilia.getInstance().verboseException = isDebugMode;
            Berilia.getInstance().init(this._uiContainer, isDebugMode, BuildInfos.BUILD_REVISION, !(isDebugMode));
            if (AirScanner.isStreamingVersion())
            {
                Berilia.embedIcons.SLOT_DEFAULT_ICON = EmbedAssets.getBitmap("DefaultBeriliaSlotIcon", true).bitmapData;
            };
            var sharedDefUri:Uri = new Uri("SharedDefinitions.swf");
            sharedDefUri.loaderContext = new LoaderContext(false, new ApplicationDomain());
            var hasNoHttpServerFile:Boolean = File.applicationDirectory.resolvePath("noHttpServer").exists;
            UiModuleManager.getInstance((((BuildInfos.BUILD_TYPE == BuildTypeEnum.RELEASE)) || (hasNoHttpServerFile))).sharedDefinitionContainer = sharedDefUri;
            EntityDisplayer.setAnimationModifier(1, new CustomAnimStatiqueAnimationModifier());
            EntityDisplayer.setAnimationModifier(2, new CustomAnimStatiqueAnimationModifier());
            EntityDisplayer.setSkinModifier(1, new BreedSkinModifier());
            EntityDisplayer.setSkinModifier(2, new BreedSkinModifier());
            EntityDisplayer.setAnimationModifier(2, new CustomAnimStatiqueAnimationModifier());
            EntityDisplayer.setSubEntityDefaultBehavior(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET, new AnimStatiqueSubEntityBehavior());
            EntityDisplayer.setSubEntityDefaultBehavior(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER, new RiderBehavior());
            CharacterWheel.setAnimationModifier(1, new CustomAnimStatiqueAnimationModifier());
            CharacterWheel.setAnimationModifier(2, new CustomAnimStatiqueAnimationModifier());
            CharacterWheel.setSkinModifier(1, new BreedSkinModifier());
            CharacterWheel.setSkinModifier(2, new BreedSkinModifier());
            CharacterWheel.setSubEntityDefaultBehavior(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET, new AnimStatiqueSubEntityBehavior());
            CharacterWheel.setSubEntityDefaultBehavior(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER, new RiderBehavior());
            EntityDisplayer.lookAdaptater = EntityLookAdapter.tiphonizeLook;
        }

        private function initDebug():void
        {
            FramerateCounter.refreshRate = 250;
            FramerateCounter.addListener(this);
            this._buildType = BuildTypeParser.getTypeName(BuildInfos.BUILD_TYPE);
            this._fpsDisplay = new TextField();
            this._fpsDisplay.mouseEnabled = false;
            this._fpsDisplay.selectable = false;
            this._fpsDisplay.defaultTextFormat = new TextFormat("Verdana", 12, 0xFFFFFF, true, false, false, null, null, TextFormatAlign.RIGHT);
            this._fpsDisplay.text = ((this._buildType + "\nr") + BuildInfos.BUILD_REVISION);
            this._fpsDisplay.filters = [new DropShadowFilter(0, 0, 0, 1, 2, 2, 5, 3)];
            this._fpsDisplay.width = 300;
            this._fpsDisplay.x = (0x0500 - this._fpsDisplay.width);
            addChild(this._fpsDisplay);
            if (Constants.EVENT_MODE)
            {
                this._fpsDisplay.visible = false;
            };
        }

        public function toggleFPS():void
        {
            this._fpsDisplay.visible = !(this._fpsDisplay.visible);
        }

        private function onClosed(e:Event):void
        {
            Console.getInstance().close();
            ConsoleLUA.getInstance().close();
            HttpServer.getInstance().close();
        }

        private function onOptionChange(e:PropertyChangeEvent):void
        {
            if (e.propertyName == "flashQuality")
            {
                if (e.propertyValue == 0)
                {
                    StageShareManager.stage.quality = StageQuality.LOW;
                }
                else
                {
                    if (e.propertyValue == 1)
                    {
                        StageShareManager.stage.quality = StageQuality.MEDIUM;
                    }
                    else
                    {
                        if (e.propertyValue == 2)
                        {
                            StageShareManager.stage.quality = StageQuality.HIGH;
                        };
                    };
                };
            };
            if (e.propertyName == "fullScreen")
            {
                StageShareManager.setFullScreen(e.propertyValue, false);
            };
        }

        public function onFps(fps:uint):void
        {
            var framesInfo:Object;
            if (this._fpsDisplay.visible)
            {
                framesInfo = RasterizedAnimation.countFrames();
                this._fpsDisplay.htmlText = ((((((((((("<font color='#FFFFFF'>" + fps) + " fps - ") + this._buildType) + "\n<font color='#B9B6ED'>") + Memory.humanReadableUsage()) + " - r") + BuildInfos.BUILD_REVISION) + "\n<font color='#92D5D8'> Anim/Img en cache - ") + framesInfo.animations) + "/") + framesInfo.frames);
            };
        }

        private function saveClientSize():void
        {
            var clientDimentionSo:CustomSharedObject = CustomSharedObject.getLocal("clientData");
            clientDimentionSo.data.height = this._stageHeight;
            clientDimentionSo.data.width = this._stageWidth;
            clientDimentionSo.data.displayState = this._displayState;
            clientDimentionSo.flush();
            clientDimentionSo.close();
        }

        public function strLoaderComplete():void
        {
            this.strComplete = true;
        }

        public function getLoadingProgress():Number
        {
            return (this.strProgress);
        }


    }
}//package 

