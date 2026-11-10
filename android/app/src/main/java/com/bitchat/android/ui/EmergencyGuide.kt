package com.bitchat.android.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import java.util.Locale

/**
 * imeCep emergency guide. Static, offline content (no model, no network):
 * every card is a short checklist. Content is bilingual (TR / EN) and picks
 * the language from the device locale (Turkish if the device language is
 * Turkish, English otherwise).
 */
private data class GuideCard(
    val emoji: String,
    val color: Color,
    val title: Pair<String, String>,
    val steps: List<Pair<String, String>>
)

private val guideCards: List<GuideCard> = listOf(
    GuideCard(
        "🌍", Color(0xFFB54708),
        "Deprem sırasında" to "During an earthquake",
        listOf(
            "ÇÖK, KAPAN, TUTUN: yere çök, başını ve boynunu kolunla koru, sağlam bir masanın altına gir ya da iç duvara yaslan." to
                "DROP, COVER, HOLD ON: get down, protect your head and neck, get under a sturdy table or against an interior wall.",
            "Pencere, ayna ve devrilebilecek dolaplardan uzak dur." to "Stay away from windows, mirrors and furniture that can fall.",
            "Sarsıntı sürerken koşma, merdivene ya da asansöre yönelme." to "Do not run or use stairs or elevators while shaking continues.",
            "Dışarıdaysan binalardan, direklerden ve kablolardan uzak, açık bir yere git." to
                "If outside, move to an open area away from buildings, poles and wires."
        )
    ),
    GuideCard(
        "🧱", Color(0xFF7A271A),
        "Enkaz altındaysan" to "If you are trapped",
        listOf(
            "Sakin kal. Bağırmak yerine enerjini sakla; bağırma yalnızca ses duyduğunda, kısa kısa." to
                "Stay calm. Save your energy; shout only in short bursts when you hear rescuers.",
            "Ağzını ve burnunu kumaşla kapat; toz solumayı azaltır." to "Cover your mouth and nose with cloth to reduce dust.",
            "Çakmak, kibrit yakma: gaz kaçağı olabilir." to "Do not light a lighter or match: there may be a gas leak.",
            "Boruya ya da duvara düzenli aralıklarla vur; düdüğün varsa çal. Ses, bağırmaktan daha uzağa gider." to
                "Tap steadily on a pipe or wall; blow a whistle if you have one. Tapping carries farther than shouting.",
            "Telefonun ekranını kıs, imeCep'te Bluetooth açık kalsın, kısa mesaj ve SOS gönder." to
                "Dim your screen, keep Bluetooth on in imeCep, send short messages and SOS."
        )
    ),
    GuideCard(
        "🔋", Color(0xFF2F7D4F),
        "Pil tasarrufu" to "Save battery",
        listOf(
            "Ekran parlaklığını en aza indir, ekranı kapat; gerektiğinde aç." to "Set brightness to minimum and turn the screen off when idle.",
            "Pil Tasarrufu / Düşük Güç modunu aç." to "Turn on Battery Saver / Low Power Mode.",
            "Mobil veri, Wi-Fi ve konumu kapat. Bluetooth'u AÇIK bırak: imeCep onunla çalışır." to
                "Turn off mobile data, Wi-Fi and location. Keep Bluetooth ON: imeCep needs it.",
            "Bildirimleri, titreşimi, arka planda yenilemeyi ve kullanmadığın uygulamaları kapat." to
                "Turn off notifications, vibration, background refresh and unused apps.",
            "Fotoğraf, video ve uzun ses gönderme; kısa metin pil harcamaz." to "Avoid photos, video and long audio; short text uses little power.",
            "Soğukta pil hızlı biter: telefonu vücudunun yakınında, cebinde sıcak tut." to
                "Batteries drain fast in the cold: keep the phone warm close to your body."
        )
    ),
    GuideCard(
        "💧", Color(0xFF175CD3),
        "Su ve yiyecek" to "Water and food",
        listOf(
            "Kişi başı günde yaklaşık 3 litre su hesapla; yudum yudum iç." to "Plan about 3 liters of water per person per day; sip slowly.",
            "Güvenli olmayan suyu en az 1 dakika kaynat; bulanıksa önce temiz bezden süz." to
                "Boil unsafe water for at least 1 minute; if cloudy, filter it through clean cloth first.",
            "Önce bozulabilecek yiyecekleri tüket, konservelere en son dokun." to "Eat perishable food first; keep canned food for later.",
            "Deniz suyu ve alkol içme." to "Do not drink sea water or alcohol."
        )
    ),
    GuideCard(
        "🩹", Color(0xFFB42318),
        "Temel ilk yardım" to "Basic first aid",
        listOf(
            "Önce kendi güvenliğini ve çevreyi kontrol et, sonra yardıma git. Mümkünse 112'yi ara." to
                "Check your own safety first, then help. Call 112 if you can.",
            "Kanama: temiz bezle yarayı doğrudan ve sıkıca bastır; bezi kaldırma, üstüne ekle." to
                "Bleeding: press firmly directly on the wound with clean cloth; do not lift it, add more on top.",
            "Yanık: 10-20 dakika akan serin suyla soğut; buz, yağ ya da diş macunu sürme." to
                "Burns: cool with running cool water for 10-20 minutes; no ice, oil or toothpaste.",
            "Kırık şüphesi: yaralıyı gereksiz oynatma, kırık bölgeyi olduğu gibi destekle." to
                "Suspected fracture: avoid moving the person, support the injured area as it is.",
            "Bilinci kapalı ve nefes yoksa: 112'yi ara, göğüs ortasına sert ve hızlı bas (dakikada yaklaşık 100-120)." to
                "Unresponsive and not breathing: call 112, push hard and fast on the center of the chest (about 100-120 per minute)."
        )
    ),
    GuideCard(
        "🔥", Color(0xFFC4320A),
        "Yangın ve duman" to "Fire and smoke",
        listOf(
            "Alçak ol, ıslak bezle ağzını ve burnunu kapat." to "Stay low and cover your nose and mouth with a wet cloth.",
            "Kapı sıcaksa açma; başka çıkış ara." to "If a door is hot, do not open it; find another exit.",
            "Asansör kullanma, merdivenle çık." to "Do not use elevators; use stairs.",
            "Kıyafetin tutuşursa dur, yere uzan, yuvarlan." to "If clothes catch fire: stop, drop, and roll."
        )
    ),
    GuideCard(
        "🌊", Color(0xFF1570EF),
        "Sel" to "Flood",
        listOf(
            "Yüksek bir yere çık; akan suya girme, araçla geçmeye çalışma." to "Move to higher ground; do not walk or drive through moving water.",
            "Elektriği ve gazı biliyorsan kapat; ıslak elle elektrik aletine dokunma." to "Switch off power and gas if you can; never touch electrics with wet hands.",
            "Sel suyuyla temas eden suyu ve yiyeceği kullanma." to "Do not use water or food that touched flood water."
        )
    ),
    GuideCard(
        "❄️", Color(0xFF3E4C9A),
        "Soğuk ve sıcak" to "Cold and heat",
        listOf(
            "Soğukta kat kat giyin, ıslak giysiyi hemen değiştir, yerle teması battaniye ya da kartonla kes." to
                "In the cold, layer clothes, change wet clothes quickly, insulate yourself from the ground.",
            "Alkol alma; ısındırdığını sanırsın ama ısı kaybını artırır." to "Avoid alcohol; it increases heat loss.",
            "Sıcakta gölgede kal, az az ve sık su iç, açık renk bol giyin." to "In heat, stay in shade, drink small sips often, wear light loose clothing."
        )
    ),
    GuideCard(
        "📣", Color(0xFF6938EF),
        "Yardım çağırma" to "Calling for help",
        listOf(
            "İmkan varsa 112'yi ara; şebeke yoksa imeCep'ten \"SOS\" gönder. Yakınındaki imeCep kullanıcılarına ulaşır." to
                "Call 112 if you can; with no network, send \"SOS\" in imeCep. It reaches nearby imeCep users.",
            "Düdük: art arda 3 kısa çalış. Işık ya da ayna ile 3 kez işaret ver." to "Whistle: 3 short blasts. Signal with a light or mirror 3 times.",
            "Bulunduğun yeri ve kaç kişi olduğunu, yaralı durumunu kısa yaz." to "Write your location, number of people and any injuries, briefly.",
            "Güvendeysen \"Güvendeyim\" düğmesine bas; yakınların bilsin." to "If you are safe, press \"I'm safe\" so others know."
        )
    ),
    GuideCard(
        "🏠", Color(0xFF027A48),
        "Önceden hazırlan" to "Prepare ahead",
        listOf(
            "Aile ile buluşma noktası belirle (ev yakını ve şehir dışı)." to "Agree on a family meeting point (near home and out of town).",
            "Çanta: su, konserve, ilk yardım, düdük, el feneri, yedek pil/powerbank, ilaçlar, belgelerin kopyası." to
                "Go-bag: water, canned food, first aid, whistle, flashlight, power bank, medicines, copies of documents.",
            "Gaz, elektrik ve su vanalarının yerini öğren." to
                "Learn where your gas, electricity and water shut-offs are."
        )
    )
)

