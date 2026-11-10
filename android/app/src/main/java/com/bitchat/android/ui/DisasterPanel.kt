package com.bitchat.android.ui

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.provider.Settings
import android.view.WindowManager
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bitchat.android.R

/**
 * imeCep disaster panel: one-tap "I'm safe", SOS (with confirmation) and
 * low-power mode. Low-power mode cannot close other apps or switch the system
 * battery saver itself (Android does not allow that); it dims this screen and
 * opens the system battery-saver page so the user can turn it on with one tap.
 */
@Composable
fun DisasterPanel(viewModel: ChatViewModel, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    var confirmSos by remember { mutableStateOf(false) }
    var lowPowerInfo by remember { mutableStateOf(false) }
    var showGuide by remember { mutableStateOf(false) }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Button(
            onClick = { viewModel.sendDisasterStatus(sos = false) },
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2F7D4F), contentColor = Color.White),
            modifier = Modifier.weight(1f)
        ) { Text(stringResource(R.string.imecep_safe_button), fontWeight = FontWeight.Bold, fontSize = 13.sp) }

        Button(
            onClick = { confirmSos = true },
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFB42318), contentColor = Color.White),
            modifier = Modifier.weight(1f)
        ) { Text(stringResource(R.string.imecep_sos_button), fontWeight = FontWeight.Bold, fontSize = 13.sp) }

        OutlinedButton(
            onClick = {
                enterLowPowerMode(context)
                lowPowerInfo = true
            },
            modifier = Modifier.weight(1f)
        ) { Text(stringResource(R.string.imecep_low_power_button), fontSize = 12.sp, maxLines = 1) }

        OutlinedButton(
            onClick = { showGuide = true },
            modifier = Modifier.weight(1f)
        ) { Text(stringResource(R.string.imecep_guide_button), fontSize = 12.sp, maxLines = 1) }
    }

    if (showGuide) {
        EmergencyGuideDialog(onDismiss = { showGuide = false })
    }

    if (confirmSos) {
        AlertDialog(
            onDismissRequest = { confirmSos = false },
            title = { Text(stringResource(R.string.imecep_sos_confirm_title)) },
            text = { Text(stringResource(R.string.imecep_sos_confirm_body)) },
            confirmButton = {
                TextButton(onClick = {
                    confirmSos = false
                    viewModel.sendDisasterStatus(sos = true)
                }) { Text(stringResource(R.string.imecep_sos_confirm_send)) }
            },
            dismissButton = {
                TextButton(onClick = { confirmSos = false }) { Text(stringResource(R.string.imecep_cancel)) }
            }
        )
    }

    if (lowPowerInfo) {
        AlertDialog(
            onDismissRequest = { lowPowerInfo = false },
            title = { Text(stringResource(R.string.imecep_low_power_title)) },
            text = { Text(stringResource(R.string.imecep_low_power_body)) },
            confirmButton = {
                TextButton(onClick = { lowPowerInfo = false }) { Text(stringResource(R.string.imecep_ok)) }
            }
        )
    }
}

private fun Context.findActivity(): Activity? {
    var c: Context? = this
    while (c is ContextWrapper) {
        if (c is Activity) return c
        c = c.baseContext
    }
    return null
}

private fun enterLowPowerMode(context: Context) {
    context.findActivity()?.window?.let { w ->
        val lp = w.attributes
        lp.screenBrightness = 0.05f
        w.attributes = lp
        w.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
    try {
        context.startActivity(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    } catch (_: Exception) {
        try {
            context.startActivity(Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (_: Exception) { }
    }
}
