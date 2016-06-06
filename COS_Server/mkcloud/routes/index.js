var express = require('express');

var AWS = require('aws-sdk');
AWS.config.update({region: 'ap-northeast-1'});
var router = express.Router();

var fs = require("fs");                     // 파일 읽기/쓰기
var multer = require("multer");             // 파일 업로드 모듈
var upload = multer({ dest: 'upload/' });   // 파일 업로드 경로 설정
var db = new AWS.DynamoDB.DocumentClient();


var schedule = require('node-schedule');        // Node 스케줄러
var time = require('time');                     // Time

var path = process.cwd();

var logger = require(path+'/config/logger.js');        // Winston Logger

var timezone = time.currentTimeZone;        // Asia/Seoul




logger.info(timezone);


// 30초마다 한번씩 수행
var rule1 = new schedule.RecurrenceRule();
rule1.second = 30;
var scheduledJob2 = schedule.scheduleJob(rule1,
    function(){
        logger.info('30초마다 수행!!');
	console.log('30마다 수행!!');

var params = {
    TableName: "mkcloud-dynamo"
};

console.log("Scanning Movies table.");
db.scan(params, onScan);

function onScan(err, data) {
    if (err) {
        console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    } else {
        // print all the movies
        console.log("Scan succeeded.");
	data.Items.forEach(function(item) {
           console.log(item);
        });
      
        // continue scanning if we have more movies
        if (typeof data.LastEvaluatedKey != "undefined") {
            console.log("Scanning for more...");
            params.ExclusiveStartKey = data.LastEvaluatedKey;
            db.scan(params, onScan);
        }
    }
}

});


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'fileUpload Example' });
});


// upload.single('var') : var 에는 file name 을 적어주어야 한다.
router.post('/upload', upload.single('uploadFile'), function (req, res, next) {

 var user_data = JSON.parse(req.body.json);

  var userName=user_data.id;
  var due_date=user_data.date;
  var filename=user_data.image_name;

  var tmp_path = req.file.path;                                             // 원래 파일 경로
  var target_path = 'upload/' + Date.now() + "_" + filename;   // 새로 저장할 파일 경로

  //var src = fs.createReadStream(tmp_path);        // 원래 파일을 스트림으로 읽기
 // var dest = fs.createWriteStream();   // 새로 저장할 파일을 스트림으로 쓰기


 var body = fs.createReadStream(tmp_path);
 var s3obj = new AWS.S3({params: {Bucket: 'mkcloud',Key: userName+'/' +filename}});
 s3obj.upload({Body: body}).
  on('httpUploadProgress', function(evt) { console.log(evt); }).
  send(function(err, data) { 
	var params  = { TableName:'mkcloud-dynamo',
			Item:{  id:userName, url:data.Location, due_date:due_date  }};
 	 db.put(params, function(err,data) {
	 console.log('업로드성공');
	}); 
	console.log(err, data) });
 
 // src.pipe(file);                                 // Readable 스트림과 Writable 스트림을 파이프 형태로 연결

  // 연결이 끝났을 때 원래 파일 삭제
  body.on('end', function () {
    fs.unlink(tmp_path, function(err){
      if(err){
        console.log(err);
      } else{
        res.redirect('/');
      }
    });
  });

  // 에러 났을 때 에러 페이지 렌더링
  body.on('error', function (err) {
    res.render('error');
  

  }); 
});

module.exports = router;
