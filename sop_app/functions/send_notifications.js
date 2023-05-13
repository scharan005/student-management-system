// send_notifications.js

const admin = require("firebase-admin");
admin.initializeApp();
const functions = require("firebase-functions");

exports.sendNotification = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const message = snapshot.data();

      // Get the recipient's device token
      const recipientId = message.recipientId;
      const userSnapshot = await admin
          .firestore()
          .collection("users")
          .doc(recipientId)
          .get();
      const recipient = userSnapshot.data();
      const recipientToken = recipient.deviceToken;

      // Construct the notification message
      const payload = {
        notification: {
          title: `New message from ${message.senderName}`,
          body: message.text,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          chatId: context.params.chatId,
          messageId: context.params.messageId,
        },
      };

      // Send the notification to the recipient's device
      await admin.messaging().sendToDevice(recipientToken, payload);
    });
