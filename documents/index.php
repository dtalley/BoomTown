<?php

  $file = "design_document.xml";
  $style = "design_document_dev.xsl";

  $_xml = new DOMDocument();
  $_xml->load( $file );

  $_xsl = new DOMDocument();
  $_xsl->load( $style );

  $_proc = new XSLTProcessor();
  $_proc->importStylesheet( $_xsl );
  echo $_proc->transformToXml( $_xml );

?>