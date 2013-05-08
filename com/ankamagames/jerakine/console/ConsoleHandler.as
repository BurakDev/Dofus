package com.ankamagames.jerakine.console
{
   import com.ankamagames.jerakine.messages.MessageHandler;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.Dictionary;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.data.I18n;
   import flash.utils.getTimer;


   public class ConsoleHandler extends Object implements MessageHandler, ConsoleInstructionHandler
   {
         

      public function ConsoleHandler(outputHandler:MessageHandler, displayExecutionTime:Boolean=true, hideCommandsWithoutHelp:Boolean=false) {
         super();
         this._outputHandler=outputHandler;
         this._handlers=new Dictionary();
         this._displayExecutionTime=displayExecutionTime;
         this._hideCommandsWithoutHelp=hideCommandsWithoutHelp;
         this._handlers["help"]=this;
      }

      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(ConsoleHandler));

      private var _name:String;

      private var _handlers:Dictionary;

      private var _outputHandler:MessageHandler;

      private var _displayExecutionTime:Boolean;

      private var _hideCommandsWithoutHelp:Boolean;

      public function get handlers() : Dictionary {
         return this._handlers;
      }

      public function get outputHandler() : MessageHandler {
         return this._outputHandler;
      }

      public function get name() : String {
         return this._name;
      }

      public function set name(value:String) : void {
         this._name=value;
      }

      public function process(msg:Message) : Boolean {
         if(msg is ConsoleInstructionMessage)
         {
            this.dispatchMessage(ConsoleInstructionMessage(msg));
            return true;
         }
         return false;
      }

      public function output(text:String, type:uint=0) : void {
         this._outputHandler.process(new ConsoleOutputMessage(this._name,text,type));
      }

      public function addHandler(cmd:*, handler:ConsoleInstructionHandler) : void {
         var s:String = null;
         if(cmd is Array)
         {
            for each (s in cmd)
            {
               if(s)
               {
                  this._handlers[String(s)]=handler;
               }
            }
         }
         else
         {
            if(cmd)
            {
               this._handlers[String(cmd)]=handler;
            }
         }
      }

      public function changeOutputHandler(outputHandler:MessageHandler) : void {
         this._outputHandler=outputHandler;
      }

      public function removeHandler(cmd:String) : void {
         delete this._handlers[[cmd]];
      }

      public function isHandled(cmd:String) : Boolean {
         return !(this._handlers[cmd]==null);
      }

      public function handle(console:ConsoleHandler, cmd:String, args:Array) : void {
         var commands:Array = null;
         var sCmd:String = null;
         var cmdHelp:String = null;
         var handler:ConsoleInstructionHandler = null;
         switch(cmd)
         {
            case "help":
               if(args.length==0)
               {
                  console.output(I18n.getUiText("ui.console.generalHelp",[this._name]));
                  commands=new Array();
                  for (cmd in this._handlers)
                  {
                     commands.push(cmd);
                  }
                  commands.sort();
                  for each (sCmd in commands)
                  {
                     cmdHelp=(this._handlers[sCmd] as ConsoleInstructionHandler).getHelp(sCmd);
                     if((cmdHelp)||(!this._hideCommandsWithoutHelp))
                     {
                        console.output("  - <b>"+sCmd+"</b>: "+cmdHelp);
                     }
                  }
               }
               else
               {
                  handler=this._handlers[args[0]];
                  if(handler)
                  {
                     console.output("<b>"+sCmd+"</b>: "+handler.getHelp(args[0]));
                  }
                  else
                  {
                     console.output(I18n.getUiText("ui.console.unknownCommand",[args[0]]));
                  }
               }
               break;
         }
      }

      public function getHelp(cmd:String) : String {
         switch(cmd)
         {
            case "help":
               return I18n.getUiText("ui.console.displayhelp");
            default:
               return I18n.getUiText("ui.chat.console.noHelp",[cmd]);
         }
      }

      public function getCmdHelp(sCmd:String) : String {
         var cih:ConsoleInstructionHandler = this._handlers[sCmd];
         if(cih)
         {
            return cih.getHelp(sCmd);
         }
         return null;
      }

      public function getParamPossibilities(cmd:String, paramIndex:uint=0, currentParams:Array=null) : Array {
         return [];
      }

      public function autoComplete(cmd:String) : String {
         var sCmd:String = null;
         var startCmd:String = null;
         var newCmd:String = null;
         var bMatch:* = false;
         var i:uint = 0;
         var aMatch:Array = new Array();
         var splittedCmd:Array = cmd.split(" ");
         if(splittedCmd.length==1)
         {
            for (sCmd in this._handlers)
            {
               if(sCmd.indexOf(cmd)==0)
               {
                  aMatch.push(sCmd);
               }
            }
            startCmd="";
         }
         else
         {
            aMatch=this.getAutoCompletePossibilitiesOnParam(splittedCmd[0],splittedCmd.slice(1).length-1,splittedCmd.slice(1));
            startCmd=splittedCmd.slice(0,splittedCmd.length-1).join(" ")+" ";
         }
         if(aMatch.length>1)
         {
            newCmd="";
            bMatch=true;
            i=1;
            while(i<30)
            {
               if(i>aMatch[0].length)
               {
               }
               else
               {
                  for each (sCmd in aMatch)
                  {
                     bMatch=(bMatch)&&(sCmd.indexOf(aMatch[0].substr(0,i))==0);
                     if(!bMatch)
                     {
                        break;
                     }
                  }
                  if(bMatch)
                  {
                     newCmd=aMatch[0].substr(0,i);
                     i++;
                     continue;
                  }
               }
            }
         }
         else
         {
            if(aMatch.length==1)
            {
               return startCmd+aMatch[0];
            }
            return cmd;
         }
      }

      public function getAutoCompletePossibilities(cmd:String) : Array {
         var sCmd:String = null;
         var aMatch:Array = new Array();
         for (sCmd in this._handlers)
         {
            if(sCmd.indexOf(cmd)==0)
            {
               aMatch.push(sCmd);
            }
         }
         return aMatch;
      }

      public function getAutoCompletePossibilitiesOnParam(cmd:String, paramIndex:uint, currentParams:Array) : Array {
         var possibility:String = null;
         var cih:ConsoleInstructionHandler = this._handlers[cmd];
         var allPossibilities:Array = new Array();
         var possibilities:Array = new Array();
         if(cih)
         {
            allPossibilities=cih.getParamPossibilities(cmd,paramIndex,currentParams);
            for each (possibility in allPossibilities)
            {
               if(possibility.indexOf(currentParams[paramIndex])==0)
               {
                  possibilities.push(possibility);
               }
            }
            return possibilities;
         }
         return [];
      }

      private function dispatchMessage(msg:ConsoleInstructionMessage) : void {
         var handler:ConsoleInstructionHandler = null;
         var t1:uint = 0;
         if(this._handlers[msg.cmd]!=null)
         {
            handler=this._handlers[msg.cmd] as ConsoleInstructionHandler;
            t1=getTimer();
            handler.handle(this,msg.cmd,msg.args);
            if(this._displayExecutionTime)
            {
               this.output("Command "+msg.cmd+" executed in "+(getTimer()-t1)+" ms");
            }
            return;
         }
         throw new UnhandledConsoleInstructionError(I18n.getUiText("ui.console.notfound",[msg.cmd]));
      }
   }

}