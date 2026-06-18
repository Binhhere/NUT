package com.binhhere.nut

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.streak_widget).apply {
                val streakCount = widgetData.getInt("streak_count", 0)
                setTextViewText(R.id.streak_text, streakCount.toString())
                setTextViewText(R.id.label_text, if (streakCount == 1) "DAY CLEAN" else "DAYS CLEAN")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
