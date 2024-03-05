const { createProxyMiddleware } = require('http-proxy-middleware');

const context = [
    "/document",
];

module.exports = function (app) {
    const appProxy = createProxyMiddleware(context, {
        target: 'http://localhost:5269',
        secure: false
    });

    app.use(appProxy);
};
