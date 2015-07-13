/**
 * Created by lin on 15/07/13.
 */
$(document).on('nested:fieldRemoved', function(event){
    var field = event.field;
    field.remove();
});