/**
 * Created by lin on 15/07/16.
 */

$(function(){

    $(".diff_version").click(function(){
        var selected = $(this).attr("title");

        $.ajax({
            url: "answers/select_version",
            type: "POST",
            data: {selected_file:selected },
            dataType: "html",
            success: function(data) {
                alert("sucess");
            },
            error: function(data) {
                alert("errror");
            }
        });
    });



});
