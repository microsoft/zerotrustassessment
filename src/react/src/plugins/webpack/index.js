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
                target: "https://localhost:7172",
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