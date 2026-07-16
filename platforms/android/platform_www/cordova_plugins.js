cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "com.ganjianping.native-session.NativeSession",
      "file": "plugins/com.ganjianping.native-session/www/nativeSession.js",
      "pluginId": "com.ganjianping.native-session",
      "clobbers": [
        "NativeSession"
      ]
    }
  ];
  module.exports.metadata = {
    "com.ganjianping.native-session": "1.0.0"
  };
});