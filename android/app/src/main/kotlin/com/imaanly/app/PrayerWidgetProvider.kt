package com.imaanly.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerWidgetProvider : AppWidgetProvider() {

  private companion object {
    const val ACTION_WIDGET_UPDATE = "es.antonborri.home_widget.action.WIDGET_UPDATE"
    const val KEY_CURRENT = "prayer_widget_current"
    const val KEY_CURRENT_TIME = "prayer_widget_current_time"
    const val KEY_NEXT = "prayer_widget_next"
    const val KEY_NEXT_TIME = "prayer_widget_next_time"
    const val KEY_LOCATION = "prayer_widget_location"
    const val KEY_URL = "prayer_url"
    const val KEY_IMAGE = "prayer_image"
  }

  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
  ) {
    val data = HomeWidgetPlugin.getData(context)

    for (widgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.prayer_widget)

      val current = data.getString(KEY_CURRENT, null)
      val currentTime = data.getString(KEY_CURRENT_TIME, null)
      val next = data.getString(KEY_NEXT, null)
      val nextTime = data.getString(KEY_NEXT_TIME, null)
      val location = data.getString(KEY_LOCATION, null)

      views.setTextViewText(R.id.prayer_widget_current, current ?: "Prayer times")
      views.setTextViewText(R.id.prayer_widget_current_time, currentTime ?: "—")
      views.setTextViewText(
        R.id.prayer_widget_next,
        if (!next.isNullOrBlank()) {
          if (nextTime.isNullOrBlank()) "Next: $next" else "Next: $next · $nextTime"
        } else {
          "Open Imaanly for today's prayer times"
        },
      )
      views.setTextViewText(R.id.prayer_widget_location, location ?: "")

      // Preserve the existing image fallback for installations that have not
      // yet received structured widget data.
      val imagePath = data.getString(KEY_IMAGE, null)
      if (current.isNullOrBlank() && !imagePath.isNullOrBlank()) {
        val bitmap = BitmapFactory.decodeFile(imagePath.removePrefix("file://"))
        if (bitmap != null) {
          views.setImageViewBitmap(R.id.prayer_image, bitmap)
        }
      }

      val prayerUrl = data.getString(KEY_URL, null)
      val launchIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        if (!prayerUrl.isNullOrBlank()) {
          data = android.net.Uri.parse(prayerUrl)
          action = Intent.ACTION_VIEW
        }
      }
      val pendingIntent = PendingIntent.getActivity(
        context,
        widgetId,
        launchIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
      views.setOnClickPendingIntent(R.id.root_prayer, pendingIntent)

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  override fun onReceive(context: Context, intent: Intent) {
    super.onReceive(context, intent)
    if (ACTION_WIDGET_UPDATE == intent.action) {
      val ids = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
      if (ids != null) {
        onUpdate(context, AppWidgetManager.getInstance(context), ids)
      }
    }
  }
}
