﻿package com.ankamagames.tubul
{
    import flash.events.EventDispatcher;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
    import __AS3__.vec.Vector;
    import com.ankamagames.tubul.interfaces.IAudioBus;
    import flash.utils.Dictionary;
    import flash.geom.Point;
    import com.ankamagames.tubul.types.SoundMerger;
    import com.ankamagames.tubul.types.TubulOptions;
    import com.ankamagames.tubul.utils.error.TubulError;
    import com.ankamagames.tubul.types.bus.LocalizedBus;
    import com.ankamagames.tubul.interfaces.ISound;
    import com.ankamagames.tubul.events.TubulEvent;
    import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
    import com.ankamagames.tubul.events.AudioBusEvent;
    import com.ankamagames.jerakine.types.Uri;
    import com.ankamagames.tubul.types.LoadedSoundInformations;
    import com.ankamagames.tubul.interfaces.ILocalizedSoundListener;
    import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
    import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
    import com.ankamagames.tubul.types.RollOffPreset;
    import com.ankamagames.jerakine.resources.adapters.AdapterFactory;
    import com.ankamagames.tubul.resources.adapters.MP3Adapter;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
    import flash.events.TimerEvent;
    import __AS3__.vec.*;

    public class Tubul extends EventDispatcher 
    {

        protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Tubul));
        private static var _self:Tubul;

        private var _resourceLoader:IResourceLoader;
        private var _audioBusList:Vector.<IAudioBus>;
        private var _busDictionary:Dictionary;
        private var _XMLSoundFilesDictionary:Dictionary;
        private var _rollOffPresets:Array;
        private var _earPosition:Point;
        private var _localizedSoundListeners:Array;
        private var _soundMerger:SoundMerger;
        private var _loadedSoundsInformations:Dictionary;
        public var playedCharacterId:int;
        private var _tuOptions:TubulOptions;

        public function Tubul()
        {
            if (_self)
            {
                throw (new TubulError("Warning : Tubul is a singleton class and shoulnd't be instancied directly!"));
            };
            this.init();
        }

        public static function getInstance():Tubul
        {
            if (!(_self))
            {
                _self = new (Tubul)();
            };
            return (_self);
        }


        public function get options():TubulOptions
        {
            return (this._tuOptions);
        }

        public function get totalPlayingSounds():uint
        {
            var bus:IAudioBus;
            var sounds:uint;
            for each (bus in this._audioBusList)
            {
                sounds = (sounds + bus.soundList.length);
            };
            return (sounds);
        }

        public function get localizedSoundListeners():Array
        {
            return (this._localizedSoundListeners);
        }

        public function get earPosition():Point
        {
            return (this._earPosition);
        }

        public function set earPosition(pPosition:Point):void
        {
            var bus:IAudioBus;
            this._earPosition = pPosition;
            for each (bus in this._audioBusList)
            {
                if ((bus is LocalizedBus))
                {
                    (bus as LocalizedBus).updateObserverPosition(pPosition);
                };
            };
        }

        public function get audioBusList():Vector.<IAudioBus>
        {
            return (this._audioBusList);
        }

        public function get isActive():Boolean
        {
            return (true);
        }

        public function get soundMerger():SoundMerger
        {
            return (this._soundMerger);
        }

        public function getSoundById(pSoundID:int):ISound
        {
            var bus:IAudioBus;
            var sound:ISound;
            for each (bus in this.audioBusList)
            {
                for each (sound in bus.soundList)
                {
                    if (sound.id == pSoundID)
                    {
                        return (sound);
                    };
                };
            };
            return (null);
        }

        public function activate(bValue:Boolean=true):void
        {
            if (this.isActive)
            {
                _log.info("Tubul is now ACTIVATED");
            }
            else
            {
                _log.info("Tubul is now DESACTIVATED");
                this.resetTubul();
            };
            var tea:TubulEvent = new TubulEvent(TubulEvent.ACTIVATION);
            tea.activated = this.isActive;
            dispatchEvent(tea);
        }

        public function setDisplayOptions(topt:TubulOptions):void
        {
            var propertyKey:String;
            var e:PropertyChangeEvent;
            this._tuOptions = topt;
            this._tuOptions.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED, this.onPropertyChanged);
            for (propertyKey in this._tuOptions)
            {
                e = new PropertyChangeEvent(this._tuOptions, propertyKey, this._tuOptions[propertyKey], this._tuOptions[propertyKey]);
            };
        }

        public function addBus(pBus:IAudioBus):void
        {
            var busID:int = pBus.id;
            if (this._busDictionary[busID] != null)
            {
                return;
            };
            if (this._audioBusList.length > BusConstants.MAXIMUM_NUMBER_OF_BUS)
            {
                throw (new TubulError("The maximum number of audio Bus have been reached !"));
            };
            this._audioBusList.push(pBus);
            this._busDictionary[busID] = pBus;
            pBus.eventDispatcher.addEventListener(AudioBusEvent.REMOVE_SOUND_IN_BUS, this.onRemoveSoundInBus);
        }

        public function clearCache():void
        {
            var bus:IAudioBus;
            for each (bus in this._busDictionary)
            {
                bus.clearCache();
            };
        }

        public function getBus(pBusID:uint):IAudioBus
        {
            if (this.contains(pBusID))
            {
                return (this._busDictionary[pBusID]);
            };
            _log.warn((("The audio BUS " + pBusID) + " doesn't exists"));
            return (null);
        }

        public function removeBus(pBusID:uint):void
        {
            var bus:IAudioBus;
            var size:int;
            var i:int;
            if (!(this.isActive))
            {
                return;
            };
            if (this.contains(pBusID))
            {
                bus = this._busDictionary[pBusID];
                bus.eventDispatcher.addEventListener(AudioBusEvent.REMOVE_SOUND_IN_BUS, this.onRemoveSoundInBus);
                delete this._busDictionary[pBusID];
                size = this._audioBusList.length;
                i = 0;
                while (i < size)
                {
                    if (this._audioBusList[i] == bus)
                    {
                        this._audioBusList[i] = null;
                        this._audioBusList.splice(i, 1);
                        break;
                    };
                    i++;
                };
            }
            else
            {
                throw (new TubulError((("The audio BUS " + pBusID) + " doesn't exist !")));
            };
        }

        public function clearBuses():void
        {
            var key:IAudioBus;
            if (!(this.isActive))
            {
                return;
            };
            for each (key in this._busDictionary)
            {
                this.removeBus(key.id);
            };
        }

        public function contains(pBusID:uint):Boolean
        {
            if (this._busDictionary[pBusID] != null)
            {
                return (true);
            };
            return (false);
        }

        public function getLoadedSoundInformations(pSoundUri:Uri):LoadedSoundInformations
        {
            if (this._loadedSoundsInformations[pSoundUri])
            {
                trace("Existe déjà");
            };
            return (null);
        }

        public function setLoadedSoundInformations(pSoundUri:Uri, pInfo:LoadedSoundInformations):void
        {
            if (this._loadedSoundsInformations[pSoundUri])
            {
                trace("Existe déjà");
            }
            else
            {
                this._loadedSoundsInformations[pSoundUri] = pInfo;
            };
        }

        public function addListener(pListener:ILocalizedSoundListener):void
        {
            if (!(this.isActive))
            {
                return;
            };
            if (this._localizedSoundListeners == null)
            {
                this._localizedSoundListeners = new Array();
            };
            if (!(this._localizedSoundListeners.indexOf(pListener)))
            {
                return;
            };
            this._localizedSoundListeners.push(pListener);
        }

        public function removeListener(pListener:ILocalizedSoundListener):void
        {
            if (this._localizedSoundListeners == null)
            {
                this._localizedSoundListeners = new Array();
            };
            var index:int = this._localizedSoundListeners.indexOf(pListener);
            if (index < 0)
            {
                return;
            };
            this._localizedSoundListeners[index] = null;
            this._localizedSoundListeners.splice(index, 1);
        }

        public function dumpPlayingSounds():void
        {
            var bus:IAudioBus;
            var sound:ISound;
            _log.debug("--------------- dumpPlayingSounds --------------------");
            for each (bus in this._audioBusList)
            {
                _log.debug(bus.name);
                for each (sound in bus.soundList)
                {
                    _log.debug(("-> " + sound.uri));
                };
            };
            _log.debug("--------------- end --------------------");
        }

        private function resetTubul():void
        {
            var bus:IAudioBus;
            for each (bus in this._audioBusList)
            {
                bus.clear();
            };
            this._resourceLoader.removeEventListener(ResourceLoadedEvent.LOADED, this.onXMLSoundsLoaded);
            this._resourceLoader.removeEventListener(ResourceErrorEvent.ERROR, this.onXMLSoundsFailed);
        }

        private function retriveRollOffPresets(pXMLPreset:XML):void
        {
            var preset:XML;
            var rollOffPreset:RollOffPreset;
            var presets:XMLList = pXMLPreset.elements();
            if (this._rollOffPresets == null)
            {
                this._rollOffPresets = new Array();
            };
            for each (preset in presets)
            {
                rollOffPreset = new RollOffPreset(uint(preset.GainMax), uint(preset.DistMax), uint(preset.DistMaxSat));
                this._rollOffPresets[preset.@id] = rollOffPreset;
            };
        }

        public function init():void
        {
            this._audioBusList = new Vector.<IAudioBus>();
            this._busDictionary = new Dictionary(true);
            this._XMLSoundFilesDictionary = new Dictionary();
            this._earPosition = new Point();
            this._loadedSoundsInformations = new Dictionary();
            AdapterFactory.addAdapter("mp3", MP3Adapter);
            this._resourceLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.SERIAL_LOADER);
            this._resourceLoader.addEventListener(ResourceLoadedEvent.LOADED, this.onXMLSoundsLoaded);
            this._resourceLoader.addEventListener(ResourceErrorEvent.ERROR, this.onXMLSoundsFailed);
            this._soundMerger = new SoundMerger();
        }

        private function setVolumeToBus(pBusId:int, pVolume:uint):void
        {
            var audioBus:IAudioBus = Tubul.getInstance().getBus(pBusId);
            if (audioBus != null)
            {
                audioBus.volume = (pVolume / 100);
            };
        }

        private function onTimerEnd(pEvent:TimerEvent):void
        {
            this._resourceLoader.load([XMLSounds.BREED_BONES_BARKS, XMLSounds.ROLLOFF_PRESET]);
        }

        private function onXMLSoundsLoaded(pEvent:ResourceLoadedEvent):void
        {
            var fileName:String = pEvent.uri.fileName.split(".")[0];
            if (fileName == XMLSounds.ROLLOFF_FILENAME)
            {
                this.retriveRollOffPresets(pEvent.resource);
            }
            else
            {
                if (!(this._XMLSoundFilesDictionary[fileName]))
                {
                    this._XMLSoundFilesDictionary[fileName] = pEvent.resource;
                };
            };
        }

        private function onXMLSoundsFailed(pEvent:ResourceErrorEvent):void
        {
            this.activate(false);
            _log.error(((((("An XML sound file failed to load : " + pEvent.uri) + " / [") + pEvent.errorCode) + "] ") + pEvent.errorMsg));
        }

        private function onRemoveSoundInBus(pEvent:AudioBusEvent):void
        {
            dispatchEvent(pEvent);
        }

        private function onPropertyChanged(e:PropertyChangeEvent):void
        {
            switch (e.propertyName)
            {
                case "muteMusic":
                    this.setVolumeToBus(0, ((e.propertyValue) ? 0 : this._tuOptions.volumeMusic));
                    return;
                case "muteSound":
                    this.setVolumeToBus(4, ((e.propertyValue) ? 0 : this._tuOptions.volumeSound));
                    return;
                case "muteAmbientSound":
                    this.setVolumeToBus(1, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    this.setVolumeToBus(2, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    this.setVolumeToBus(3, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    this.setVolumeToBus(5, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    this.setVolumeToBus(6, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    this.setVolumeToBus(7, ((e.propertyValue) ? 0 : this._tuOptions.volumeAmbientSound));
                    return;
                case "volumeMusic":
                    if (this._tuOptions.muteMusic == false)
                    {
                        this.setVolumeToBus(0, e.propertyValue);
                    };
                    return;
                case "volumeSound":
                    if (this._tuOptions.muteSound == false)
                    {
                        this.setVolumeToBus(4, e.propertyValue);
                    };
                    return;
                case "volumeAmbientSound":
                    if (this._tuOptions.muteAmbientSound == false)
                    {
                        this.setVolumeToBus(1, e.propertyValue);
                        this.setVolumeToBus(2, e.propertyValue);
                        this.setVolumeToBus(3, e.propertyValue);
                        this.setVolumeToBus(5, e.propertyValue);
                        this.setVolumeToBus(6, e.propertyValue);
                        this.setVolumeToBus(7, e.propertyValue);
                    };
                    return;
            };
        }


    }
}//package com.ankamagames.tubul

