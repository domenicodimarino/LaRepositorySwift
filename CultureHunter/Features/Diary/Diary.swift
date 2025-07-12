//
//  Diary.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import Foundation
import CoreLocation

// Modello di dati ampliato per un luogo
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let history: String
    let yearBuilt: String
    let location: String
    let audioName: String? // Nuovo campo per riferimento al file audio

    // Se non specifichi audioName, usa il nome del POI
    var effectiveAudioName: String {
        return audioName ?? name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}

// Database di luoghi con informazioni storiche
class PlacesData {
    static let shared = PlacesData()

    let places: [Place] = [
        Place(
            name: "Torre di Cetara",
            imageName: "poi_locked",
            history: "La Torre di Cetara, detta anche “Torre Vicereale”, fu costruita tra il 1551 e il 1565 per volontà del viceré di Napoli, con l’obiettivo di difendere il borgo dalle incursioni di pirati saraceni e barbareschi. Situata a picco sul mare, la torre aveva funzioni di avvistamento e segnalazione: tramite fuochi e segnali luminosi comunicava con le altre torri costiere in caso di pericolo. La struttura, massiccia e a pianta irregolare, era dotata di cannoni e di spazi per la guarnigione. Nel corso dei secoli perse la sua funzione militare ma rimase simbolo di protezione per la comunità locale. Oggi la Torre è uno dei monumenti più rappresentativi di Cetara e ospita mostre, eventi culturali e installazioni artistiche. All’interno si trovano pannelli informativi e materiali che raccontano la storia della torre e delle difese costiere della Costiera Amalfitana. Dalla terrazza si gode di una splendida vista sul Golfo di Salerno e sul borgo marinaro, rendendo la Torre di Cetara una meta imperdibile per chi visita la zona.",
            yearBuilt: "1551-1565",
            location: "Cetara, Salerno",
            audioName: nil
        ),
        Place(
            name: "Castello di Arechi",
            imageName: "poi_locked",
            history: "Il Castello di Arechi si erge sulla cima del Monte Bonadies, a controllo della città e del golfo di Salerno. Costruito durante il periodo longobardo tra il VII e il IX secolo, prende il nome dal duca Arechi II, che lo fece ampliare e fortificare. Successivamente, la struttura fu ulteriormente potenziata dai Normanni e dagli Aragonesi, assumendo l’aspetto di una grande fortezza con mura possenti, torri di guardia e un profondo fossato. Il castello ebbe per secoli un ruolo strategico nella difesa e nel controllo del territorio salernitano. Oggi, perfettamente restaurato, ospita un interessante museo con reperti archeologici, ceramiche, armi e oggetti storici, oltre a spazi per eventi culturali. Il percorso di visita si snoda tra sale interne, camminamenti panoramici e terrazze, offrendo spettacolari vedute sulla città di Salerno e sul mare. Il Castello di Arechi è uno dei simboli storici più amati della città e una meta imperdibile per chi vuole scoprire la storia e i panorami della Costiera Amalfitana.",
            yearBuilt: "VII-IX secolo, ampliamenti successivi",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Giardino della Minerva",
            imageName: "poi_locked",
            history: "Il Giardino della Minerva è uno dei più antichi orti botanici d’Europa, situato nel cuore del centro storico di Salerno. Fu realizzato nel XIII secolo da Matteo Silvatico, celebre medico della Scuola Medica Salernitana, che vi coltivava piante officinali per lo studio e la preparazione di rimedi terapeutici. Il giardino rappresentava un vero e proprio laboratorio a cielo aperto, dove venivano sperimentate le proprietà delle erbe medicinali secondo i principi della medicina medievale. Oggi il Giardino della Minerva è un museo storico dedicato alla botanica e alla storia della medicina, visitabile attraverso suggestive terrazze panoramiche che ospitano numerose piante rare e officinali, molte delle quali descritte nei trattati antichi. Il percorso è arricchito da pannelli didattici, eventi culturali e laboratori per grandi e piccoli. La posizione, affacciata sul golfo di Salerno, rende questo luogo unico sia dal punto di vista scientifico che paesaggistico.",
            yearBuilt: "XIII secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Porto di Salerno",
            imageName: "poi_locked",
            history: "Il Porto di Salerno affonda le sue origini nell’epoca romana, quando fungeva da scalo strategico per i traffici commerciali e le comunicazioni marittime. Durante il Medioevo assunse un ruolo fondamentale per l’economia del Principato di Salerno, facilitando gli scambi con il Mediterraneo. Nel corso dei secoli il porto è stato più volte ampliato e modernizzato, soprattutto nel XX secolo, fino a diventare uno dei principali scali commerciali e turistici d’Italia. Oggi il Porto di Salerno offre collegamenti con numerose destinazioni nazionali e internazionali e ospita attività commerciali, traghetti passeggeri, crociere e numerosi servizi logistici. Il porto è anche punto di accesso privilegiato per la Costiera Amalfitana e per la città stessa, rappresentando un volano per l’economia e il turismo locali. La sua posizione strategica e le moderne infrastrutture ne fanno uno dei poli portuali più dinamici del Mediterraneo.",
            yearBuilt: "Epoca romana, ampliamenti recenti nel XX secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di San Giorgio",
            imageName: "poi_locked",
            history: "La Chiesa di San Giorgio è tra gli edifici religiosi più antichi di Salerno, con origini paleocristiane risalenti ai primi secoli dopo Cristo. Nel corso dei secoli, la chiesa ha subito numerose ricostruzioni, in particolare tra il X e il XVII secolo, che le hanno conferito l’aspetto attuale. Un tempo annessa a un importante monastero benedettino, la chiesa rappresenta un autentico esempio di stratificazione storica e artistica della città. L’interno è riccamente decorato con affreschi barocchi e ospita un pregiato altare ligneo seicentesco, oltre a numerose opere d’arte sacra. La Chiesa di San Giorgio è oggi considerata un piccolo gioiello nel cuore del centro storico di Salerno, meta di studiosi e visitatori interessati alla storia dell’arte e della spiritualità cittadina.",
            yearBuilt: "Origini paleocristiane, ricostruita tra X e XVII secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Piazza della Libertà",
            imageName: "poi_locked",
            history: "Piazza della Libertà è una delle piazze più grandi e moderne di Salerno, simbolo della recente riqualificazione urbana della zona costiera. Inaugurata nel 2021 dopo un decennio di lavori, si estende tra il lungomare e il porto, trasformando radicalmente il volto della città. La piazza offre una vasta area pedonale con pavimentazione scenografica, ampie zone verdi, fontane e spazi per il relax. Grazie alla sua posizione strategica e alla sua architettura contemporanea, è divenuta rapidamente uno dei principali punti di riferimento per cittadini e turisti. Piazza della Libertà ospita regolarmente eventi pubblici, spettacoli e manifestazioni culturali, diventando un luogo di aggregazione sociale e uno spazio simbolico per la comunità. La piazza rappresenta uno degli interventi più significativi nella riqualificazione del fronte mare di Salerno, unendo funzionalità, modernità e attenzione al paesaggio urbano.",
            yearBuilt: "2011-2021",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Museo Diocesano San Matteo",
            imageName: "poi_locked",
            history: "Il Museo Diocesano San Matteo si trova nell’antico palazzo arcivescovile nel centro storico di Salerno e fu istituito nel 1956. La sede attuale risale al XVII secolo, ma le collezioni abbracciano un arco temporale molto più ampio, con opere d’arte sacra dal XII al XVIII secolo. Di particolare pregio sono le tavole d’avorio salernitane del XII secolo, capolavori di arte medievale, e i dipinti di Andrea Sabatini e altri artisti della scuola salernitana. Il museo raccoglie inoltre sculture, oggetti liturgici, codici miniati e testimonianze legate a San Matteo, patrono della città. Attraverso le sue collezioni, il museo offre un viaggio nella storia religiosa e artistica di Salerno e della sua diocesi, rappresentando uno dei principali punti di riferimento culturale della città.",
            yearBuilt: "Sede XVII secolo, collezioni dal XII secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Duomo di Salerno",
            imageName: "poi_locked",
            history: "Il Duomo di Salerno, dedicato a San Matteo evangelista, fu costruito tra il 1076 e il 1085 per volere di Roberto il Guiscardo, duca normanno. È uno dei più importanti esempi di architettura romanica del Sud Italia, arricchito da influssi arabi e bizantini. Il suo splendido campanile, decorato in stile arabo-normanno, è uno dei simboli della città. L’interno del Duomo custodisce preziosi mosaici, affreschi e numerose opere d’arte di varie epoche. Particolarmente suggestiva è la cripta, che conserva le reliquie di San Matteo, patrono di Salerno. Nel corso dei secoli, la cattedrale ha subito restauri e trasformazioni, tra cui l’aggiunta di elementi barocchi dopo il terremoto del 1688. Oggi il Duomo rappresenta non solo il centro spirituale della città, ma anche un luogo di grande interesse storico e artistico, meta di pellegrini e visitatori da tutto il mondo.",
            yearBuilt: "1076-1085",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di Saragnano",
            imageName: "poi_locked",
            history: "La Chiesa di Saragnano si trova nell’omonima frazione del comune di Baronissi, in provincia di Salerno. Di origini medievali, la chiesa è stata più volte ristrutturata e ampliata nel corso dei secoli, adattandosi alle esigenze della comunità locale. Al suo interno conserva preziosi arredi sacri e opere d’arte di diverse epoche, che testimoniano la ricca storia religiosa della zona. Punto di riferimento spirituale e sociale per gli abitanti di Saragnano, la chiesa è spesso sede di celebrazioni, tradizioni popolari e momenti di aggregazione. La stratificazione architettonica e artistica rende l’edificio un interessante esempio di continuità storica e di legame con il territorio.",
            yearBuilt: "Origini medievali, ristrutturazioni successive",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa del Monte dei Morti",
            imageName: "poi_locked",
            history: "La Chiesa del Monte dei Morti, costruita nel XVII secolo nel centro storico di Salerno, fu sede della Confraternita del Monte dei Morti, impegnata nell’assistenza ai defunti e ai bisognosi. L’edificio è un esempio di architettura barocca, caratterizzato da una facciata sobria che contrasta con l’interno riccamente decorato da stucchi e affreschi seicenteschi. In passato, la chiesa era un importante luogo di culto popolare, dove venivano celebrate messe in suffragio delle anime dei defunti. Ancora oggi conserva numerosi elementi artistici di pregio, come altari in marmo, opere pittoriche e testimonianze della religiosità locale. La Chiesa del Monte dei Morti rappresenta uno dei principali esempi della tradizione confraternale e della pietà popolare salernitana.",
            yearBuilt: "XVII secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Teatro Verdi",
            imageName: "poi_locked",
            history: "Il Teatro Municipale Giuseppe Verdi di Salerno fu costruito tra il 1863 e il 1872, prendendo ispirazione dal celebre Teatro San Carlo di Napoli. Inaugurato con il 'Rigoletto' di Giuseppe Verdi, il teatro si caratterizza per l’elegante architettura neoclassica e per i raffinati interni decorati con affreschi e stucchi. Nel tempo è diventato uno dei principali centri culturali della città, ospitando stagioni liriche, concerti, spettacoli teatrali ed eventi di rilievo nazionale e internazionale. Il Teatro Verdi rappresenta un punto di riferimento per la vita artistica e musicale di Salerno e contribuisce a valorizzare la tradizione operistica italiana. La sua posizione centrale e la ricca programmazione lo rendono una meta imperdibile per appassionati di musica e visitatori.",
            yearBuilt: "1863-1872",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Acquedotto Medievale",
            imageName: "poi_locked",
            history: "L’Acquedotto Medievale di Salerno, conosciuto come 'Ponte dei Diavoli', è uno dei monumenti più emblematici della città. Realizzato probabilmente nel IX secolo dai monaci benedettini, aveva il compito fondamentale di trasportare l’acqua dalle colline circostanti fino al monastero di San Benedetto nel centro antico. Il suo percorso si snoda tra suggestivi archi in pietra, molti dei quali sono ancora oggi ben visibili tra via Arce e via Velia. La struttura, perfettamente integrata nel tessuto urbano, ha alimentato nel tempo numerose leggende: la più nota narra che fu costruita in una sola notte grazie all’aiuto di forze sovrannaturali. Dal punto di vista ingegneristico, rappresenta un capolavoro di architettura medievale, testimonianza delle avanzate conoscenze tecniche dei costruttori dell’epoca. L’acquedotto è oggi uno dei simboli storici di Salerno, meta di visite guidate, itinerari culturali e fonte di ispirazione per fotografi e artisti. Il suo fascino, sospeso tra realtà e mito, continua a incantare cittadini e visitatori, offrendo scorci unici e la possibilità di immergersi nella storia millenaria della città.",
            yearBuilt: "IX secolo",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Museo dello Sbarco e Salerno Capitale",
            imageName: "poi_locked",
            history: "Il Museo dello Sbarco e Salerno Capitale, inaugurato nel 2012, è dedicato a uno dei momenti più significativi della storia contemporanea italiana: lo sbarco alleato del settembre 1943 sulle coste salernitane, noto come Operazione Avalanche. Il museo racconta anche la fase in cui Salerno fu capitale d’Italia (1943-1944), durante la transizione tra monarchia e repubblica. L’allestimento comprende fotografie, documenti, uniformi, oggetti militari, diorami e testimonianze dirette che ricostruiscono i giorni cruciali della liberazione. Installazioni multimediali e ricostruzioni scenografiche permettono ai visitatori di rivivere la drammaticità dell’epoca e di comprendere il ruolo di Salerno come crocevia della storia nazionale. Il museo è oggi un luogo della memoria, fondamentale per chi desidera approfondire la storia della Seconda Guerra Mondiale e il contributo di Salerno alla rinascita democratica dell’Italia. Rappresenta un punto di riferimento per studenti, studiosi e cittadini interessati a conoscere e conservare la memoria degli eventi che hanno cambiato il destino del Paese.",
            yearBuilt: "2012",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Museo virtuale della scuola medica salernitana",
            imageName: "poi_locked",
            history: "Il Museo virtuale della scuola medica salernitana, inaugurato nel 2009, celebra la storia della più antica scuola di medicina d’Europa, attiva tra IX e XIII secolo. Attraverso avanzate tecnologie multimediali, percorsi interattivi e ricostruzioni digitali, il museo offre un viaggio affascinante nell’evoluzione della medicina a Salerno, mostrando come la Scuola Medica Salernitana sia stata un crocevia di saperi greci, latini, arabi ed ebraici. Si possono scoprire le principali figure storiche, i trattati medici e le innovazioni che hanno influenzato la scienza occidentale. Il museo è pensato come luogo di divulgazione e didattica, rivolto a studenti, ricercatori e semplici curiosi, e contribuisce a valorizzare il patrimonio culturale della città. Il percorso espositivo, arricchito da supporti visivi e interattivi, rende la visita coinvolgente e istruttiva, sottolineando il ruolo di Salerno come capitale storica della medicina europea e anticipatrice di concetti ancora oggi validi nella moderna pratica medica.",
            yearBuilt: "2009",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Museo archeologico provinciale di Salerno",
            imageName: "poi_locked",
            history: "Il Museo archeologico provinciale di Salerno, fondato nel 1939 e ospitato nell’ex convento di San Benedetto, è un punto di riferimento per la conoscenza della storia antica della provincia. Le collezioni coprono un arco temporale che va dalla preistoria all’epoca romana, con reperti provenienti dagli scavi di Fratte, Pontecagnano e Salerno stessa. Tra i pezzi più importanti vi è la celebre testa di Apollo, capolavoro risalente al I-II secolo d.C. Il museo espone anche ceramiche, monete, oggetti di uso quotidiano e sculture che raccontano la vita e le culture del territorio in diverse epoche. L’istituto svolge inoltre un ruolo centrale nella valorizzazione e tutela del patrimonio archeologico locale, promuovendo mostre temporanee, attività educative e pubblicazioni scientifiche. La visita al museo permette di compiere un vero e proprio viaggio nel tempo, alla scoperta delle radici di Salerno e dei suoi legami con le grandi civiltà del passato.",
            yearBuilt: "1939 (sede nell’ex convento di San Benedetto)",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa della Santissima Annunziata",
            imageName: "poi_locked",
            history: "La Chiesa della Santissima Annunziata di Salerno, edificata nel XIV secolo nei pressi dell’antica Porta Catena, rappresenta uno degli edifici religiosi più significativi della città. Nel corso dei secoli ha subito numerosi restauri, in particolare dopo il terremoto del 1688 che portò all’inserimento di raffinati elementi barocchi. L’edificio si distingue per la facciata in stile neoclassico, il campanile decorato con maioliche colorate e l’interno riccamente ornato da stucchi e dipinti di pregio. La chiesa è stata a lungo sede di una storica confraternita cittadina e ancora oggi è punto di riferimento per la vita religiosa locale. La sua posizione strategica, l’architettura elegante e le opere d’arte conservate al suo interno la rendono una meta apprezzata da fedeli, studiosi e turisti.",
            yearBuilt: "XIV secolo (restauri XVII-XVIII sec.)",
            location: "Salerno",
            audioName: nil
        ),
        Place(
            name: "Parrocchia di San Pietro Apostolo",
            imageName: "poi_locked",
            history: "La Parrocchia di San Pietro Apostolo è la chiesa principale di Cetara, pittoresco borgo della Costiera Amalfitana. Le sue origini risalgono probabilmente tra il IX e il X secolo, e l’edificio ha subito ampliamenti e rimaneggiamenti nei secoli successivi. L’attuale aspetto barocco è frutto di interventi realizzati tra il XVII e il XVIII secolo. La chiesa si distingue per la facciata elegante e il campanile maiolicato, che domina il profilo del paese. All’interno si conservano preziosi arredi sacri, dipinti e una statua lignea di San Pietro, patrono del borgo, a cui sono dedicate tradizionali feste religiose. La parrocchia rappresenta un fondamentale punto di riferimento non solo per la fede, ma anche per l’identità e la coesione della comunità di Cetara.",
            yearBuilt: "IX-X secolo (aspetto attuale XVII-XVIII secolo)",
            location: "Cetara, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di Santa Maria di Costantinopoli",
            imageName: "poi_locked",
            history: "La Chiesa di Santa Maria di Costantinopoli, situata a Cetara sulla Costiera Amalfitana, fu edificata nel XVII secolo come segno di devozione verso la Madonna di Costantinopoli, protettrice dei marinai. La chiesa presenta un’unica navata, arricchita da altari barocchi e una pregevole statua lignea della Vergine. Nel corso dei secoli è stata oggetto di restauri che hanno permesso di conservare il suo valore artistico e spirituale. Fortemente legata alle tradizioni religiose e marinare del borgo, la chiesa è ancora oggi luogo di culto e di partecipazione collettiva. La sua posizione panoramica e il fascino delle decorazioni interne la rendono una tappa imperdibile per chi visita Cetara.",
            yearBuilt: "XVII secolo",
            location: "Cetara, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di San Francesco",
            imageName: "poi_locked",
            history: "La Chiesa di San Francesco, edificata insieme all’annesso convento dei Frati Minori nel XVII secolo, è uno dei principali luoghi di culto di Cetara. L’edificio si distingue per la facciata semplice e l’interno riccamente decorato in stile barocco, con stucchi, affreschi e un pregevole altare maggiore. Il convento, per secoli punto di riferimento spirituale e culturale per la comunità, conserva ancora oggi numerose opere d’arte e oggetti sacri di pregio. La chiesa è centro di vita religiosa e sociale, ospitando celebrazioni, eventi e momenti di raccoglimento molto sentiti dagli abitanti del paese.",
            yearBuilt: "XVII secolo",
            location: "Cetara, Salerno",
            audioName: nil
        ),
        Place(
            name: "Fabbrica Nettuno",
            imageName: "poi_locked",
            history: "La Fabbrica Nettuno è una storica azienda conserviera di Cetara, fondata nel 1950 e celebre per la produzione artigianale della tradizionale colatura di alici. L’azienda ha contribuito in modo determinante a valorizzare i prodotti ittici della Costiera Amalfitana, mantenendo metodi di lavorazione tramandati di generazione in generazione. Oltre alla celebre colatura, la Fabbrica Nettuno produce filetti di alici e altri prodotti conservieri di alta qualità. La fabbrica rappresenta un punto di riferimento per l’economia locale e per la cultura gastronomica del borgo: è spesso meta di visite guidate e degustazioni che permettono di scoprire i segreti della tradizione cetarese.",
            yearBuilt: "1950",
            location: "Cetara, Salerno",
            audioName: nil
        ),
        Place(
            name: "Monumento ai Caduti",
            imageName: "poi_locked",
            history: "Il Monumento ai Caduti di Cava de' Tirreni, inaugurato nel 1925 e situato nella centrale Piazza Abbro, è stato eretto per commemorare i soldati della città caduti durante la Prima Guerra Mondiale. Progettato dallo scultore Luigi Caputo, il monumento si caratterizza per una statua bronzea raffigurante un soldato e per i bassorilievi che riportano i nomi dei caduti. Negli anni successivi, la dedica è stata estesa anche ai caduti delle guerre successive, rendendolo un simbolo della memoria storica e del sacrificio della comunità cavese. Il monumento, luogo di cerimonie ufficiali e commemorazioni, rappresenta un punto di riferimento civico per la città.",
            yearBuilt: "1925",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Duomo di Cava",
            imageName: "poi_locked",
            history: "Il Duomo di Cava, dedicato a Santa Maria della Visitazione, è la principale chiesa di Cava de’ Tirreni. La sua fondazione risale all’XI secolo, ma l’edificio ha subito importanti rifacimenti, soprattutto dopo il terremoto del 1688 che lo ha trasformato in stile barocco. Il Duomo custodisce preziose opere d’arte sacra, tra cui il busto argenteo di Sant’Alferio e un monumentale organo. La facciata, il campanile e gli interni riccamente decorati rappresentano simboli della storia e dell’identità religiosa cavese. Oggi il Duomo è fulcro di importanti celebrazioni religiose e meta di pellegrinaggi.",
            yearBuilt: "XI secolo (rifacimenti XVII-XVIII secolo)",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di San Rocco",
            imageName: "poi_locked",
            history: "La Chiesa di San Rocco fu edificata nel XVI secolo a Cava de’ Tirreni come ex voto per la fine di una grave epidemia di peste. L’edificio, di dimensioni raccolte ma di grande valore storico e devozionale, presenta una facciata semplice e un interno arricchito da un altare maggiore e dalla statua di San Rocco, protettore contro le malattie. Ancora oggi la chiesa è centro di devozione popolare, sede di tradizionali celebrazioni e meta di fedeli che vi si recano per chiedere protezione e grazie.",
            yearBuilt: "XVI secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Giardini di San Giovanni",
            imageName: "poi_locked",
            history: "I Giardini di San Giovanni, situati nel cuore di Cava de’ Tirreni, fanno parte dello storico complesso dell’ex Monastero di San Giovanni. Realizzati a partire dal XVII secolo come orti e spazi verdi conventuali, sono oggi un elegante giardino pubblico, ricco di piante ornamentali, percorsi, fontane e scorci panoramici sulla città. I giardini ospitano regolarmente eventi culturali, mostre e momenti di relax, rappresentando uno dei polmoni verdi più suggestivi e apprezzati della città. Sono un luogo d’incontro e di svago per cittadini e visitatori.",
            yearBuilt: "XVII secolo (riqualificati in epoca recente)",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di Maria Assunta in Cielo (Purgatorio)",
            imageName: "poi_locked",
            history: "La Chiesa di Maria Assunta in Cielo, nota come Chiesa del Purgatorio, fu edificata nel XVII secolo nel centro storico di Cava de’ Tirreni. Legata fin dall’origine alla confraternita delle Anime del Purgatorio, si distingue per la facciata sobria e per l’interno ricco di decorazioni barocche, altari in marmo e preziosi dipinti seicenteschi. Qui si svolgono riti e celebrazioni legati alla memoria dei defunti e alle festività mariane, rendendo la chiesa un importante punto di riferimento spirituale e tradizionale per la città.",
            yearBuilt: "XVII secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Santuario Francescano S.Francesco e S.Antonio",
            imageName: "poi_locked",
            history: "Il Santuario Francescano dei Santi Francesco e Antonio, fondato nel XVI secolo dai frati minori, è immerso nel verde e meta di pellegrinaggi a Cava de’ Tirreni. L’edificio è caratterizzato da una facciata sobria e da un ampio portico, mentre l’interno custodisce numerose opere d’arte, tra cui affreschi e statue dedicate ai santi titolari. Il santuario è ancora oggi un importante centro spirituale e culturale della città, ospitando celebrazioni religiose e iniziative sociali che coinvolgono tutta la comunità.",
            yearBuilt: "XVI secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di Santa Maria Incoronata dell'Olmo",
            imageName: "poi_locked",
            history: "La Chiesa di Santa Maria Incoronata dell’Olmo, nel centro storico di Cava de’ Tirreni, è tra gli edifici religiosi più antichi e significativi della città. Fondata secondo la tradizione nel medioevo, fu ampliata e trasformata tra il XVII e il XVIII secolo, assumendo l’attuale aspetto barocco. L’interno, a navata unica, custodisce preziose opere d’arte sacra, tra cui dipinti, affreschi e la venerata immagine della Madonna dell’Olmo, patrona della città. La chiesa è ancora oggi meta di pellegrinaggi e luogo di culto molto sentito.",
            yearBuilt: "Medioevo (aspetto attuale XVII-XVIII secolo)",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Abbazia della Santissima Trinità",
            imageName: "poi_locked",
            history: "L’Abbazia della Santissima Trinità, detta anche Badia di Cava, fu fondata nell’XI secolo da Sant’Alferio Pappacarbone in una verde vallata a Cava de’ Tirreni. È uno dei più importanti complessi monastici del Sud Italia e ha avuto un ruolo centrale nella vita spirituale, culturale e sociale della regione. L’abbazia conserva elementi romanici, barocchi e neoclassici, con chiostri, affreschi e opere d’arte di grande pregio. Nei secoli ha ospitato una ricca biblioteca e preziosi archivi storici. Oggi è centro di spiritualità, cultura e meta di pellegrinaggi.",
            yearBuilt: "XI secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa dell'Avvocatella",
            imageName: "poi_locked",
            history: "La Chiesa dell’Avvocatella, situata ai piedi dei monti che circondano Cava de’ Tirreni, fu fondata nel XVII secolo e dedicata alla Madonna Avvocata. È un luogo di grande devozione popolare, noto per la posizione panoramica e per i suggestivi sentieri che vi conducono. L’interno, semplice e raccolto, custodisce una venerata statua della Madonna e numerosi ex voto. Ogni anno la chiesa è meta di pellegrinaggi e festeggiamenti tradizionali, rappresentando un importante punto di riferimento spirituale e identitario per la comunità locale.",
            yearBuilt: "XVII secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Chiesa di San Lorenzo",
            imageName: "poi_locked",
            history: "La Chiesa di San Lorenzo è uno degli edifici religiosi più antichi di Cava de’ Tirreni, risalente al periodo medievale e situata nell’omonima frazione. Ricostruita e ampliata nei secoli successivi, la chiesa conserva elementi architettonici romanici e barocchi. All’interno si trovano pregevoli altari, affreschi e una statua lignea di San Lorenzo, patrono della comunità locale. Ogni anno, la chiesa è fulcro di sentite celebrazioni religiose e tradizionali feste popolari, che mantengono vivo il legame con la storia e le tradizioni della zona.",
            yearBuilt: "Medioevo (successivi rifacimenti)",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        ),
        Place(
            name: "Villa Comunale Falcone e Borsellino",
            imageName: "poi_locked",
            history: "La Villa Comunale Falcone e Borsellino è il principale parco pubblico di Cava de’ Tirreni, intitolato ai due magistrati simbolo della lotta alla mafia. Realizzata nel corso del XX secolo e situata nel centro cittadino, la villa offre ampi spazi verdi, aree giochi per bambini, percorsi pedonali e zone dedicate a eventi culturali e ricreativi. È un punto di ritrovo per famiglie, giovani e anziani e rappresenta uno dei polmoni verdi della città. Il parco è anche luogo di memoria civica grazie alle dediche ai magistrati, promuovendo valori di legalità e impegno sociale.",
            yearBuilt: "XX secolo",
            location: "Cava de' Tirreni, Salerno",
            audioName: nil
        )
    ]
}
