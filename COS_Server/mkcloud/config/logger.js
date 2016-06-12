/**
 * Created by AvILoS on 7/28/15.
 */
var winston = require('winston');
var time = require('time');

aa
var logger = new winston.Logger({
    transports:[
        new winston.transports.Console({
            level:'info',
            colorize:false
        }),
        new winston.transports.DailyRotateFile({
            level:'debug',
            filename:'./log_history/app-debug',
	   maxsize:1024,
            datePattern:'yyyy-MM-ddTHH-mm.log',
            timestamp:function(){
                var timezone = time.currentTimezone; // Asia/Seoul
                var now = new time.Date();
                now.setTimezone(timezone);
                return now.toString();
            }
        })
    ]
});

module.exports = logger;
