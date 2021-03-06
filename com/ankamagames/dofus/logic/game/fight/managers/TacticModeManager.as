﻿package com.ankamagames.dofus.logic.game.fight.managers
{
    import com.ankamagames.jerakine.data.XmlConfig;
    import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayInteractivesFrame;
    import com.ankamagames.atouin.types.Selection;
    import com.ankamagames.atouin.utils.DataMapProvider;
    import __AS3__.vec.Vector;
    import flash.display.Sprite;
    import com.ankamagames.atouin.data.map.CellData;
    import com.ankamagames.atouin.types.CellReference;
    import com.ankamagames.jerakine.types.positions.MapPoint;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Point;
    import com.ankamagames.dofus.kernel.Kernel;
    import com.ankamagames.berilia.managers.KernelEventsManager;
    import com.ankamagames.dofus.misc.lists.HookList;
    import com.ankamagames.atouin.managers.MapDisplayManager;
    import com.ankamagames.atouin.managers.InteractiveCellManager;
    import com.ankamagames.atouin.managers.SelectionManager;
    import com.ankamagames.atouin.utils.CellIdConverter;
    import com.ankamagames.atouin.renderers.ZoneClipRenderer;
    import com.ankamagames.atouin.enums.PlacementStrataEnums;
    import com.ankamagames.jerakine.types.zones.Custom;
    import com.ankamagames.atouin.renderers.ZoneDARenderer;
    import com.ankamagames.jerakine.types.Color;
    import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
    import com.ankamagames.dofus.types.entities.AnimatedCharacter;
    import com.ankamagames.jerakine.entities.interfaces.IEntity;
    import com.ankamagames.atouin.managers.EntitiesManager;
    import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
    import com.ankamagames.jerakine.types.zones.ZRectangle;
    import com.ankamagames.atouin.utils.CellUtil;
    import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
    import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
    import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
    import com.ankamagames.jerakine.types.Uri;
    import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSwfAdapter;
    import flash.system.ApplicationDomain;
    import __AS3__.vec.*;

    public class TacticModeManager 
    {

        private static var SWF_LIB:String = XmlConfig.getInstance().getEntry("config.ui.skin").concat("assets_tacticmod.swf");
        private static var TILES_REACHABLE:Array = ["Dalle01"];
        private static var TILES_NO_MVT:Array = ["BlocageMvt"];
        private static var TILES_NO_VIEW:Array = ["BlocageLDV"];
        private static var SHOW_BLOC_MOVE:Boolean = false;
        private static var SHOW_BACKGROUND:Boolean = false;
        private static var _self:TacticModeManager;
        private static const DEBUG_FIGHT_MODE:int = 0;
        private static const DEBUG_RP_MODE:int = 1;

        private var _roleplayInteractivesFrame:RoleplayInteractivesFrame;
        private var _tacticReachableRangeSelection:Selection;
        private var _tacticUnreachableRangeSelection:Selection;
        private var _tacticOtherSelection:Selection;
        private var _debugCellId:uint;
        private var _debugMode:Boolean = false;
        private var _debugCache:Boolean = true;
        private var _debugType:int;
        private var _showFightZone:Boolean = false;
        private var _fightZone:Selection;
        private var _showInteractiveCells:Boolean = false;
        private var _interactiveCellsZone:Selection;
        private var _showScaleZone:Boolean = false;
        private var _scaleZone:Selection;
        private var _flattenCells:Boolean;
        private var _showBlockMvt:Boolean = true;
        private var _dmp:DataMapProvider;
        private var _cellsRef:Array;
        private var _cellsData:Array;
        private var _cellZones:Vector.<int>;
        private var _currentNbZone:int = 0;
        private var _zones:Array;
        private var _tacticModeActivated:Boolean = false;
        private var _currentMapId:uint;
        private var _nbMov:int;
        private var _nbLos:int;
        private var _reachablePath:Vector.<uint>;
        private var _unreachablePath:Vector.<uint>;
        private var _otherPath:Vector.<uint>;
        private var _background:Sprite;

        public function TacticModeManager(pvt:PrivateClass)
        {
            this._dmp = DataMapProvider.getInstance();
        }

        public static function getInstance():TacticModeManager
        {
            if (_self == null)
            {
                _self = new (TacticModeManager)(new PrivateClass());
            };
            return (_self);
        }


        public function show(pPoint:WorldPointWrapper, openByTerminal:Boolean=false):void
        {
            var i:int;
            var len:int;
            var _local_5:Vector.<uint>;
            var _local_6:CellData;
            var _local_7:CellReference;
            var _local_8:int;
            var _local_9:MapPoint;
            var _local_10:DisplayObjectContainer;
            var _local_11:Boolean;
            var _local_12:Boolean;
            var _local_13:Boolean;
            var _local_14:Boolean;
            var _local_15:Array;
            var _local_16:Object;
            var _local_17:Point;
            var _local_18:int;
            var _local_19:int;
            var _local_20:int;
            var _local_21:int;
            var _local_22:Object;
            if (!(openByTerminal))
            {
                this._debugMode = false;
                SHOW_BLOC_MOVE = false;
            }
            else
            {
                this._debugMode = true;
                SHOW_BLOC_MOVE = true;
            };
            if (this._roleplayInteractivesFrame == null)
            {
                this._roleplayInteractivesFrame = (Kernel.getWorker().getFrame(RoleplayInteractivesFrame) as RoleplayInteractivesFrame);
            };
            if (this._tacticModeActivated)
            {
                return;
            };
            this._tacticModeActivated = true;
            KernelEventsManager.getInstance().processCallback(HookList.ShowTacticMode, true);
            if (((((this._debugMode) && (this._debugCache))) || (((((((!(this._debugMode)) && (this._currentMapId))) && ((this._currentMapId == pPoint.mapId)))) && ((this._cellsRef.length > 0))))))
            {
                if ((((this._cellsRef == null)) || ((this._cellsRef[0] == null))))
                {
                    this._cellsRef = MapDisplayManager.getInstance().getDataMapContainer().getCell();
                    this._cellsData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells;
                };
                len = this._cellsRef.length;
                if (((!(this._debugMode)) || (((this._debugMode) && (this._flattenCells)))))
                {
                    i = 0;
                    while (i < len)
                    {
                        if (this._cellsRef[i] != null)
                        {
                            this._cellsRef[i].visible = true;
                            this._cellsRef[i].visible = false;
                            if (this._cellsData[i].floor != 0)
                            {
                                _local_10 = InteractiveCellManager.getInstance().getCell(this._cellsRef[i].id);
                                _local_10.y = (this._cellsRef[i].elevation + this._cellsData[i].floor);
                                this.updateEntitiesOnCell(i);
                            };
                        };
                        i = (i + 1);
                    };
                };
                SelectionManager.getInstance().addSelection(this._tacticReachableRangeSelection, "tacticReachableRange", 0);
                if (((!(this._debugMode)) || (this._showBlockMvt)))
                {
                    SelectionManager.getInstance().addSelection(this._tacticUnreachableRangeSelection, "tacticUnreachableRange", 0);
                };
                if (((SHOW_BLOC_MOVE) && ((this._nbMov > this._nbLos))))
                {
                    SelectionManager.getInstance().addSelection(this._tacticOtherSelection, "tacticOtherRange", 0);
                }
                else
                {
                    if (((((!(SHOW_BLOC_MOVE)) && (this._tacticOtherSelection))) && (!((SelectionManager.getInstance().getSelection("tacticOtherRange") == null)))))
                    {
                        SelectionManager.getInstance().getSelection("tacticOtherRange").remove();
                    };
                };
                if (((this._debugMode) && (this._fightZone)))
                {
                    if (this._showFightZone)
                    {
                        SelectionManager.getInstance().addSelection(this._fightZone, "debugSelection", this._debugCellId);
                    }
                    else
                    {
                        SelectionManager.getInstance().getSelection("debugSelection").remove();
                    };
                };
                if (((this._debugMode) && (this._scaleZone)))
                {
                    if (this._showScaleZone)
                    {
                        SelectionManager.getInstance().addSelection(this._scaleZone, "scaleZone", this._debugCellId);
                    }
                    else
                    {
                        SelectionManager.getInstance().getSelection("scaleZone").remove();
                    };
                };
                if (((this._debugMode) && (this._interactiveCellsZone)))
                {
                    if (this._showInteractiveCells)
                    {
                        SelectionManager.getInstance().addSelection(this._interactiveCellsZone, "interactiveCellsZone", this._debugCellId);
                    }
                    else
                    {
                        SelectionManager.getInstance().getSelection("interactiveCellsZone").remove();
                    };
                };
            }
            else
            {
                this._currentMapId = pPoint.mapId;
                this._reachablePath = new Vector.<uint>();
                this._unreachablePath = new Vector.<uint>();
                this._otherPath = new Vector.<uint>();
                _local_5 = new Vector.<uint>();
                this._cellsRef = MapDisplayManager.getInstance().getDataMapContainer().getCell();
                this._cellsData = MapDisplayManager.getInstance().getDataMapContainer().dataMap.cells;
                len = this._cellsRef.length;
                this._cellZones = new Vector.<int>(len);
                this._currentNbZone = 0;
                this._nbMov = 0;
                this._nbLos = 0;
                i = 0;
                while (i < len)
                {
                    _local_7 = this._cellsRef[i];
                    _local_6 = this._cellsData[i];
                    _local_7.visible = true;
                    _local_7.visible = false;
                    if (!_local_7.isDisabled)
                    {
                        _local_8 = this.getCellZone(i);
                        _local_9 = MapPoint.fromCellId(i);
                        _local_11 = ((this._dmp.pointMov(_local_9.x, _local_9.y)) && (((this._debugMode) || (((!(this._debugMode)) && (!(this._dmp.farmCell(_local_9.x, _local_9.y))))))));
                        _local_12 = this._dmp.pointLos(_local_9.x, _local_9.y);
                        _local_13 = _local_6.nonWalkableDuringFight;
                        _local_14 = _local_6.nonWalkableDuringRP;
                        if (_local_6.moveZone)
                        {
                            _local_5.push(_local_7.id);
                        };
                        if (((((!(this._debugMode)) || (((this._debugMode) && (this._flattenCells))))) && (!((_local_6.floor == 0)))))
                        {
                            _local_10 = InteractiveCellManager.getInstance().getCell(_local_7.id);
                            _local_10.y = (_local_7.elevation + _local_6.floor);
                            this.updateEntitiesOnCell(i);
                        };
                        if (this.canMoveOnThisCell(_local_11, _local_13, _local_14))
                        {
                            if (_local_8 > 0)
                            {
                                this._cellZones[i] = _local_8;
                            }
                            else
                            {
                                this._currentNbZone++;
                                this._cellZones[i] = this._currentNbZone;
                            };
                        }
                        else
                        {
                            if (((_local_12) && (!(this.canMoveOnThisCell(_local_11, _local_13, _local_14)))))
                            {
                                this._cellZones[i] = 0;
                            }
                            else
                            {
                                if (((!(_local_12)) && (!(this.canMoveOnThisCell(_local_11, _local_13, _local_14)))))
                                {
                                    this._cellZones[i] = -1;
                                };
                            };
                        };
                    };
                    i = (i + 1);
                };
                this.updateCellWithRealCellZone();
                _local_15 = new Array();
                this._zones = new Array();
                i = 0;
                while (i < len)
                {
                    switch (this._cellZones[i])
                    {
                        case -1:
                            this._unreachablePath.push(i);
                            break;
                        case 0:
                            if (((SHOW_BLOC_MOVE) && (this.getInformations(i)[0])))
                            {
                                this._otherPath.push(i);
                                this._nbLos++;
                            };
                            break;
                        default:
                            if (_local_15.indexOf(this._cellZones[i]) == -1)
                            {
                                _local_15.push(this._cellZones[i]);
                            };
                            _local_17 = CellIdConverter.cellIdToCoord(i);
                            if (this._zones[this._cellZones[i]] == null)
                            {
                                _local_16 = new Object();
                                _local_16.map = new Vector.<int>();
                                _local_16.maxX = _local_17.x;
                                _local_16.minX = _local_17.x;
                                _local_16.maxY = _local_17.y;
                                _local_16.minY = _local_17.y;
                                this._zones[this._cellZones[i]] = _local_16;
                            }
                            else
                            {
                                _local_16 = this._zones[this._cellZones[i]];
                                if (_local_17.x > _local_16.maxX)
                                {
                                    _local_16.maxX = _local_17.x;
                                };
                                if (_local_17.x < _local_16.minX)
                                {
                                    _local_16.minX = _local_17.x;
                                };
                                if (_local_17.y > _local_16.maxY)
                                {
                                    _local_16.maxY = _local_17.y;
                                };
                                if (_local_17.y < _local_16.minY)
                                {
                                    _local_16.minY = _local_17.y;
                                };
                            };
                            this._zones[this._cellZones[i]].map.push(i);
                            if (this._reachablePath.indexOf(i) == -1)
                            {
                                this._reachablePath.push(i);
                            };
                            this._nbMov++;
                    };
                    i = (i + 1);
                };
                this._currentNbZone = _local_15.length;
                _local_15 = null;
                for each (_local_22 in this._zones)
                {
                    if (!(_local_20))
                    {
                        _local_20 = _local_22.maxX;
                    }
                    else
                    {
                        _local_20 = Math.max(_local_20, _local_22.maxX);
                    };
                    if (!(_local_19))
                    {
                        _local_21 = _local_22.minX;
                    }
                    else
                    {
                        _local_21 = Math.min(_local_21, _local_22.minX);
                    };
                    if (!(_local_18))
                    {
                        _local_18 = _local_22.maxY;
                    }
                    else
                    {
                        _local_18 = Math.max(_local_18, _local_22.maxY);
                    };
                    if (!(_local_19))
                    {
                        _local_19 = _local_22.minY;
                    }
                    else
                    {
                        _local_19 = Math.min(_local_19, _local_22.minY);
                    };
                };
                this.clearUnneededCells(_local_20, _local_18, _local_21, _local_19);
                this._tacticReachableRangeSelection = new Selection();
                this._tacticReachableRangeSelection.renderer = new ZoneClipRenderer(PlacementStrataEnums.STRATA_NO_Z_ORDER, SWF_LIB, TILES_REACHABLE, (((TILES_REACHABLE.length)>1) ? this._currentMapId : -1), SHOW_BLOC_MOVE);
                this._tacticReachableRangeSelection.zone = new Custom(this._reachablePath);
                SelectionManager.getInstance().addSelection(this._tacticReachableRangeSelection, "tacticReachableRange", 0);
                if (((!(this._debugMode)) || (this._showBlockMvt)))
                {
                    this._tacticUnreachableRangeSelection = new Selection();
                    this._tacticUnreachableRangeSelection.renderer = new ZoneClipRenderer(PlacementStrataEnums.STRATA_AREA, SWF_LIB, TILES_NO_VIEW, (((TILES_NO_VIEW.length)>1) ? this._currentMapId : -1), SHOW_BLOC_MOVE);
                    this._tacticUnreachableRangeSelection.zone = new Custom(this._unreachablePath);
                    SelectionManager.getInstance().addSelection(this._tacticUnreachableRangeSelection, "tacticUnreachableRange", 0);
                };
                if ((((((this._nbMov > this._nbLos)) && (SHOW_BLOC_MOVE))) || (this._debugMode)))
                {
                    this._tacticOtherSelection = new Selection();
                    this._tacticOtherSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_NO_Z_ORDER);
                    this._tacticOtherSelection.color = new Color(717337);
                    this._tacticOtherSelection.zone = new Custom(this._otherPath);
                };
                if (((this._debugMode) && (this._showScaleZone)))
                {
                    this._scaleZone = new Selection();
                    this._scaleZone.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_NO_Z_ORDER);
                    this._scaleZone.color = new Color(5085175);
                    this._scaleZone.zone = new Custom(_local_5);
                    SelectionManager.getInstance().addSelection(this._scaleZone, "scaleZone", this._debugCellId);
                };
                if (((this._debugMode) && (this._showFightZone)))
                {
                    SelectionManager.getInstance().addSelection(this._fightZone, "debugSelection", this._debugCellId);
                };
                if (((this._debugMode) && (this._showInteractiveCells)))
                {
                    this._interactiveCellsZone = new Selection();
                    this._interactiveCellsZone.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_NO_Z_ORDER);
                    this._interactiveCellsZone.color = new Color(0xFFFFFF);
                    this._interactiveCellsZone.zone = new Custom(this._roleplayInteractivesFrame.getInteractiveElementsCells());
                    SelectionManager.getInstance().addSelection(this._interactiveCellsZone, "interactiveCellsZone", this._debugCellId);
                };
            };
            MapDisplayManager.getInstance().hideBackgroundForTacticMode(true);
            if (SHOW_BACKGROUND)
            {
                this.loadBackground();
            };
        }

        private function canMoveOnThisCell(canMov:Boolean, nonWalkableDuringFight:Boolean, nonWalkableDuringRp:Boolean):Boolean
        {
            if (!(canMov))
            {
                return (false);
            };
            if (((((!(this._debugMode)) || (((this._debugMode) && ((this._debugType == DEBUG_FIGHT_MODE)))))) && (nonWalkableDuringFight)))
            {
                return (false);
            };
            if (((((this._debugMode) && ((this._debugType == DEBUG_RP_MODE)))) && (nonWalkableDuringRp)))
            {
                return (false);
            };
            return (true);
        }

        public function hide(force:Boolean=false):void
        {
            var s:Selection;
            var cellRef:CellReference;
            var cellData:CellData;
            var i:int;
            var cellInteractionCtr:DisplayObjectContainer;
            if (!(this._tacticModeActivated))
            {
                return;
            };
            this._tacticModeActivated = false;
            if (!(force))
            {
                KernelEventsManager.getInstance().processCallback(HookList.ShowTacticMode, false);
            };
            if (SHOW_BACKGROUND)
            {
                this.removeBackground();
            };
            s = SelectionManager.getInstance().getSelection("tacticReachableRange");
            if (s)
            {
                s.remove();
            };
            s = SelectionManager.getInstance().getSelection("tacticUnreachableRange");
            if (s)
            {
                s.remove();
            };
            if (this._tacticOtherSelection != null)
            {
                s = SelectionManager.getInstance().getSelection("tacticOtherRange");
                if (s)
                {
                    s.remove();
                };
            };
            if (this._interactiveCellsZone != null)
            {
                s = SelectionManager.getInstance().getSelection("interactiveCellsZone");
                if (s)
                {
                    s.remove();
                };
            };
            if (this._scaleZone != null)
            {
                s = SelectionManager.getInstance().getSelection("scaleZone");
                if (s)
                {
                    s.remove();
                };
            };
            if (this._fightZone != null)
            {
                s = SelectionManager.getInstance().getSelection("debugSelection");
                if (s)
                {
                    s.remove();
                };
            };
            var len:int = this._cellsRef.length;
            i = 0;
            while (i < len)
            {
                cellRef = this._cellsRef[i];
                if (cellRef)
                {
                    cellData = this._cellsData[i];
                    if (cellRef)
                    {
                        cellRef.visible = true;
                    };
                    if (cellData.floor != 0)
                    {
                        cellInteractionCtr = InteractiveCellManager.getInstance().getCell(cellRef.id);
                        cellInteractionCtr.y = cellRef.elevation;
                        this.updateEntitiesOnCell(i);
                    };
                };
                i++;
            };
            MapDisplayManager.getInstance().hideBackgroundForTacticMode(false);
        }

        private function updateEntitiesOnCell(cellId:uint):void
        {
            var characterEntity:AnimatedCharacter;
            var e:IEntity;
            var entities:Array = EntitiesManager.getInstance().getEntitiesOnCell(cellId);
            for each (e in entities)
            {
                characterEntity = (DofusEntities.getEntity(e.id) as AnimatedCharacter);
                if (characterEntity)
                {
                    characterEntity.jump(characterEntity.position);
                };
            };
        }

        private function clearUnneededCells(zonesMaxX:int, zonesMaxY:int, zonesMinX:int, zonesMinY:int):void
        {
            var uCell:uint;
            var i:int;
            var infos:Array;
            var avgX:int = (zonesMaxX - zonesMinX);
            var avgY:int = (Math.abs(zonesMinY) + Math.abs(zonesMaxY));
            var centerCellId:int = CellIdConverter.coordToCellId(((avgX / 2) + zonesMinX), ((avgY / 2) + zonesMinY));
            var l:ZRectangle = new ZRectangle(0, (avgX / 2), (avgY / 2), null);
            var collideCells:Vector.<uint> = l.getCells(centerCellId);
            if (((this._debugMode) && (this._showFightZone)))
            {
                this._fightZone = new Selection();
                this._fightZone.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA);
                this._fightZone.color = new Color(0xFFEE00);
                this._fightZone.zone = l;
                this._debugCellId = centerCellId;
            };
            var unreachablePathDuplicate:Vector.<uint> = this._unreachablePath.concat();
            var len:int = unreachablePathDuplicate.length;
            i = 0;
            while (i < len)
            {
                uCell = unreachablePathDuplicate[i];
                infos = this.getInformations(uCell);
                if (((infos[1]) || ((((collideCells.indexOf(uCell) == -1)) && (!(infos[0]))))))
                {
                    this._unreachablePath.splice(this._unreachablePath.indexOf(uCell), 1);
                };
                i = (i + 1);
            };
            unreachablePathDuplicate = null;
        }

        private function updateCellWithRealCellZone():void
        {
            var zone:int;
            var isLeftCol:Boolean;
            var isRightCol:Boolean;
            var isEvenRow:Boolean;
            var zones:Vector.<int>;
            var cellId:int;
            var i:int;
            var len2:int;
            var j:int;
            var minValue:int;
            var maxValue:int;
            var len:int = this._cellZones.length;
            var collideZones:Array = new Array();
            cellId = 0;
            while (cellId < len)
            {
                zone = this._cellZones[cellId];
                if (zone > 0)
                {
                    isLeftCol = CellUtil.isLeftCol(cellId);
                    isRightCol = CellUtil.isRightCol(cellId);
                    isEvenRow = CellUtil.isEvenRow(cellId);
                    zones = new Vector.<int>();
                    if (((((cellId - 28) > 0)) && ((this._cellZones[(cellId - 28)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId - 28)]);
                    };
                    if (((((!(isRightCol)) && (((cellId + 1) < this._cellZones.length)))) && ((this._cellZones[(cellId + 1)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId + 1)]);
                    };
                    if (((((cellId + 28) < this._cellZones.length)) && ((this._cellZones[(cellId + 28)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId + 28)]);
                    };
                    if (((((!(isLeftCol)) && (((cellId - 1) > 0)))) && ((this._cellZones[(cellId - 1)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId - 1)]);
                    };
                    if (((((((!(isLeftCol)) || (((isLeftCol) && (!(isEvenRow)))))) && (((cellId + 14) < this._cellZones.length)))) && ((this._cellZones[(cellId + 14)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId + 14)]);
                    };
                    if (((((((!(isLeftCol)) || (((isLeftCol) && (!(isEvenRow)))))) && (((cellId - 14) > 0)))) && ((this._cellZones[(cellId - 14)] > 0))))
                    {
                        zones.push(this._cellZones[(cellId - 14)]);
                    };
                    if (isEvenRow)
                    {
                        if (((((!(isLeftCol)) && (((cellId + 13) < this._cellZones.length)))) && ((this._cellZones[(cellId + 13)] > 0))))
                        {
                            zones.push(this._cellZones[(cellId + 13)]);
                        };
                        if (((((!(isLeftCol)) && (((cellId - 15) > 0)))) && ((this._cellZones[(cellId - 15)] > 0))))
                        {
                            zones.push(this._cellZones[(cellId - 15)]);
                        };
                    }
                    else
                    {
                        if (((((!(isRightCol)) && (((cellId - 13) > 0)))) && ((this._cellZones[(cellId - 13)] > 0))))
                        {
                            zones.push(this._cellZones[(cellId - 13)]);
                        };
                        if (((((!(isRightCol)) && (((cellId + 15) < this._cellZones.length)))) && ((this._cellZones[(cellId + 15)] > 0))))
                        {
                            zones.push(this._cellZones[(cellId + 15)]);
                        };
                    };
                    if (zones.length > 0)
                    {
                        len2 = zones.length;
                        i = 0;
                        while (i < len2)
                        {
                            if (((!((zone == zones[i]))) && (!(this.containZone(collideZones, zone, zones[i])))))
                            {
                                collideZones.push({
                                    "z1":zone,
                                    "z2":zones[i]
                                });
                            };
                            if (zones[i] < zone)
                            {
                                zone = zones[i];
                            };
                            i = (i + 1);
                        };
                        if (zone > 0)
                        {
                            this._cellZones[cellId] = zone;
                            if (((((cellId - 28) > 0)) && ((this._cellZones[(cellId - 28)] > 0))))
                            {
                                this._cellZones[(cellId - 28)] = zone;
                            };
                            if (((((cellId - 13) > 0)) && ((this._cellZones[(cellId - 13)] > 0))))
                            {
                                this._cellZones[(cellId - 13)] = zone;
                            };
                            if (((((cellId + 1) < this._cellZones.length)) && ((this._cellZones[(cellId + 1)] > 0))))
                            {
                                this._cellZones[(cellId + 1)] = zone;
                            };
                            if (((((cellId + 15) < this._cellZones.length)) && ((this._cellZones[(cellId + 15)] > 0))))
                            {
                                this._cellZones[(cellId + 15)] = zone;
                            };
                            if (((((cellId + 28) < this._cellZones.length)) && ((this._cellZones[(cellId + 28)] > 0))))
                            {
                                this._cellZones[(cellId + 28)] = zone;
                            };
                            if (((((cellId + 14) < this._cellZones.length)) && ((this._cellZones[(cellId + 14)] > 0))))
                            {
                                this._cellZones[(cellId + 14)] = zone;
                            };
                            if (((((cellId - 1) > 0)) && ((this._cellZones[(cellId - 1)] > 0))))
                            {
                                this._cellZones[(cellId - 1)] = zone;
                            };
                        };
                    };
                };
                cellId = (cellId + 1);
            };
            if (collideZones.length > 0)
            {
                i = 0;
                while (i < collideZones.length)
                {
                    if (((!((this._cellZones.indexOf(collideZones[i].z1) == -1))) && (!((this._cellZones.indexOf(collideZones[i].z2) == -1)))))
                    {
                        minValue = Math.min(collideZones[i].z1, collideZones[i].z2);
                        maxValue = Math.max(collideZones[i].z1, collideZones[i].z2);
                        j = 0;
                        while (j < len)
                        {
                            if (this._cellZones[j] == maxValue)
                            {
                                this._cellZones[j] = minValue;
                            };
                            j = (j + 1);
                        };
                    };
                    i = (i + 1);
                };
                collideZones = null;
            };
        }

        private function containZone(zones:Array, z1:int, z2:int):Boolean
        {
            var i:int;
            var len:int = zones.length;
            i = 0;
            while (i < len)
            {
                if ((((((zones[i].z1 == z1)) && ((zones[i].z2 == z2)))) || ((((zones[i].z1 == z2)) && ((zones[i].z2 == z1))))))
                {
                    return (true);
                };
                i = (i + 1);
            };
            return (false);
        }

        private function getCellZone(cellId:int):int
        {
            var zone:int = -1;
            var isLeftCol:Boolean = CellUtil.isLeftCol(cellId);
            var isRightCol:Boolean = CellUtil.isRightCol(cellId);
            var isEvenRow:Boolean = CellUtil.isEvenRow(cellId);
            if (((((!(isLeftCol)) && (((cellId - 1) > 0)))) && ((this._cellZones[(cellId - 1)] > 0))))
            {
                zone = this._cellZones[(cellId - 1)];
            }
            else
            {
                if (((((cellId - 28) > 0)) && ((this._cellZones[(cellId - 28)] > 0))))
                {
                    zone = this._cellZones[(cellId - 28)];
                }
                else
                {
                    if (((((((!(isEvenRow)) && (!(isRightCol)))) && (((cellId - 13) > 0)))) && ((this._cellZones[(cellId - 13)] > 0))))
                    {
                        zone = this._cellZones[(cellId - 13)];
                    }
                    else
                    {
                        if (((((((isEvenRow) && (((!(isLeftCol)) || (((isLeftCol) && (!(isEvenRow)))))))) && (((cellId - 14) > 0)))) && ((this._cellZones[(cellId - 14)] > 0))))
                        {
                            zone = this._cellZones[(cellId - 14)];
                        };
                    };
                };
            };
            return (zone);
        }

        private function getInformations(cellId:int):Array
        {
            var isBorder:Boolean;
            var isUseless:Boolean = true;
            var isLeftCol:Boolean = CellUtil.isLeftCol(cellId);
            var isRightCol:Boolean = CellUtil.isRightCol(cellId);
            var isEvenRow:Boolean = CellUtil.isEvenRow(cellId);
            if (((!(isLeftCol)) && (((cellId - 1) > 0))))
            {
                if (this._cellZones[(cellId - 1)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId - 1)] != -1)
                {
                    isUseless = false;
                };
            };
            if (((!(isRightCol)) && (((cellId + 1) < this._cellZones.length))))
            {
                if (this._cellZones[(cellId + 1)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId + 1)] != -1)
                {
                    isUseless = false;
                };
            };
            if (((((!(isLeftCol)) || (((isLeftCol) && (!(isEvenRow)))))) && (((cellId + 14) < this._cellZones.length))))
            {
                if (this._cellZones[(cellId + 14)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId + 14)] != -1)
                {
                    isUseless = false;
                };
            };
            if ((cellId + 28) < this._cellZones.length)
            {
                if (this._cellZones[(cellId + 28)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId + 28)] != -1)
                {
                    isUseless = false;
                };
            };
            if (((((!(isLeftCol)) || (((isLeftCol) && (!(isEvenRow)))))) && (((cellId - 14) > 0))))
            {
                if (this._cellZones[(cellId - 14)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId - 14)] != -1)
                {
                    isUseless = false;
                };
            };
            if ((cellId - 28) > 0)
            {
                if (this._cellZones[(cellId - 28)] > 0)
                {
                    isBorder = true;
                };
                if (this._cellZones[(cellId - 28)] != -1)
                {
                    isUseless = false;
                };
            };
            if (isEvenRow)
            {
                if (((!(isLeftCol)) && (((cellId + 13) < this._cellZones.length))))
                {
                    if (this._cellZones[(cellId + 13)] > 0)
                    {
                        isBorder = true;
                    };
                    if (this._cellZones[(cellId + 13)] != -1)
                    {
                        isUseless = false;
                    };
                };
                if (((!(isLeftCol)) && (((cellId - 15) > 0))))
                {
                    if (this._cellZones[(cellId - 15)] > 0)
                    {
                        isBorder = true;
                    };
                    if (this._cellZones[(cellId - 15)] != -1)
                    {
                        isUseless = false;
                    };
                };
            }
            else
            {
                if (((!(isRightCol)) && (((cellId - 13) > 0))))
                {
                    if (this._cellZones[(cellId - 13)] > 0)
                    {
                        isBorder = true;
                    };
                    if (this._cellZones[(cellId - 13)] != -1)
                    {
                        isUseless = false;
                    };
                };
                if (((!(isRightCol)) && (((cellId + 15) < this._cellZones.length))))
                {
                    if (this._cellZones[(cellId + 15)] > 0)
                    {
                        isBorder = true;
                    };
                    if (this._cellZones[(cellId + 15)] != -1)
                    {
                        isUseless = false;
                    };
                };
            };
            return ([isBorder, isUseless]);
        }

        public function get tacticModeActivated():Boolean
        {
            return (this._tacticModeActivated);
        }

        private function loadBackground():void
        {
            var loader:IResourceLoader;
            if (this._background == null)
            {
                loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.SINGLE_LOADER);
                loader.addEventListener(ResourceLoadedEvent.LOADED, this.onBackgroundLoaded);
                loader.load(new Uri(SWF_LIB), null, AdvancedSwfAdapter);
            }
            else
            {
                MapDisplayManager.getInstance().renderer.container.addChildAt(this._background, 0);
            };
        }

        private function removeBackground():void
        {
            if (((!((this._background == null))) && (MapDisplayManager.getInstance().renderer.container.contains(this._background))))
            {
                MapDisplayManager.getInstance().renderer.container.removeChild(this._background);
            };
        }

        private function onBackgroundLoaded(pEvt:ResourceLoadedEvent=null):void
        {
            pEvt.currentTarget.removeEventListener(ResourceLoadedEvent.LOADED, this.onBackgroundLoaded);
            var appDomain:ApplicationDomain = pEvt.resource.applicationDomain;
            this._background = (new (appDomain.getDefinition("BG"))() as Sprite);
            this._background.name = "TacticModeBackground";
            MapDisplayManager.getInstance().renderer.container.addChildAt(this._background, 0);
        }

        public function setDebugMode(pShowFightZone:Boolean=false, pUseCache:Boolean=false, pDebugType:int=0, pShowInteractiveCells:Boolean=false, pShowScaleZone:Boolean=false, pFlattenCells:Boolean=true, pShowBlockMvt:Boolean=true):void
        {
            this._showFightZone = pShowFightZone;
            this._debugCache = pUseCache;
            this._debugType = pDebugType;
            this._showInteractiveCells = pShowInteractiveCells;
            this._showScaleZone = pShowScaleZone;
            this._flattenCells = pFlattenCells;
            this._showBlockMvt = pShowBlockMvt;
        }


    }
}//package com.ankamagames.dofus.logic.game.fight.managers

class PrivateClass 
{


}

