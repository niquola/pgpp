var Client = require('pg-native')

var client = new Client()

client.connectSync('postgres://root:root@localhost:5432/test');

module.exports = {
  execute: function(){
    return client.querySync
      .apply(client,arguments)
      .map(function(x){
        var obj = {}
        for(k in x){
          obj[k] = JSON.stringify(x[k])
        }
        return obj;
      });
  },
  elog: function(x, msg){
    console.log(msg)
  }
}

