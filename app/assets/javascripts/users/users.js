$(function () {
  $('[data-toggle="tooltip"]').popover();
})

var url = document.location.toString();
if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
    console.log(url);
    console.log("activate");
}

$('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
    console.log(e.target.hash);
})
