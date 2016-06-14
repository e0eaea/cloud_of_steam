
var express = require('express');
var router = express.Router();
var schedule = require('node-schedule');        // Node 스케줄러
var time = require('time');                     // Time
var path = process.cwd();
var logger = require(path+'/config/logger.js');        // Winston Logger

var AWS = require('aws-sdk');
AWS.config.update({region: 'ap-northeast-1'});
var db = new AWS.DynamoDB.DocumentClient();
var s3 = new AWS.S3();

// 30초마다 한번씩 수행
var rule1 = new schedule.RecurrenceRule();
rule1.seconds = 00;
var scheduledJob2 = schedule.scheduleJob(rule1,
    function(){
        console.log('00마다 수행!!');
    var timezone = time.currentTimezone; // Asia/Seoul
    
    var offset = 9;
    var now = new time.Date(new Date().getTime() + offset * 3600 * 1000).toISOString().replace(/T/, ' ').replace(/\..+/, '');    // delete the dot and everything after
    var now_time=now.toString();
    console.log(now.toString());

    var params = {
        TableName: "mkcloud-dynamo",
        FilterExpression: "due_date between :start_date and :end_date",
        ExpressionAttributeValues: {
         ":start_date": "*",
         ":end_date": now_time
     }
 };

 console.log("Scanning all table.");


 db.scan(params,onScan);

 function onScan(err, data) {
    var delete_arr=new Array();

    
    if (err) {
        console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    } else {
        // print all the movies
        console.log("Scan succeeded.");
        data.Items.forEach(function(item) {

            var delete_obj=new Object();
            delete_obj.id=item.id;
            delete_obj.url=item.url;
            delete_arr.push(delete_obj);


        });


        // continue scanning if we have more movies
        if (typeof data.LastEvaluatedKey != "undefined") {
            console.log("Scanning for more...");
            params.ExclusiveStartKey = data.LastEvaluatedKey;
            db.scan(params, onScan);
        }
    }

  //그냥 여기 넣자!

  for (var i=0; i<delete_arr.length; i++)
  {
    var obj=delete_arr[i];
    console.log("삭제하려는 거"+obj);

    var delete_params = {
        TableName:"mkcloud-dynamo",
        Key:{
            "id":obj.id,
            "url":obj.url
        }      
    }


    console.log("Attempting a conditional delete...");
    db.delete(delete_params, function(err, data) {
        if (err) {
            console.error("Unable to delete item. Error JSON:", JSON.stringify(err, null, 2));
        } else {
            console.log("DeleteItem succeeded:", JSON.stringify(data, null, 2));
        }
    });



    var delete_s3_param = {
      Bucket: 'mkcloud', 
      Key: obj.url
    };
    
    s3.deleteObject(delete_s3_param, function(err, data) {
                if (err) console.log(err, err.stack);
                else console.log('delete', data);
            });



}

}

});


router.post('/delete', function(req, res, next) {

  var id=req.body.id;
  var url=req.body.url;

 console.log("delete dynamo,s3");
  console.log(req.body);

  var delete_params = {
        TableName:"mkcloud-dynamo",
        Key:{
            "id":id,
            "url":url
        }      
    }


    console.log("Attempting a conditional delete...");


    db.delete(delete_params, function(err, data) {
        if (err) {
            console.error("Unable to delete item. Error JSON:", JSON.stringify(err, null, 2));
        } else {
            console.log("DeleteItem succeeded:", JSON.stringify(data, null, 2));
        }
    });



    var delete_s3_param = {
      Bucket: 'mkcloud', 
      Key: url
    };
    
    s3.deleteObject(delete_s3_param, function(err, data) {
                if (err) console.log(err, err.stack);
                else console.log('delete', data);
            });

});









module.exports = router;
