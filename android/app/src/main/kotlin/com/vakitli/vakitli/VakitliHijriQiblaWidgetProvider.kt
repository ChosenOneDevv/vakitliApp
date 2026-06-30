package com.vakitli.vakitli

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Hicri tarih + kıble yönü gösteren widget. */
class VakitliHijriQiblaWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vakitli_hijri_qibla_widget).apply {
                setTextViewText(
                    R.id.tv_hijri,
                    widgetData.getString("w_hijri", "") ?: ""
                )
                setTextViewText(
                    R.id.tv_qibla,
                    widgetData.getString("w_qibla", "--°") ?: "--°"
                )
                val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, intent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
