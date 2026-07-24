cordova.define("com.ganjianping.native-session.NativeSession", function(require, exports, module) {
var exec = require('cordova/exec');

exports.logout = function (success, error) {
    exec(success, error, 'NativeSession', 'logout', []);
};

});
