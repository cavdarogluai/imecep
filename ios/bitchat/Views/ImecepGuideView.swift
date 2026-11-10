//
// ImecepGuideView.swift
// imeCep — offline emergency guide (earthquake, trapped, fire, flood, first aid,
// water/food, battery saving). Static, curated, bilingual TR/EN; no network, no AI.
// General guidance only: it never replaces 112 / professional help.
//

import SwiftUI

private struct GuideStep: Identifiable {
    let id = UUID()
    let icon: String
    let tr: String
    let en: String
}

private struct GuideTopic: Identifiable {
    let id: String
    let icon: String
    let color: Color
    let titleTR: String
    let titleEN: String
    let steps: [GuideStep]
    @MainActor var title: String { ImecepDisaster.t(titleTR, titleEN) }
}

private enum GuideContent {
    static func s(_ icon: String, _ tr: String, _ en: String) -> GuideStep { GuideStep(icon: icon, tr: tr, en: en) }

    static let topics: [GuideTopic] = [
        GuideTopic(id: "quake", icon: "waveform.path.ecg", color: .orange, titleTR: "Deprem", titleEN: "Earthquake", steps: [
            s("arrow.down.to.line", "ÇÖK: Hemen yere çök.", "DROP: get down on hands and knees."),
            s("shield.lefthalf.filled", "KAPAN: Başını ve boynunu kolunla koru; sağlam bir masa/sıra altına gir ya da iç duvar dibinde kapan.", "COVER: protect head and neck; get under a sturdy table or beside an inside wall."),
            s("hand.raised.fill", "TUTUN: Sarsıntı bitene kadar yerinde kal, tutunduğun nesneyi bırakma.", "HOLD ON: stay put until shaking stops."),
            s("window.vertical.closed", "Cam, ayna, devrilebilecek dolap ve pencerelerden uzak dur.", "Stay away from glass, mirrors, tall furniture and windows."),
            s("figure.walk", "Sarsıntı bitince: ayakkabı giy, doğal gaz/elektriği kapat, merdivenle çık; asansör kullanma.", "After it stops: put on shoes, shut off gas/power, use stairs, never elevators."),
            s("building.2", "Açık alanda toplan; binalardan, kablolardan ve duvarlardan uzak dur. Artçılara hazır ol.", "Gather in the open away from buildings and wires. Expect aftershocks."),
        ]),
        GuideTopic(id: "trapped", icon: "exclamationmark.triangle.fill", color: .red, titleTR: "Enkaz altında", titleEN: "Trapped", steps: [
            s("lungs.fill", "Sakin kal, yavaş nefes al. Toz için ağzını ve burnunu kumaşla kapat.", "Stay calm, breathe slowly. Cover mouth and nose with cloth against dust."),
            s("flame.fill", "Kibrit/çakmak yakma: gaz kaçağı olabilir.", "Do not light matches or lighters: gas may be leaking."),
            s("hand.tap.fill", "Boru veya duvara düzenli vur; bağırmak yerine ıslık çal. Enerjini koru.", "Tap pipes or walls steadily; use a whistle instead of shouting."),
            s("iphone.radiowaves.left.and.right", "Telefonun varsa imeCep'ten SOS gönder (yakındaki telefonlar tekrar yayar) ve ekranı kıs.", "If you have a phone, send SOS in imeCep (nearby phones relay it) and dim the screen."),
            s("drop.fill", "Suyu az az iç; hareket edebiliyorsan kendini daha fazla göçüğe sokma.", "Ration water; avoid moving debris that could collapse further."),
        ]),
        GuideTopic(id: "fire", icon: "flame.fill", color: .red, titleTR: "Yangın", titleEN: "Fire", steps: [
            s("bell.fill", "Herkesi uyar, binayı hemen terk et. Eşya toplamak için geri dönme.", "Alert everyone and leave immediately. Do not go back for belongings."),
            s("arrow.down.to.line", "Duman varsa yere yakın, eğilerek ilerle; ağzını ıslak bezle kapat.", "In smoke stay low; cover mouth with a damp cloth."),
            s("hand.point.up.left.fill", "Kapıyı açmadan önce elinin tersiyle sıcaklığı dene; sıcaksa açma.", "Check a door with the back of your hand; if hot, do not open it."),
            s("figure.stairs", "Asansör kullanma, merdivenleri kullan.", "Use stairs, never elevators."),
            s("figure.fall", "Kıyafetin tutuşursa: dur, yere yat, yuvarlan.", "If clothes catch fire: stop, drop, roll."),
            s("phone.fill", "Güvenli yerde 112'yi ara.", "Call 112 from a safe place."),
        ]),
        GuideTopic(id: "flood", icon: "cloud.heavyrain.fill", color: .blue, titleTR: "Sel", titleEN: "Flood", steps: [
            s("arrow.up.to.line", "Yüksek yere çık; sel sularında yürüme ya da araç sürme.", "Move to higher ground; never walk or drive through flood water."),
            s("bolt.slash.fill", "Elektriği kapat; ıslakken elektrikli aletlere dokunma.", "Cut power; do not touch electrical items when wet."),
            s("drop.triangle.fill", "Sel suyunu içme; temiz suyu sakla.", "Do not drink flood water; store clean water."),
            s("antenna.radiowaves.left.and.right", "Resmi uyarıları (AFAD, 112) dinle.", "Follow official warnings (AFAD, 112)."),
        ]),
        GuideTopic(id: "firstaid", icon: "cross.case.fill", color: .pink, titleTR: "İlk yardım (temel)", titleEN: "First aid (basics)", steps: [
            s("eye.fill", "Önce ortam güvenli mi bak; kendini tehlikeye atma.", "Check the scene is safe first; do not put yourself at risk."),
            s("phone.fill", "Mümkünse 112'yi ara ve tarif ettiklerini uygula.", "Call 112 if you can and follow their instructions."),
            s("hand.raised.square.fill", "Kanama: temiz bezle doğrudan ve sıkı baskı uygula, bırakma.", "Bleeding: apply firm direct pressure with clean cloth; keep it on."),
            s("person.fill.questionmark", "Bilinçsiz ama nefes alıyorsa: yan yatır. Boyun/omurga yaralanması şüphesinde gereksiz hareket ettirme.", "Unconscious but breathing: recovery position. Avoid moving if neck/spine injury is possible."),
            s("thermometer.snowflake", "Üşüyeni ısıt: kuru örtü, yalıtım. Yaralıyı yalnız bırakma.", "Keep casualties warm and dry; do not leave them alone."),
        ]),
        GuideTopic(id: "water", icon: "drop.fill", color: .cyan, titleTR: "Su ve gıda", titleEN: "Water & food", steps: [
            s("drop.fill", "Kişi başı günde en az 3 litre su hesapla; önce suyu koru.", "Plan at least 3 L of water per person per day."),
            s("flame", "Şüpheli suyu en az 1 dakika kaynat ya da klor/arıtma tableti kullan.", "Boil doubtful water for 1 minute or use purification tablets."),
            s("refrigerator.fill", "Önce buzdolabındaki bozulacak gıdaları, sonra dondurucuyu, en son konserveyi tüket.", "Eat fridge food first, then freezer, canned food last."),
            s("fork.knife", "Az ve sık ye; tuzlu yiyecekten kaçın, su tüketimini artırma.", "Eat small amounts; avoid salty food to save water."),
        ]),
        GuideTopic(id: "battery", icon: "battery.100.bolt", color: .green, titleTR: "Pil tasarrufu", titleEN: "Save battery", steps: [
            s("battery.25", "Düşük Güç Modu'nu aç (Denetim Merkezi / Ayarlar > Pil).", "Turn on Low Power Mode (Control Center / Settings > Battery)."),
            s("sun.min.fill", "Ekran parlaklığını en aza indir, otomatik kilidi 30 sn yap; gerekmedikçe ekranı açma.", "Dim the screen to minimum; set auto-lock to 30 s; keep it off unless needed."),
            s("airplane", "Hücresel şebeke yoksa Uçak Modu'nu aç, sonra yalnız Bluetooth'u aç: imeCep Bluetooth ile çalışır, telefon sinyal aramaz ve pil çok daha az harcanır.", "With no cell signal, enable Airplane Mode then turn Bluetooth back on: imeCep works over Bluetooth and the phone stops hunting for signal."),
            s("arrow.triangle.2.circlepath", "Arka planda uygulama yenilemeyi ve konumu kapat; kullanmadığın uygulamaları kapat.", "Turn off Background App Refresh and Location; close unused apps."),
            s("message.fill", "Arama yerine kısa mesaj; video, müzik, fener ve oyunlardan kaçın.", "Prefer short texts over calls; avoid video, music, flashlight, games."),
            s("moon.fill", "Koyu mod ve sessiz mod kullan. Soğukta telefonu vücuduna yakın, sıcak tut (soğuk pili hızla bitirir).", "Use dark mode and silent mode. Keep the phone warm near your body; cold drains batteries."),
            s("powerplug.fill", "Powerbank, araç şarjı ya da elde çevirmeli şarj kullan; şarjı yalnız gerektiğinde tamamla.", "Use a power bank or car charger; charge only when needed."),
        ]),
    ]
}

