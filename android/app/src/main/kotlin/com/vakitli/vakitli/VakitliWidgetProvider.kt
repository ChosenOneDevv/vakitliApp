package com.vakitli.vakitli

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class VakitliWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vakitli_widget).apply {
                setTextViewText(
                    R.id.tv_prayer,
                    widgetData.getString("widget_next_name", "Sonraki Vakit") ?: "Sonraki Vakit"
                )
                setTextViewText(
                    R.id.tv_time,
                    widgetData.getString("widget_next_time", "--:--") ?: "--:--"
                )
                setTextViewText(
                    R.id.tv_remaining,
                    widgetData.getString("widget_remaining", "") ?: ""
                )
                setTextViewText(
                    R.id.tv_city,
                    widgetData.getString("widget_city", "") ?: ""
                )

                // Tıklayınca uygulamayı aç.
                val intent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, intent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
