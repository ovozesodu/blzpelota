import SceneKit
import SwiftUI

struct ContentView: View {
    @AppStorage("preferredGlove") private var preferredGlove = Artifact.guante.rawValue
    @AppStorage("trainerDifficulty") private var trainerDifficulty = TrainerDifficulty.club.rawValue
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("museumNotesEnabled") private var museumNotesEnabled = true
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @State private var selectedSection: AppSection = .home
    @State private var sessionScore = 1240
    @State private var cleanHits = 18
    @State private var bestTiming = 82.0

    private var difficulty: TrainerDifficulty {
        TrainerDifficulty(rawValue: trainerDifficulty) ?? .club
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        TabView(selection: $selectedSection) {
            HomeView(
                selectedSection: $selectedSection,
                sessionScore: sessionScore,
                cleanHits: cleanHits,
                bestTiming: bestTiming,
                difficulty: difficulty
            )
            .tag(AppSection.home)
            .tabItem { Label(language.homeTab, systemImage: "house.fill") }

            StudioView(
                preferredGlove: $preferredGlove,
                museumNotesEnabled: museumNotesEnabled,
                sessionScore: sessionScore,
                cleanHits: cleanHits,
                bestTiming: bestTiming
            )
            .tag(AppSection.studio)
            .tabItem { Label(language.studioTab, systemImage: "viewfinder") }

            TrainerView(
                difficulty: difficulty,
                hapticsEnabled: hapticsEnabled,
                sessionScore: $sessionScore,
                cleanHits: $cleanHits,
                bestTiming: $bestTiming
            )
            .tag(AppSection.trainer)
            .tabItem { Label(language.trainerTab, systemImage: "bolt.fill") }

            KnowledgeView()
                .tag(AppSection.knowledge)
                .tabItem { Label(language.archiveTab, systemImage: "books.vertical.fill") }

            SettingsView(
                selectedSection: $selectedSection,
                preferredGlove: $preferredGlove,
                trainerDifficulty: $trainerDifficulty,
                hapticsEnabled: $hapticsEnabled,
                museumNotesEnabled: $museumNotesEnabled,
                sessionScore: $sessionScore,
                cleanHits: $cleanHits,
                bestTiming: $bestTiming
            )
            .tag(AppSection.settings)
            .tabItem { Label(language.settingsTab, systemImage: "slider.horizontal.3") }
        }
        .tint(.mixtecaRed)
    }
}

enum AppSection {
    case home
    case studio
    case trainer
    case knowledge
    case settings
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case portuguese = "pt"
    case spanish = "es"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .portuguese: "Português"
        case .spanish: "Español"
        }
    }

    var homeTab: String {
        switch self {
        case .english: "Home"
        case .portuguese: "Início"
        case .spanish: "Inicio"
        }
    }

    var archiveTab: String {
        switch self {
        case .english: "Archive"
        case .portuguese: "Arquivo"
        case .spanish: "Archivo"
        }
    }

    var studioTab: String {
        switch self {
        case .english: "Studio"
        case .portuguese: "Estúdio"
        case .spanish: "Studio"
        }
    }

    var trainerTab: String {
        switch self {
        case .english: "Trainer"
        case .portuguese: "Treino"
        case .spanish: "Trainer"
        }
    }

    var settingsTab: String {
        switch self {
        case .english: "Settings"
        case .portuguese: "Ajustes"
        case .spanish: "Ajustes"
        }
    }
}

struct HomeView: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @AppStorage("selectedDrill") private var selectedDrill = Drill.crossCourt.rawValue
    @Binding var selectedSection: AppSection
    let sessionScore: Int
    let cleanHits: Int
    let bestTiming: Double
    let difficulty: TrainerDifficulty

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCanvas()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HomeHero {
                            selectedSection = .trainer
                        } openStudio: {
                            selectedSection = .studio
                        }

                        ScoreStrip(score: sessionScore, cleanHits: cleanHits, bestTiming: bestTiming)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(homeCopy.recommendedTitle)
                                        .font(.title3.bold())
                                        .foregroundStyle(Color.ink)
                                    Text(homeCopy.recommendedSubtitle)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(difficulty.title(language))
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.mixtecaRed)
                                    .clipShape(Capsule())
                            }

                            TrainingProgramRow(step: "01", title: homeCopy.programOneTitle, detail: homeCopy.programOneDetail, minutes: "3 min") {
                                selectedSection = .studio
                            }
                            TrainingProgramRow(step: "02", title: homeCopy.programTwoTitle, detail: homeCopy.programTwoDetail, minutes: "4 min") {
                                openTrainer(drill: .crossCourt)
                            }
                            TrainingProgramRow(step: "03", title: homeCopy.programThreeTitle, detail: homeCopy.programThreeDetail, minutes: "5 min") {
                                openTrainer(drill: .lateCut)
                            }
                        }
                        .surface()

                        SectionTitle(homeCopy.quickAccessTitle)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                            QuickAction(title: homeCopy.openStudioTitle, subtitle: homeCopy.openStudioSubtitle, icon: "viewfinder") {
                                selectedSection = .studio
                            }
                            QuickAction(title: homeCopy.trainTitle, subtitle: homeCopy.trainSubtitle, icon: "bolt.fill") {
                                selectedSection = .trainer
                            }
                            QuickAction(title: homeCopy.rulesTitle, subtitle: homeCopy.rulesSubtitle, icon: "books.vertical.fill") {
                                selectedSection = .knowledge
                            }
                            QuickAction(title: homeCopy.settingsTitle, subtitle: homeCopy.settingsSubtitle, icon: "slider.horizontal.3") {
                                selectedSection = .settings
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("BLZ Pelota")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var homeCopy: HomeCopy {
        HomeCopy(language)
    }

    private func openTrainer(drill: Drill) {
        selectedDrill = drill.rawValue
        selectedSection = .trainer
    }
}

struct StudioView: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @Binding var preferredGlove: String
    let museumNotesEnabled: Bool
    let sessionScore: Int
    let cleanHits: Int
    let bestTiming: Double
    @State private var selectedArtifact = Artifact.guante
    @State private var detailLevel = 0.68

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCanvas()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ProductHeader(
                            eyebrow: "BLZ Pelota Lab",
                            title: studioCopy.title,
                            subtitle: studioCopy.subtitle
                        )

                        ScoreStrip(score: sessionScore, cleanHits: cleanHits, bestTiming: bestTiming)

                        VStack(spacing: 0) {
                            StudioSceneStage(artifact: selectedArtifact, detailLevel: detailLevel, language: language)
                                .frame(height: 420)

                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedArtifact.title(language))
                                            .font(.title2.bold())
                                        Text(selectedArtifact.collectionNote(language))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(selectedArtifact.period(language))
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.mixtecaRed)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color.redWash)
                                        .clipShape(Capsule())
                                }

                                Picker(studioCopy.piecePicker, selection: $selectedArtifact) {
                                    ForEach(Artifact.allCases) { artifact in
                                        Text(artifact.shortTitle(language)).tag(artifact)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: selectedArtifact) { artifact in
                                    preferredGlove = artifact.rawValue
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Label(studioCopy.detailLevel, systemImage: "dial.medium.fill")
                                            .font(.subheadline.bold())
                                        Spacer()
                                        Text("\(Int(detailLevel * 100))%")
                                            .font(.subheadline.monospacedDigit())
                                            .foregroundStyle(.secondary)
                                    }
                                    Slider(value: $detailLevel, in: 0.25...1.0)
                                }
                            }
                            .padding(16)
                        }
                        .surface()

                        if museumNotesEnabled {
                            CuratorNote(
                                title: studioCopy.curatorTitle,
                                body: studioCopy.curatorBody
                            )
                        }

                        SectionTitle(studioCopy.inventoryTitle)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 12)], spacing: 12) {
                            InventoryMetric(title: studioCopy.massMetric, value: selectedArtifact.mass(language), icon: "scalemass.fill")
                            InventoryMetric(title: studioCopy.readingMetric, value: selectedArtifact.readingCue(language), icon: "eye.fill")
                            InventoryMetric(title: studioCopy.riskMetric, value: selectedArtifact.risk(language), icon: "exclamationmark.triangle.fill")
                            InventoryMetric(title: studioCopy.trainingMetric, value: selectedArtifact.practiceUse(language), icon: "figure.core.training")
                        }

                        SectionTitle(studioCopy.museumPiecesTitle)
                        ForEach(Artifact.allCases) { artifact in
                            ArtifactRow(artifact: artifact, isSelected: artifact == selectedArtifact) {
                                selectedArtifact = artifact
                                preferredGlove = artifact.rawValue
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(language.studioTab)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedArtifact = Artifact(rawValue: preferredGlove) ?? .guante
            }
        }
    }

    private var studioCopy: StudioCopy {
        StudioCopy(language)
    }
}

struct StudioSceneStage: View {
    let artifact: Artifact
    let detailLevel: Double
    let language: AppLanguage

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 1.0, green: 0.945, blue: 0.935),
                    Color(red: 0.965, green: 0.975, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            StudioStageLines()
                .opacity(0.92)

            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mixtecaRed.opacity(0.18),
                                Color.white.opacity(0.62),
                                Color.mixtecaRed.opacity(0.08)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 78)
                    .padding(.horizontal, 26)
                    .padding(.bottom, 22)
                    .blur(radius: 0.4)
            }

            GuanteSceneView(artifact: artifact, detailLevel: detailLevel, language: language)
                .padding(.horizontal, 8)
                .padding(.top, 4)
                .padding(.bottom, 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color.mixtecaRed.opacity(0.26), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct StudioStageLines: View {
    var body: some View {
        Canvas { context, size in
            var trajectory = Path()
            trajectory.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.72))
            trajectory.addQuadCurve(
                to: CGPoint(x: size.width * 0.9, y: size.height * 0.28),
                control: CGPoint(x: size.width * 0.48, y: size.height * 0.06)
            )
            context.stroke(
                trajectory,
                with: .linearGradient(
                    Gradient(colors: [Color.mixtecaRed.opacity(0.04), Color.mixtecaRed.opacity(0.26), Color.mixtecaRed.opacity(0.05)]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: size.height)
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 12])
            )

            var lower = Path()
            lower.move(to: CGPoint(x: size.width * 0.02, y: size.height * 0.86))
            lower.addCurve(
                to: CGPoint(x: size.width * 0.98, y: size.height * 0.62),
                control1: CGPoint(x: size.width * 0.34, y: size.height * 0.96),
                control2: CGPoint(x: size.width * 0.63, y: size.height * 0.52)
            )
            context.stroke(lower, with: .color(Color.ink.opacity(0.05)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

            var verticals = Path()
            for x in stride(from: size.width * 0.12, through: size.width * 0.9, by: 42) {
                verticals.move(to: CGPoint(x: x, y: size.height * 0.12))
                verticals.addLine(to: CGPoint(x: x, y: size.height * 0.9))
            }
            context.stroke(verticals, with: .color(Color.mixtecaRed.opacity(0.025)), lineWidth: 1)
        }
    }
}

