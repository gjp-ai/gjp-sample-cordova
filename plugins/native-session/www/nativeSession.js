var exec = require('cordova/exec');

exports.logout = function (success, error) {
    exec(success, error, 'NativeSession', 'logout', []);
};
