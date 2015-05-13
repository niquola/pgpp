var Client = require('pg-native')

var client = new Client()

client.connectSync('postgres://root:root@localhost:5432/fhirbase');

module.exports = {
  execute: function(q){
    return client.querySync(q);
  }
}

