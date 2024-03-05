// plugins/webpack/index.js
module.exports = function (context, options) {
    return {
      name: "custom-webpack-plugin",
      configureWebpack(config, isServer, utils) {
        return {
          mergeStrategy: { "devServer.proxy": "replace" },
          devServer: {
            proxy: {
              "/document": {
                target: "http://localhost:5269",
                secure: false,
                changeOrigin: true,
                logLevel: "debug",
              },
            },
          },
        };
      },
    };
  };