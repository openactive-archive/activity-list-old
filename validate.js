
const Ajv = require('ajv');
const fs = require('fs');

var schemafile = "activity-list.json.schema";
var rawfile = "unvalidated_activity_list.jsonld";
var goodfile = "validated_activity_list.jsonld";

let schema = JSON.parse(fs.readFileSync(schemafile));
let data = JSON.parse(fs.readFileSync(rawfile));

var ajv = new Ajv({ allErrors: 'true', verbose: 'true' });

var validate = ajv.compile(schema);
var is_valid = validate(data);

if(is_valid){

  fs.copyFile(rawfile, goodfile, (err)=>{
    if(err) throw err;
    console.log("Validated file successfully copied");
  });

}
else{

  err_msg = "File failed validation\n=======\n"
  console.log(err_msg);
  console.log(validate.errors);
  throw new Error(err_msg)

}
