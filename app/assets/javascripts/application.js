// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery_nested_form
//= require jquery-ui
//= require lib/jquery.timepicker.js
//= require lib/jquery-ui-timepicker-addon.js
//= require_tree .
//= require_directory ./lib
//= require_directory ./user_js

$(function(){
    $('#proftab a').click(function (e) {
        $('ul.nav-tabs li.active').removeClass('active')
        $(this).parent('li').addClass('active')
    })
    $('#questions_tab').click(function (e) {
        $('#tab1').removeClass('active')
        $('#tab2').addClass('active')
    })
    $('#home_tab').click(function (e) {
        $('#tab2').removeClass('active')
        $('#tab1').addClass('active')
    })
    $('#students_tab').click(function (e) {
        $('#tab1').removeClass('active')
        $('#tab2').addClass('active')
    })
})