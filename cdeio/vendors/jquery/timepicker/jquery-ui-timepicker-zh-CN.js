/* Chinese initialisation for the jQuery UI date picker plugin. */
/* Written by Cloudream (cloudream@gmail.com). */
jQuery(function($) {
    $.timepicker.regional['zh-CN'] = {
        timeOnlyTitle: '选择时间',
        timeText: '时间',
        hourText: '时',
        minuteText: '分',
        secondText: '秒',
        millisecText: '毫秒',
        currentText: '当前时间',
        closeText: '关闭'
    };

    $.timepicker.setDefaults($.timepicker.regional['zh-CN']);
});
