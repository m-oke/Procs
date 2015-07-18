/**
 * Created by lin on 15/07/16.
 */

$(function(){

    $("#diff_select").change(function(){
        var selected = $("#diff_select option:selected").text()
        var path = $("#diff_select_directory").text()
        $.ajax({
            url: "answers/diff_select",
            type: "GET",
            data: {diff_selected_file:selected ,
                   diff_selected_directory:path
            },
            dataType: "html",
            success: function(data) {
                $('#diff_area').html(
                    data
                );
            },
            error: function(data) {

            }
        });
    });



});
