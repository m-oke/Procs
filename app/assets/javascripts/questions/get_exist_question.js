$(function(){
    $("#get_exist_question").change(function(){
        var question_id = this.value;
        window.q = this;

        $.ajax({
            url: "/ajax/questions/get_exist_question",
            type: "POST",
            data: {question_id:question_id}
        });
    });

});