struct GuanteSceneView: UIViewRepresentable {
    let artifact: Artifact
    let detailLevel: Double
    let language: AppLanguage

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = makeScene()
        view.allowsCameraControl = true
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.preferredFramesPerSecond = 60
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = makeScene()
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 34
        camera.position = SCNVector3(0.12, 0.02, 7.7)
        let target = SCNNode()
        target.position = SCNVector3(0, 0.02, 0)
        scene.rootNode.addChildNode(target)
        camera.constraints = [SCNLookAtConstraint(target: target)]
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 560
        ambient.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .area
        key.light?.intensity = 1720
        key.light?.areaExtents = SIMD3<Float>(4.2, 4.2, 1.0)
        key.position = SCNVector3(-2.9, 4.5, 5.4)
        scene.rootNode.addChildNode(key)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .omni
        fill.light?.intensity = 620
        fill.light?.color = UIColor(Color.redWash)
        fill.position = SCNVector3(3.2, 0.4, 4.6)
        scene.rootNode.addChildNode(fill)

        let rim = SCNNode()
        rim.light = SCNLight()
        rim.light?.type = .spot
        rim.light?.intensity = 980
        rim.light?.spotInnerAngle = 35
        rim.light?.spotOuterAngle = 72
        rim.light?.color = UIColor(Color.warmWhite)
        rim.position = SCNVector3(0, 2.3, -4.4)
        rim.constraints = [SCNLookAtConstraint(target: target)]
        scene.rootNode.addChildNode(rim)

        let displayRing = SCNNode(geometry: SCNTorus(ringRadius: 1.86, pipeRadius: 0.018))
        displayRing.geometry?.firstMaterial = Artifact.material(.redWash, roughness: 0.22, metalness: 0.0)
        displayRing.position = SCNVector3(0.0, 0.18, -0.62)
        displayRing.eulerAngles = SCNVector3(0.18, 0.08, -0.52)
        displayRing.opacity = 0.72
        scene.rootNode.addChildNode(displayRing)

        let displayRingAccent = SCNNode(geometry: SCNTorus(ringRadius: 1.32, pipeRadius: 0.012))
        displayRingAccent.geometry?.firstMaterial = Artifact.material(.mixtecaRed, roughness: 0.28, metalness: 0.0)
        displayRingAccent.position = SCNVector3(0.18, 0.0, -0.68)
        displayRingAccent.eulerAngles = SCNVector3(0.22, -0.04, -0.52)
        displayRingAccent.opacity = 0.28
        scene.rootNode.addChildNode(displayRingAccent)

        let model = artifact.node(detailLevel: detailLevel, language: language)
        model.eulerAngles = SCNVector3(-0.12, 0.32, -0.04)
        model.scale = SCNVector3(0.98, 0.98, 0.98)
        model.runAction(.repeatForever(.rotateBy(x: 0, y: 0.2, z: 0, duration: 12)))
        scene.rootNode.addChildNode(model)

        let plinth = SCNNode(geometry: SCNCylinder(radius: 2.05, height: 0.18))
        plinth.geometry?.firstMaterial = Artifact.material(.white, roughness: 0.28, metalness: 0.0)
        plinth.position = SCNVector3(0, -1.64, 0)
        scene.rootNode.addChildNode(plinth)

        let plinthRing = SCNNode(geometry: SCNCylinder(radius: 2.08, height: 0.055))
        plinthRing.geometry?.firstMaterial = Artifact.material(.mixtecaRed, roughness: 0.34, metalness: 0.0)
        plinthRing.position = SCNVector3(0, -1.76, 0)
        scene.rootNode.addChildNode(plinthRing)

        let floor = SCNFloor()
        floor.reflectivity = 0.08
        floor.reflectionFalloffEnd = 3.8
        floor.firstMaterial = Artifact.material(.white, roughness: 0.36, metalness: 0.0)
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -1.86, 0)
        scene.rootNode.addChildNode(floorNode)

        return scene
    }
}

enum Artifact: String, CaseIterable, Identifiable {
    case guante
    case pelota
    case cancha

    var id: String { rawValue }

    func shortTitle(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "Glove"
        case (.guante, .portuguese): "Luva"
        case (.guante, .spanish): "Guante"
        case (.pelota, .english): "Balls"
        case (.pelota, .portuguese): "Bolas"
        case (.pelota, .spanish): "Pelotas"
        case (.cancha, .english): "Court"
        case (.cancha, .portuguese): "Quadra"
        case (.cancha, .spanish): "Cancha"
        }
    }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "Heavy-strike glove"
        case (.guante, .portuguese): "Luva de golpe pesado"
        case (.guante, .spanish): "Guante de golpe pesado"
        case (.pelota, .english): "Three reading balls"
        case (.pelota, .portuguese): "Três bolas de leitura"
        case (.pelota, .spanish): "Tres pelotas de lectura"
        case (.cancha, .english): "Long court and live zone"
        case (.cancha, .portuguese): "Quadra longa e zona viva"
        case (.cancha, .spanish): "Cancha larga y zona viva"
        }
    }

    func period(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "core object"
        case (.guante, .portuguese): "peça central"
        case (.guante, .spanish): "pieza central"
        case (.pelota, .english): "comparison"
        case (.pelota, .portuguese): "comparativo"
        case (.pelota, .spanish): "comparativa"
        case (.cancha, .english): "tactical map"
        case (.cancha, .portuguese): "mapa tático"
        case (.cancha, .spanish): "mapa tactico"
        }
    }

    func collectionNote(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english):
            "Oversized palm, rigid wrist and rivets that communicate weight before movement."
        case (.guante, .portuguese):
            "Palma ampliada, punho rígido e rebites que comunicam peso antes do movimento."
        case (.guante, .spanish):
            "Palma sobredimensionada, muneca rigida y remaches que comunican peso antes del movimiento."
        case (.pelota, .english):
            "The trainer compares visual response: rubber, covered and practice balls move at different rhythms."
        case (.pelota, .portuguese):
            "O treinador compara resposta visual: borracha, revestimento e bola de treino têm ritmos distintos."
        case (.pelota, .spanish):
            "El entrenador compara respuesta visual: hule, forro y pelota de practica tienen ritmos distintos."
        case (.cancha, .english):
            "The court is read like a corridor: distance, bounce and response line matter more than raw force."
        case (.cancha, .portuguese):
            "A quadra é lida como corredor: distância, quique e linha de resposta importam mais que força pura."
        case (.cancha, .spanish):
            "La cancha se lee como corredor: distancia, bote y linea de respuesta importan mas que la fuerza pura."
        }
    }

    func mass(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "high"
        case (.guante, .portuguese): "alta"
        case (.guante, .spanish): "alta"
        case (.pelota, .english): "variable"
        case (.pelota, .portuguese): "variável"
        case (.pelota, .spanish): "variable"
        case (.cancha, .english): "long"
        case (.cancha, .portuguese): "longa"
        case (.cancha, .spanish): "larga"
        }
    }

    func readingCue(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "set shoulder"
        case (.guante, .portuguese): "preparar ombro"
        case (.guante, .spanish): "preparar hombro"
        case (.pelota, .english): "early bounce"
        case (.pelota, .portuguese): "quique cedo"
        case (.pelota, .spanish): "rebote temprano"
        case (.cancha, .english): "line crossing"
        case (.cancha, .portuguese): "cruzar linha"
        case (.cancha, .spanish): "cruce de linea"
        }
    }

    func risk(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "fatigue"
        case (.guante, .portuguese): "fadiga"
        case (.guante, .spanish): "fatiga"
        case (.pelota, .english): "bad bounce"
        case (.pelota, .portuguese): "quique ruim"
        case (.pelota, .spanish): "mal bote"
        case (.cancha, .english): "closed angle"
        case (.cancha, .portuguese): "ângulo fechado"
        case (.cancha, .spanish): "angulo cerrado"
        }
    }

    func practiceUse(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.guante, .english): "dry timing"
        case (.guante, .portuguese): "timing seco"
        case (.guante, .spanish): "timing seco"
        case (.pelota, .english): "tracking"
        case (.pelota, .portuguese): "seguimento"
        case (.pelota, .spanish): "seguimiento"
        case (.cancha, .english): "position"
        case (.cancha, .portuguese): "posição"
        case (.cancha, .spanish): "posicion"
        }
    }

    func node(detailLevel: Double, language: AppLanguage) -> SCNNode {
        switch self {
        case .guante: makeGuante(detailLevel: detailLevel)
        case .pelota: makeBalls(detailLevel: detailLevel, language: language)
        case .cancha: makeCourt(detailLevel: detailLevel)
        }
    }

    private func makeGuante(detailLevel: Double) -> SCNNode {
        let root = SCNNode()
        let red = Self.material(.gloveRed, roughness: 0.48, metalness: 0.02)
        let deepRed = Self.material(.deepRed, roughness: 0.56, metalness: 0.03)
        let bone = Self.material(.warmWhite, roughness: 0.34, metalness: 0.0)
        let metal = Self.material(.steel, roughness: 0.18, metalness: 0.86)
        let blackLeather = Self.material(.ink, roughness: 0.58, metalness: 0.0)
        let scale = CGFloat(1.0 + detailLevel * 0.12)

        let palm = SCNNode(geometry: SCNBox(width: 2.28 * scale, height: 2.62 * scale, length: 0.76, chamferRadius: 0.36))
        palm.geometry?.firstMaterial = red
        root.addChildNode(palm)

        let facePanel = SCNNode(geometry: SCNBox(width: 1.42 * scale, height: 2.0 * scale, length: 0.08, chamferRadius: 0.24))
        facePanel.geometry?.firstMaterial = Self.material(.gloveHighlight, roughness: 0.42, metalness: 0.01)
        facePanel.position = SCNVector3(0.14, 0.04, 0.43)
        root.addChildNode(facePanel)

        for index in 0..<4 {
            let finger = SCNNode(geometry: SCNBox(width: 0.44, height: 1.32 + CGFloat(index % 2) * 0.16, length: 0.64, chamferRadius: 0.21))
            finger.geometry?.firstMaterial = red
            finger.position = SCNVector3(-0.72 + Float(index) * 0.48, 1.82, 0.03)
            finger.eulerAngles.z = Float(index - 1) * 0.05
            root.addChildNode(finger)

            let cap = SCNNode(geometry: SCNBox(width: 0.34, height: 0.18, length: 0.07, chamferRadius: 0.05))
            cap.geometry?.firstMaterial = bone
            cap.position = SCNVector3(-0.72 + Float(index) * 0.48, 2.42 + Float(index % 2) * 0.08, 0.39)
            root.addChildNode(cap)
        }

        let thumb = SCNNode(geometry: SCNBox(width: 0.58, height: 1.42, length: 0.64, chamferRadius: 0.22))
        thumb.geometry?.firstMaterial = deepRed
        thumb.position = SCNVector3(-1.36, 0.36, 0.03)
        thumb.eulerAngles.z = 0.72
        root.addChildNode(thumb)

        let cuff = SCNNode(geometry: SCNBox(width: 2.05, height: 0.78, length: 0.84, chamferRadius: 0.24))
        cuff.geometry?.firstMaterial = deepRed
        cuff.position = SCNVector3(0, -1.69, 0)
        root.addChildNode(cuff)

        let stripe = SCNNode(geometry: SCNBox(width: 2.08, height: 0.14, length: 0.08, chamferRadius: 0.03))
        stripe.geometry?.firstMaterial = bone
        stripe.position = SCNVector3(0, -1.42, 0.48)
        root.addChildNode(stripe)

        let rows = detailLevel > 0.55 ? 6 : 4
        let cols = detailLevel > 0.55 ? 6 : 5
        for row in 0..<rows {
            for col in 0..<cols {
                let stud = SCNNode(geometry: SCNSphere(radius: 0.072 + detailLevel * 0.018))
                stud.geometry?.firstMaterial = metal
                stud.position = SCNVector3(-0.92 + Float(col) * 0.36, -0.82 + Float(row) * 0.34, 0.52)
                root.addChildNode(stud)
            }
        }

        let seam = SCNNode(geometry: SCNTorus(ringRadius: 0.88, pipeRadius: 0.032))
        seam.geometry?.firstMaterial = bone
        seam.scale = SCNVector3(1.08, 1.48, 0.16)
        seam.position = SCNVector3(0, 0.16, 0.54)
        root.addChildNode(seam)

        let centerRidge = SCNNode(geometry: SCNBox(width: 0.12, height: 2.24, length: 0.08, chamferRadius: 0.04))
        centerRidge.geometry?.firstMaterial = bone
        centerRidge.position = SCNVector3(0.72, -0.04, 0.56)
        centerRidge.eulerAngles.z = -0.18
        root.addChildNode(centerRidge)

        for index in 0..<4 {
            let lace = SCNNode(geometry: SCNBox(width: 0.1, height: 0.74, length: 0.08, chamferRadius: 0.04))
            lace.geometry?.firstMaterial = index.isMultiple(of: 2) ? bone : blackLeather
            lace.position = SCNVector3(-0.56 + Float(index) * 0.34, 0.6 - Float(index) * 0.22, 0.6)
            lace.eulerAngles.z = -0.92
            root.addChildNode(lace)
        }

        let wristOpening = SCNNode(geometry: SCNTorus(ringRadius: 0.58, pipeRadius: 0.05))
        wristOpening.geometry?.firstMaterial = blackLeather
        wristOpening.scale = SCNVector3(1.35, 0.55, 0.18)
        wristOpening.position = SCNVector3(0, -1.82, 0.52)
        root.addChildNode(wristOpening)

        return root
    }

    private func makeBalls(detailLevel: Double, language: AppLanguage) -> SCNNode {
        let root = SCNNode()
        let colors: [Color] = [.mixtecaRed, .warmWhite, .deepRed]
        let labels = ballLabels(language)
        for index in 0..<3 {
            let ball = SCNNode(geometry: SCNSphere(radius: 0.58 - CGFloat(index) * 0.06))
            ball.geometry?.firstMaterial = Self.material(colors[index], roughness: 0.58, metalness: 0)
            ball.position = SCNVector3(-1.35 + Float(index) * 1.35, 0.1, 0)
            root.addChildNode(ball)

            let belt = SCNNode(geometry: SCNTorus(ringRadius: 0.48 - CGFloat(index) * 0.05, pipeRadius: 0.018 + detailLevel * 0.008))
            belt.geometry?.firstMaterial = Self.material(index == 1 ? .mixtecaRed : .warmWhite, roughness: 0.35, metalness: 0.05)
            belt.position = ball.position
            belt.eulerAngles.x = .pi / 2
            root.addChildNode(belt)

            let text = SCNText(string: labels[index], extrusionDepth: 0.015)
            text.font = .systemFont(ofSize: 0.18, weight: .bold)
            text.firstMaterial?.diffuse.contents = UIColor(Color.ink)
            let label = SCNNode(geometry: text)
            label.position = SCNVector3(-1.67 + Float(index) * 1.35, -0.86, 0)
            root.addChildNode(label)
        }
        return root
    }

    private func ballLabels(_ language: AppLanguage) -> [String] {
        switch language {
        case .english: ["rubber", "covered", "practice"]
        case .portuguese: ["borracha", "revestida", "treino"]
        case .spanish: ["hule", "forro", "practica"]
        }
    }

    private func makeCourt(detailLevel: Double) -> SCNNode {
        let root = SCNNode()
        let red = Self.material(.mixtecaRed, roughness: 0.28, metalness: 0.0)
        let dark = Self.material(.ink, roughness: 0.5, metalness: 0.0)
        let lineCount = detailLevel > 0.65 ? 7 : 5

        for index in 0..<lineCount {
            let line = SCNNode(geometry: SCNBox(width: 4.0, height: 0.035, length: 0.035, chamferRadius: 0.01))
            line.geometry?.firstMaterial = index == lineCount / 2 ? red : dark
            line.position = SCNVector3(0, -1.18 + Float(index) * 0.4, 0)
            root.addChildNode(line)
        }

        let launch = SCNNode(geometry: SCNTorus(ringRadius: 1.08, pipeRadius: 0.022))
        launch.geometry?.firstMaterial = red
        launch.scale = SCNVector3(1.58, 0.38, 0.12)
        launch.eulerAngles.z = -0.5
        root.addChildNode(launch)

        let zone = SCNNode(geometry: SCNBox(width: 0.88, height: 0.88, length: 0.04, chamferRadius: 0.05))
        zone.geometry?.firstMaterial = Self.material(.redWash, roughness: 0.38, metalness: 0)
        zone.position = SCNVector3(1.12, 0.24, 0.02)
        root.addChildNode(zone)

        return root
    }

    static func material(_ color: Color, roughness: CGFloat, metalness: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(color)
        material.specular.contents = UIColor.white.withAlphaComponent(0.35)
        material.roughness.contents = roughness
        material.metalness.contents = metalness
        material.isDoubleSided = true
        return material
    }
}

