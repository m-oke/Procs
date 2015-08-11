$(function(){

    $("#diff_select").change(function(){
        var diff_selected = $("#diff_select option:selected").text()
        var path = $("#diff_select_directory").text()
        var raw_selected = $("#select_file_raw").text()

        $.ajax({
            url: "/ajax/answers/diff_select",
            type: "GET",
            data: {diff_selected_file:diff_selected ,
                raw_selected_file:raw_selected,
                diff_selected_directory:path
            }
        });
    });

});
