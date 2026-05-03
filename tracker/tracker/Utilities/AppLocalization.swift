import Foundation
import Observation

@Observable
final class AppLocalization {
    static let shared = AppLocalization()

    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "app_language") }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.language = AppLanguage(rawValue: stored) ?? .english
    }

    private func t(_ en: String, _ tr: String) -> String {
        language == .turkish ? tr : en
    }

    // MARK: - Sentiment
    var bullish: String      { t("Bullish", "Pozitif") }
    var bearish: String      { t("Bearish", "Negatif") }
    var neutral: String      { t("Neutral", "Nötr") }

    func sentimentLabel(_ s: String) -> String {
        switch s.lowercased() {
        case "bullish": return bullish
        case "bearish": return bearish
        case "neutral": return neutral
        default: return s.capitalized
        }
    }

    // MARK: - Tabs
    var feedTab: String      { t("Feed", "Akış") }
    var topicsTab: String    { t("Topics", "Konular") }
    var channelsTab: String  { t("Channels", "Kanallar") }
    var settingsTab: String  { t("Settings", "Ayarlar") }

    // MARK: - Channel Profile
    var opinionsTab: String      { t("Opinions", "Görüşler") }
    var videosTab: String        { t("Videos", "Videolar") }
    var subscribersLabel: String { t("Subscribers", "Abone") }
    var topicsLabel: String      { t("Topics", "Konular") }
    var videosLabel: String      { t("Videos", "Videolar") }
    var follow: String           { t("Follow", "Takip Et") }
    var following: String        { t("Following", "Takip Ediliyor") }
    var latestTake: String       { t("Latest take", "Son görüş") }
    func onTopic(_ name: String) -> String { t("on \(name)", "\(name) hakkında") }

    // MARK: - Actions
    var tryAgain: String { t("Try Again", "Tekrar Dene") }
    var retry: String    { t("Retry", "Tekrar Dene") }

    // MARK: - Empty / Error
    var noContent: String         { t("No Content", "İçerik Yok") }
    var noTopics: String          { t("No Topics", "Konu Yok") }
    var noChannels: String        { t("No Channels", "Kanal Yok") }
    var somethingWentWrong: String { t("Something went wrong", "Bir şeyler ters gitti") }
    var noOpinionsYet: String     { t("No opinions yet", "Henüz görüş yok") }
    var noOpinionsDesc: String    { t("No topic-level takes have been classified for this channel.", "Bu kanal için konu bazlı görüş sınıflandırılmamış.") }
    var couldntLoadOpinions: String { t("Couldn't load opinions", "Görüşler yüklenemedi") }
    var noOpinionsTopic: String   { t("No opinions found for this topic", "Bu konu için henüz görüş bulunmuyor") }

    // MARK: - Section headers
    var analysis: String    { t("Analysis", "Analiz") }
    var keyLevels: String   { t("Key Levels", "Kilit Seviyeler") }
    var confidence: String  { t("Confidence", "Güven") }
    var mentions: String    { t("mentions", "bahis") }

    // MARK: - Video detail
    var untitled: String       { t("Untitled", "Başlıksız") }
    var highlights: String     { t("Highlights", "Öne Çıkanlar") }
    var fullSummary: String    { t("Full Summary", "Tam Özet") }
    var watchSource: String    { t("Watch Source", "Kaynağı İzle") }
    var quickTake: String      { t("Quick Take", "Hızlı Yorum") }
    var summaryTitle: String   { t("Summary", "Özet") }

    // MARK: - Economic thesis
    var analysisUnavailable: String    { t("Analysis unavailable", "Analiz mevcut değil") }
    var noThesisGenerated: String      { t("No thesis generated", "Analiz üretilmedi") }
    var analysingTranscript: String    { t("Analysing transcript…", "Transkript analiz ediliyor…") }
    var keyTakeaway: String            { t("Key takeaway", "Temel çıkarım") }
    var macroOutlook: String           { t("Macro Outlook", "Makro Görünüm") }
    var primaryDriver: String          { t("Primary Driver", "Ana Etken") }
    var economicChain: String          { t("Economic Chain", "Ekonomik Zincir") }
    var causeLabel: String             { t("Cause", "Neden") }
    var transmissionLabel: String      { t("Transmission", "Yayılım") }
    var macroEffects: String           { t("Macro Effects", "Makro Etkiler") }
    var marketEffects: String          { t("Market Effects", "Piyasa Etkileri") }
    var conclusionLabel: String        { t("Conclusion", "Sonuç") }
    var keyWarnings: String            { t("Key Warnings", "Temel Riskler") }
    var topInsights: String            { t("Top Insights", "Öne Çıkan Görüşler") }
    var importantForFollowers: String  { t("Important for Followers", "Takipçiler İçin Önemli") }
    var supportingEvidence: String     { t("Supporting Evidence", "Destekleyici Kanıtlar") }
    var secondaryTopics: String        { t("Secondary Topics", "İkincil Konular") }

    // MARK: - Action bias
    var riskOff: String  { t("Risk Off", "Riskten Kaçış") }
    var riskOn: String   { t("Risk On", "Riske Giriş") }
    var cautious: String { t("Cautious", "Temkinli") }
    var mixed: String    { t("Mixed", "Karışık") }

    // MARK: - Settings
    var languageLabel: String    { t("Language", "Dil") }
    var appLanguageLabel: String { t("App Language", "Uygulama Dili") }
    var appearanceLabel: String  { t("Appearance", "Görünüm") }

    func appearanceName(_ a: AppAppearance) -> String {
        switch a {
        case .system: return t("System", "Sistem")
        case .light:  return t("Light", "Açık")
        case .dark:   return t("Dark", "Koyu")
        }
    }
}