struct TrainerView: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @AppStorage("selectedDrill") private var selectedDrillRaw = Drill.crossCourt.rawValue
    let difficulty: TrainerDifficulty
    let hapticsEnabled: Bool
    @Binding var sessionScore: Int
    @Binding var cleanHits: Int
    @Binding var bestTiming: Double

    @State private var phase: CGFloat = 0
    @State private var streak = 0
    @State private var feedback = TrainerCopy(.english).initialFeedback
    @State private var isPaused = false
    @State private var lastQuality: Double = 0
    @State private var misses = 0
    @State private var remainingSeconds = 45.0
    @State private var roundState = RoundState.ready

    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    private var selectedDrill: Drill {
        Drill(rawValue: selectedDrillRaw) ?? .crossCourt
    }

    private var selectedDrillBinding: Binding<Drill> {
        Binding {
            selectedDrill
        } set: { drill in
            selectDrill(drill)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCanvas()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ProductHeader(
                            eyebrow: trainerCopy.eyebrow,
                            title: trainerCopy.title,
                            subtitle: trainerCopy.subtitle
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Picker(trainerCopy.drillPicker, selection: selectedDrillBinding) {
                                ForEach(Drill.allCases) { drill in
                                    Text(drill.title(language)).tag(drill)
                                }
                            }
                            .pickerStyle(.segmented)

                            HStack(spacing: 10) {
                                RoundChip(title: trainerCopy.timeChip, value: "\(max(0, Int(remainingSeconds)))s", icon: "timer")
                                RoundChip(title: trainerCopy.missesChip, value: "\(misses)/3", icon: "xmark.circle.fill")
                                RoundChip(title: trainerCopy.gradeChip, value: precisionGrade, icon: "seal.fill")
                            }

                            ProgressView(value: remainingSeconds, total: 45)
                                .tint(.mixtecaRed)
                        }
                        .surface()

                        GeometryReader { proxy in
                            let size = proxy.size
                            let ball = selectedDrill.position(phase: phase, in: size)
                            let zone = selectedDrill.zone(in: size)

                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .overlay(TrainingCourtGrid())
                                    .overlay(alignment: .topLeading) {
                                        HStack(spacing: 8) {
                                            Label(difficulty.title(language), systemImage: "speedometer")
                                            Label(selectedDrill.focus(language), systemImage: selectedDrill.icon)
                                        }
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.mixtecaRed)
                                        .padding(10)
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Text(roundState.title(language))
                                            .font(.caption.bold())
                                            .foregroundStyle(roundState == .running ? Color.mixtecaRed : Color.secondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(Color.white.opacity(0.9))
                                            .clipShape(Capsule())
                                            .padding(10)
                                    }

                                selectedDrill.path(in: size)
                                    .stroke(Color.ink.opacity(0.18), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 9]))

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.redWash.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.mixtecaRed, style: StrokeStyle(lineWidth: 3, dash: roundState == .running ? [] : [8, 6]))
                                    )
                                    .frame(width: zone.width, height: zone.height)
                                    .position(x: zone.midX, y: zone.midY)

                                ImpactHalo(quality: lastQuality)
                                    .position(ball)

                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.white, .mixtecaRed.opacity(0.95), .deepRed],
                                            center: .topLeading,
                                            startRadius: 2,
                                            endRadius: 30
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .mixtecaRed.opacity(0.26), radius: 14)
                                    .position(ball)

                                VStack {
                                    Spacer()
                                    HStack {
                                        TrainerBadge(title: trainerCopy.streakBadge, value: "\(streak)")
                                        TrainerBadge(title: trainerCopy.qualityBadge, value: "\(Int(lastQuality * 100))%")
                                        TrainerBadge(title: trainerCopy.bestBadge, value: "\(Int(bestTiming))%")
                                    }
                                    .padding(12)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if roundState == .running {
                                    strike(ball: ball, zone: zone)
                                } else {
                                    startRound()
                                }
                            }
                        }
                        .frame(height: 360)
                        .surface()

                        HStack(spacing: 12) {
                            Button {
                                if roundState == .ready || roundState == .finished {
                                    startRound()
                                } else {
                                    isPaused.toggle()
                                    roundState = isPaused ? .paused : .running
                                }
                            } label: {
                                Label(primaryActionTitle, systemImage: primaryActionIcon)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            Button {
                                resetRound()
                            } label: {
                                Label(trainerCopy.resetButton, systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        CuratorNote(title: trainerCopy.coachCueTitle, body: feedback)

                        SectionTitle(trainerCopy.practicePlanTitle)
                        ForEach(Drill.allCases) { drill in
                            DrillPlanRow(drill: drill, isActive: drill == selectedDrill) {
                                selectDrill(drill)
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(language.trainerTab)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onReceive(timer) { _ in
            guard roundState == .running else { return }
            phase += selectedDrill.speed * difficulty.speedMultiplier
            remainingSeconds -= 0.016
            if remainingSeconds <= 0 {
                finishRound(message: trainerCopy.roundComplete)
                return
            }
            if phase > 1 {
                phase = 0
                streak = 0
                lastQuality = 0
                misses += 1
                feedback = trainerCopy.ballPassed
                if misses >= 3 {
                    finishRound(message: trainerCopy.threeMissesSlowDown)
                }
            }
        }
    }

    private var precisionGrade: String {
        switch bestTiming {
        case 90...: "A"
        case 78..<90: "B"
        case 62..<78: "C"
        default: "D"
        }
    }

    private var primaryActionTitle: String {
        switch roundState {
        case .ready, .finished: trainerCopy.startButton
        case .running: trainerCopy.pauseButton
        case .paused: trainerCopy.continueButton
        }
    }

    private var primaryActionIcon: String {
        switch roundState {
        case .ready, .finished, .paused: "play.fill"
        case .running: "pause.fill"
        }
    }

    private func strike(ball: CGPoint, zone: CGRect) {
        if zone.contains(ball) {
            let center = CGPoint(x: zone.midX, y: zone.midY)
            let distance = hypot(ball.x - center.x, ball.y - center.y)
            let quality = max(0.18, 1 - distance / max(zone.width, zone.height))
            lastQuality = quality
            bestTiming = max(bestTiming, quality * 100)
            streak += 1
            cleanHits += quality > 0.72 ? 1 : 0
            let comboBonus = streak > 0 && streak % 5 == 0 ? 160 : 0
            sessionScore += Int(quality * 140) + streak * 12 + comboBonus
            phase = 0
            feedback = comboBonus > 0 ? trainerCopy.comboFeedback : quality > 0.78 ? trainerCopy.cleanImpactFeedback : trainerCopy.goodContactFeedback
            if hapticsEnabled {
                UIImpactFeedbackGenerator(style: quality > 0.78 ? .medium : .light).impactOccurred()
            }
        } else {
            streak = 0
            lastQuality = 0
            misses += 1
            sessionScore = max(0, sessionScore - 45)
            feedback = trainerCopy.outsideWindow
            if hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            if misses >= 3 {
                finishRound(message: trainerCopy.threeMissesFinished)
            }
        }
    }

    private func resetRound() {
        phase = 0
        streak = 0
        misses = 0
        lastQuality = 0
        remainingSeconds = 45
        roundState = .ready
        isPaused = false
        feedback = selectedDrill.resetCue(language)
    }

    private func selectDrill(_ drill: Drill) {
        selectedDrillRaw = drill.rawValue
        resetRound()
    }

    private func startRound() {
        phase = 0
        streak = 0
        misses = 0
        lastQuality = 0
        remainingSeconds = 45
        isPaused = false
        roundState = .running
        feedback = trainerCopy.roundActive
    }

    private func finishRound(message: String) {
        roundState = .finished
        isPaused = true
        remainingSeconds = max(0, remainingSeconds)
        feedback = message
    }

    private var trainerCopy: TrainerCopy {
        TrainerCopy(language)
    }
}

enum RoundState {
    case ready
    case running
    case paused
    case finished

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.ready, .english): "READY"
        case (.ready, .portuguese): "PRONTO"
        case (.ready, .spanish): "LISTO"
        case (.running, .english): "IN ROUND"
        case (.running, .portuguese): "EM RODADA"
        case (.running, .spanish): "EN RONDA"
        case (.paused, .english): "PAUSED"
        case (.paused, .portuguese): "PAUSA"
        case (.paused, .spanish): "PAUSA"
        case (.finished, .english): "CLOSED"
        case (.finished, .portuguese): "FECHADO"
        case (.finished, .spanish): "CIERRE"
        }
    }
}

enum TrainerDifficulty: String, CaseIterable, Identifiable {
    case escuela
    case club
    case torneo

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.escuela, .english): "School"
        case (.escuela, .portuguese): "Escola"
        case (.escuela, .spanish): "Escuela"
        case (.club, .english): "Club"
        case (.club, .portuguese): "Clube"
        case (.club, .spanish): "Club"
        case (.torneo, .english): "Tournament"
        case (.torneo, .portuguese): "Torneio"
        case (.torneo, .spanish): "Torneo"
        }
    }

    var speedMultiplier: CGFloat {
        switch self {
        case .escuela: 0.74
        case .club: 1.0
        case .torneo: 1.34
        }
    }

    func description(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.escuela, .english): "Wide windows and slower reading for learning the curve."
        case (.escuela, .portuguese): "Janelas amplas e leitura pausada para aprender a curva."
        case (.escuela, .spanish): "Ventanas amplias y lectura pausada para aprender la curva."
        case (.club, .english): "Balanced rhythm for daily sessions."
        case (.club, .portuguese): "Ritmo equilibrado para sessões diárias."
        case (.club, .spanish): "Ritmo equilibrado para sesiones diarias."
        case (.torneo, .english): "Fast ball, higher penalty and demanding timing."
        case (.torneo, .portuguese): "Bola rápida, penalidade maior e timing exigente."
        case (.torneo, .spanish): "Pelota rapida, castigo mayor y timing exigente."
        }
    }
}

