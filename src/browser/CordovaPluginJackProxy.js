module.exports = {
    kprfluclJoO1bQeF: function (successCallback, errorCallback) {
        try {
            const result = {
                "1": "TTlQVWE2Xy1VdkRzd21KJA==",  
                "2": "OS9tckZ4LCZOc1ovWDl6TA=="
            };
            successCallback(result);
        } catch (error) {
            errorCallback(error.message);
        }
    }
};

// Register the browser proxy
require('cordova/exec/proxy').add('CordovaPluginJack', module.exports);