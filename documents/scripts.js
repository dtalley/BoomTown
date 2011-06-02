var features = new Array();
$(document).ready(function(){
  $(".feature").each(function(ifeat, feature){
    initializeFeature( feature );
  });
  $(".save_document").click(function(){
    
  });
});

function initializeFeature( feature ) {
  var id = feature.id;
  features[id] = new Array();
  features[id].title = $("#feature_title",feature).val();
  features[id].plural = $("#feature_plural",feature).val();
  //Contact info editing
  var contact_info = $(".contact_info",feature);
  var contact_edit = $(".edit_contact_info",feature);
  $(".edit_contact",feature).click(function(){
    $(contact_info).toggle();
    $(contact_edit).toggle();
    return false;
  });
  $(".save_contact",contact_edit).click(function(){
    $(contact_info).toggle();
    $(contact_edit).toggle();
    var author = $(".edit_author",contact_edit).val();
    var email = $(".edit_email",contact_edit).val();
    $(contact_info).html("Author: <a href=\"mailto:" + email + "\">" + author + "</a>");
    return false;
  });
  //Background editing
  var background_body = $(".background_body",feature);
  var background_text = $(".background_text",feature);
  var background_edit = $(".edit_background",feature);
  $(".background_edit",background_edit).change(function(){
    if( $(".background_edit",background_edit).attr("scrollHeight") > 120 ) {
      $(".background_edit",background_edit).css("height",$(".background_edit",background_edit).attr("scrollHeight") + "px");
    } else {
      $(".background_edit",background_edit).css("height","120px");
    }
  });
  $(".edit_background_btn",feature).click(function(){
    $(background_body).toggle();
    $(background_edit).toggle();
    if( $(".background_edit",background_edit).attr("scrollHeight") > 120 ) {
      $(".background_edit",background_edit).css("height",$(".background_edit",background_edit).attr("scrollHeight") + "px");
    } else {
      $(".background_edit",background_edit).css("height","120px");
    }
    return false;
  });
  $(".save_background",background_edit).click(function(){
    $(background_body).toggle();
    $(background_edit).toggle();
    var newtext = $(".background_edit",background_edit).val();
    if( newtext ) {
      newtext = replaceValues( newtext, id );
      $(background_text).html(newtext);
    }
    return false;
  });
  //Implementation editing
  var implementation_body = $(".implementation_body",feature);
  var implementation_text = $(".implementation_text",feature);
  var implementation_edit = $(".edit_implementation",feature);
  $(".implementation_edit",implementation_edit).change(function(){
    if( $(".implementation_edit",implementation_edit).attr("scrollHeight") > 120 ) {
      $(".implementation_edit",implementation_edit).css("height",$(".implementation_edit",implementation_edit).attr("scrollHeight") + "px");
    } else {
      $(".implementation_edit",implementation_edit).css("height","120px");
    }
  });
  $(".edit_implementation_btn",feature).click(function(){
    $(implementation_body).toggle();
    $(implementation_edit).toggle();
    if( $(".implementation_edit",implementation_edit).attr("scrollHeight") > 0 ) {
      $(".implementation_edit",implementation_edit).css("height",$(".implementation_edit",implementation_edit).attr("scrollHeight") + "px");
    } else {
      $(".implementation_edit",implementation_edit).css("height","120px");
    }
    return false;
  });
  $(".save_implementation",implementation_edit).click(function(){
    $(implementation_body).toggle();
    $(implementation_edit).toggle();
    var newtext = $(".implementation_edit",implementation_edit).val();
    if( newtext ) {
      newtext = replaceValues( newtext, id );
      $(implementation_text).html(newtext);
    }
    return false;
  });
  //Impact editing
  var impact_body = $(".impact_body",feature);
  var impact_text = $(".impact_text",feature);
  var impact_edit = $(".edit_impact",feature);
  $(".impact_edit",impact_edit).bind( "keydown", function(){
    if( $(".impact_edit",impact_edit).attr("scrollHeight") > 120 ) {
      $(".impact_edit",impact_edit).css("height",$(".impact_edit",impact_edit).attr("scrollHeight") + "px");
    } else {
      $(".impact_edit",impact_edit).css("height","120px");
    }
  });
  $(".edit_impact_btn",feature).click(function(){
    $(impact_body).toggle();
    $(impact_edit).toggle();
    if( $(".impact_edit",impact_edit).attr("scrollHeight") > 0 ) {
      $(".impact_edit",impact_edit).css("height",$(".impact_edit",impact_edit).attr("scrollHeight") + "px");
    } else {
      $(".impact_edit",impact_edit).css("height","120px");
    }
    return false;
  });
  $(".save_impact",impact_edit).click(function(){
    $(impact_body).toggle();
    $(impact_edit).toggle();
    var newtext = $(".impact_edit",impact_edit).val();
    if( newtext ) {
      newtext = replaceValues( newtext, id );
      $(impact_text).html(newtext);
    }
    return false;
  });
  var goaltemplate = $(".goals_list li.goal_template",feature);
  $(".goals_list li",feature).each(function(igoal, goal){
    initializeGoal( id, goaltemplate, goal, null, null );
  });
}

