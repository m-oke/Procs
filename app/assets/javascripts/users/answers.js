/**
 * Created by lin on 15/07/20.
 */
/**
 * Created by lin on 15/07/16.
 */

$(function(){

    $("#diff_select").change(function(){
        var diff_selected = $("#diff_select option:selected").text()
        var path = $("#diff_select_directory").text()
        var ram_selected = $("#select_file_ram").text()

        $.ajax({
            url: "diff_select",
            type: "POST",
            data: {diff_selected_file:diff_selected ,
                ram_selected_file:ram_selected,
                diff_selected_directory:path
            }
        });
    });

});