enum Drill: String, CaseIterable, Identifiable {
    case crossCourt
    case risingBounce
    case lateCut

    var id: String { rawValue }

    func title(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.crossCourt, .english): "Cross"
        case (.crossCourt, .portuguese): "Cruzada"
        case (.crossCourt, .spanish): "Cruzada"
        case (.risingBounce, .english): "Bounce"
        case (.risingBounce, .portuguese): "Quique"
        case (.risingBounce, .spanish): "Bote"
        case (.lateCut, .english): "Late cut"
        case (.lateCut, .portuguese): "Corte"
        case (.lateCut, .spanish): "Corte"
        }
    }

    var icon: String {
        switch self {
        case .crossCourt: "arrow.up.right"
        case .risingBounce: "waveform.path.ecg"
        case .lateCut: "arrow.turn.down.left"
        }
    }

    func focus(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.crossCourt, .english): "lateral read"
        case (.crossCourt, .portuguese): "leitura lateral"
        case (.crossCourt, .spanish): "lectura lateral"
        case (.risingBounce, .english): "early bounce"
        case (.risingBounce, .portuguese): "quique cedo"
        case (.risingBounce, .spanish): "rebote temprano"
        case (.lateCut, .english): "late reaction"
        case (.lateCut, .portuguese): "reação tardia"
        case (.lateCut, .spanish): "reaccion tardia"
        }
    }

    func resetCue(_ language: AppLanguage) -> String {
        switch (self, language) {
        case (.crossCourt, .english): "Cross active: wait until the ball crosses the red box."
        case (.crossCourt, .portuguese): "Cruzada ativa: espere a bola atravessar a caixa vermelha."
        case (.crossCourt, .spanish): "Cruzada activa: espera que la pelota atraviese la caja roja."
        case (.risingBounce, .english): "Bounce active: read the height peak before touching."
        case (.risingBounce, .portuguese): "Quique ativo: observe o pico de altura antes de tocar."
        case (.risingBounce, .spanish): "Bote activo: mira el pico de altura antes de tocar."
        case (.lateCut, .english): "Late cut active: do not over-anticipate; let the angle close."
        case (.lateCut, .portuguese): "Corte ativo: não antecipe demais; deixe o ângulo fechar."
        case (.lateCut, .spanish): "Corte activo: no anticipes demasiado, deja que cierre el angulo."
        }
    }

    var speed: CGFloat {
        switch self {
        case .crossCourt: 0.0037
        case .risingBounce: 0.0033
        case .lateCut: 0.0041
        }
    }

    func zone(in size: CGSize) -> CGRect {
        switch self {
        case .crossCourt:
            CGRect(x: size.width * 0.66, y: size.height * 0.28, width: 88, height: 118)
        case .risingBounce:
            CGRect(x: size.width * 0.48, y: size.height * 0.18, width: 96, height: 104)
        case .lateCut:
            CGRect(x: size.width * 0.72, y: size.height * 0.52, width: 90, height: 110)
        }
    }

    func position(phase: CGFloat, in size: CGSize) -> CGPoint {
        let t = phase
        switch self {
        case .crossCourt:
            return quadratic(
                t,
                CGPoint(x: 26, y: size.height * 0.78),
                CGPoint(x: size.width * 0.46, y: size.height * 0.03),
                CGPoint(x: size.width - 28, y: size.height * 0.34)
            )
        case .risingBounce:
            let base = quadratic(
                t,
                CGPoint(x: 28, y: size.height * 0.7),
                CGPoint(x: size.width * 0.5, y: size.height * -0.08),
                CGPoint(x: size.width - 34, y: size.height * 0.72)
            )
            return CGPoint(x: base.x, y: base.y + sin(t * .pi * 3) * 28)
        case .lateCut:
            return quadratic(
                t,
                CGPoint(x: 30, y: size.height * 0.2),
                CGPoint(x: size.width * 0.82, y: size.height * 0.06),
                CGPoint(x: size.width * 0.72, y: size.height * 0.88)
            )
        }
    }

    func path(in size: CGSize) -> Path {
        Path { path in
            switch self {
            case .crossCourt:
                path.move(to: CGPoint(x: 26, y: size.height * 0.78))
                path.addQuadCurve(
                    to: CGPoint(x: size.width - 28, y: size.height * 0.34),
                    control: CGPoint(x: size.width * 0.46, y: size.height * 0.03)
                )
            case .risingBounce:
                path.move(to: CGPoint(x: 28, y: size.height * 0.7))
                path.addQuadCurve(
                    to: CGPoint(x: size.width - 34, y: size.height * 0.72),
                    control: CGPoint(x: size.width * 0.5, y: size.height * -0.08)
                )
            case .lateCut:
                path.move(to: CGPoint(x: 30, y: size.height * 0.2))
                path.addQuadCurve(
                    to: CGPoint(x: size.width * 0.72, y: size.height * 0.88),
                    control: CGPoint(x: size.width * 0.82, y: size.height * 0.06)
                )
            }
        }
    }

    private func quadratic(_ t: CGFloat, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGPoint {
        CGPoint(
            x: pow(1 - t, 2) * a.x + 2 * (1 - t) * t * b.x + pow(t, 2) * c.x,
            y: pow(1 - t, 2) * a.y + 2 * (1 - t) * t * b.y + pow(t, 2) * c.y
        )
    }
}

