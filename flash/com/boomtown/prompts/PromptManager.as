package com.boomtown.prompts {
  import com.boomtown.events.PromptEvent;
  import flash.display.Sprite;
  import flash.events.EventDispatcher;
	/**
   * ...
   * @author David Talley
   */
  public class PromptManager {
    
    private static var _dispatcher:EventDispatcher;
    private static var _prompts:Object = {};
    
    public static function issuePrompt( id:String, prompt:Prompt ):void {
      _prompts[id] = prompt;
      _dispatcher.dispatchEvent( new PromptEvent( PromptEvent.PROMPT_ISSUED, prompt ) );
      prompt.addEventListener( PromptEvent.PROMPT_ACCEPTED, promptAccepted );
      prompt.addEventListener( PromptEvent.PROMPT_CANCELED, promptCanceled );
    }
    
    private static function promptAccepted( e:PromptEvent ):void {
      _dispatcher.dispatchEvent( new PromptEvent( PromptEvent.PROMPT_ACCEPTED, e.prompt ) );
      closePrompt( e.prompt );
    }
    
    private static function promptCanceled( e:PromptEvent ):void {
      _dispatcher.dispatchEvent( new PromptEvent( PromptEvent.PROMPT_CANCELED, e.prompt ) );
      closePrompt( e.prompt );
    }
    
    public static function addEventListener( type:String, func:Function ):void {
      _dispatcher.addEventListener( type, func );
    }
    
    public static function removeEventListener( type:String, func:Function ):void {
      _dispatcher.removeEventListener( type, func );
    }
    
    public static function closePrompt( obj:* ):void {
      var prompt:Prompt;
      if ( obj is String ) {
        prompt = _prompts[String(obj)];
      } else {
        prompt = Prompt( obj );
      }
      prompt.removeEventListener( PromptEvent.PROMPT_ACCEPTED, promptAccepted );
      prompt.removeEventListener( PromptEvent.PROMPT_CANCELED, promptCanceled );
      if( prompt ) {
        _dispatcher.dispatchEvent( new PromptEvent( PromptEvent.CLOSE_PROMPT, prompt ) );
      }
    }
    
    public static function getPrompt( id:String ):Prompt {
      return _prompts[id];
    }
    
    public static function get dispatcher():EventDispatcher {
      if ( !_dispatcher ) {
        _dispatcher = new EventDispatcher();
      }
      return _dispatcher;
    }
    
  }

}