private fun isTurkish(): Boolean = Locale.getDefault().language.lowercase(Locale.ROOT) == "tr"

@Composable
fun EmergencyGuideDialog(onDismiss: () -> Unit) {
    val tr = remember { isTurkish() }
    var open by remember { mutableStateOf<Int?>(null) }
    val colorScheme = MaterialTheme.colorScheme

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(modifier = Modifier.fillMaxSize(), color = colorScheme.background) {
            Column(modifier = Modifier.fillMaxSize()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = if (tr) "Acil Durum Rehberi" else "Emergency Guide",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = colorScheme.onBackground
                    )
                    TextButton(onClick = onDismiss) { Text(if (tr) "Kapat" else "Close") }
                }
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    item {
                        Surface(
                            color = Color(0xFFB42318).copy(alpha = 0.12f),
                            shape = RoundedCornerShape(14.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = if (tr)
                                    "Hayati tehlikede önce 112'yi arayın. Bu rehber çevrimdışı çalışır ve resmî acil yardımın ya da sağlık profesyonelinin yerine geçmez."
                                else
                                    "In danger to life, call 112 first. This guide works offline and does not replace official emergency services or medical professionals.",
                                fontSize = 13.sp,
                                color = colorScheme.onBackground,
                                modifier = Modifier.padding(14.dp)
                            )
                        }
                    }
                    items(guideCards.size) { index ->
                        val card = guideCards[index]
                        val expanded = open == index
                        Surface(
                            color = colorScheme.surface,
                            shape = RoundedCornerShape(16.dp),
                            border = BorderStroke(1.dp, card.color.copy(alpha = 0.35f)),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { open = if (expanded) null else index }
                        ) {
                            Column(modifier = Modifier.padding(14.dp)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Box(
                                        modifier = Modifier
                                            .size(44.dp)
                                            .background(card.color.copy(alpha = 0.16f), CircleShape),
                                        contentAlignment = Alignment.Center
                                    ) { Text(card.emoji, fontSize = 22.sp) }
                                    Spacer(Modifier.size(12.dp))
                                    Text(
                                        text = if (tr) card.title.first else card.title.second,
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        color = colorScheme.onSurface,
                                        modifier = Modifier.weight(1f)
                                    )
                                    Text(if (expanded) "−" else "+", fontSize = 20.sp, color = card.color)
                                }
                                if (expanded) {
                                    Spacer(Modifier.height(10.dp))
                                    card.steps.forEachIndexed { i, step ->
                                        Row(modifier = Modifier.padding(vertical = 4.dp)) {
                                            Box(
                                                modifier = Modifier
                                                    .size(22.dp)
                                                    .background(card.color, CircleShape),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Text("${i + 1}", fontSize = 12.sp, color = Color.White, fontWeight = FontWeight.Bold)
                                            }
                                            Spacer(Modifier.size(10.dp))
                                            Text(
                                                text = if (tr) step.first else step.second,
                                                fontSize = 14.sp,
                                                color = colorScheme.onSurface
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    item { Spacer(Modifier.height(24.dp)) }
                }
            }
        }
    }
}