struct KnowledgeView: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCanvas()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ProductHeader(
                            eyebrow: knowledgeCopy.eyebrow,
                            title: knowledgeCopy.title,
                            subtitle: knowledgeCopy.subtitle
                        )

                        SectionTitle(knowledgeCopy.rulesTitle)
                        ForEach(knowledgeCopy.ruleCards) { card in
                            NavigationLink(destination: RuleDetailView(card: card)) {
                                KnowledgeCardView(card: card)
                            }
                            .buttonStyle(.plain)
                        }

                        SectionTitle(knowledgeCopy.culturalMapTitle)
                        ForEach(knowledgeCopy.archive) { entry in
                            ArchiveEntryView(entry: entry)
                        }

                        CuratorNote(
                            title: knowledgeCopy.editorialTitle,
                            body: knowledgeCopy.editorialBody
                        )
                    }
                    .padding(18)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(language.archiveTab)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var knowledgeCopy: KnowledgeCopy {
        KnowledgeCopy(language)
    }
}

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    @Binding var selectedSection: AppSection
    @Binding var preferredGlove: String
    @Binding var trainerDifficulty: String
    @Binding var hapticsEnabled: Bool
    @Binding var museumNotesEnabled: Bool
    @Binding var sessionScore: Int
    @Binding var cleanHits: Int
    @Binding var bestTiming: Double

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppCanvas()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ProductHeader(
                            eyebrow: settingsCopy.eyebrow,
                            title: settingsCopy.title,
                            subtitle: settingsCopy.subtitle
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text(settingsCopy.languageSection)
                                .font(.headline)
                            Picker(settingsCopy.languagePicker, selection: $appLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.title).tag(language.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            Text(settingsCopy.languageNote)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .surface()

                        VStack(alignment: .leading, spacing: 14) {
                            Text(settingsCopy.trainingSection)
                                .font(.headline)
                            Picker(settingsCopy.difficultyPicker, selection: $trainerDifficulty) {
                                ForEach(TrainerDifficulty.allCases) { difficulty in
                                    Text(difficulty.title(language)).tag(difficulty.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text((TrainerDifficulty(rawValue: trainerDifficulty) ?? .club).description(language))
                                .font(.callout)
                                .foregroundStyle(.secondary)

                            Toggle(isOn: $hapticsEnabled) {
                                Label(settingsCopy.hapticFeedback, systemImage: "iphone.radiowaves.left.and.right")
                            }
                        }
                        .surface()

                        VStack(alignment: .leading, spacing: 14) {
                            Text(settingsCopy.museumSection)
                                .font(.headline)
                            Picker(settingsCopy.initialPiecePicker, selection: $preferredGlove) {
                                ForEach(Artifact.allCases) { artifact in
                                    Text(artifact.shortTitle(language)).tag(artifact.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)

                            Toggle(isOn: $museumNotesEnabled) {
                                Label(settingsCopy.showCuratorNotes, systemImage: "text.book.closed.fill")
                            }
                        }
                        .surface()

                        VStack(alignment: .leading, spacing: 14) {
                            Text(settingsCopy.progressSection)
                                .font(.headline)
                            ScoreStrip(score: sessionScore, cleanHits: cleanHits, bestTiming: bestTiming)

                            Button {
                                sessionScore = 0
                                cleanHits = 0
                                bestTiming = 0
                            } label: {
                                Label(settingsCopy.resetStats, systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .surface()

                        Button {
                            selectedSection = .trainer
                        } label: {
                            Label(settingsCopy.openTrainer, systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(18)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(language.settingsTab)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var settingsCopy: SettingsCopy {
        SettingsCopy(language)
    }
}

struct HomeHero: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    let startTrainer: () -> Void
    let openStudio: () -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("BLZ")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Pelota")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text(HomeCopy(language).heroSubtitle)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 94, height: 94)
                    Image("BrandLogo")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 66, height: 66)
                        .accessibilityLabel("BLZ Pelota logo")
                }
            }

            HStack(spacing: 10) {
                Button(action: startTrainer) {
                    Label(HomeCopy(language).startRoundButton, systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(HeroPrimaryButtonStyle())

                Button(action: openStudio) {
                    Image(systemName: "cube.transparent")
                        .frame(width: 52, height: 48)
                }
                .buttonStyle(HeroIconButtonStyle())
            }
        }
        .padding(20)
        .background(
            ZStack {
                LinearGradient(colors: [.mixtecaRed, .deepRed], startPoint: .topLeading, endPoint: .bottomTrailing)
                GeometryReader { proxy in
                    Path { path in
                        path.move(to: CGPoint(x: proxy.size.width * 0.05, y: proxy.size.height * 0.84))
                        path.addCurve(
                            to: CGPoint(x: proxy.size.width * 0.96, y: proxy.size.height * 0.24),
                            control1: CGPoint(x: proxy.size.width * 0.32, y: proxy.size.height * 0.58),
                            control2: CGPoint(x: proxy.size.width * 0.56, y: proxy.size.height * 0.08)
                        )
                    }
                    .stroke(Color.white.opacity(0.24), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [12, 10]))

                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 44, height: 44)
                        .position(x: proxy.size.width * 0.74, y: proxy.size.height * 0.36)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .mixtecaRed.opacity(0.24), radius: 22, y: 12)
    }
}

struct TrainingProgramRow: View {
    let step: String
    let title: String
    let detail: String
    let minutes: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Text(step)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.mixtecaRed)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color.ink)
                        Spacer()
                        Text(minutes)
                            .font(.caption.bold())
                            .foregroundStyle(Color.mixtecaRed)
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.mixtecaRed.opacity(0.72))
                    }
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .background(Color.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct QuickAction: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.mixtecaRed)
                    .frame(width: 38, height: 38)
                    .background(Color.redWash)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.ink)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .surface()
        }
        .buttonStyle(.plain)
    }
}

struct RoundChip: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.mixtecaRed)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.ink)
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct HeroPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.mixtecaRed)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? Color.white.opacity(0.84) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct HeroIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .background(configuration.isPressed ? Color.white.opacity(0.12) : Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ProductHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.mixtecaRed)
                    .frame(width: 28, height: 4)
                Text(eyebrow.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(Color.mixtecaRed)
            }

            Text(title)
                .font(.system(.largeTitle, design: .rounded).weight(.black))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ScoreStrip: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    let score: Int
    let cleanHits: Int
    let bestTiming: Double

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        HStack(spacing: 10) {
            ScoreCell(title: scoreCopy.score, value: "\(score)", icon: "target")
            ScoreCell(title: scoreCopy.cleanHits, value: "\(cleanHits)", icon: "checkmark.seal.fill")
            ScoreCell(title: scoreCopy.timing, value: "\(Int(bestTiming))%", icon: "gauge.with.dots.needle.bottom.50percent")
        }
    }

    private var scoreCopy: ScoreCopy {
        ScoreCopy(language)
    }
}

struct ScoreCell: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.mixtecaRed)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 5)
    }
}

struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(Color.ink)
            .padding(.top, 6)
    }
}

struct CuratorNote: View {
    let title: String
    let text: String

    init(title: String, body: String) {
        self.title = title
        self.text = body
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "quote.opening")
                .font(.headline)
                .foregroundStyle(Color.mixtecaRed)
            Text(text)
                .font(.callout)
                .foregroundStyle(Color.ink.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
        .surface()
    }
}

struct InventoryMetric: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.mixtecaRed)
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surface()
    }
}

struct ArtifactRow: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    let artifact: Artifact
    let isSelected: Bool
    let action: () -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.mixtecaRed : Color.redWash)
                    Image(systemName: artifact == .guante ? "hand.raised.fill" : artifact == .pelota ? "circle.circle.fill" : "rectangle.dashed")
                        .foregroundStyle(isSelected ? .white : .mixtecaRed)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(artifact.title(language))
                        .font(.headline)
                        .foregroundStyle(Color.ink)
                    Text(artifact.collectionNote(language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(isSelected ? Color.mixtecaRed : Color.secondary)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct TrainerBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.ink)
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ImpactHalo: View {
    let quality: Double

    var body: some View {
        Circle()
            .stroke(Color.mixtecaRed.opacity(quality > 0 ? 0.38 : 0), lineWidth: 7)
            .frame(width: 74 + quality * 34, height: 74 + quality * 34)
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: quality)
    }
}

struct DrillPlanRow: View {
    @AppStorage("appLanguage") private var appLanguage = AppLanguage.english.rawValue
    let drill: Drill
    let isActive: Bool
    let action: () -> Void

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguage) ?? .english
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: drill.icon)
                    .font(.headline)
                    .foregroundStyle(isActive ? .white : .mixtecaRed)
                    .frame(width: 42, height: 42)
                    .background(isActive ? Color.mixtecaRed : Color.redWash)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(drill.title(language))
                        .font(.headline)
                        .foregroundStyle(Color.ink)
                    Text(drill.focus(language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(isActive ? trainerCopy.activeLabel : trainerCopy.openLabel)
                    .font(.caption.bold())
                    .foregroundStyle(isActive ? Color.mixtecaRed : Color.secondary)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var trainerCopy: TrainerCopy {
        TrainerCopy(language)
    }
}

struct KnowledgeCardView: View {
    let card: KnowledgeCard

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: card.icon)
                    .foregroundStyle(Color.mixtecaRed)
                    .frame(width: 34, height: 34)
                    .background(Color.redWash)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(.headline)
                    Text(card.label.uppercased())
                        .font(.caption2.bold())
                        .foregroundStyle(Color.mixtecaRed)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color.mixtecaRed.opacity(0.72))
            }
            Text(card.body)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surface()
    }
}

struct RuleDetailView: View {
    let card: KnowledgeCard

