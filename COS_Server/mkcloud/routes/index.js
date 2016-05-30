var express = require('express');

var AWS = require('aws-sdk');

var router = express.Router();

var fs = require("fs");                     // 파일 읽기/쓰기
var multer = require("multer");             // 파일 업로드 모듈
var upload = multer({ dest: 'upload/' });   // 파일 업로드 경로 설정
var ddb = require('dynamodb').ddb({ accessKeyId: '', secretAccessKey:'' ,region: ''});



//ddb.listTables({}, function(err, res) {console.log(res);});


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
	var item = { id:userName,destination:data.Location   };

 	 ddb.putItem('link', item, {}, function(err, res, cap) {}); 
 
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
