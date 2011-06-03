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
    
    public static const PROMPT_ISSUED:String = "prompt_issued";    
    public static const CLOSE_PROMPT:String = "close_prompt";    
    public static const PROMPT_ACCEPTED:String = "prompt_accepted";    
    public static const PROMPT_CANCELED:String = "prompt_canceled";
    
  }

}