function initializeGoal( id, goaltemplate, goal, goalv, goalt ) {
  var view = $(".view_goal_section",goal);
  var edit = $(".edit_goal_section",goal);
  var editbox = $(".edit_goal_edit",edit);
  var textbox = $(".edit_goal_text",view);
  if( goalv && goalt ) {
    $(editbox).text(goalv);
    $(textbox).html(goalt);
  }
  $(".delete_goal",view).click(function(){
    var conf = confirm( "Are you sure you want to delete this goal?" );
    if( conf ) {
      $(goal).remove();
    }
    return false;
  });
  $(".edit_goal",view).click(function(){
    toggleGoal( edit, view );
    return false;
  });
  $(".add_goal",view).click(function(){
    $(".edit_goal_holder",edit).html("<textarea class=\"edit_goal_edit\"></textarea>");
    $(".edit_goal_edit",edit).text("Edit this...");
    $(".edit_goal_edit",edit).click(function(){
      $(".edit_goal_edit",edit).text("");
      $(".edit_goal_edit",edit).click(function(){});
    });
    $(".edit_goal_edit",edit).bind("keydown", function(key){
      if( key.keyCode == 13 ) {
        if( $(".edit_goal_edit",edit).get(0).value.length > 0 ) {
          saveGoal( id, goaltemplate, goal, edit, view, true );
          $(".edit_goal_holder",edit).html("");
        }
        return false;
      }
    });
    //$(".edit_goal_edit",edit).text("Edit this...");
    //$(".edit_goal_edit",edit).click(function(){
      //$(".edit_goal_edit",edit).text("");
    //});
    toggleGoal( edit, view );
    return false;
  });
  $(".save_goal",edit).click(function(){
    if( $(".edit_goal_holder",edit).get(0).value.length > 0 ) {
      saveGoal( id, goaltemplate, goal, edit, view, false );
    }
    return false;
  });
  $(".save_new_goal",edit).click(function(){
    if( $(".edit_goal_holder",edit).get(0).value.length > 0 ) {
      saveGoal( id, goaltemplate, goal, edit, view, true );
      $(".edit_goal_holder",edit).html("");
    }
    return false;
  });
}

function saveGoal( id, goaltemplate, goal, edit, view, isClone ) {
  var textarea = $(".edit_goal_edit",edit).get(0);
  var goalv = textarea.value;
  var goalt = replaceValues( goalv, id );
  if( isClone ) {
    var clone = $(goaltemplate).clone();
    $(clone).insertBefore(goal);
    $(clone).toggle();
    $(".edit_goal_edit",edit).text("Edit this...");
    initializeGoal( id, goaltemplate, clone, goalv, goalt );
  } else {
    $(".edit_goal_text",view).html(goalt);
  }
  toggleGoal( edit, view );
  return false;
}

function toggleGoal( edit, view ) {
  $(edit).toggle();
  $(view).toggle();
}

function replaceValues( text, id ) {
  text = text.replace( /<t(\s*?)\/>/gi, features[id].title );
  text = text.replace( /<p(\s*?)\/>/gi, features[id].plural );

  var linkpattern = new RegExp( '<l>([^<>]+)</l>', 'gi' );
  var matches = text.match(linkpattern);
  if( matches ) {
    var total = matches.length;
    for( var i = 0; i < total; i++ ) {
      var newid = matches[i].replace( "<l>", "" ).replace( "</l>", "" );
      var rep = "<l>" + newid + "</l>";
      var reptext = "<a href=\"#feature_" + newid + "\">" + features[newid].title + "</a>";
      text = text.replace( rep, reptext );
    }
  }

  var pluralpattern = new RegExp( '<pl>([^<>]+)</pl>', 'gi' );
  matches = text.match(pluralpattern);
  if( matches ) {
    var total = matches.length;
    for( var i = 0; i < total; i++ ) {
      var newid = matches[i].replace( "<pl>", "" ).replace( "</pl>", "" );
      var rep = "<pl>" + newid + "</pl>";
      var reptext = "<a href=\"#feature_" + newid + "\">" + features[newid].plural + "</a>";
      text = text.replace( rep, reptext );
    }
  }

  return text;
}