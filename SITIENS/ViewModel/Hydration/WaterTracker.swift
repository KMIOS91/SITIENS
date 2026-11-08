//
//  WaterTracker.swift
//  SITIENS
//
//  Suivi de l'eau bue dans la journée : verres ajoutés, objectif, remise à zéro quotidienne.
//  Aucune dépendance à SwiftUI : le modèle se teste sans afficher d'écran.
//

import Foundation
import Observation

@MainActor
@Observable
final class WaterTracker {
    enum Keys {
        static let profile = "profilType"
        static let container = "glace"
        static let glassesToday = "glassesToday"
        static let lastTrackingDate = "lastTrackingDate"
        /// Ancienne sauvegarde (fraction de l'objectif), lue une seule fois pour migrer.
        static let legacyProgress = "progress"
    }

    /// Profil choisi (« Sportifs »…), qui fixe l'objectif du jour.
    var profile: String {
        didSet {
            defaults.set(profile, forKey: Keys.profile)
            publishToWidget()
        }
    }

    /// Récipient choisi (« Moyen – 300 ml »…).
    var container: String {
        didSet { defaults.set(container, forKey: Keys.container) }
    }

    /// Nombre de verres bus aujourd'hui.
    /// Un entier plutôt qu'une fraction cumulée : 6 × (1/6) vaut 0,999… en virgule flottante,
    /// alors que 6 × 500 ml vaut exactement 3 000 ml.
    private(set) var glassesToday: Int {
        didSet { defaults.set(glassesToday, forKey: Keys.glassesToday) }
    }

    /// Moment du dernier verre (en secondes depuis 1970, comme dans les versions précédentes).
    @ObservationIgnored private var lastTrackingDate: TimeInterval {
        didSet { defaults.set(lastTrackingDate, forKey: Keys.lastTrackingDate) }
    }

    // Dépendances injectées : les vraies dans l'app, des fausses dans les tests.
    @ObservationIgnored private let goals: GoalRecording
    @ObservationIgnored private let widget: HydrationWidgetPublishing
    @ObservationIgnored private let calculator: UserSettingsViewModel
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: Calendar

    init(
        goals: GoalRecording,
        widget: HydrationWidgetPublishing = SharedWidgetPublisher(),
        calculator: UserSettingsViewModel = UserSettingsViewModel(),
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { .now },
        calendar: Calendar = .current
    ) {
        self.goals = goals
        self.widget = widget
        self.calculator = calculator
        self.defaults = defaults
        self.now = now
        self.calendar = calendar

        profile = defaults.string(forKey: Keys.profile) ?? ""
        container = defaults.string(forKey: Keys.container) ?? ""
        lastTrackingDate = defaults.double(forKey: Keys.lastTrackingDate)
        glassesToday = 0
        glassesToday = savedGlasses()
    }

    // MARK: - Calculs

    /// Objectif du jour en litres, selon le profil (0 sans profil).
    var targetLiters: Double {
        calculator.updateWater(type: profile)
    }

    /// Contenance du récipient en millilitres (0 sans récipient).
    var containerMilliliters: Int {
        calculator.quantityWaterNumber(chooseBottle: container)
    }

    /// Nom de l'image du récipient dans le catalogue d'assets.
    var containerImageName: String {
        calculator.chooseBottleOfWater(name: container)
    }

    var isConfigured: Bool {
        targetLiters > 0 && containerMilliliters > 0
    }

    /// Nombre de verres nécessaires pour atteindre l'objectif.
    var glassesPerDay: Int {
        guard isConfigured else { return 0 }
        return Int((Double(targetMilliliters) / Double(containerMilliliters)).rounded(.up))
    }

    /// Litres bus aujourd'hui, plafonnés à l'objectif.
    var drunkLiters: Double {
        min(Double(drunkMilliliters) / 1000, targetLiters)
    }

    /// Part de l'objectif atteinte, entre 0 et 1.
    var progress: Double {
        guard targetMilliliters > 0 else { return 0 }
        return min(Double(drunkMilliliters) / Double(targetMilliliters), 1)
    }

    var isGoalReached: Bool {
        isConfigured && drunkMilliliters >= targetMilliliters
    }

    var canAddGlass: Bool {
        isConfigured && !isGoalReached
    }

    /// Le profil et le récipient ne changent pas en cours de journée : les verres déjà bus en dépendent.
    var canChangeSettings: Bool {
        glassesToday == 0
    }

    private var drunkMilliliters: Int {
        glassesToday * containerMilliliters
    }

    private var targetMilliliters: Int {
        Int((targetLiters * 1000).rounded())
    }

    // MARK: - Actions

    func addGlass() {
        guard canAddGlass else { return }
        glassesToday += 1
        lastTrackingDate = now().timeIntervalSince1970
        publishToWidget()

        // Enregistré au moment précis où l'objectif est atteint (et donc une seule fois par jour).
        if isGoalReached {
            do {
                try goals.recordGoal(profile: profile, liters: drunkLiters)
            } catch {
                print("Impossible d'enregistrer l'objectif dans l'historique : \(error)")
            }
        }
    }

    func reset() {
        glassesToday = 0
        publishToWidget()
    }

    /// À appeler à l'affichage et au retour au premier plan :
    /// le suivi est journalier, un nouveau jour repart de zéro.
    func refresh() {
        if calculator.isNewDay(lastTracking: lastTrackingDate, now: now(), calendar: calendar) {
            glassesToday = 0
            lastTrackingDate = 0
        }
        publishToWidget()
    }

    // MARK: - Étapes internes

    private func publishToWidget() {
        widget.publish(liters: drunkLiters, targetLiters: targetLiters)
    }

    /// Verres sauvegardés. Les versions précédentes enregistraient une fraction de l'objectif :
    /// on la convertit en nombre de verres la première fois.
    private func savedGlasses() -> Int {
        if defaults.object(forKey: Keys.glassesToday) != nil {
            return defaults.integer(forKey: Keys.glassesToday)
        }
        let legacyProgress = defaults.double(forKey: Keys.legacyProgress)
        guard legacyProgress > 0, isConfigured else { return 0 }
        let glasses = legacyProgress * Double(targetMilliliters) / Double(containerMilliliters)
        return min(Int(glasses.rounded()), glassesPerDay)
    }
}
