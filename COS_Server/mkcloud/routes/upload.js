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
  console.log("upload page");
  res.render('index', { title: 'fileUpload Example' });
});


// upload.single('var') : var 에는 file name 을 적어주어야 한다.
router.post('/picture', upload.single('uploadFile'), function (req, res, next) {

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
			Item:{  id:userName, url:userName+'/' +filename, due_date:due_date  }};
 	 
   var resObj = {
          server_url: userName+'/' +filename ,
          status: "success"
        };

   db.put(params, function(err,data) {
   console.log('업로드성공');
   
        console.log("리스폰스 보냄");
        res.end(JSON.stringify(resObj));
	});
	console.log(err, data) });

 // src.pipe(file);                                 // Readable 스트림과 Writable 스트림을 파이프 형태로 연결

  // 연결이 끝났을 때 원래 파일 삭제
  body.on('end', function () {
    fs.unlink(tmp_path, function(err){
      if(err){
        console.log(err);
      } else{
        
      }
    });
  });

  // 에러 났을 때 에러 페이지 렌더링
  body.on('error', function (err) {
    res.render('error');


  });
});


// upload.single('var') : var 에는 file name 을 적어주어야 한다.
router.post('/aa', upload.single('uploadFile'), function (req, res, next) {

  var userName=req.body.keyName.id;
  var due_date=req.body.keyName.date;
  var filename=req.body.keyName.image_name;

  console.log();

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
      Item:{  id:userName, url:userName+'/' +filename, due_date:due_date  }};

      var resObj = {
          server_url: userName+'/' +filename,
          status: "success"
        };

   db.put(params, function(err,data) {
   console.log('업로드성공');
   
        console.log("리스폰스 보냄");
        res.writeHead(200);
        res.end(JSON.stringify(resObj));

  });
  console.log(err, data) });

 // src.pipe(file);                                 // Readable 스트림과 Writable 스트림을 파이프 형태로 연결

  // 연결이 끝났을 때 원래 파일 삭제
  body.on('end', function () {
    fs.unlink(tmp_path, function(err){
      if(err){
        console.log(err);
      } else{
          console.log("리쿼스트 받아옴");
       }
    });
  });

  // 에러 났을 때 에러 페이지 렌더링
  body.on('error', function (err) {
    res.render('error');
  });

});

module.exports = router;
