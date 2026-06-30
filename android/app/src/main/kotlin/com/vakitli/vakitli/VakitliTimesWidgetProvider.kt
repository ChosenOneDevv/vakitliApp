package com.vakitli.vakitli

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Günün tüm namaz vakitlerini listeleyen widget. */
class VakitliTimesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val nameIds = intArrayOf(
            R.id.tv_name_0, R.id.tv_name_1, R.id.tv_name_2,
            R.id.tv_name_3, R.id.tv_name_4, R.id.tv_name_5
        )
        val timeIds = intArrayOf(
            R.id.tv_time_0, R.id.tv_time_1, R.id.tv_time_2,
            R.id.tv_time_3, R.id.tv_time_4, R.id.tv_time_5
        )
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vakitli_times_widget).apply {
                setTextViewText(
                    R.id.tv_city,
                    widgetData.getString("widget_city", "") ?: ""
                )
                for (i in 0 until 6) {
                    setTextViewText(nameIds[i], widgetData.getString("w_name_$i", "") ?: "")
                    setTextViewText(timeIds[i], widgetData.getString("w_time_$i", "") ?: "")
                }
                val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, intent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
