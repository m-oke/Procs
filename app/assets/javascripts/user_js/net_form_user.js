$(document).on('nested:fieldRemoved', function(event){
    var field = event.field;
    field.remove();
});