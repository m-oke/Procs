$('#lesson_delete').click(function(){

    var str = $("#lesson_delete_attach").text()

    var str_url = "/lessons/"+str
    if(!confirm('この授業を非公開にしますか？\n一度非公開にした場合は、再公開するにはシステム管理者に連絡する必要があります。')){
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
