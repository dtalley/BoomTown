var features = new Array();
$(document).ready(function(){
  $(".feature").each(function(ifeat, feature){
    var id = feature.id;
    features[id] = new Array();
    features[id].title = $("#feature_title",feature).val();
    features[id].plural = $("#feature_plural",feature).val();
  });
  $(".feature").each(function(ifeat, feature){
    var id = feature.id;
    $(".goals_list li",feature).each(function(igoal, goal){
      var view = $(".view_goal_section",goal);
      var edit = $(".edit_goal_section",goal);
      
      $(".delete_goal",view).click(function(){
        var conf = confirm( "Are you sure you want to delete this goal?" );
        if( conf ) {
          $(goal).remove();
        }
        return false;
      });
      $(".edit_goal",view).click(function(){
        $(view).toggle();
        $(edit).toggle();
        return false;
      });
      $(".save_goal",edit).click(function(){
        var textarea = $(".edit_goal_edit",edit).get(0);
        var goalv = textarea.value;
        goalv = replace_values( goalv, id );
        $(".edit_goal_text",view).html(goalv);
        $(edit).toggle();
        $(view).toggle();
        return false;
      });
    });
  });
});

function replace_values( text, id ) {
  text = text.replace( /<t(\s*?)\/>/i, features[id].title );
  text = text.replace( /<p(\s*?)\/>/i, features[id].plural );

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