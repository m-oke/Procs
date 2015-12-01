$('#lesson_delete').click(function(){

    var str = $("#lesson_delete_attach").text()

    var str_url = "/lessons/"+str
    if(!confirm('この授業を削除しますか？')){
        return false
    }else{
        $.ajax({
            url: str_url,
            type: "DELETE",
            data:{
                lesson_id:str
            }
        });
    }
})
