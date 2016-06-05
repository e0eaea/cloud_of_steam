/**
 * Created by AvILoS on 7/28/15.
 */
var schedule = require('node-schedule');        // Node 스케줄러
var time = require('time');                     // Time

var path = process.cwd();

var logger = require(path+'/config/logger.js');        // Winston Logger

var timezone = time.currentTimeZone;        // Asia/Seoul

logger.info(timezone);


// 매시간 1분마다 한번씩 수행
var rule1 = new schedule.RecurrenceRule();
rule1.minute = 1;
var scheduledJob2 = schedule.scheduleJob(rule1,
    function(){
        logger.info('매시간 1분마다 수행!!');
	console.log('매시간 1분마다 수행!!');
    }
);


var express = require('express');

var AWS = require('aws-sdk');
AWS.config.update({region: 'ap-northeast-1'});
var router = express.Router();

var fs = require("fs");                     // 파일 읽기/쓰기
var multer = require("multer");             // 파일 업로드 모듈
var upload = multer({ dest: 'upload/' });   // 파일 업로드 경로 설정
var db = new AWS.DynamoDB.DocumentClient();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'fileUpload Example' });
});


// upload.single('var') : var 에는 file name 을 적어주어야 한다.
router.post('/upload', upload.single('uploadFile'), function (req, res, next) {
  console.log(req.body.UserData);
 var userName=req.body.UserData;
//  console.log(req.file);

  var tmp_path = req.file.path;                                             // 원래 파일 경로
  var target_path = 'upload/' + Date.now() + "_" + req.file.originalname;   // 새로 저장할 파일 경로

  //var src = fs.createReadStream(tmp_path);        // 원래 파일을 스트림으로 읽기
 // var dest = fs.createWriteStream();   // 새로 저장할 파일을 스트림으로 쓰기


 var body = fs.createReadStream(tmp_path);
 var s3obj = new AWS.S3({params: {Bucket: 'mkcloud',Key: userName+'/' +req.file.originalname}});
 s3obj.upload({Body: body}).
  on('httpUploadProgress', function(evt) { console.log(evt); }).
  send(function(err, data) { 
	var params  = { TableName:'mkcloud-dynamo',
			Item:{  id:userName, url:data.Location   }};
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