    var body: some View {
        ZStack {
            AppCanvas()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: card.icon)
                                .font(.title2)
                                .foregroundStyle(Color.mixtecaRed)
                                .frame(width: 48, height: 48)
                                .background(Color.redWash)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(card.label.uppercased())
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.mixtecaRed)
                                Text(card.title)
                                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                                    .foregroundStyle(Color.ink)
                            }
                        }

                        Text(card.body)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .surface()

                    RuleVisual(card: card)
                        .frame(height: 250)
                        .surface()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(card.detailTitle)
                            .font(.title3.bold())
                            .foregroundStyle(Color.ink)
                        Text(card.detailBody)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .surface()

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(card.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color.mixtecaRed)
                                    .frame(width: 22)
                                Text(point)
                                    .font(.callout)
                                    .foregroundStyle(Color.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .surface()

                    CuratorNote(title: card.cueTitle, body: card.cueBody)
                }
                .padding(18)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RuleVisual: View {
    let card: KnowledgeCard

    var body: some View {
        Canvas { context, size in
            let court = CGRect(x: size.width * 0.08, y: size.height * 0.18, width: size.width * 0.84, height: size.height * 0.58)
            let red = Color.mixtecaRed
            let ink = Color.ink

            let courtPath = Path(roundedRect: court, cornerRadius: 8)
            context.fill(courtPath, with: .color(Color.white))
            context.stroke(courtPath, with: .color(red.opacity(0.28)), lineWidth: 3)

            var center = Path()
            center.move(to: CGPoint(x: court.midX, y: court.minY))
            center.addLine(to: CGPoint(x: court.midX, y: court.maxY))
            context.stroke(center, with: .color(ink.opacity(0.12)), style: StrokeStyle(lineWidth: 2, dash: [8, 8]))

            switch card.kind {
            case .serve:
                drawServe(context: context, size: size, court: court)
            case .glove:
                drawGlove(context: context, size: size, court: court)
            case .point:
                drawPoint(context: context, size: size, court: court)
            case .court:
                drawCourt(context: context, size: size, court: court)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.redWash.opacity(0.55), Color.white, Color.appBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func drawServe(context: GraphicsContext, size: CGSize, court: CGRect) {
        var arc = Path()
        arc.move(to: CGPoint(x: court.minX + 24, y: court.maxY - 28))
        arc.addQuadCurve(
            to: CGPoint(x: court.maxX - 34, y: court.minY + 34),
            control: CGPoint(x: court.midX - 12, y: court.minY - 58)
        )
        context.stroke(arc, with: .color(.mixtecaRed), style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [12, 9]))
        drawBall(context: context, at: CGPoint(x: court.maxX - 34, y: court.minY + 34), radius: 15)
        drawPlayer(context: context, at: CGPoint(x: court.minX + 30, y: court.maxY - 24))
    }

    private func drawGlove(context: GraphicsContext, size: CGSize, court: CGRect) {
        let palm = CGRect(x: court.midX - 44, y: court.midY - 18, width: 88, height: 90)
        context.fill(Path(roundedRect: palm, cornerRadius: 18), with: .color(.deepRed))
        context.fill(Path(roundedRect: CGRect(x: court.midX - 26, y: court.minY + 18, width: 52, height: 94), cornerRadius: 14), with: .color(.mixtecaRed))
        context.stroke(Path(roundedRect: palm.insetBy(dx: 8, dy: 8), cornerRadius: 14), with: .color(.white.opacity(0.5)), lineWidth: 2)
        for index in 0..<7 {
            let y = court.midY + CGFloat(index * 12) - 10
            drawBall(context: context, at: CGPoint(x: court.midX + 32, y: y), radius: 5)
        }
    }

    private func drawPoint(context: GraphicsContext, size: CGSize, court: CGRect) {
        for index in 0..<4 {
            let x = court.minX + CGFloat(index) * court.width / 3
            var mark = Path()
            mark.move(to: CGPoint(x: x, y: court.minY))
            mark.addLine(to: CGPoint(x: x, y: court.maxY))
            context.stroke(mark, with: .color(.mixtecaRed.opacity(index == 2 ? 0.42 : 0.14)), lineWidth: index == 2 ? 4 : 2)
        }
        drawBall(context: context, at: CGPoint(x: court.midX + 40, y: court.midY), radius: 17)
        context.draw(Text("+1").font(.system(size: 44, weight: .black, design: .rounded)).foregroundColor(.mixtecaRed), at: CGPoint(x: court.midX - 56, y: court.midY))
    }

    private func drawCourt(context: GraphicsContext, size: CGSize, court: CGRect) {
        for index in 1...4 {
            let y = court.minY + CGFloat(index) * court.height / 5
            var line = Path()
            line.move(to: CGPoint(x: court.minX, y: y))
            line.addLine(to: CGPoint(x: court.maxX, y: y))
            context.stroke(line, with: .color(.ink.opacity(0.08)), lineWidth: 2)
        }
        let zones = [
            CGRect(x: court.minX + 18, y: court.minY + 22, width: 72, height: 54),
            CGRect(x: court.maxX - 92, y: court.maxY - 76, width: 72, height: 54)
        ]
        for zone in zones {
            context.fill(Path(roundedRect: zone, cornerRadius: 8), with: .color(.redWash.opacity(0.9)))
            context.stroke(Path(roundedRect: zone, cornerRadius: 8), with: .color(.mixtecaRed), lineWidth: 2)
        }
    }

    private func drawBall(context: GraphicsContext, at point: CGPoint, radius: CGFloat) {
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: rect), with: .radialGradient(Gradient(colors: [.white, .mixtecaRed, .deepRed]), center: point, startRadius: 2, endRadius: radius))
    }

    private func drawPlayer(context: GraphicsContext, at point: CGPoint) {
        context.fill(Path(ellipseIn: CGRect(x: point.x - 14, y: point.y - 14, width: 28, height: 28)), with: .color(.ink.opacity(0.72)))
        context.fill(Path(roundedRect: CGRect(x: point.x - 18, y: point.y + 6, width: 36, height: 44), cornerRadius: 10), with: .color(.deepRed))
    }
}

struct ArchiveEntryView: View {
    let entry: ArchiveEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.mixtecaRed)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(Color.redWash)
                    .frame(width: 3, height: 58)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.region)
                        .font(.headline)
                    Text(entry.focus)
                        .font(.caption.bold())
                        .foregroundStyle(Color.mixtecaRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.redWash)
                        .clipShape(Capsule())
                }
                Text(entry.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .surface()
    }
}

struct TrainingCourtGrid: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            for x in stride(from: 0, through: size.width, by: 34) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: 34) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.ink.opacity(0.055)), lineWidth: 1)

            var middle = Path()
            middle.move(to: CGPoint(x: 0, y: size.height * 0.5))
            middle.addLine(to: CGPoint(x: size.width, y: size.height * 0.5))
            context.stroke(middle, with: .color(.mixtecaRed.opacity(0.3)), lineWidth: 2)
        }
    }
}

struct AppCanvas: View {
    var body: some View {
        Color.appBackground
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.72),
                        Color.redWash.opacity(0.2),
                        Color.appBackground.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.mixtecaRed.opacity(0.055))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -92, y: 86)
            }
            .ignoresSafeArea()
    }
}

struct SurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.055), radius: 14, y: 6)
    }
}

extension View {
    func surface() -> some View {
        modifier(SurfaceModifier())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? Color.deepRed : Color.mixtecaRed)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.mixtecaRed)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? Color.redWash.opacity(0.55) : Color.redWash)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct KnowledgeCard: Identifiable {
    let kind: RuleKind
    var id: RuleKind { kind }
    let title: String
    let label: String
    let body: String
    let icon: String
    let detailTitle: String
    let detailBody: String
    let keyPoints: [String]
    let cueTitle: String
    let cueBody: String
}

enum RuleKind: String, Hashable {
    case serve
    case glove
    case point
    case court
}

struct ArchiveEntry: Identifiable {
    let id = UUID()
    let region: String
    let focus: String
    let detail: String
}

private func copy(_ language: AppLanguage, en: String, pt: String, es: String) -> String {
    switch language {
    case .english: en
    case .portuguese: pt
    case .spanish: es
    }
}

struct HomeCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var heroSubtitle: String { copy(language, en: "Heavy-glove museum + reaction trainer for timing, reading and respect for the real game.", pt: "Museu da luva pesada + treino de leitura para reação, timing e respeito pelo jogo real.", es: "Museo de guante pesado + trainer de lectura para reaccion, timing y respeto por el juego real.") }
    var startRoundButton: String { copy(language, en: "Start round", pt: "Começar rodada", es: "Empezar ronda") }
    var recommendedTitle: String { copy(language, en: "Recommended session", pt: "Sessão recomendada", es: "Sesion recomendada") }
    var recommendedSubtitle: String { copy(language, en: "12 minutes: short museum pass, visual reading and precision under pressure.", pt: "12 minutos: museu curto, leitura visual e precisão sob pressão.", es: "12 minutos: museo corto, lectura visual y precision bajo presion.") }
    var programOneTitle: String { copy(language, en: "Glove inspection", pt: "Inspeção da luva", es: "Inspeccion de guante") }
    var programOneDetail: String { copy(language, en: "Rotate the object and locate palm, rivets and wrist support.", pt: "Gire a peça e localize palma, rebites e punho.", es: "Gira la pieza y localiza palma, remaches y muneca.") }
    var programTwoTitle: String { copy(language, en: "Trajectory reading", pt: "Leitura de trajetória", es: "Lectura de trayectoria") }
    var programTwoDetail: String { copy(language, en: "Follow three curves without touching: learn rhythm first.", pt: "Siga três curvas sem tocar: aprenda o ritmo primeiro.", es: "Sigue tres curvas sin tocar: aprende ritmo primero.") }
    var programThreeTitle: String { copy(language, en: "Precision round", pt: "Rodada de precisão", es: "Ronda de precision") }
    var programThreeDetail: String { copy(language, en: "45 seconds, three misses max, target 70%+.", pt: "45 segundos, máximo três erros, objetivo 70%+.", es: "45 segundos, maximo tres errores, objetivo 70%+.") }
    var quickAccessTitle: String { copy(language, en: "Quick access", pt: "Acesso rápido", es: "Accesos rapidos") }
    var openStudioTitle: String { copy(language, en: "Open Studio", pt: "Abrir Estúdio", es: "Abrir Studio") }
    var openStudioSubtitle: String { copy(language, en: "3D + inventory", pt: "3D + inventário", es: "3D + inventario") }
    var trainTitle: String { copy(language, en: "Train", pt: "Treinar", es: "Entrenar") }
    var trainSubtitle: String { copy(language, en: "timed round", pt: "rodada cronometrada", es: "ronda cronometrada") }
    var rulesTitle: String { copy(language, en: "Rules", pt: "Regras", es: "Reglas") }
    var rulesSubtitle: String { copy(language, en: "living archive", pt: "arquivo vivo", es: "archivo vivo") }
    var settingsTitle: String { copy(language, en: "Settings", pt: "Ajustes", es: "Ajustes") }
    var settingsSubtitle: String { copy(language, en: "difficulty", pt: "dificuldade", es: "dificultad") }
}

struct StudioCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var title: String { copy(language, en: "Glove, ball, reading", pt: "Luva, bola, leitura", es: "Guante, pelota, lectura") }
    var subtitle: String { copy(language, en: "A tactile museum and practice system for understanding the real weight of the game without pretending the phone replaces the court.", pt: "Um museu tátil e um sistema de prática para entender o peso real do jogo sem fingir que o telefone substitui a quadra.", es: "Un museo tactil y un sistema de practica para entender el peso real del juego sin fingir que el telefono reemplaza la cancha.") }
    var piecePicker: String { copy(language, en: "Object", pt: "Peça", es: "Pieza") }
    var detailLevel: String { copy(language, en: "Detail level", pt: "Nível de detalhe", es: "Nivel de detalle") }
    var curatorTitle: String { copy(language, en: "Curator note", pt: "Nota de curadoria", es: "Nota de curaduria") }
    var curatorBody: String { copy(language, en: "The mixteca glove is not just protection. Its mass changes posture, forces the player to read the ball before impact and turns every strike into a full-body decision.", pt: "A luva mixteca não é só proteção. Sua massa muda a postura, obriga a ler a bola antes do impacto e transforma cada golpe numa decisão de corpo inteiro.", es: "La guanteleta mixteca no es solo proteccion. Su masa cambia la postura, obliga a leer la pelota antes del impacto y vuelve cada golpe una decision de cuerpo completo.") }
    var inventoryTitle: String { copy(language, en: "Technical inventory", pt: "Inventário técnico", es: "Inventario tecnico") }
    var massMetric: String { copy(language, en: "Visual mass", pt: "Massa visual", es: "Masa visual") }
    var readingMetric: String { copy(language, en: "Reading", pt: "Leitura", es: "Lectura") }
    var riskMetric: String { copy(language, en: "Risk", pt: "Risco", es: "Riesgo") }
    var trainingMetric: String { copy(language, en: "Training", pt: "Treino", es: "Entreno") }
    var museumPiecesTitle: String { copy(language, en: "Museum objects", pt: "Peças do museu", es: "Piezas del museo") }
}

