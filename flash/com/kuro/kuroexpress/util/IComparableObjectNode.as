package com.kuro.kuroexpress.util {
  public interface IComparableObjectNode extends ILinkedObjectNode {
    function compare( obj:IComparableObjectNode ):int;
  }
}