struct ImecepGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    quakeStrip
                    ForEach(GuideContent.topics) { topic in
                        NavigationLink(destination: GuideTopicView(topic: topic)) {
                            HStack(spacing: 14) {
                                Image(systemName: topic.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Circle().fill(topic.color))
                                Text(topic.title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                    }
                    Text(ImecepDisaster.t(
                        "Genel bilgilendirmedir; 112'nin ve uzman yardımının yerine geçmez. İnternet gerekmez.",
                        "General guidance only; it does not replace 112 or professional help. Works offline."))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding()
            }
            .navigationTitle(ImecepDisaster.t("Acil durum rehberi", "Emergency guide"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ImecepDisaster.t("Kapat", "Close")) { dismiss() }
                }
            }
        }
    }

    /// Visual: Drop – Cover – Hold On pictogram strip.
    private var quakeStrip: some View {
        HStack(spacing: 8) {
            quakeCell("arrow.down.to.line", ImecepDisaster.t("ÇÖK", "DROP"))
            quakeCell("shield.lefthalf.filled", ImecepDisaster.t("KAPAN", "COVER"))
            quakeCell("hand.raised.fill", ImecepDisaster.t("TUTUN", "HOLD ON"))
        }
    }

    private func quakeCell(_ icon: String, _ label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 30, weight: .bold))
            Text(label).font(.system(size: 14, weight: .heavy))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 84)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange))
        .accessibilityElement(children: .combine)
    }
}

private struct GuideTopicView: View {
    let topic: GuideTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(topic.steps.enumerated()), id: \.element.id) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle().fill(topic.color.opacity(0.18)).frame(width: 44, height: 44)
                            Image(systemName: step.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(topic.color)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(ImecepDisaster.t(step.tr, step.en))
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding()
        }
        .navigationTitle(topic.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
