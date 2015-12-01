/**
 * Created by lin on 15/07/13.
 */
$(document).on('nested:fieldRemoved', function(event){
    var field = event.field;
    var parent = field.parent();
    var id = parent[0].id;
    document.field = field;

    if($('#' + id).find('.fields').length != 1){
        field.find('input').attr({required: false});
        field.find('textarea').attr({required: false});
    } else {
        field.css("display", "");
    }
});
