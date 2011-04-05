package com.boomtown.events {
  import com.boomtown.prompts.Prompt;
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class PromptEvent extends Event {
    
    private var _prompt:Prompt;
    
    public function PromptEvent( type:String, prompt:Prompt ) {
      _prompt = prompt;
      super(type);
    }
    
    public function get prompt():Prompt {
      return _prompt;
    }
    
    public static function get PROMPT_ISSUED():String {
      return "prompt_issued";
    }
    
    public static function get CLOSE_PROMPT():String {
      return "close_prompt";
    }
    
    public static function get PROMPT_ACCEPTED():String {
      return "prompt_accepted";
    }
    
    public static function get PROMPT_CANCELED():String {
      return "prompt_canceled";
    }
    
  }

}