const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.sendTaskReminders = onSchedule(
  {
    schedule: 'every 5 minutes',
    timeZone: 'Etc/UTC',
  },
  async () => {
    const db = getFirestore();
    const messaging = getMessaging();
    const now = new Date();
    const windowEnd = new Date(now.getTime() + 30 * 60 * 1000);

    const remindersSnapshot = await db
      .collectionGroup('reminders')
      .where('sent', '==', false)
      .where('notifyAt', '>=', now)
      .where('notifyAt', '<=', windowEnd)
      .get();

    if (remindersSnapshot.empty) {
      return null;
    }

    for (const doc of remindersSnapshot.docs) {
      const data = doc.data();
      const tokensSnapshot = await db
        .collection('user_tokens')
        .doc(data.userId)
        .collection('tokens')
        .get();

      const tokens = tokensSnapshot.docs.map((t) => t.id);
      if (!tokens.length) {
        await doc.ref.update({
          sent: true,
          sentAt: FieldValue.serverTimestamp(),
        });
        continue;
      }

      const title = data.title ?? 'One of your tasks';
      const message = {
        notification: {
          title: 'Task reminder',
          body: title + ' is due soon.',
        },
        data: {
          taskId: data.taskId ?? '',
          route: '/notifications',
        },
        tokens,
      };

      await messaging.sendEachForMulticast(message);

      const repeatInterval = data.repeatIntervalMinutes;
      const dueTs = data.dueDate;
      const notifyTs = data.notifyAt;
      const hasRepeat = typeof repeatInterval === 'number' && repeatInterval > 0 && dueTs && notifyTs;

      if (hasRepeat) {
        const dueDate = dueTs.toDate ? dueTs.toDate() : new Date(dueTs);
        const currentNotifyAt = notifyTs.toDate ? notifyTs.toDate() : new Date(notifyTs);
        const nextCandidate = new Date(currentNotifyAt.getTime() + repeatInterval * 60 * 1000);

        if (nextCandidate <= dueDate) {
          await doc.ref.update({
            notifyAt: nextCandidate,
            updatedAt: FieldValue.serverTimestamp(),
          });
          continue;
        }

        if (currentNotifyAt < dueDate) {
          await doc.ref.update({
            notifyAt: dueDate,
            updatedAt: FieldValue.serverTimestamp(),
          });
          continue;
        }
      }

      await doc.ref.update({
        sent: true,
        sentAt: FieldValue.serverTimestamp(),
      });
    }

    return null;
  }
);

exports.onNotificationCreated = onDocumentCreated(
  'notifications/{userId}/messages/{messageId}',
  async (event) => {
    const db = getFirestore();
    const messaging = getMessaging();
    const { userId } = event.params;
    const data = event.data?.data();
    if (!data) return null;

    const tokensSnapshot = await db
      .collection('user_tokens')
      .doc(userId)
      .collection('tokens')
      .get();

    const tokens = tokensSnapshot.docs.map((t) => t.id);
    if (!tokens.length) {
      return null;
    }

    const message = {
      notification: {
        title: data.title || 'Update',
        body: data.body || '',
      },
      data: {
        route: data.route || '/notifications',
        taskId: data.taskId || '',
      },
      tokens,
    };

    return messaging.sendEachForMulticast(message);
  }
);
