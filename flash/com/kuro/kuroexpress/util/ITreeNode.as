package com.kuro.kuroexpress.util {
  public interface ITreeNode {
    function get left():ITreeNode;
    function set left( val:ITreeNode ):void;
    function get right():ITreeNode;
    function set right( val:ITreeNode ):void;
    function get level():uint;
    function set level( val:uint ):void;
    function compare( obj:ITreeNode ):int;
    function copy( obj:ITreeNode ):void;
  }
}