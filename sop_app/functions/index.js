// index.js

const sendNotification = require("./send_notifications");

// Export the sendNotification function
exports.sendNotification = sendNotification;

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
