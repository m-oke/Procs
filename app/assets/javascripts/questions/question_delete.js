$('#question_delete').click(function(){

    var str = $("#question_delete_attach").text().split(';')
    var str_lesson_id = str[0]
    var str_question_id = str[1]
    var str_url = "/lessons/"+str_lesson_id+"/questions/"+str_question_id
    var btn_label = $("#question_delete").text()
    var msg =""
    if(btn_label == "削除"){
        msg = "この問題を削除しますか？"
    }else{
        msg = "この問題を非公開にしますか？\n一度非公開にした場合は、再公開するにはシステム管理者に連絡する必要があります。"
    }
    if(!confirm(msg)){
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