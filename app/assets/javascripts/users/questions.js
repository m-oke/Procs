/**
 * Created by lin on 15/07/12.
 */

$(function(){
    var startDateTextBox = $('.datepicker1');
    var endDateTextBox = $('.datepicker2');
    var op = {
        closeText: '閉じる',
        currentText: '現在日時',
        timeOnlyTitle: '日時を選択',
        timeText: '時間',
        hourText: '時',
        minuteText: '分',
        secondText: '秒',
        millisecText: 'ミリ秒',
        microsecText: 'マイクロ秒',
        timezoneText: 'タイムゾーン',
        prevText: '&#x3c;前',
        nextText: '次&#x3e;',
        monthNames: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
        monthNamesShort: ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
        dayNames: ['日曜日','月曜日','火曜日','水曜日','木曜日','金曜日','土曜日'],
        dayNamesShort: ['日','月','火','水','木','金','土'],
        dayNamesMin: ['日','月','火','水','木','金','土'],
        weekHeader: '週',
        yearSuffix: '年',
        dateFormat: 'yy-mm-dd',
        timeFormat: 'HH:mm:ss'
    };
    var event1= {
        onClose: function(dateText, inst) {
            if (endDateTextBox.val() != '') {
                var testStartDate = startDateTextBox.datetimepicker('getDate');
                var testEndDate = endDateTextBox.datetimepicker('getDate');
                if (testStartDate > testEndDate)
                    endDateTextBox.datetimepicker('setDate', testStartDate);
            }
            else {
                endDateTextBox.val(dateText);
            }
        },
        onSelect: function (selectedDateTime){
            endDateTextBox.datetimepicker('option', 'minDate', startDateTextBox.datetimepicker('getDate') );
        }
    };
    var event2 = {
        onClose: function(dateText, inst) {
            if (startDateTextBox.val() != '') {
                var testStartDate = startDateTextBox.datetimepicker('getDate');
                var testEndDate = endDateTextBox.datetimepicker('getDate');
                if (testStartDate > testEndDate)
                    startDateTextBox.datetimepicker('setDate', testEndDate);
            }
            else {
                startDateTextBox.val(dateText);
            }
        },
        onSelect: function (selectedDateTime){
            startDateTextBox.datetimepicker('option', 'maxDate', endDateTextBox.datetimepicker('getDate') );
        }
    };
    var new_event1 =$.extend({},op,event1);
    var new_evnet2 = $.extend({},op,event2);
    $('.datepicker1').datetimepicker(new_event1);
    $('.datepicker2').datetimepicker(new_evnet2);

});

