$('#question_delete').click(function(){

    var str = $("#question_delete_attach").text().split(';')
    var str_lesson_id = str[0]
    var str_question_id = str[1]
    var str_url = "/lessons/"+str_lesson_id+"/questions/"+str_question_id
    if(!confirm('この問題を削除しますか？')){
        return false
    }else{
        $.ajax({
            url: str_url,
            type: "DELETE",
            data:{
                lesson_id:str_lesson_id,
                question_id:str_question_id
            }
        });
    }
})