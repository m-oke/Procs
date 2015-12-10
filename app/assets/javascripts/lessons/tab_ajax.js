$(function(){
    $('#proftab a').click(function (e) {
        $('ul.nav-tabs li.active').removeClass('active')
        $(this).parent('li').addClass('active')
    })
    $('#questions_tab').click(function (e) {
        $('#tab1').removeClass('active')
        $('#tab3').removeClass('active')
        $('#tab2').addClass('active')
    })
    $('#home_tab').click(function (e) {
        $('#tab2').removeClass('active')
        $('#tab3').removeClass('active')
        $('#tab1').addClass('active')
    })
    $('#students_tab').click(function (e) {
        $('#tab1').removeClass('active')
        $('#tab2').removeClass('active')
        $('#tab3').addClass('active')
    })

})

