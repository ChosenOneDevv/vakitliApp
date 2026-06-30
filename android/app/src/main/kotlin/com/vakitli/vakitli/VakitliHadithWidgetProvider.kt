package com.vakitli.vakitli

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Günün hadisini gösteren widget. */
class VakitliHadithWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vakitli_hadith_widget).apply {
                setTextViewText(
                    R.id.tv_hadith,
                    widgetData.getString("w_hadith_text", "") ?: ""
                )
                setTextViewText(
                    R.id.tv_source,
                    widgetData.getString("w_hadith_source", "") ?: ""
                )
                val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, intent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
