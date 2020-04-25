
const Ajv = require('ajv');
const fs = require('fs');
const skos = require('@openactive/skos');

var schemafile = "activity-list.json.schema";
var rawfile = "unvalidated_activity_list.jsonld";
var goodfile = "validated_activity_list.jsonld";

let schema = JSON.parse(fs.readFileSync(schemafile));
let data = JSON.parse(fs.readFileSync(rawfile));

var ajv = new Ajv({ allErrors: 'true', verbose: 'true' });

var validate = ajv.compile(schema);
var is_valid = validate(data);

// Try to load into SKOS.js (will throw on failure)
var scheme = new skos.ConceptScheme(data);

if(is_valid){ console.log("File passed validation :-D");}
else{

  err_msg = "File failed validation\n=======\n"
  console.log(err_msg);
  console.log(validate.errors);
  throw new Error(err_msg)

}