struct TrainerCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var eyebrow: String { copy(language, en: "Reaction Trainer", pt: "Treino de reação", es: "Trainer de reaccion") }
    var title: String { copy(language, en: "Impact round", pt: "Rodada de impacto", es: "Ronda de impacto") }
    var subtitle: String { copy(language, en: "45 seconds, three misses max, clean reading. The mechanic rewards waiting for the window, not tapping fast without judgment.", pt: "45 segundos, no máximo três erros, leitura limpa. A mecânica premia esperar a janela, não tocar rápido sem critério.", es: "45 segundos, tres errores maximo, lectura limpia. La mecanica premia esperar la ventana, no tocar rapido sin criterio.") }
    var initialFeedback: String { copy(language, en: "Wait for the red window. Strike when the ball crosses the center.", pt: "Espere a janela vermelha. Golpeie quando a bola cruzar o centro.", es: "Espera la ventana roja. Golpea cuando la pelota cruza el centro.") }
    var drillPicker: String { copy(language, en: "Drill", pt: "Exercício", es: "Drill") }
    var timeChip: String { copy(language, en: "Time", pt: "Tempo", es: "Tiempo") }
    var missesChip: String { copy(language, en: "Misses", pt: "Erros", es: "Errores") }
    var gradeChip: String { copy(language, en: "Grade", pt: "Nota", es: "Grado") }
    var streakBadge: String { copy(language, en: "Streak", pt: "Sequência", es: "Streak") }
    var qualityBadge: String { copy(language, en: "Quality", pt: "Qualidade", es: "Quality") }
    var bestBadge: String { copy(language, en: "Best", pt: "Melhor", es: "Best") }
    var startButton: String { copy(language, en: "Start", pt: "Iniciar", es: "Iniciar") }
    var pauseButton: String { copy(language, en: "Pause", pt: "Pausar", es: "Pausar") }
    var continueButton: String { copy(language, en: "Continue", pt: "Continuar", es: "Continuar") }
    var resetButton: String { copy(language, en: "Reset", pt: "Reiniciar", es: "Reset") }
    var coachCueTitle: String { copy(language, en: "Coach cue", pt: "Dica do treinador", es: "Coach cue") }
    var practicePlanTitle: String { copy(language, en: "Practice plan", pt: "Plano de prática", es: "Plan de practica") }
    var activeLabel: String { copy(language, en: "Active", pt: "Ativo", es: "Activo") }
    var openLabel: String { copy(language, en: "Open", pt: "Abrir", es: "Abrir") }
    var roundComplete: String { copy(language, en: "Round complete. Review your grade and change drill if you need another read.", pt: "Rodada completa. Revise sua nota e troque de exercício se precisar de outra leitura.", es: "Ronda completa. Revisa tu grado y cambia de drill si necesitas otra lectura.") }
    var ballPassed: String { copy(language, en: "The ball passed. Reset your eyes on the opponent's imaginary shoulder.", pt: "A bola passou. Reinicie o olhar no ombro imaginário do rival.", es: "La pelota paso. Reinicia la mirada en el hombro imaginario del rival.") }
    var threeMissesSlowDown: String { copy(language, en: "Round closed after three misses. Lower the speed or return to School to clean the read.", pt: "Rodada fechada por três erros. Reduza a velocidade ou volte à Escola para limpar a leitura.", es: "Ronda cerrada por tres errores. Baja velocidad o vuelve a Escuela para limpiar la lectura.") }
    var comboFeedback: String { copy(language, en: "Five-hit combo. You are holding tournament rhythm without rushing the hand.", pt: "Combo de cinco. Você mantém ritmo de torneio sem adiantar a mão.", es: "Combo de cinco. Mantienes ritmo de torneo sin adelantar la mano.") }
    var cleanImpactFeedback: String { copy(language, en: "Clean impact. Your read was early and contact landed inside the central window.", pt: "Impacto limpo. Sua leitura foi cedo e o contato caiu dentro da janela central.", es: "Impacto limpio. Tu lectura fue temprana y el contacto cayo dentro de la ventana central.") }
    var goodContactFeedback: String { copy(language, en: "Good contact. Adjust half a beat earlier so you do not chase the ball.", pt: "Bom contato. Ajuste meio pulso antes para não perseguir a bola.", es: "Buen contacto. Ajusta medio pulso antes para no perseguir la pelota.") }
    var outsideWindow: String { copy(language, en: "Outside the window. Stay patient: the ball is struck when it arrives, not when it appears.", pt: "Fora da janela. Tenha paciência: a bola é golpeada quando chega, não quando aparece.", es: "Fuera de ventana. Mantente paciente: la pelota se golpea cuando llega, no cuando aparece.") }
    var threeMissesFinished: String { copy(language, en: "Three misses. Round finished: read the trajectory again before touching.", pt: "Três erros. Rodada encerrada: leia a trajetória antes de tocar.", es: "Tres errores. Ronda terminada: vuelve a leer trayectoria antes de tocar.") }
    var roundActive: String { copy(language, en: "Round active. Breathe, follow the curve and tap only inside the red window.", pt: "Rodada ativa. Respire, siga a curva e toque apenas dentro da janela vermelha.", es: "Ronda activa. Respira, sigue la curva y toca solo dentro de la ventana roja.") }
}

