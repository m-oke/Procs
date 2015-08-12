/**
 * Created by lin on 15/07/13.
 */
$(document).on('nested:fieldRemoved', function(event){
    var field = event.field;
    var parent = field.parent();
    var id = parent[0].id;
    console.log($('#' + id).find('.fields'));
    console.log($('#' + id).find('.fields').length);
    console.log($('#' + id).find('.fields').length == 1);
    if($('#' + id).find('.fields').length != 1){
        field.remove();
    } else {
        field.css("display", "");
    }
});
