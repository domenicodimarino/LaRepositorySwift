import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [BadgeModel] = []
    private var certifiedPOIIDs: Set<UUID> = []

    init() {
        badges = [
            BadgeModel(cityName: "Salerno", totalPOI: 16, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["castello_arechi","chiesa_monte_morti","chiesa_sangiorgio","chiesa_ssannunziata","duomo_salerno","giardino_minerva","museo_archeologico","museo_diocesano_salerno","museo_sbarco","museo_virtuale","piazza_liberta","porto_salerno","saragnano","stadio_arechi","teatro_verdi","velia"], cityStory: "Salerno è una storica città campana affacciata sul mar Tirreno, nota per la sua posizione strategica tra la Costiera Amalfitana e il Cilento, ma soprattutto per il suo prestigioso passato. Nel Medioevo, Salerno fu capitale del Principato Longobardo (IX-XI sec.) e visse il suo massimo splendore con la Scuola Medica Salernitana, considerata la prima e più importante istituzione medica d’Europa, anticipando le università moderne. Dopo il periodo normanno, la città visse secoli alterni tra dominazioni sveve, angioine, aragonesi e spagnole, conservando un ruolo chiave nei traffici marittimi e nella vita religiosa e culturale. Nel XX secolo, Salerno ebbe un ruolo storico durante la Seconda guerra mondiale: nel 1943, dopo lo sbarco degli Alleati, divenne capitale d’Italia per alcuni mesi, ospitando il governo provvisorio. Oggi Salerno è una città dinamica e in continua trasformazione. È nota per il centro storico medievale, il lungomare, il Duomo di San Matteo (XI sec.), le Luci d’Artista invernali e il mix equilibrato tra storia, arte, mare e innovazione."),
            BadgeModel(cityName: "Cetara", totalPOI: 5, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["chiesa_sanpietro","costantinopoli","fabbrica_nettuno","piazza_sanfra","torre_di_cetara"], cityStory: "Cetara è un affascinante borgo marinaro della Costiera Amalfitana, noto per la sua profonda identità legata al mare e alla pesca, in particolare del tonno e delle alici, da cui si ricava la celebre colatura di alici, prodotto tradizionale di origini antichissime. Il nome “Cetara” deriva dal latino cetaria, ovvero “luogo dove si lavorano i grossi pesci” (come i tonni). Le sue origini risalgono all’epoca medievale, quando fu fondata come colonia di pescatori saraceni, insediati qui probabilmente per la posizione strategica della costa. Nel Medioevo e nel Rinascimento, Cetara fu spesso bersaglio di attacchi pirateschi, per cui fu costruita una torre vicereale di difesa costiera (ancora visibile e ben conservata). Nel corso dei secoli, Cetara ha sempre mantenuto la sua vocazione marinara, diventando uno dei porti più attivi per la pesca del tonno rosso. Ancora oggi la pesca rappresenta una parte vitale dell’economia locale, insieme al turismo gastronomico. Oggi è un piccolo gioiello sospeso tra tradizione e bellezza naturale, famoso per il suo centro pittoresco, la spiaggia ai piedi del paese, la chiesa di San Pietro Apostolo e soprattutto per la colatura di alici, presidio Slow Food e simbolo della cultura cetarese."),
            BadgeModel(cityName: "Cava de' Tirreni", totalPOI: 11, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: ["caduti", "abbazia","chiesa_avvocatella","chiesa_sanlo","duomo_cava","giardini_sangio","madonna_olmo","purgatorio","santuario","villa_comunale","chiesa_sanrocco"], cityStory: "Cava de’ Tirreni è una città campana dal passato ricco e affascinante, situata tra i Monti Lattari e la Costiera Amalfitana. Le sue origini risalgono a tempi antichi, ma è nel Medioevo che inizia a svilupparsi come centro urbano, grazie alla fondazione, nel 1011, dell’Abbazia Benedettina della Santissima Trinità da parte di Sant’Alferio. L’abbazia divenne presto un importante centro religioso e culturale del Sud Italia. Attorno a questo polo spirituale nacque il borgo medievale, oggi rappresentato dal celebre corso porticato (Corso Umberto I), simbolo della città. Nel 1497, per la sua fedeltà alla monarchia, Cava ricevette dal re Federico d’Aragona il titolo di “Città Fedelissima”, che ancora oggi porta con orgoglio. Tra il XVI e il XVIII secolo, fu un centro culturale, tipografico e commerciale, attirando anche viaggiatori europei in epoca Grand Tour. Nell’Ottocento e Novecento si espanse, integrando molte frazioni e diventando un punto strategico tra l’entroterra e il mare. Oggi è una città moderna, viva, ricca di storia, tradizioni popolari (come la Disfida dei Trombonieri) e vicina a bellezze come Salerno e la Costiera Amalfitana. L’Abbazia è ancora attiva e il suo centro storico è una delle mete più caratteristiche della Campania."),
        ]
    }
    
    func addPOI(for city: String, imageName: String?) {
        if let index = badges.firstIndex(where: { $0.cityName == city }) {
            badges[index].totalPOI += 1
            if let imgName = imageName {
                badges[index].discoveredImageNames.append(imgName)
            }
            objectWillChange.send()
        } else {
            badges.append(BadgeModel(cityName: city, totalPOI: 1, certifiedPOI: 0, unlockedDate: nil, discoveredImageNames: imageName != nil ? [imageName!] : [], cityStory: ""))
            objectWillChange.send()
        }
    }

    func updateBadgeForDiscoveredPOI(city: String, poiID: UUID, imageName: String?) {
        guard !certifiedPOIIDs.contains(poiID) else { return }
        certifiedPOIIDs.insert(poiID)
        guard let index = badges.firstIndex(where: { $0.cityName == city }) else { return }
        badges[index].certifiedPOI += 1
        if let imgName = imageName {
            badges[index].discoveredImageNames.append(imgName)
        }
        if badges[index].certifiedPOI >= badges[index].totalPOI, badges[index].unlockedDate == nil {
            badges[index].unlockedDate = Date()
        }
        objectWillChange.send()
    }
    
    func reset() {
        for i in badges.indices {
            badges[i].certifiedPOI = 0
            badges[i].unlockedDate = nil
            badges[i].discoveredImageNames = []
        }
        certifiedPOIIDs.removeAll()
        objectWillChange.send()
    }
}
