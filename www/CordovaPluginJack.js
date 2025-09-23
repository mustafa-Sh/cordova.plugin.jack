var exec = require('cordova/exec');

var CordovaPluginJack = {
  // ----- existing (unchanged) -----
  pl5zyyMtbzNpFsQ0: function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'pl5zyyMtbzNpFsQ0', []);
  },

  ciNHTYHuzuwTN65D: function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'ciNHTYHuzuwTN65D', []);
  },

  kprfluclJoO1bQeF: function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'kprfluclJoO1bQeF', []);
  },

  // ----- new (added only) -----
  // opts example: { style: 'black' | 'blur', screenshotMaskMs: 800 }
  enable: function (successCallback, errorCallback, opts) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'enable', [opts || {}]);
  },

  disable: function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'disable', []);
  }

  addSecureRect: function (successCallback, errorCallback, opts) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'addSecureRect', [opts || {}]);
  };

  clearSecureRects: function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'CordovaPluginJack', 'clearSecureRects', []);
  };  
};

module.exports = CordovaPluginJack;