struct KnowledgeCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var eyebrow: String { copy(language, en: "Living archive", pt: "Arquivo vivo", es: "Archivo vivo") }
    var title: String { copy(language, en: "Rules, history, regions", pt: "Regras, história, regiões", es: "Reglas, historia, regiones") }
    var subtitle: String { copy(language, en: "Reference content for respectful play: what to watch, what to ask and how to recognize local variants.", pt: "Conteúdo de consulta para jogar com respeito: o que observar, o que perguntar e como reconhecer variantes locais.", es: "Contenido de consulta para jugar con respeto: que mirar, que preguntar y como reconocer variantes locales.") }
    var rulesTitle: String { copy(language, en: "Rules explained", pt: "Regras explicadas", es: "Reglas explicadas") }
    var culturalMapTitle: String { copy(language, en: "Cultural map", pt: "Mapa cultural", es: "Mapa cultural") }
    var editorialTitle: String { copy(language, en: "Editorial principle", pt: "Princípio editorial", es: "Principio editorial") }
    var editorialBody: String { copy(language, en: "BLZ Pelota avoids presenting one rule set as definitive. Tradition changes by community, so the archive separates general principles, variants and regional context.", pt: "BLZ Pelota evita apresentar uma regra única como definitiva. A tradição muda por comunidade; por isso o arquivo separa princípios gerais, variantes e contexto regional.", es: "BLZ Pelota evita presentar una regla unica como definitiva. La tradicion cambia por comunidad; por eso el archivo separa principios generales, variantes y contexto regional.") }
    var ruleCards: [KnowledgeCard] {
        [
            KnowledgeCard(
                kind: .serve,
                title: copy(language, en: "Serve", pt: "Saque", es: "Saque"),
                label: copy(language, en: "Opening", pt: "Início", es: "Inicio"),
                body: copy(language, en: "The serve opens the read. In many variants, the first strike seeks depth and forces the rival to judge bounce, distance and body position.", pt: "O saque abre a leitura. Em muitas variantes, o golpe inicial busca profundidade e obriga o rival a medir quique, distância e posição corporal.", es: "El saque abre la lectura. En muchas variantes, el golpe inicial busca profundidad y obliga al rival a medir bote, distancia y posicion corporal."),
                icon: "flag.checkered",
                detailTitle: copy(language, en: "How the opening works", pt: "Como a abertura funciona", es: "Como funciona la apertura"),
                detailBody: copy(language, en: "A serve is less about raw speed than about starting the point with a difficult read. A deep first ball can move the receiver backward, expose a weak side and decide whether the rally begins as attack or recovery.", pt: "O saque é menos sobre velocidade pura e mais sobre iniciar o ponto com uma leitura difícil. Uma bola profunda pode empurrar o recebedor, expor o lado fraco e decidir se a troca começa em ataque ou recuperação.", es: "El saque trata menos de velocidad pura y mas de iniciar el punto con una lectura dificil. Una pelota profunda puede mover al receptor, exponer el lado debil y decidir si el intercambio empieza en ataque o recuperacion."),
                keyPoints: [
                    copy(language, en: "Look for depth before power.", pt: "Procure profundidade antes de força.", es: "Busca profundidad antes que fuerza."),
                    copy(language, en: "The receiver reads bounce, lane and shoulder position.", pt: "O recebedor lê quique, corredor e posição do ombro.", es: "El receptor lee bote, carril y posicion del hombro."),
                    copy(language, en: "Local agreements define exact serve limits.", pt: "Acordos locais definem os limites exatos do saque.", es: "Los acuerdos locales definen limites exactos del saque.")
                ],
                cueTitle: copy(language, en: "Reading cue", pt: "Dica de leitura", es: "Clave de lectura"),
                cueBody: copy(language, en: "Do not chase the hand. Watch where the ball will land and prepare the body before the glove arrives.", pt: "Não persiga a mão. Observe onde a bola vai cair e prepare o corpo antes da luva chegar.", es: "No persigas la mano. Mira donde caera la pelota y prepara el cuerpo antes de que llegue el guante.")
            ),
            KnowledgeCard(
                kind: .glove,
                title: copy(language, en: "Glove", pt: "Luva", es: "Guante"),
                label: copy(language, en: "Equipment", pt: "Equipamento", es: "Equipo"),
                body: copy(language, en: "The glove can be heavy and rigid. The app presents it as a study object because safety and real craft depend on correct material.", pt: "A luva pode ser pesada e rígida. O app a apresenta como peça de estudo porque segurança e ofício real dependem do material correto.", es: "La guanteleta puede ser pesada y rigida. La app la presenta como pieza de estudio porque la seguridad y el oficio real dependen del material correcto."),
                icon: "hand.raised.fill",
                detailTitle: copy(language, en: "Why the glove changes everything", pt: "Por que a luva muda tudo", es: "Por que el guante lo cambia todo"),
                detailBody: copy(language, en: "The guante is a striking tool, a shield and a craft object at the same time. Its weight changes the timing of the swing, so players learn to set their feet early and let the body carry the strike.", pt: "A luva é ferramenta de golpe, proteção e peça artesanal ao mesmo tempo. Seu peso muda o tempo do movimento, então jogadores aprendem a firmar os pés cedo e deixar o corpo carregar o golpe.", es: "El guante es herramienta de golpe, proteccion y pieza artesanal a la vez. Su peso cambia el tiempo del movimiento, por eso se aprende a plantar los pies temprano y dejar que el cuerpo lleve el golpe."),
                keyPoints: [
                    copy(language, en: "Mass supports impact but punishes late movement.", pt: "A massa sustenta o impacto, mas pune movimento tardio.", es: "La masa sostiene el impacto, pero castiga el movimiento tardio."),
                    copy(language, en: "Rivets, palm and wrist support are safety-critical.", pt: "Rebites, palma e punho são essenciais para segurança.", es: "Remaches, palma y muneca son claves para seguridad."),
                    copy(language, en: "Phone training should develop reading, not imitate real contact.", pt: "O treino no telefone deve desenvolver leitura, não imitar contato real.", es: "El treino en telefono debe desarrollar lectura, no imitar contacto real.")
                ],
                cueTitle: copy(language, en: "Museum cue", pt: "Dica de museu", es: "Clave de museo"),
                cueBody: copy(language, en: "Rotate the model and identify the palm face, fasteners and wrist channel before thinking about the strike.", pt: "Gire o modelo e identifique a face da palma, fixadores e canal do punho antes de pensar no golpe.", es: "Gira el modelo e identifica la palma, fijaciones y canal de muneca antes de pensar en el golpe.")
            ),
            KnowledgeCard(
                kind: .point,
                title: copy(language, en: "Point", pt: "Ponto", es: "Tanto"),
                label: copy(language, en: "Score", pt: "Placar", es: "Marcador"),
                body: copy(language, en: "Scoring forms change by community and tournament. The common principle: sustain the rally, defend the line and convert rival errors.", pt: "As formas de pontuar mudam por comunidade e torneio. O princípio comum: sustentar a troca, defender a linha e converter erros do rival.", es: "Las formas de puntuar cambian por comunidad y torneo. El principio comun: sostener el intercambio, defender linea y convertir errores del rival."),
                icon: "number",
                detailTitle: copy(language, en: "What usually decides a point", pt: "O que costuma decidir um ponto", es: "Que suele decidir un tanto"),
                detailBody: copy(language, en: "A point often turns on control: keeping the ball playable, forcing the opponent into a bad angle and respecting the agreed boundaries. The visible score may vary, but the tactical logic stays familiar.", pt: "Um ponto costuma virar no controle: manter a bola jogável, forçar ângulo ruim no rival e respeitar os limites combinados. O placar visível pode variar, mas a lógica tática permanece familiar.", es: "Un tanto suele decidirse por control: mantener la pelota jugable, forzar mal angulo al rival y respetar limites acordados. El marcador visible puede variar, pero la logica tactica permanece."),
                keyPoints: [
                    copy(language, en: "Errors matter as much as winners.", pt: "Erros contam tanto quanto golpes vencedores.", es: "Los errores pesan tanto como golpes ganadores."),
                    copy(language, en: "Line defense is a shared tactical language.", pt: "Defender a linha é uma linguagem tática comum.", es: "Defender linea es lenguaje tactico comun."),
                    copy(language, en: "Always confirm local scoring before a match.", pt: "Sempre confirme a pontuação local antes da partida.", es: "Siempre confirma marcador local antes del partido.")
                ],
                cueTitle: copy(language, en: "Score cue", pt: "Dica de placar", es: "Clave de marcador"),
                cueBody: copy(language, en: "Think in pressure, not only points: each clean return can make the next ball easier.", pt: "Pense em pressão, não só em pontos: cada devolução limpa pode facilitar a próxima bola.", es: "Piensa en presion, no solo en puntos: cada devolucion limpia puede facilitar la siguiente pelota.")
            ),
            KnowledgeCard(
                kind: .court,
                title: copy(language, en: "Court", pt: "Quadra", es: "Cancha"),
                label: copy(language, en: "Space", pt: "Espaço", es: "Espacio"),
                body: copy(language, en: "It is played in long spaces: streets, fields or adapted courts. The orientation of the ground transforms strategy.", pt: "Joga-se em espaços longos: ruas, campos ou quadras adaptadas. A orientação do terreno transforma a estratégia.", es: "Se juega en espacios largos: calles, campos o canchas adaptadas. La orientacion del terreno transforma la estrategia."),
                icon: "rectangle.dashed",
                detailTitle: copy(language, en: "Reading the playing space", pt: "Lendo o espaço de jogo", es: "Leer el espacio de juego"),
                detailBody: copy(language, en: "Pelota mixteca is often shaped by the place where it is played. Street width, surface, sun, slope and crowd position can all become part of the match rhythm.", pt: "A pelota mixteca muitas vezes é moldada pelo lugar onde se joga. Largura da rua, piso, sol, inclinação e posição do público podem entrar no ritmo da partida.", es: "La pelota mixteca muchas veces se moldea por el lugar donde se juega. Ancho de calle, piso, sol, pendiente y publico pueden entrar en el ritmo del partido."),
                keyPoints: [
                    copy(language, en: "Long lanes reward depth and patience.", pt: "Corredores longos premiam profundidade e paciência.", es: "Carriles largos premian profundidad y paciencia."),
                    copy(language, en: "Surface changes bounce and recovery timing.", pt: "O piso muda o quique e o tempo de recuperação.", es: "La superficie cambia bote y tiempo de recuperacion."),
                    copy(language, en: "Boundaries should be agreed before play starts.", pt: "Limites devem ser combinados antes do jogo.", es: "Los limites deben acordarse antes de jugar.")
                ],
                cueTitle: copy(language, en: "Space cue", pt: "Dica de espaço", es: "Clave de espacio"),
                cueBody: copy(language, en: "Before the rally, scan the lane: where does the ball die, where does it speed up, and where is the safe recovery step?", pt: "Antes da troca, leia o corredor: onde a bola morre, onde acelera e onde está o passo seguro de recuperação?", es: "Antes del intercambio, lee el carril: donde muere la pelota, donde acelera y donde esta el paso seguro de recuperacion?")
            )
        ]
    }
    var archive: [ArchiveEntry] {
        [
            ArchiveEntry(region: "Oaxaca", focus: copy(language, en: "mixtec root", pt: "raiz mixteca", es: "raiz mixteca"), detail: copy(language, en: "Glove makers, community memory and celebrations where pelota remains a social language.", pt: "Ofício de luveiros, memória comunitária e festas onde a pelota segue como linguagem social.", es: "Oficio de guanteros, memoria comunitaria y fiestas donde la pelota sigue siendo lenguaje social.")),
            ArchiveEntry(region: "Puebla", focus: copy(language, en: "variants", pt: "variantes", es: "variantes"), detail: copy(language, en: "Clubs and families preserve local forms of court, ball and match agreement.", pt: "Clubes e famílias conservam formas locais de quadra, bola e acordo de partida.", es: "Clubes y familias conservan formas locales de cancha, pelota y acuerdo de partido.")),
            ArchiveEntry(region: "California", focus: copy(language, en: "diaspora", pt: "diáspora", es: "diaspora"), detail: copy(language, en: "Migrant communities sustain tournaments, training and intergenerational audiovisual archives.", pt: "Comunidades migrantes sustentam torneios, treino e arquivo audiovisual intergeracional.", es: "Comunidades migrantes sostienen torneos, entrenamiento y archivo audiovisual intergeneracional.")),
            ArchiveEntry(region: copy(language, en: "Mexico City", pt: "Cidade do México", es: "Ciudad de Mexico"), focus: copy(language, en: "exhibition", pt: "exibição", es: "exhibicion"), detail: copy(language, en: "Cultural meetings connect pelota mixteca with museums, universities and new publics.", pt: "Encontros culturais conectam a pelota mixteca a museus, universidades e novos públicos.", es: "Encuentros culturales conectan la pelota mixteca con museos, universidades y nuevos publicos."))
        ]
    }
}

struct SettingsCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var eyebrow: String { copy(language, en: "Settings", pt: "Ajustes", es: "Ajustes") }
    var title: String { copy(language, en: "Personalize the session", pt: "Personalize a sessão", es: "Personaliza la sesion") }
    var subtitle: String { copy(language, en: "Control language, difficulty, initial object, feedback and training stats.", pt: "Controle idioma, dificuldade, peça inicial, feedback e estatísticas de treino.", es: "Controla idioma, dificultad, pieza inicial, feedback y estadisticas de entrenamiento.") }
    var languageSection: String { copy(language, en: "Language", pt: "Idioma", es: "Idioma") }
    var languagePicker: String { copy(language, en: "App language", pt: "Idioma do app", es: "Idioma de app") }
    var languageNote: String { copy(language, en: "The full interface, archive content and trainer feedback update immediately.", pt: "Toda a interface, o arquivo e o feedback do treino mudam imediatamente.", es: "La interfaz completa, el archivo y el feedback del trainer cambian de inmediato.") }
    var trainingSection: String { copy(language, en: "Training", pt: "Treino", es: "Entrenamiento") }
    var difficultyPicker: String { copy(language, en: "Difficulty", pt: "Dificuldade", es: "Dificultad") }
    var hapticFeedback: String { copy(language, en: "Haptic feedback", pt: "Feedback tátil", es: "Feedback haptico") }
    var museumSection: String { copy(language, en: "Museum", pt: "Museu", es: "Museo") }
    var initialPiecePicker: String { copy(language, en: "Initial object", pt: "Peça inicial", es: "Pieza inicial") }
    var showCuratorNotes: String { copy(language, en: "Show curator notes", pt: "Mostrar notas de curadoria", es: "Mostrar notas curatoriales") }
    var progressSection: String { copy(language, en: "Progress", pt: "Progresso", es: "Progreso") }
    var resetStats: String { copy(language, en: "Reset statistics", pt: "Reiniciar estatísticas", es: "Reiniciar estadisticas") }
    var openTrainer: String { copy(language, en: "Open trainer", pt: "Abrir treino", es: "Abrir trainer") }
}

struct ScoreCopy {
    let language: AppLanguage
    init(_ language: AppLanguage) { self.language = language }

    var score: String { copy(language, en: "Score", pt: "Placar", es: "Score") }
    var cleanHits: String { copy(language, en: "Clean", pt: "Limpos", es: "Limpios") }
    var timing: String { copy(language, en: "Timing", pt: "Timing", es: "Timing") }
}

extension Color {
    static let appBackground = Color(red: 0.985, green: 0.982, blue: 0.972)
    static let warmWhite = Color(red: 0.98, green: 0.94, blue: 0.88)
    static let redWash = Color(red: 0.98, green: 0.88, blue: 0.86)
    static let mixtecaRed = Color(red: 0.79, green: 0.08, blue: 0.08)
    static let gloveRed = Color(red: 0.92, green: 0.02, blue: 0.04)
    static let gloveHighlight = Color(red: 1.0, green: 0.12, blue: 0.12)
    static let deepRed = Color(red: 0.45, green: 0.02, blue: 0.04)
    static let ink = Color(red: 0.12, green: 0.11, blue: 0.11)
    static let steel = Color(red: 0.72, green: 0.72, blue: 0.72)
}

#Preview {
    ContentView()
}
