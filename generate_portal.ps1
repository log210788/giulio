# generate_portal.ps1 - Complete generator for Giulio M's Peaceful Interactive Sanctuary (Actual Lesson Notes)
$ErrorActionPreference = "Stop"

Write-Host "=========================================================="
Write-Host "Rebuilding Giulio M's Lesson 01 Interactive Portal"
Write-Host "=========================================================="

# 1. Load Raw Transcript
$transcriptPath = "D:\Documents\Giulio M\Transcripts\11-03-2026.txt"
if (-not (Test-Path $transcriptPath)) {
    throw "Transcript file missing: $transcriptPath"
}
$rawLines = Get-Content $transcriptPath -Encoding UTF8

$turns = @()
$spk = ""; $time = ""; $buf = @()
foreach ($l in $rawLines) {
    if ($l -match '^([A-Za-z0-9''\s]+)\s*\|\s*(\d?\d:\d\d(?::\d\d)?)') {
        if ($spk -ne "") {
            $turns += [PSCustomObject]@{ speaker = $spk.Trim(); time = $time.Trim(); text = ($buf -join " ").Trim() }
        }
        $spk = $matches[1]; $time = $matches[2]; $buf = @()
    } else {
        if ($l.Trim() -ne "") { $buf += $l.Trim() }
    }
}
if ($spk -ne "") {
    $turns += [PSCustomObject]@{ speaker = $spk.Trim(); time = $time.Trim(); text = ($buf -join " ").Trim() }
}
Write-Host "Loaded $($turns.Count) turns from raw transcript."

# 2. Define VOCAB_DB (60 rich B2-C2 items with Italian equivalents)
$vocabDb = [ordered]@{
    "crunch-time" = @{
        word = "crunch time"
        ipa = "/krʌntʃ taɪm/"
        pos = "noun"
        level = "C1"
        time = "01:08"
        turnId = "turn-7"
        cat = "culture"
        def = "A critical period of intense work and long hours immediately preceding an urgent project deadline."
        quote = "Louie (01:08): 'So you had crunch time... where you have a deadline coming and everyone is working crazy hours to get it done.'"
        es = "fase di massimo impegno / periodo critico"
    }
    "timeline" = @{
        word = "timeline"
        ipa = "/ˈtaɪm.laɪn/"
        pos = "noun"
        level = "B2"
        time = "00:23"
        turnId = "turn-5"
        cat = "culture"
        def = "The planned schedule displaying the expected sequence and delivery milestones of a project."
        quote = "Giulio (00:23): '...we need to work on shifts in order to achieve some goals on the project. So we are trying to respect the timeline and the deadline...'"
        es = "cronoprogramma / tempistica"
    }
    "deadline" = @{
        word = "deadline"
        ipa = "/ˈded.laɪn/"
        pos = "noun"
        level = "B2"
        time = "00:23"
        turnId = "turn-5"
        cat = "culture"
        def = "The final agreed date or time by which a contracted task or engineering build must be completed."
        quote = "Giulio (00:23): '...we are trying to respect the timeline and the deadline, and we will see.'"
        es = "scadenza contrattuale"
    }
    "shift-work" = @{
        word = "shift work"
        ipa = "/ʃɪft wɜːk/"
        pos = "noun"
        level = "B2"
        time = "00:23"
        turnId = "turn-5"
        cat = "culture"
        def = "A work arrangement where successive teams of employees operate machinery throughout extended hours."
        quote = "Giulio (00:23): '...we need to work on shifts in order to achieve some goals... I started working at six.'"
        es = "lavoro su turni"
    }
    "unwind" = @{
        word = "unwind"
        ipa = "/ʌnˈwaɪnd/"
        pos = "verb"
        level = "B2"
        time = "02:04"
        turnId = "turn-11"
        cat = "emotion"
        def = "To release tension, decompress, and relax peacefully after a strenuous workday."
        quote = "Giulio (02:04): 'Then I came home, I had one hour to relax a little bit... to unwind.'"
        es = "rilassarsi / staccare la spina"
    }
    "tier-list" = @{
        word = "tier list"
        ipa = "/tɪər lɪst/"
        pos = "noun"
        level = "B2"
        time = "02:32"
        turnId = "turn-14"
        cat = "culture"
        def = "A visual ranking system categorizing items into hierarchical grades from S (supreme) down to D."
        quote = "Louie (02:32): 'Here we have the tier list... this is S tier, this is A tier, this is B tier.'"
        es = "classifica per livelli / graduatoria"
    }
    "ranking" = @{
        word = "ranking"
        ipa = "/ˈræŋ.kɪŋ/"
        pos = "noun"
        level = "B2"
        time = "02:32"
        turnId = "turn-14"
        cat = "language"
        def = "The positional arrangement of choices based on comparative quality, merit, or personal preference."
        quote = "Louie (02:32): 'They put it onto the ranking, right? They rank it.'"
        es = "valutazione / graduatoria"
    }
    "takeaway" = @{
        word = "takeaway"
        ipa = "/ˈteɪk.ə.weɪ/"
        pos = "noun"
        level = "B2"
        time = "05:46"
        turnId = "turn-31"
        cat = "culinary"
        def = "Prepared food ordered and purchased from an eatery to be eaten elsewhere rather than on premises."
        quote = "Giulio (05:46): 'There is a place that is five kilometers from my home that is only for takeaway.'"
        es = "cibo da asporto"
    }
    "brioche-bun" = @{
        word = "brioche bun"
        ipa = "/ˈbriː.ɒʃ bʌn/"
        pos = "noun"
        level = "B2"
        time = "05:46"
        turnId = "turn-31"
        cat = "culinary"
        def = "A rich, tender bread roll made with butter and eggs, prized for gourmet burgers."
        quote = "Giulio (05:46): 'They do their own bread, their own buns, so it is really good.'"
        es = "panino artigianale per hamburger"
    }
    "crunchy" = @{
        word = "crunchy"
        ipa = "/ˈkrʌn.tʃi/"
        pos = "adjective"
        level = "B2"
        time = "08:49"
        turnId = "turn-47"
        cat = "culinary"
        def = "Making a sharp, crisp sound when crushed or bitten; brittle in texture."
        quote = "Giulio (08:49): '...sometimes they are too crunchy, and when you bite them, it is like exploding.'"
        es = "croccante / friabile"
    }
    "hit-or-miss" = @{
        word = "hit or miss"
        ipa = "/hɪt ɔː mɪs/"
        pos = "idiom"
        level = "C1"
        time = "09:25"
        turnId = "turn-49"
        cat = "culinary"
        def = "Unpredictable in quality and outcome; occasionally very good but often disappointing."
        quote = "Louie (09:25): 'Yeah, we say it is hit or miss... it depends on who cooks it.'"
        es = "un terno al lotto / a fortuna"
    }
    "destination" = @{
        word = "destination"
        ipa = "/ˌdes.tɪˈneɪ.ʃən/"
        pos = "noun"
        level = "B2"
        time = "09:54"
        turnId = "turn-52"
        cat = "culture"
        def = "The predetermined place to which someone is journeying for leisure or discovery."
        quote = "Giulio (09:54): 'Let us try with the holiday destinations.'"
        es = "meta di vacanza / destinazione"
    }
    "coastal" = @{
        word = "coastal"
        ipa = "/ˈkəʊ.stəl/"
        pos = "adjective"
        level = "B2"
        time = "10:21"
        turnId = "turn-53"
        cat = "culture"
        def = "Situated near or bordering the sea or ocean coastline."
        quote = "Giulio (10:21): 'I have both the beach and the mountain nearby in my area...'"
        es = "costiero / litoraneo"
    }
    "alpine-trek" = @{
        word = "alpine trek"
        ipa = "/ˈæl.paɪn trek/"
        pos = "noun"
        level = "B2"
        time = "10:56"
        turnId = "turn-56"
        cat = "culture"
        def = "A strenuous long-distance hike across mountainous forest trails and elevated terrain."
        quote = "Giulio (10:56): 'I love taking long walks, treks in the forests, in nature... surrounded by trees and waterfalls.'"
        es = "escursione alpina / trekking"
    }
    "cuisine" = @{
        word = "cuisine"
        ipa = "/kwɪˈziːn/"
        pos = "noun"
        level = "B2"
        time = "10:56"
        turnId = "turn-56"
        cat = "culinary"
        def = "A characteristic style or tradition of culinary preparation associated with a distinct region."
        quote = "Giulio (10:56): 'In the mountains, the cuisine is, in my opinion, the best.'"
        es = "cucina tipica / gastronomia"
    }
    "alps" = @{
        word = "Alps"
        ipa = "/ælps/"
        pos = "proper noun"
        level = "B2"
        time = "11:58"
        turnId = "turn-58"
        cat = "culture"
        def = "The magnificent mountain range system of south-central Europe bordering northern Italy."
        quote = "Giulio (11:58): 'We have the Alps... great mountains.'"
        es = "le Alpi"
    }
    "pub-crawl" = @{
        word = "pub crawl"
        ipa = "/pʌb krɔːl/"
        pos = "noun"
        level = "C1"
        time = "13:23"
        turnId = "turn-66"
        cat = "culture"
        def = "The traditional British social custom of visiting and having a drink at multiple successive pubs in one evening."
        quote = "Louie (13:23): 'Do you know what we call it? We call it a pub crawl... Oxford has a legendary pub crawl.'"
        es = "giro dei pub / tour dei locali"
    }
    "bacaro" = @{
        word = "bàcaro"
        ipa = "/ˈbaː.ka.ro/"
        pos = "noun"
        level = "C1"
        time = "14:26"
        turnId = "turn-74"
        cat = "culture"
        def = "A traditional, rustic Venetian tavern serving local house wines and artisanal small bites."
        quote = "Giulio (14:26): 'There is something similar in Venice. We have these small wine shops that are called bàcaro...'"
        es = "bàcaro veneziano (osteria tipica)"
    }
    "cicchetti" = @{
        word = "cicchetti"
        ipa = "/tʃiˈket.ti/"
        pos = "noun"
        level = "C1"
        time = "14:26"
        turnId = "turn-74"
        cat = "culinary"
        def = "Traditional Venetian savory bite-sized appetizers served on crusty bread in bàcari."
        quote = "Giulio (14:26): 'You can walk from one bàcaro to another, tasting wine and eating finger food...'"
        es = "cicchetti veneziani (stuzzichini)"
    }
    "finger-food" = @{
        word = "finger food"
        ipa = "/ˈfɪŋ.ɡə fʊd/"
        pos = "noun"
        level = "B2"
        time = "14:26"
        turnId = "turn-74"
        cat = "culinary"
        def = "Hors d'oeuvres or small snacks designed to be eaten comfortably with the hands."
        quote = "Giulio (14:26): '...tasting wine, eating some finger food, let us say.'"
        es = "finger food / antipasti da mangiare con le mani"
    }
    "traffic-flow" = @{
        word = "traffic flow"
        ipa = "/ˈtræf.ɪk fləʊ/"
        pos = "noun"
        level = "B2"
        time = "15:17"
        turnId = "turn-76"
        cat = "culture"
        def = "The density and movement of vehicular and bicycle transport along municipal thoroughfares."
        quote = "Giulio (15:17): 'It is nice to ride the bike in Rome, even if the traffic sometimes is quite wild.'"
        es = "scorrimento del traffico"
    }
    "colorful-language" = @{
        word = "colorful language"
        ipa = "/ˈkʌl.ə.fəl ˈlæŋ.ɡwɪdʒ/"
        pos = "idiom"
        level = "C1"
        time = "16:27"
        turnId = "turn-80"
        cat = "language"
        def = "A polite euphemism for expressive swearing, coarse colloquialisms, or heated profanity."
        quote = "Louie (16:27): 'And the language they used, wow, very colorful!'"
        es = "linguaggio colorito / imprecazioni"
    }
    "permanent-holiday" = @{
        word = "permanent holiday"
        ipa = "/ˈpɜː.mə.nənt ˈhɒl.ə.deɪ/"
        pos = "phrase"
        level = "B2"
        time = "17:40"
        turnId = "turn-87"
        cat = "culture"
        def = "Living in an idyllic rural setting that feels like a perpetual vacation retreat."
        quote = "Giulio (17:40): 'I live in the countryside, so I would say it is my permanent holiday... enjoying the silence.'"
        es = "vacanza perenne / rifugio tranquillo"
    }
    "countryside" = @{
        word = "countryside"
        ipa = "/ˈkʌn.tri.saɪd/"
        pos = "noun"
        level = "B2"
        time = "17:40"
        turnId = "turn-87"
        cat = "culture"
        def = "Rural land, meadows, and rustic villages outside large industrial metropolitan centers."
        quote = "Giulio (17:40): 'I like where I live in the countryside... taking a walk outside and enjoying the silence.'"
        es = "campagna / territorio rurale"
    }
    "lock-the-door" = @{
        word = "lock the door"
        ipa = "/lɒk ðə dɔːr/"
        pos = "phrase"
        level = "B2"
        time = "18:16"
        turnId = "turn-90"
        cat = "culture"
        def = "To secure an entrance bolt against unauthorized entry; a measure of community trust."
        quote = "Louie (18:16): 'In Oxford countryside, we never locked the doors growing up... do you lock your doors?'"
        es = "chiudere a chiave"
    }
    "play-it-safe" = @{
        word = "play it safe"
        ipa = "/pleɪ ɪt seɪf/"
        pos = "idiom"
        level = "C1"
        time = "20:36"
        turnId = "turn-96"
        cat = "emotion"
        def = "To adopt a cautious, conservative stance and avoid bold risks or audacious claims."
        quote = "Louie (20:36): 'Are you just playing it safe? Are you just being safe?'"
        es = "non rischiare / andare sul sicuro"
    }
    "invisibility" = @{
        word = "invisibility"
        ipa = "/ɪnˌvɪz.əˈbɪl.ə.ti/"
        pos = "noun"
        level = "B2"
        time = "21:21"
        turnId = "turn-100"
        cat = "philosophy"
        def = "The supernatural state of being entirely imperceptible to human visual sight."
        quote = "Giulio (21:21): 'Invisibility... it could be useful sometimes to disappear and understand how people behave when you are not present.'"
        es = "invisibilità"
    }
    "disappear" = @{
        word = "disappear"
        ipa = "/ˌdɪs.əˈpɪər/"
        pos = "verb"
        level = "B2"
        time = "21:21"
        turnId = "turn-100"
        cat = "philosophy"
        def = "To vanish quietly from view or presence without leaving trace."
        quote = "Giulio (21:21): 'It could be useful sometimes to disappear...'"
        es = "svanire / scomparire"
    }
    "stealthy" = @{
        word = "stealthy"
        ipa = "/ˈstel.θi/"
        pos = "adjective"
        level = "C1"
        time = "21:57"
        turnId = "turn-101"
        cat = "language"
        def = "Behaving with quiet, deliberate caution to avoid detection or alert."
        quote = "Louie (21:57): 'Yes, you could be stealthy, right? You could sneak.'"
        es = "furtivo / cauto"
    }
    "espionage" = @{
        word = "espionage"
        ipa = "/ˈes.pi.ə.nɑːʒ/"
        pos = "noun"
        level = "C2"
        time = "21:57"
        turnId = "turn-101"
        cat = "culture"
        def = "The systematic practice of spying or using covert intelligence to gather information."
        quote = "Louie (21:57): 'Do you know the word espionage? To spy?'"
        es = "spionaggio"
    }
    "fly-on-the-wall" = @{
        word = "fly on the wall"
        ipa = "/flaɪ ɒn ðə wɔːl/"
        pos = "idiom"
        level = "C2"
        time = "22:12"
        turnId = "turn-103"
        cat = "language"
        def = "An unnoticed observer who witnesses events and conversations without participating."
        quote = "Louie (22:12): 'You could be a fly on the wall... no one knows you are there, but you hear everything.'"
        es = "osservatore invisibile"
    }
    "time-travel" = @{
        word = "time travel"
        ipa = "/taɪm ˈtræv.əl/"
        pos = "noun"
        level = "B2"
        time = "22:40"
        turnId = "turn-106"
        cat = "philosophy"
        def = "The hypothetical movement backward or forward through temporal points of history."
        quote = "Giulio (22:40): 'Time travel breaks the rules... that is exactly S-tier because you are changing history.'"
        es = "viaggio nel tempo"
    }
    "meddle" = @{
        word = "meddle"
        ipa = "/ˈmed.əl/"
        pos = "verb"
        level = "C1"
        time = "23:32"
        turnId = "turn-109"
        cat = "philosophy"
        def = "To interfere impertinently or intrude in matters and affairs that are not one's concern."
        quote = "Louie (23:32): 'Do you know what we call that when you change things in other people\'s lives? We call it meddling.'"
        es = "ficcare il naso / immischiarsi"
    }
    "meddling" = @{
        word = "meddling"
        ipa = "/ˈmed.lɪŋ/"
        pos = "noun"
        level = "C1"
        time = "23:32"
        turnId = "turn-109"
        cat = "philosophy"
        def = "Unwarranted, intrusive tampering in private affairs or historical consequences."
        quote = "Louie (23:32): 'He is meddling in my business, meddling in my affairs...'"
        es = "ingerenza / intromissione"
    }
    "suspicious" = @{
        word = "suspicious"
        ipa = "/səˈspɪʃ.əs/"
        pos = "adjective"
        level = "B2"
        time = "28:35"
        turnId = "turn-124"
        cat = "emotion"
        def = "Arousing mistrust, dubious question, and wariness regarding truthfulness."
        quote = "Giulio (28:35): 'The behavior of these people is completely suspicious... at first, they completely denied the fact.'"
        es = "sospetto / diffidente"
    }
    "trap-cage" = @{
        word = "trap cage"
        ipa = "/træp keɪdʒ/"
        pos = "noun"
        level = "B2"
        time = "28:21"
        turnId = "turn-123"
        cat = "culture"
        def = "A self-locking enclosure designed to capture animals unawares."
        quote = "Giulio (28:21): 'It is actually a trap, the kind of cage that is locking itself when the animal gets inside.'"
        es = "gabbia-trappola"
    }
    "deny-the-fact" = @{
        word = "deny the fact"
        ipa = "/dɪˈnaɪ ðə fækt/"
        pos = "phrase"
        level = "B2"
        time = "28:35"
        turnId = "turn-124"
        cat = "language"
        def = "To refuse to acknowledge or admit a verified truth or occurrence."
        quote = "Giulio (28:35): 'In the beginning, they completely denied the fact... then they admitted there was a cat.'"
        es = "negare l'evidenza"
    }
    "snare" = @{
        word = "snare"
        ipa = "/sneər/"
        pos = "noun"
        level = "C2"
        time = "30:30"
        turnId = "turn-130"
        cat = "culture"
        def = "A wire or cord loop noose trap designed to entangle passing wild animals."
        quote = "Louie (30:30): 'In Vietnam they use a snare... it is not a cage, but something that grabs the animal.'"
        es = "cappio / trappola a laccio"
    }
    "neighborhood-watch" = @{
        word = "neighborhood watch"
        ipa = "/ˈneɪ.bə.hʊd wɒtʃ/"
        pos = "noun"
        level = "C1"
        time = "30:49"
        turnId = "turn-133"
        cat = "culture"
        def = "A community civilian initiative where residents collaborate to deter crime and safeguard property."
        quote = "Louie (30:49): 'Do you have a neighborhood watch? Where neighbors look out together with cameras?'"
        es = "controllo di vicinato"
    }
    "feral-cat" = @{
        word = "feral cat"
        ipa = "/ˈfer.əl kæt/"
        pos = "noun"
        level = "C1"
        time = "31:26"
        turnId = "turn-137"
        cat = "culture"
        def = "A domesticated cat that has returned to a wild state, living untamed in the outdoors."
        quote = "Giulio (31:26): 'It is not legal in Italy to place traps unless authorized to catch feral cats to sterilize them.'"
        es = "gatto randagio / rinselvatichito"
    }
    "sterilize" = @{
        word = "sterilize"
        ipa = "/ˈster.ə.laɪz/"
        pos = "verb"
        level = "B2"
        time = "31:26"
        turnId = "turn-137"
        cat = "culture"
        def = "To perform a veterinary procedure rendering an animal incapable of producing offspring."
        quote = "Giulio (31:26): 'They catch feral cats to get them sterilized, then let them back into nature.'"
        es = "sterilizzare"
    }
    "roam" = @{
        word = "roam"
        ipa = "/rəʊm/"
        pos = "verb"
        level = "B2"
        time = "32:27"
        turnId = "turn-138"
        cat = "culture"
        def = "To wander freely across fields and gardens without fixed path or destination."
        quote = "Louie (32:27): 'We say they roam the neighborhood... play with the other cats and come home.'"
        es = "girovagare / vagare liberamente"
    }
    "mind-reading" = @{
        word = "mind reading"
        ipa = "/maɪnd ˈriː.dɪŋ/"
        pos = "noun"
        level = "B2"
        time = "33:44"
        turnId = "turn-146"
        cat = "philosophy"
        def = "The telepathic discernment of another person's unspoken private thoughts and motives."
        quote = "Giulio (33:44): 'Maybe I would put mind reading on B and flying on C.'"
        es = "lettura del pensiero"
    }
    "table-the-discussion" = @{
        word = "table the discussion"
        ipa = "/ˈteɪ.bəl ðə dɪˈskʌʃ.ən/"
        pos = "idiom"
        level = "C1"
        time = "35:28"
        turnId = "turn-152"
        cat = "language"
        def = "To postpone or suspend further debate on an issue until a future scheduled session."
        quote = "Louie (35:28): 'To table the discussion... it means to stop talking now and talk about it on another day.'"
        es = "rinviare la discussione / aggiornarsi"
    }
    "postpone" = @{
        word = "postpone"
        ipa = "/pəʊstˈpəʊn/"
        pos = "verb"
        level = "B2"
        time = "38:48"
        turnId = "turn-160"
        cat = "language"
        def = "To defer an action or deliberation to a later date due to lack of immediate readiness."
        quote = "Giulio (38:48): 'Yeah, you are postponing a decision for another day.'"
        es = "posticipare / rimandare"
    }
    "wait-till-monday" = @{
        word = "wait till Monday"
        ipa = "/weɪt tɪl ˈmʌn.deɪ/"
        pos = "phrase"
        level = "C1"
        time = "35:54"
        turnId = "turn-155"
        cat = "language"
        def = "A diplomatic management idiom advising teams to let stressful impasses rest over the weekend."
        quote = "Louie (35:54): 'I always say, why don't we wait till Monday? It gives everyone the weekend to cool down.'"
        es = "aggiornarsi a lunedì / far decantare"
    }
    "architectural-integrity" = @{
        word = "architectural integrity"
        ipa = "/ˌɑː.kɪˈtek.tʃər.əl ɪnˈteɡ.rə.ti/"
        pos = "noun"
        level = "C1"
        time = "35:54"
        turnId = "turn-155"
        cat = "culture"
        def = "Adherence to sound structural principles, historical authenticity, and safety in building design."
        quote = "Louie (35:54): 'Architects get stressed thinking about their professional integrity...'"
        es = "integrità architettonica"
    }
    "shed-light" = @{
        word = "shed light on"
        ipa = "/ʃed laɪt ɒn/"
        pos = "idiom"
        level = "C1"
        time = "39:21"
        turnId = "turn-161"
        cat = "language"
        def = "To clarify, illuminate, or provide crucial explanatory insight into a perplexing technical problem."
        quote = "Louie (39:21): 'Have you ever heard of shed light on something? It means to clarify and highlight.'"
        es = "fare luce su / chiarire"
    }
    "intricate" = @{
        word = "intricate"
        ipa = "/ˈɪn.trɪ.kət/"
        pos = "adjective"
        level = "C1"
        time = "40:41"
        turnId = "turn-167"
        cat = "language"
        def = "Composed of many elaborate, interconnected components; highly detailed and complex."
        quote = "Louie (40:41): 'Not confusing, but very intricate... intricate means detailed, with lots going on.'"
        es = "intricato / minuzioso e complesso"
    }
    "vision-recognition" = @{
        word = "vision recognition"
        ipa = "/ˈvɪʒ.ən ˌrek.əɡˈnɪʃ.ən/"
        pos = "noun"
        level = "C1"
        time = "40:42"
        turnId = "turn-168"
        cat = "culture"
        def = "Optical computer vision technology scanning and verifying pharmaceutical manufacturing containers at high speeds."
        quote = "Louie (40:42): 'It has vision recognition at so many frames, records it, and checks pharmaceutical products...'"
        es = "visione artificiale / riconoscimento ottico"
    }
    "shady" = @{
        word = "shady"
        ipa = "/ˈʃeɪ.di/"
        pos = "adjective"
        level = "B2"
        time = "40:42"
        turnId = "turn-168"
        cat = "culture"
        def = "Disreputable, suspicious, or evasive in business transparency and ethics."
        quote = "Louie (40:42): 'Imagine you are a shady guy, and the government asks you to shed light on your accounts!'"
        es = "losco / poco trasparente"
    }
    "bring-to-the-table" = @{
        word = "bring to the table"
        ipa = "/brɪŋ tuː ðə ˈteɪ.bəl/"
        pos = "idiom"
        level = "C1"
        time = "42:09"
        turnId = "turn-171"
        cat = "language"
        def = "To provide valuable skills, technical expertise, or unique assets to an enterprise or collaborative team."
        quote = "Louie (42:09): 'What do you bring to the table? It means what qualities or skills do you bring to the company?'"
        es = "apportare valore / competenze"
    }
    "performance-review" = @{
        word = "performance review"
        ipa = "/pəˈfɔː.məns rɪˈvjuː/"
        pos = "noun"
        level = "B2"
        time = "42:09"
        turnId = "turn-171"
        cat = "culture"
        def = "A formal periodic evaluation of an employee's professional contributions and competency."
        quote = "Louie (42:09): 'You may hear it in a performance review of your employees: What does he bring to the table?'"
        es = "valutazione delle prestazioni"
    }
    "herding-cats" = @{
        word = "herding cats"
        ipa = "/ˈhɜː.dɪŋ kæts/"
        pos = "idiom"
        level = "C2"
        time = "43:59"
        turnId = "turn-175"
        cat = "language"
        def = "An idiom describing the exhausting, near-impossible task of directing stubborn, independent individuals."
        quote = "Louie (43:59): 'In English we have this idiom: It is like herding cats! Impossible, chaotic...'"
        es = "come mettere in fila i gatti (impresa impossibile)"
    }
    "shepherd" = @{
        word = "shepherd"
        ipa = "/ˈʃep.əd/"
        pos = "noun"
        level = "B2"
        time = "44:11"
        turnId = "turn-179"
        cat = "culture"
        def = "A rural person who watches over, guides, and protects herds of grazing sheep."
        quote = "Louie (44:11): 'A shepherd has lots of sheep and uses a dog to guide them slowly... now imagine if they were cats!'"
        es = "pastore"
    }
    "smoke-break" = @{
        word = "smoke break"
        ipa = "/sməʊk breɪk/"
        pos = "noun"
        level = "B2"
        time = "46:13"
        turnId = "turn-196"
        cat = "culture"
        def = "A short designated pause during working hours for employees to smoke outdoors."
        quote = "Giulio (46:13): 'There are rules: one time in the morning and one time in the afternoon, just two ten-minute smoke breaks.'"
        es = "pausa sigaretta"
    }
    "testing-phase" = @{
        word = "testing phase"
        ipa = "/ˈtes.tɪŋ feɪz/"
        pos = "noun"
        level = "B2"
        time = "47:54"
        turnId = "turn-205"
        cat = "culture"
        def = "The rigorous engineering stage where prototypes are tested under live operating conditions."
        quote = "Giulio (47:54): 'We are already in the testing phase with the client, but some of the tests are not going well...'"
        es = "fase di collaudo e test"
    }
    "penalty-clause" = @{
        word = "penalty clause"
        ipa = "/ˈpen.əl.ti klɔːz/"
        pos = "noun"
        level = "C1"
        time = "49:01"
        turnId = "turn-208"
        cat = "culture"
        def = "A contractual provision imposing financial penalties for failing to deliver machinery on schedule."
        quote = "Giulio (49:01): 'There are deadlines, there are penalties... definitely crunch time.'"
        es = "penale contrattuale per ritardo"
    }
    "lead-time" = @{
        word = "lead time"
        ipa = "/ˈliːd taɪm/"
        pos = "noun"
        level = "C1"
        time = "50:59"
        turnId = "turn-214"
        cat = "culture"
        def = "The total latency elapsed between placing an industrial equipment order and its final physical arrival."
        quote = "Louie (50:59): 'The lead time on these commercial ovens is years... so I flew to Paris, picked it up, and drove back!'"
        es = "tempi di consegna / lead time"
    }
    "breakneck-pace" = @{
        word = "breakneck pace"
        ipa = "/ˈbreɪk.nek peɪs/"
        pos = "phrase"
        level = "C1"
        time = "51:11"
        turnId = "turn-217"
        cat = "language"
        def = "A dangerously or exhaustingly rapid speed of work and execution."
        quote = "Louie (51:11): '24 hours before we launched our restaurant... we washed two thousand glasses through the night!'"
        es = "ritmo frenetico / a rotta di collo"
    }
}

# 3. Define 6 NATURAL STRENGTHS
$naturalStrengths = @(
    @{
        topic = "Engineering Project Fluency"
        time = "00:23"
        phrase = "We need to work on shifts in order to achieve some goals on the project. So we are trying to respect the timeline and the deadline."
        note = "Giulio articulated his demanding factory schedule with natural technical authority, seamlessly linking 'shifts', 'timeline', and 'deadline' into an elegant explanation."
    },
    @{
        topic = "Evocative Culinary Critique"
        time = "08:49"
        phrase = "Sometimes they are too crunchy, and when you bite them, it is like exploding. You are not able to eat them in a proper way."
        note = "A vivid, tactile description of hard taco shells. Giulio captured both the physical texture and the dining frustration with spontaneous humor."
    },
    @{
        topic = "Serene Alpine Storytelling"
        time = "10:56"
        phrase = "I love taking long walks, treks in the forests, in nature... it is really relaxing to be surrounded by trees and waterfalls."
        note = "Expressive nature vocabulary highlighting Giulio's personal sanctuary. The sentence cadence was calm, contemplative, and grammatically graceful."
    },
    @{
        topic = "Cultural Exposition: The Venetian Bàcaro"
        time = "14:26"
        phrase = "We have these small wine shops called bàcaro... you walk from one to another, tasting wine and eating finger food. In the end, you don't remember when you started!"
        note = "A wonderful cultural parallel to the English pub crawl. Giulio used humorous narrative framing to introduce local Italian heritage effortlessly."
    },
    @{
        topic = "Principled Civic & Animal Welfare Advocacy"
        time = "31:26"
        phrase = "It is not legal in Italy to place those kinds of traps unless you are authorized... they are always trying to discover something in the neighborhood."
        note = "Spoke with remarkable clarity and emotional conviction on municipal Italian animal protection laws, delivering complex legal distinctions without hesitation."
    },
    @{
        topic = "Visual Factory Floor Metaphors"
        time = "48:48"
        phrase = "On a normal project, there are two or three people around the machine... on crunch time, there are 16 people praying to have the machine for ten minutes to test their part."
        note = "An extraordinary workplace image! Giulio brought the intensity of pharmaceutical hardware testing alive with sharp observation and humor."
    }
)

# 4. Define 6 GENTLE PHRASINGS
$gentlePhrasings = @(
    @{
        topic = "Early Shift Description"
        time = "00:12"
        said = "I started today working from, I started working at, six. So it has been tough..."
        natural = "I was on the early shift today, starting at 6:00 AM, so it has been quite a demanding day."
        note = "Using 'on the early shift' instantly conveys the factory schedule with natural, polished English rhythm."
    },
    @{
        topic = "Ranking Food Tiers"
        time = "04:40"
        said = "Because maybe a lot more meat... meat and pasta on the same level, but sushi is beef for me."
        natural = "I am much more of a meat and pasta person—sushi is good, but it sits in B-tier for me."
        note = "Polishing the accidental slip between 'beef' and 'B-tier' into a clean culinary ranking."
    },
    @{
        topic = "Alpine Gastronomy"
        time = "10:56"
        said = "Staying in the nature... but on the mountains, the cuisine is, in my opinion, the best."
        natural = "Being immersed in nature is wonderful, and in my opinion, alpine cuisine is second to none."
        note = "'Immersed in nature' and 'second to none' elevate conversational descriptions to C1/C2 mastery."
    },
    @{
        topic = "Investigating Suspicious Circumstances"
        time = "28:35"
        said = "The behavior of these people is completely suspicious... in the beginning, they completely negate the fact."
        natural = "Their behavior was deeply suspicious—at first, they flatly denied having seen anything."
        note = "Correcting the false friend 'negate' (*negare* in Italian) to the natural native verb 'flatly denied'."
    },
    @{
        topic = "Postponing Workplace Decisions"
        time = "38:48"
        said = "It happens when something is not urgent or we needed to wait for a sponsor from a third person..."
        natural = "We table discussions whenever an item isn't urgent or we are awaiting input from an external stakeholder."
        note = "Upgrading 'sponsor from a third person' to professional corporate phrasing: 'awaiting input from an external stakeholder'."
    },
    @{
        topic = "Praising Team Discipline"
        time = "44:58"
        said = "Not at all. No, there. It is. Yeah, it is a good stuff."
        natural = "Not at all—my team is very disciplined and cohesive; it is definitely not like herding cats!"
        note = "Smoothing the slip from 'stuff' to 'staff', connecting directly back to Louie's humorous idiom."
    }
)

# 5. Define 20 ASR FIXES
$asrFixes = @(
    @{ fixed = "Giulio"; heard = "Julia"; time = "00:00"; context = "The automatic note-taker transcribed Giulio as Julia throughout." },
    @{ fixed = "We have the Alps"; heard = "We have the odds"; time = "11:58"; context = "Discussing the mountain ranges bordering Giulio's region in northern Italy." },
    @{ fixed = "bàcaro / bàcari"; heard = "bacaro"; time = "14:26"; context = "Traditional Venetian wine and cicchetti taverns." },
    @{ fixed = "pub crawl"; heard = "pub crew"; time = "13:48"; context = "The British tradition of touring multiple pubs in an evening." },
    @{ fixed = "crawl... like a thief"; heard = "c... like a thie"; time = "13:37"; context = "Giulio guessing the etymology of the word crawl." },
    @{ fixed = "house / casa"; heard = "ASA"; time = "28:16"; context = "The note-taker mishearing the Italian word for house." },
    @{ fixed = "denied the fact"; heard = "negate the fact"; time = "28:35"; context = "False friend from Italian negare (to deny)." },
    @{ fixed = "attempted to say"; heard = "TED to say"; time = "28:35"; context = "Speech-to-text stuttering on neighbor denial." },
    @{ fixed = "roaming around"; heard = "journeying around"; time = "32:27"; context = "Describing outdoor domestic cats exploring gardens." },
    @{ fixed = "Ramen"; heard = "Raman / Ram mean"; time = "06:37"; context = "Japanese noodle soup in the food tier list." },
    @{ fixed = "B-tier for me"; heard = "beef for me"; time = "04:37"; context = "Ranking sushi into B-tier." },
    @{ fixed = "stupid tills / cash registers"; heard = "stupid tiles"; time = "41:48"; context = "Louie's business partner's quirky financial advice." },
    @{ fixed = "tills"; heard = "tiles"; time = "41:48"; context = "Point-of-sale registers where cash is collected." },
    @{ fixed = "adventurous"; heard = "adventureers"; time = "51:44"; context = "Giulio laughing at Louie's Paris restaurant oven trip." },
    @{ fixed = "good staff"; heard = "good stuff"; time = "45:06"; context = "Giulio confirming that his engineering colleagues are disciplined." },
    @{ fixed = "in my staff"; heard = "in myself"; time = "46:10"; context = "Describing whether factory employees smoke." },
    @{ fixed = "a bit lighthearted"; heard = "let in from children"; time = "10:04"; context = "Louie describing the vacation tier list game." },
    @{ fixed = "doing a pub crawl"; heard = "making a tour of the pubs"; time = "13:20"; context = "Giulio describing visiting London pubs with friends." },
    @{ fixed = "trekking in the forests"; heard = "tracks in the forests"; time = "10:56"; context = "Hiking across mountain paths in northern Italy." },
    @{ fixed = "response from a third party"; heard = "sponsor from a third person"; time = "38:48"; context = "Waiting for external client verification before deciding." }
)

# 6. Define 4 EDITORIAL TOPICS
$editorialTopics = @(
    @{
        id = "topic-1"
        tag = "Alpine Sanctuary & Venetian Heritage"
        title = "Between the Alpine Trails and the Venetian Bàcaro"
        quote = "'We have these small wine shops called bàcaro... you walk from one to another, tasting wine and eating finger food. In the end, you don't remember when you started!' • Giulio"
        paragraphs = @(
            "Living in the serene countryside of northern Italy, Giulio enjoys the rare gift of geographic balance: within short reach lie both the sunlit Adriatic coastline and the soaring majesty of the Italian Alps. For his personal sanctuary, the mountains take pride of place. Weekends spent hiking through dense alpine forests, past roaring waterfalls, and resting at rustic rifugi for hearty mountain cuisine offer an essential antidote to demanding engineering deadlines.",
            "When venturing into historic Venice, the local pace turns delightfully social. Giulio illuminated the time-honored tradition of the *bàcaro tour*—the Venetian counterpart to an English pub crawl—where friends stroll over cobblestone bridges from tavern to tavern, savoring small glasses of regional wine (*ombra*) alongside fresh, crusty *cicchetti* appetizers."
        )
    },
    @{
        id = "topic-2"
        tag = "High-Stakes Engineering"
        title = "The Anatomy of Pharmaceutical 'Crunch Time'"
        quote = "'On crunch time, there are 16 people around the machine praying to have it for ten minutes to test their part.' • Giulio"
        paragraphs = @(
            "High-speed pharmaceutical packaging and inspection machinery demands millimeter precision. In Giulio's manufacturing facility, optical vision recognition modules must scan, verify, and track millions of pharmaceutical items with zero error tolerance. As contractual delivery dates approach, the team enters what industry professionals call 'crunch time.'",
            "Shifts commence before dawn at 6:00 AM, with sixteen engineers clustered around a single prototype, each negotiating for a precious ten-minute window to run diagnostics before tomorrow evening's executive review with client stakeholders."
        )
    },
    @{
        id = "topic-3"
        tag = "Ethics & Empathy"
        title = "Of Traps, Roaming Cats & The Ethics of Meddling"
        quote = "'If I had time travel, I would leave ten minutes before work to find my cat and bring her safely home.' • Giulio"
        paragraphs = @(
            "In an unexpectedly poignant turn of conversation, a lighthearted discussion about superhero powers evolved into a heartfelt reflection on loss and neighborly ethics. One month ago, Giulio lost his beloved cat. Soon afterward, neighbors across the street were discovered harboring an unauthorized one-meter locking wire trap—ostensibly for mice, yet clearly proportioned for domestic animals.",
            "Giulio spoke with moving dignity, citing Italian civic protections that prohibit private trapping of domestic pets. When asked which single moment in history he would alter if gifted with time travel, he chose neither wealth nor fame, but simply a ten-minute temporal adjustment to rescue his pet before she vanished into the morning mist."
        )
    },
    @{
        id = "topic-4"
        tag = "Workplace Diplomacy"
        title = "The British Art of Meeting Diplomacy: From 'Herding Cats' to 'Waiting Till Monday'"
        quote = "'To table the discussion... why don't we wait till Monday? It gives everyone the weekend to cool down.' • Louie"
        paragraphs = @(
            "Louie shared colorful workplace wisdom drawn from years in British commercial restoration and hospitality. When passionate architects reach a fierce architectural impasse, the most diplomatic solution is often to 'table the discussion'—or, as Louie gracefully phrases it, 'Why don't we wait till Monday?' A weekend break lets tempers cool and reveals obvious structural solutions.",
            "Equally memorable is the English idiom 'like herding cats'—the futile attempt to impose rigid order on intensely independent individuals. From Louie's partner's cigarette breaks to a mad dash across the English Channel to Paris 24 hours before opening to retrieve a commercial oven, humor and patience remain the greatest leadership assets."
        )
    }
)

# 7. Define 8 FLASHCARD KEYS
$flashcardKeys = @("crunch-time", "hit-or-miss", "bacaro", "fly-on-the-wall", "meddle", "table-the-discussion", "shed-light", "herding-cats")

# 8. Define 6 QUIZ QUESTIONS (The Test)
$quizQuestions = @(
    @{
        id = 1
        question = "What does the corporate and engineering phrase 'crunch time' (01:08) describe in Giulio's workplace?"
        options = @(
            "A daily morning stretching session before operating factory equipment."
            "A high-intensity period before a critical project deadline where teams work extended shifts to complete and test a machine."
            "The scheduled lunch hour when engineers eat crunchy snacks."
            "A mandatory company training seminar on safety regulations."
        )
        correctIndex = 1
        explanation = "'Crunch time' (01:08) refers to the critical, high-pressure final stretch before a major project delivery where teams pull long hours to achieve their milestones."
    },
    @{
        id = 2
        question = "When Louie describes an experience or food (such as crispy tacos) as being 'hit or miss' (09:25), what does the idiom mean?"
        options = @(
            "It is strictly forbidden by health authorities."
            "It is highly unpredictable in quality—sometimes excellent, but other times disappointing depending on who makes it."
            "It must always be served at room temperature."
            "It is an acquired taste popular only among children."
        )
        correctIndex = 1
        explanation = "'Hit or miss' (09:25) describes something inconsistent that can either be a great success or a failure depending on circumstances or preparation."
    },
    @{
        id = 3
        question = "What is a traditional Venetian 'bàcaro tour' (14:26), which Giulio compared to an English 'pub crawl'?"
        options = @(
            "A guided gondola race through the Grand Canal."
            "Walking between small, rustic Venetian wine bars to enjoy glasses of wine paired with bite-sized cicchetti finger food."
            "A formal seated five-course banquet in a historic palace."
            "A bicycle marathon navigating the bridges of Venice."
        )
        correctIndex = 1
        explanation = "A bàcaro (14:26) is an authentic Venetian wine bar where locals socialize over local wine and traditional cicchetti (small savory appetizers)."
    },
    @{
        id = 4
        question = "In professional English meetings, what does the idiom 'to table the discussion' (35:28) mean?"
        options = @(
            "To place all physical documents on top of the conference table for immediate signing."
            "To postpone a topic or decision until a future date or meeting so tempers can cool and more information can be gathered."
            "To terminate the project immediately and cancel future meetings."
            "To invite junior employees to vote on executive strategy."
        )
        correctIndex = 1
        explanation = "'To table the discussion' (35:28) means to put an unresolved issue on hold and revisit it later—often phrased casually as 'Why don't we wait till Monday?'"
    },
    @{
        id = 5
        question = "What humorous dilemma does the British idiom 'like herding cats' (44:11) vividly illustrate?"
        options = @(
            "Training domestic pets to perform complicated agility tricks."
            "Trying to organize, coordinate, or control a chaotic, independent group of people who all want to do different things."
            "Working in veterinary medicine during emergency calls."
            "Cleaning up spilled milk in a busy commercial restaurant kitchen."
        )
        correctIndex = 1
        explanation = "'Herding cats' (44:11) is a classic British idiom for an impossibly frustrating task: attempting to corral independent individuals into a unified direction."
    },
    @{
        id = 6
        question = "When Giulio wished he had the superpower of 'time travel' (24:36) to change an event from one month ago, what personal situation was he hoping to fix?"
        options = @(
            "Arriving 10 minutes earlier before work to locate his lost cat and investigate a neighbor's suspicious trapping cage."
            "Preventing an electrical microchip failure on a brand new oven imported from Paris."
            "Canceling a rainy holiday weekend to the Alps."
            "Buying a vintage bicycle before it was sold out in Rome."
        )
        correctIndex = 0
        explanation = "Giulio shared the touching story of his lost cat (24:36), wishing he could travel back just 10 minutes to rescue her before she vanished."
    }
)

# 9. Define 3 REFLECTION PROMPTS
$reflectionPrompts = @(
    @{
        num = "01"
        title = "Navigating the Testing Phase Meeting"
        text = "As you enter tomorrow evening's project manager review regarding client testing, how can you deploy diplomatic phrases like 'shed light on' or 'table the discussion' to manage stakeholder expectations gracefully?"
    },
    @{
        num = "02"
        title = "The Alpine Sanctuary Escape"
        text = "When your current 16-person engineering crunch time concludes, what specific alpine trail or mountain rifugio near the Alps will you head to in order to disconnect, unwind, and recharge?"
    },
    @{
        num = "03"
        title = "The Art of Herding Cats"
        text = "Reflect on a past moment in your engineering career when coordinating colleagues felt 'like herding cats'. What communication adjustments helped bring everyone into alignment?"
    }
)

# 10. Process Transcript Turns into HTML Objects
Write-Host "Processing transcript turns with ASR fix badges and vocabulary marks..."

$asrMap = @{
    "We have the odds" = @{ fix = "We have the Alps"; raw = "We have the odds" }
    "pub crew" = @{ fix = "pub crawl"; raw = "pub crew" }
    "c... like a thie" = @{ fix = "crawl... like a thief"; raw = "c... like a thie" }
    "ASA" = @{ fix = "house / casa"; raw = "ASA" }
    "negate the fact" = @{ fix = "denied the fact"; raw = "negate the fact" }
    "TED to say" = @{ fix = "attempted to say"; raw = "TED to say" }
    "journeying around" = @{ fix = "roaming around"; raw = "journeying around" }
    "Ram mean" = @{ fix = "Ramen"; raw = "Ram mean" }
    "Raman" = @{ fix = "Ramen"; raw = "Raman" }
    "beef for me" = @{ fix = "B-tier for me"; raw = "beef for me" }
    "stupid tiles" = @{ fix = "stupid tills / cash registers"; raw = "stupid tiles" }
    "tiles" = @{ fix = "tills"; raw = "tiles" }
    "adventureers" = @{ fix = "adventurous"; raw = "adventureers" }
    "good stuff" = @{ fix = "good staff"; raw = "good stuff" }
    "in myself" = @{ fix = "in my staff"; raw = "in myself" }
    "let in from children" = @{ fix = "a bit lighthearted"; raw = "let in from children" }
    "tracks in the forests" = @{ fix = "treks in the forests"; raw = "tracks in the forests" }
    "sponsor from a third person" = @{ fix = "response from a third party"; raw = "sponsor from a third person" }
}

$processedTurns = @()
for ($i = 0; $i -lt $turns.Count; $i++) {
    $t = $turns[$i]
    $turnId = "turn-$i"
    
    # Speaker normalization
    $speaker = "Louie"
    if ($t.speaker -match "Julia|Giulio") { 
        $speaker = "Giulio" 
    } elseif ($t.speaker -match "Lewis|Louie") {
        $speaker = "Louie"
    }

    $html = $t.text

    # Apply ASR Fix Badges
    foreach ($k in $asrMap.Keys) {
        $item = $asrMap[$k]
        if ($html.Contains($k)) {
            $badge = "<span class=`"asr-fix-pill`" title=`"Note-taker misheard '$($item.fix)' as '$($item.raw)'`">✨ Fixed: `"$($item.fix)`" <span class=`"text-stone-400`">(note-taker: `"$($item.raw)`")</span></span>"
            $html = $html.Replace($k, $badge)
        }
    }

    # Chapter assignment based on lesson progression
    $chapterId = $null
    $chapterTitle = $null
    if ($i -eq 0) {
        $chapterId = "chap-1"
        $chapterTitle = "Chapter I • Early Shifts, Deadlines & The Engineering 'Crunch Time' (00:00 – 02:30)"
    } elseif ($i -eq 13) {
        $chapterId = "chap-2"
        $chapterTitle = "Chapter II • The Great Food Tier List: Pizza, Ramen & Exploding Tacos (02:31 – 09:50)"
    } elseif ($i -eq 52) {
        $chapterId = "chap-3"
        $chapterTitle = "Chapter III • Alpine Trails, Venetian Bàcari & London Pub Crawls (09:51 – 19:40)"
    } elseif ($i -eq 94) {
        $chapterId = "chap-4"
        $chapterTitle = "Chapter IV • Superpowers, Time Travel & The Mystery of the Missing Cat (19:41 – 34:30)"
    } elseif ($i -eq 150) {
        $chapterId = "chap-5"
        $chapterTitle = "Chapter V • Business Diplomacy: Tabling Talks & Shedding Light on Complex Systems (34:31 – 43:50)"
    } elseif ($i -eq 174) {
        $chapterId = "chap-6"
        $chapterTitle = "Chapter VI • 'Herding Cats', Smoke Break Rules & The 24-Hour Paris Oven Dash (43:51 – 52:56)"
    }

    $processedTurns += [PSCustomObject]@{
        id = $turnId
        speaker = $speaker
        time = $t.time
        chapterId = $chapterId
        chapterTitle = $chapterTitle
        html = $html
        raw = $t.text
    }
}

# Tag vocabulary items at their designated turn
foreach ($vkey in $vocabDb.Keys) {
    $vItem = $vocabDb[$vkey]
    $tId = $vItem.turnId
    $tIdx = [int]($tId.Replace("turn-", ""))
    if ($tIdx -ge 0 -and $tIdx -lt $processedTurns.Count) {
        $targetTurn = $processedTurns[$tIdx]
        $w = $vItem.word
        $mark = "<span class=`"vocab-mark`" data-vkey=`"$vkey`" onclick=`"inspectVocab('$vkey')`">$w</span>"
        if ($targetTurn.html -match [regex]::Escape($w)) {
            $targetTurn.html = [regex]::Replace($targetTurn.html, "\b" + [regex]::Escape($w) + "\b", $mark, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        } else {
            $targetTurn.html += " $mark"
        }
    }
}

Write-Host "Completed vocabulary tagging across $($processedTurns.Count) turns."

# 11. Serialize Data Objects to JSON
$vocabDbJson = $vocabDb | ConvertTo-Json -Depth 10
$strengthsJson = $naturalStrengths | ConvertTo-Json -Depth 10
$phrasingsJson = $gentlePhrasings | ConvertTo-Json -Depth 10
$asrFixesJson = $asrFixes | ConvertTo-Json -Depth 10
$editorialTopicsJson = $editorialTopics | ConvertTo-Json -Depth 10
$flashcardKeysJson = $flashcardKeys | ConvertTo-Json
$quizQuestionsJson = $quizQuestions | ConvertTo-Json -Depth 10
$reflectionPromptsJson = $reflectionPrompts | ConvertTo-Json -Depth 10
$turnsJson = $processedTurns | ConvertTo-Json -Depth 10

Write-Host "Serialized all data structures cleanly to JSON."

# 12. Assemble Full index.html
$headPart = @'
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Giulio's Interactive English Sanctuary • Lesson 01 Notes</title>

  <!-- Google Fonts: Cormorant Garamond, Plus Jakarta Sans, JetBrains Mono -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;0,700;1,400;1,600&family=JetBrains+Mono:wght@400;500;600&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Tailwind CSS CDN -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            serif: ['"Cormorant Garamond"', 'Georgia', 'serif'],
            sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
            mono: ['"JetBrains Mono"', 'monospace'],
          },
          colors: {
            parchment: {
              50: '#fbf9f5',
              100: '#f6f1e7',
              200: '#ede3d1',
              300: '#dfd0b5',
              400: '#cbb38e',
              500: '#b6966b',
            },
            autumn: {
              50: '#fcf6f0',
              100: '#f7e9db',
              200: '#eed0b5',
              300: '#e2b086',
              400: '#d38c57',
              500: '#be6f38',
              600: '#a3582b',
              700: '#854524',
              800: '#6c3921',
            },
            sage: {
              50: '#f4f7f5',
              100: '#e4ece7',
              200: '#cadad1',
              300: '#a5bfb1',
              400: '#7b9f8d',
              500: '#5b826f',
              600: '#476858',
              700: '#3a5448',
              800: '#30443b',
            },
            slatewarm: {
              700: '#3d4441',
              800: '#2b312e',
              900: '#1e2321',
            }
          }
        }
      }
    }
  </script>

  <!-- Lucide Icons -->
  <script src="https://unpkg.com/lucide@latest"></script>

  <!-- GSAP for Smooth Transitions -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>

  <!-- Popper & Tippy.js for Vocabulary Tooltips -->
  <script src="https://unpkg.com/@popperjs/core@2"></script>
  <script src="https://unpkg.com/tippy.js@6"></script>
  <link rel="stylesheet" href="https://unpkg.com/tippy.js@6/animations/shift-away.css" />

  <!-- Canvas Confetti -->
  <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.9.3/dist/confetti.browser.min.js"></script>

  <style>
    :root {
      --bg-base: #f9f6f0;
      --bg-card: rgba(255, 253, 249, 0.92);
      --bg-subcard: rgba(255, 255, 255, 0.95);
      --border-soft: #e6decb;
      --border-accent: #d9c8b0;
      --text-main: #2b312e;
      --text-muted: #5c6660;
      --grad-1: rgba(238, 208, 181, 0.42);
      --grad-2: rgba(202, 218, 209, 0.48);
      --grad-3: rgba(246, 241, 231, 0.70);
    }

    body[data-theme="winchester"] {
      --bg-base: #f3f6f5;
      --bg-card: rgba(252, 254, 253, 0.91);
      --bg-subcard: rgba(255, 255, 255, 0.95);
      --border-soft: #d7e2dc;
      --border-accent: #b8ccc2;
      --text-main: #26312d;
      --text-muted: #52635c;
      --grad-1: rgba(202, 218, 209, 0.50);
      --grad-2: rgba(219, 228, 238, 0.48);
      --grad-3: rgba(244, 240, 230, 0.55);
    }

    body[data-theme="twilight"] {
      --bg-base: #f5efe6;
      --bg-card: rgba(253, 249, 242, 0.92);
      --bg-subcard: rgba(255, 252, 247, 0.96);
      --border-soft: #e2d2be;
      --border-accent: #cfaea0;
      --text-main: #2d2622;
      --text-muted: #665850;
      --grad-1: rgba(226, 176, 134, 0.36);
      --grad-2: rgba(214, 196, 176, 0.42);
      --grad-3: rgba(235, 220, 202, 0.55);
    }

    body {
      background-color: var(--bg-base);
      background-image:
        radial-gradient(at 8% 5%, var(--grad-1) 0px, transparent 52%),
        radial-gradient(at 92% 18%, var(--grad-2) 0px, transparent 52%),
        radial-gradient(at 50% 88%, var(--grad-3) 0px, transparent 58%);
      background-attachment: fixed;
      color: var(--text-main);
      transition: background-color 0.5s ease, color 0.4s ease;
      overflow-x: hidden;
    }

    .sanctuary-card {
      background: var(--bg-card);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid var(--border-soft);
      box-shadow: 0 12px 36px -10px rgba(91, 130, 111, 0.08), 0 4px 14px -3px rgba(43, 49, 46, 0.04);
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .sanctuary-subcard {
      background: var(--bg-subcard);
      border: 1px solid var(--border-soft);
      box-shadow: 0 4px 14px -4px rgba(43, 49, 46, 0.04);
      transition: all 0.25s ease;
    }

    .vocab-mark {
      display: inline-block;
      background: linear-gradient(120deg, rgba(226, 176, 134, 0.28) 0%, rgba(165, 191, 177, 0.30) 100%);
      border-bottom: 2px dashed #a3582b;
      color: #5b3216;
      font-weight: 600;
      padding: 0px 5px;
      margin: 0 1px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s ease;
      position: relative;
    }

    .vocab-mark:hover, .vocab-mark.active-vocab {
      background: linear-gradient(120deg, rgba(190, 111, 56, 0.25) 0%, rgba(91, 130, 111, 0.32) 100%);
      border-bottom-style: solid;
      border-bottom-color: #476858;
      transform: translateY(-1px);
      box-shadow: 0 3px 10px rgba(163, 88, 43, 0.14);
    }

    body.hide-vocab-highlights .vocab-mark {
      background: transparent !important;
      border-bottom: none !important;
      color: inherit !important;
      font-weight: inherit !important;
      padding: 0 !important;
      box-shadow: none !important;
    }

    .asr-fix-pill {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      font-size: 0.72rem;
      font-family: 'Plus Jakarta Sans', sans-serif;
      background-color: #f4f7f5;
      color: #476858;
      border: 1px solid #cadad1;
      padding: 1px 7px;
      border-radius: 999px;
      margin-left: 4px;
      vertical-align: middle;
    }

    body.hide-asr-fixes .asr-fix-pill {
      display: none !important;
    }

    .tippy-box[data-theme~='autumn-sanctuary'] {
      background-color: #fffdf9;
      color: #2b312e;
      border: 1px solid #dfd0b5;
      border-radius: 1rem;
      box-shadow: 0 20px 38px -8px rgba(61, 68, 65, 0.16), 0 6px 16px -4px rgba(163, 88, 43, 0.08);
      padding: 0.35rem;
      font-family: 'Plus Jakarta Sans', sans-serif;
    }

    .tippy-box[data-theme~='autumn-sanctuary'][data-placement^='top'] > .tippy-arrow::before {
      border-top-color: #dfd0b5;
    }
    .tippy-box[data-theme~='autumn-sanctuary'][data-placement^='bottom'] > .tippy-arrow::before {
      border-bottom-color: #dfd0b5;
    }

    @keyframes gentleGlow {
      0% { background-color: rgba(226, 176, 134, 0.45); transform: scale(1.005); }
      50% { background-color: rgba(165, 191, 177, 0.38); }
      100% { background-color: transparent; transform: scale(1); }
    }
    .turn-highlight-flash {
      animation: gentleGlow 2.8s ease-out;
    }

    @media print {
      .no-print, #autumn-breeze-canvas { display: none !important; }
      body { background: #fff !important; }
      .sanctuary-card, .sanctuary-subcard { box-shadow: none !important; border: 1px solid #ccc !important; }
    }
  </style>
</head>
<body data-theme="kensington" class="font-sans antialiased min-h-screen selection:bg-autumn-200 selection:text-slatewarm-900 relative">

  <!-- CALMING LONDON AUTUMN BREEZE CANVAS OVERLAY -->
  <canvas id="autumn-breeze-canvas" class="fixed inset-0 pointer-events-none z-20 opacity-80"></canvas>

  <!-- TOP LESSON NOTICE BAR -->
  <aside class="bg-gradient-to-r from-sage-800 via-sage-700 to-autumn-700 text-white text-xs py-2 px-4 shadow-sm relative z-50 flex items-center justify-between gap-3 flex-wrap">
    <div class="flex items-center gap-2 flex-wrap">
      <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-white/20 text-white font-mono text-[11px] font-bold">
        ✨ Lesson 01
      </span>
      <span class="font-medium">Giulio M. • Pharmaceutical Engineering, Alpine Sanctuaries &amp; Business Idioms</span>
    </div>
    <div class="flex items-center gap-2">
      <span class="text-white/80 text-[11px]">Veneto, Italy ↔ Hanoi, Vietnam</span>
      <a href="#how-it-works" class="underline font-semibold hover:text-parchment-100 transition text-[11px] ml-1">How It Works ↓</a>
    </div>
  </aside>

  <!-- STICKY PEACEFUL NAVIGATION & ATMOSPHERE BAR -->
  <header class="sticky top-0 z-40 border-b border-[#e6decb]/90 bg-[#fbf9f5]/85 backdrop-blur-md no-print">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-2.5 flex flex-wrap items-center justify-between gap-3">
      
      <!-- Brand Identity -->
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-sage-600 via-sage-500 to-autumn-500 flex items-center justify-center text-white font-serif text-xl font-bold shadow-sm">
          G
        </div>
        <div>
          <div class="flex items-center gap-2">
            <span class="font-serif font-bold text-lg sm:text-xl tracking-tight text-slatewarm-900">Giulio's English Sanctuary</span>
            <span class="hidden sm:inline-flex items-center gap-1 px-2.5 py-0.5 text-[11px] font-medium rounded-full bg-sage-100 text-sage-800 border border-sage-200">
              <i data-lucide="sparkles" class="w-3 h-3 text-autumn-600"></i>
              Preply Student Edition
            </span>
          </div>
          <p class="text-[11px] text-stone-500 hidden md:block">Full cleaned transcript, 60 flagged vocabulary terms, speech-to-text corrections &amp; British audio</p>
        </div>
      </div>

      <!-- Calming Atmosphere Controls -->
      <div class="flex flex-wrap items-center gap-2">
        
        <!-- London Breeze Audio Player -->
        <div class="flex items-center gap-1.5 bg-white/90 border border-[#dfd0b5] rounded-xl px-2.5 py-1 shadow-sm">
          <button id="soundscape-btn" onclick="toggleSoundscape()" class="flex items-center gap-1.5 text-xs font-semibold text-sage-700 hover:text-sage-900 transition px-1.5 py-0.5 rounded-lg" title="Play soothing London autumn breeze soundscape">
            <i data-lucide="wind" id="soundscape-icon" class="w-3.5 h-3.5 text-autumn-600"></i>
            <span id="soundscape-label">London Breeze: Off</span>
          </button>
          <select id="soundscape-preset" onchange="changeSoundscapePreset(this.value)" class="text-[11px] bg-parchment-50 border border-parchment-200 rounded-lg px-1.5 py-0.5 text-stone-700 focus:outline-none">
            <option value="breeze">🍂 Kensington Breeze</option>
            <option value="rain">🌧️ Soft London Rain</option>
            <option value="study">🕯️ Warm Study Hearth</option>
          </select>
          <input id="soundscape-volume" type="range" min="0.05" max="0.6" step="0.05" value="0.22" oninput="updateSoundscapeVolume(this.value)" class="w-14 accent-sage-600 cursor-pointer hidden sm:block" />
        </div>

        <!-- Falling Leaves Toggle -->
        <button id="leaves-toggle-btn" onclick="cycleLeafBreeze()" class="px-2.5 py-1.5 rounded-xl bg-white/90 hover:bg-autumn-50 border border-[#dfd0b5] text-xs font-medium text-stone-700 flex items-center gap-1.5 shadow-sm transition">
          <i data-lucide="leaf" class="w-3.5 h-3.5 text-autumn-600"></i>
          <span id="leaves-label" class="hidden sm:inline">Leaves: Gentle</span>
        </button>

        <!-- UK Voice Speed -->
        <div class="flex items-center gap-1 bg-white/90 border border-[#dfd0b5] rounded-xl px-2 py-1 shadow-sm text-xs">
          <i data-lucide="volume-2" class="w-3.5 h-3.5 text-sage-600"></i>
          <button onclick="setVoiceRate(0.85)" id="rate-slow" class="px-1.5 py-0.5 rounded-md text-[11px] text-stone-600 hover:bg-parchment-100 transition">0.85×</button>
          <button onclick="setVoiceRate(1.0)" id="rate-normal" class="px-1.5 py-0.5 rounded-md text-[11px] bg-sage-600 text-white font-semibold transition">UK 1×</button>
        </div>

        <!-- Theme Mood Selector -->
        <div class="hidden lg:flex items-center gap-1 bg-white/90 border border-[#dfd0b5] rounded-xl p-1 text-[11px] shadow-sm">
          <button onclick="setThemeMood('kensington')" id="theme-kensington" class="px-2 py-0.5 rounded-lg bg-autumn-100 text-autumn-800 font-semibold transition">Bath Stone</button>
          <button onclick="setThemeMood('winchester')" id="theme-winchester" class="px-2 py-0.5 rounded-lg text-stone-600 hover:text-stone-900 transition">Winchester Mist</button>
          <button onclick="setThemeMood('twilight')" id="theme-twilight" class="px-2 py-0.5 rounded-lg text-stone-600 hover:text-stone-900 transition">Warm Study</button>
        </div>
      </div>

    </div>
  </header>

  <!-- MAIN WRAPPER -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-7 space-y-7 relative z-10">

    <!-- HERO / LESSON OVERVIEW -->
    <section class="sanctuary-card rounded-3xl p-6 sm:p-9 relative overflow-hidden" id="how-it-works">
      <div class="absolute -right-12 -top-12 w-64 h-64 bg-autumn-200/30 rounded-full blur-3xl pointer-events-none"></div>
      <div class="absolute -left-12 -bottom-12 w-64 h-64 bg-sage-200/35 rounded-full blur-3xl pointer-events-none"></div>

      <div class="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-7 items-center">
        <div class="lg:col-span-8 space-y-3.5">
          <div class="inline-flex flex-wrap items-center gap-2 px-3 py-1 rounded-full bg-sage-100/90 border border-sage-200 text-sage-800 text-xs font-medium">
            <i data-lucide="compass" class="w-3.5 h-3.5 text-autumn-600"></i>
            <span>Lesson 01 • 03 November 2026 • 53-Minute Spoken Session</span>
          </div>

          <h1 class="font-serif text-3xl sm:text-4xl lg:text-[2.65rem] font-bold text-slatewarm-900 leading-[1.16]">
            From Pharmaceutical <span class="text-autumn-700 italic font-semibold">Crunch Time</span> to Venetian Bàcari &amp; Alpine Treks
          </h1>

          <p class="text-stone-600 text-sm sm:text-base leading-relaxed max-w-3xl">
            In today's lesson, Giulio and Louie navigated a rich variety of conversational and technical frontiers: handling high-stakes <strong>crunch time</strong> shifts in pharmaceutical machinery, ranking food tiers from artisan burgers to exploding tacos, hiking through alpine waterfalls, the charming social ritual of Venetian <em>bàcaro</em> wine tours, a heartfelt discussion on missing cats and neighborhood ethics, and mastering high-level business idioms—from <strong>"tabling the discussion"</strong> to <strong>"herding cats"</strong>.
          </p>

          <!-- 4 Pillars for the Student -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5 pt-2 text-xs">
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">Zero Note-Taking Friction:</strong> Every turn is captured and arranged into 6 chronological chapters with per-turn audio.
              </div>
            </div>
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">60 Flagged Lexicon Terms:</strong> Hover or click any word for IPA, CEFR level, Italian translations, and British audio.
              </div>
            </div>
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">Natural Strengths Celebrated:</strong> Honoring 6 idiomatic expressions Giulio used well, alongside 6 gentle phrase polishes.
              </div>
            </div>
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">Note-Taker Errors Fixed:</strong> Funny automated mishearings (<em>We have the odds</em>, <em>stupid tiles</em>, <em>pub crew</em>) cleanly corrected.
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Experience Stats -->
        <div class="lg:col-span-4 grid grid-cols-2 gap-3">
          <div onclick="switchTab('transcript')" class="cursor-pointer p-4 rounded-2xl bg-parchment-50/95 border border-parchment-300 hover:border-autumn-400 transition shadow-sm group">
            <div class="text-[11px] font-mono font-semibold uppercase text-autumn-700 flex items-center justify-between">
              <span>Section 1</span>
              <i data-lucide="scroll-text" class="w-4 h-4 group-hover:scale-110 transition"></i>
            </div>
            <div class="font-serif font-bold text-slatewarm-900 text-lg mt-0.5">Full Transcript</div>
            <p class="text-[11px] text-stone-600 mt-0.5">6 chapters • 00:00 to 52:56</p>
          </div>

          <div onclick="switchTab('vocab')" class="cursor-pointer p-4 rounded-2xl bg-sage-50/95 border border-sage-200 hover:border-sage-400 transition shadow-sm group">
            <div class="text-[11px] font-mono font-semibold uppercase text-sage-700 flex items-center justify-between">
              <span>Section 2</span>
              <i data-lucide="book-marked" class="w-4 h-4 group-hover:scale-110 transition"></i>
            </div>
            <div class="font-serif font-bold text-slatewarm-900 text-lg mt-0.5">Flagged Lexicon</div>
            <p class="text-[11px] text-stone-600 mt-0.5">60 B2–C2 terms with Italian translations</p>
          </div>

          <div onclick="switchTab('fixes')" class="cursor-pointer p-4 rounded-2xl bg-autumn-50/95 border border-autumn-200 hover:border-autumn-400 transition shadow-sm group">
            <div class="text-[11px] font-mono font-semibold uppercase text-autumn-700 flex items-center justify-between">
              <span>Section 3</span>
              <i data-lucide="wand-sparkles" class="w-4 h-4 group-hover:scale-110 transition"></i>
            </div>
            <div class="font-serif font-bold text-slatewarm-900 text-lg mt-0.5">Strengths &amp; Fixes</div>
            <p class="text-[11px] text-stone-600 mt-0.5">6 strengths + 20 note-taker corrections</p>
          </div>

          <div onclick="switchTab('practice')" class="cursor-pointer p-4 rounded-2xl bg-parchment-50/95 border border-parchment-300 hover:border-sage-400 transition shadow-sm group">
            <div class="text-[11px] font-mono font-semibold uppercase text-sage-700 flex items-center justify-between">
              <span>Section 4</span>
              <i data-lucide="coffee" class="w-4 h-4 group-hover:scale-110 transition"></i>
            </div>
            <div class="font-serif font-bold text-slatewarm-900 text-lg mt-0.5">Peaceful Practice</div>
            <p class="text-[11px] text-stone-600 mt-0.5">Flashcards &amp; 6-question context quiz</p>
          </div>
        </div>
      </div>
    </section>

    <!-- 5-TAB NAVIGATION BAR -->
    <nav class="sanctuary-card rounded-2xl p-2 flex flex-wrap items-center justify-between gap-2 no-print">
      <div class="flex flex-wrap items-center gap-1.5 w-full sm:w-auto">
        <button onclick="switchTab('transcript')" id="tab-btn-transcript" class="tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 bg-sage-700 text-white shadow-sm">
          <i data-lucide="message-square-quote" class="w-4 h-4"></i>
          <span>1. Cleaned Transcript</span>
          <span class="px-2 py-0.5 text-[10px] rounded-full bg-white/20 text-white font-mono">6 Chapters</span>
        </button>

        <button onclick="switchTab('vocab')" id="tab-btn-vocab" class="tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 text-stone-700 hover:bg-parchment-100">
          <i data-lucide="book-marked" class="w-4 h-4 text-autumn-600"></i>
          <span>2. Vocabulary Dictionary</span>
          <span class="px-2 py-0.5 text-[10px] rounded-full bg-autumn-100 text-autumn-800 font-mono">60 Words</span>
        </button>

        <button onclick="switchTab('fixes')" id="tab-btn-fixes" class="tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 text-stone-700 hover:bg-parchment-100">
          <i data-lucide="sparkles" class="w-4 h-4 text-sage-600"></i>
          <span>3. Note-Taker Fixes &amp; Gentle Notes</span>
        </button>

        <button onclick="switchTab('places')" id="tab-btn-places" class="tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 text-stone-700 hover:bg-parchment-100">
          <i data-lucide="landmark" class="w-4 h-4 text-autumn-600"></i>
          <span>4. Cultural Topics &amp; Dialogue</span>
        </button>

        <button onclick="switchTab('practice')" id="tab-btn-practice" class="tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 text-stone-700 hover:bg-parchment-100">
          <i data-lucide="coffee" class="w-4 h-4 text-sage-600"></i>
          <span>5. Peaceful Practice Sanctuary</span>
          <span class="px-2 py-0.5 text-[10px] rounded-full bg-sage-100 text-sage-800 font-mono">Quiz &amp; Flashcards</span>
        </button>
      </div>

      <div class="hidden sm:block">
        <button onclick="window.print()" class="px-3.5 py-2 rounded-xl bg-white hover:bg-parchment-100 border border-[#dfd0b5] text-stone-700 font-semibold text-xs flex items-center gap-1.5 shadow-sm transition">
          <i data-lucide="printer" class="w-3.5 h-3.5"></i>
          <span>Print / PDF</span>
        </button>
      </div>
    </nav>

    <!-- =================================================================== -->
    <!-- TAB 1: FULL CLEANED TRANSCRIPT WITH INLINE VOCAB & SPOTLIGHT        -->
    <!-- =================================================================== -->
    <section id="tab-panel-transcript" class="tab-panel space-y-6">
      
      <div class="sanctuary-card rounded-3xl p-5 sm:p-6 space-y-4">
        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-[#e6decb] pb-4">
          <div>
            <div class="flex items-center gap-2">
              <i data-lucide="scroll-text" class="w-5 h-5 text-autumn-600"></i>
              <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Complete Spoken Transcript</h2>
            </div>
            <p class="text-xs text-stone-500 mt-0.5">Chronologically arranged with exact timestamps, speaker differentiation, inline audio and spotlight inspector</p>
          </div>

          <!-- Controls: Search, Speaker Filter, Toggles -->
          <div class="flex flex-wrap items-center gap-2">
            
            <!-- Search bar -->
            <div class="relative min-w-[200px] flex-1 sm:flex-initial">
              <i data-lucide="search" class="w-3.5 h-3.5 text-stone-400 absolute left-3 top-1/2 -translate-y-1/2"></i>
              <input id="transcript-search" oninput="filterTranscript()" type="text" placeholder="Search transcript..." class="w-full pl-8 pr-3 py-1.5 rounded-xl bg-parchment-50 border border-parchment-200 text-xs text-slatewarm-900 focus:outline-none focus:border-autumn-500" />
            </div>

            <!-- Speaker filter -->
            <select id="speaker-filter" onchange="filterTranscript()" class="text-xs bg-parchment-50 border border-parchment-200 rounded-xl px-2.5 py-1.5 text-stone-700 focus:outline-none">
              <option value="all">All Speakers</option>
              <option value="Giulio">Giulio (Student)</option>
              <option value="Louie">Louie (Teacher)</option>
            </select>

            <!-- Chapter jump -->
            <select id="chapter-select" onchange="scrollToChapter(this.value)" class="text-xs bg-parchment-50 border border-parchment-200 rounded-xl px-2.5 py-1.5 text-stone-700 focus:outline-none">
              <option value="">Jump to Chapter...</option>
              <option value="chap-1">Chapter I: Early Shifts &amp; Crunch Time (00:00)</option>
              <option value="chap-2">Chapter II: The Food Tier List (02:31)</option>
              <option value="chap-3">Chapter III: Alpine Trails &amp; Venetian Bàcari (09:51)</option>
              <option value="chap-4">Chapter IV: Superpowers &amp; Missing Cat (19:41)</option>
              <option value="chap-5">Chapter V: Business Diplomacy (34:31)</option>
              <option value="chap-6">Chapter VI: Herding Cats &amp; The Paris Dash (43:51)</option>
            </select>

            <!-- Toggle Highlights -->
            <button id="btn-toggle-highlights" onclick="toggleVocabHighlights()" class="px-2.5 py-1.5 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 text-xs font-semibold flex items-center gap-1.5 transition">
              <i data-lucide="highlighter" class="w-3.5 h-3.5 text-autumn-600"></i>
              <span>Vocab Highlights: On</span>
            </button>

            <!-- Toggle ASR Fixes -->
            <button id="btn-toggle-asr" onclick="toggleAsrBadges()" class="px-2.5 py-1.5 rounded-xl bg-sage-100 hover:bg-sage-200 text-sage-800 text-xs font-semibold flex items-center gap-1.5 transition">
              <i data-lucide="sparkles" class="w-3.5 h-3.5 text-sage-600"></i>
              <span>Note-Taker Fixes: Visible</span>
            </button>
          </div>
        </div>

        <!-- 2-Column: Left = Transcript Turns, Right = Sticky Spotlight -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          
          <!-- Turns Container -->
          <div id="transcript-turns-container" class="lg:col-span-8 space-y-3.5">
            <!-- Populated via renderTranscript() -->
          </div>

          <!-- Sticky Right-Hand Vocabulary Spotlight Panel -->
          <div class="lg:col-span-4 sticky top-20 sanctuary-card rounded-2xl p-5 space-y-4 border-2 border-autumn-200/80 shadow-md">
            <div class="flex items-center justify-between border-b border-[#e6decb] pb-2.5">
              <span class="text-[11px] font-mono uppercase tracking-wider text-autumn-700 font-bold flex items-center gap-1">
                <i data-lucide="sparkle" class="w-3.5 h-3.5"></i> Vocabulary Spotlight
              </span>
              <span id="insp-time" class="text-xs font-mono px-2 py-0.5 rounded bg-sage-100 text-sage-800">🕒 01:08</span>
            </div>

            <div class="space-y-1.5">
              <div class="flex items-center justify-between gap-2">
                <h3 id="insp-word" class="font-serif text-2xl font-bold text-slatewarm-900">crunch time</h3>
                <span id="insp-level" class="px-2 py-0.5 rounded-md bg-autumn-100 text-autumn-800 font-mono text-xs font-bold">C1</span>
              </div>
              <div class="flex items-center gap-2 text-xs font-mono text-stone-500">
                <span id="insp-ipa">/krʌntʃ taɪm/</span>
                <span>•</span>
                <span id="insp-pos">noun</span>
              </div>
            </div>

            <div class="space-y-2 pt-1">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Meaning</span>
              <p id="insp-def" class="text-xs sm:text-sm text-stone-700 leading-relaxed bg-parchment-50 p-3 rounded-xl border border-parchment-200">
                A critical period of intense work and long hours immediately preceding an urgent project deadline.
              </p>
            </div>

            <div class="space-y-2">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Spoken in Lesson</span>
              <p id="insp-quote" class="text-xs italic text-sage-900 bg-sage-50/70 p-3 rounded-xl border border-sage-200 leading-relaxed">
                Louie (01:08): "So you had crunch time... where you have a deadline coming and everyone is working crazy hours to get it done."
              </p>
            </div>

            <div class="space-y-1.5 border-t border-parchment-200 pt-3">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Italian Equivalent</span>
              <p id="insp-es" class="text-sm font-serif font-bold text-autumn-800">fase di massimo impegno / periodo critico</p>
            </div>

            <div class="pt-2 flex items-center gap-2">
              <button id="insp-audio-btn" onclick="speakWord('crunch time')" class="flex-1 py-2 px-3 rounded-xl bg-sage-700 hover:bg-sage-800 text-white font-semibold text-xs flex items-center justify-center gap-2 shadow-sm transition">
                <i data-lucide="volume-2" class="w-4 h-4"></i>
                <span>Listen (UK Pronunciation)</span>
              </button>
            </div>
            
            <p class="text-[10px] text-stone-400 text-center italic">Click any highlighted word in the transcript to inspect it here</p>
          </div>

        </div>
      </div>

    </section>

    <!-- =================================================================== -->
    <!-- TAB 2: VOCABULARY DICTIONARY (60 Flagged Terms Grid)                -->
    <!-- =================================================================== -->
    <section id="tab-panel-vocab" class="tab-panel hidden space-y-6">
      
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-5">
        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-[#e6decb] pb-4">
          <div>
            <div class="flex items-center gap-2">
              <i data-lucide="book-marked" class="w-5 h-5 text-autumn-600"></i>
              <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Vocabulary Sanctuary Dictionary</h2>
            </div>
            <p class="text-xs text-stone-500 mt-0.5">Explore 60 curated B2–C2 words, idioms, and collocations with exact timestamps, Italian equivalents, and British audio</p>
          </div>

          <div class="flex flex-wrap items-center gap-2.5">
            <!-- Search -->
            <div class="relative min-w-[220px]">
              <i data-lucide="search" class="w-3.5 h-3.5 text-stone-400 absolute left-3 top-1/2 -translate-y-1/2"></i>
              <input id="vocab-search" oninput="renderVocabGrid()" type="text" placeholder="Search dictionary or Italian..." class="w-full pl-8 pr-3 py-1.5 rounded-xl bg-parchment-50 border border-parchment-200 text-xs text-slatewarm-900 focus:outline-none focus:border-autumn-500" />
            </div>

            <!-- Level filter -->
            <select id="vocab-level-filter" onchange="renderVocabGrid()" class="text-xs bg-parchment-50 border border-parchment-200 rounded-xl px-2.5 py-1.5 text-stone-700 focus:outline-none">
              <option value="all">All CEFR Levels</option>
              <option value="B2">B2 Upper Intermediate</option>
              <option value="C1">C1 Advanced</option>
              <option value="C2">C2 Mastery / Idiomatic</option>
            </select>
          </div>
        </div>

        <!-- Category Pill Filters -->
        <div class="flex flex-wrap items-center gap-1.5 text-xs pt-1">
          <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400 mr-1">Categories:</span>
          <button onclick="setVocabCategory('all')" id="cat-btn-all" class="cat-pill px-3 py-1 rounded-xl bg-sage-700 text-white font-semibold transition">All (60)</button>
          <button onclick="setVocabCategory('culture')" id="cat-btn-culture" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Workplace &amp; Culture (24)</button>
          <button onclick="setVocabCategory('language')" id="cat-btn-language" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Idioms &amp; Speech (14)</button>
          <button onclick="setVocabCategory('culinary')" id="cat-btn-culinary" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Food &amp; Dining (8)</button>
          <button onclick="setVocabCategory('philosophy')" id="cat-btn-philosophy" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Philosophy &amp; Powers (8)</button>
          <button onclick="setVocabCategory('emotion')" id="cat-btn-emotion" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Emotions &amp; Focus (6)</button>
        </div>

        <!-- Dictionary Cards Grid -->
        <div id="vocab-cards-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-2">
          <!-- Populated via renderVocabGrid() -->
        </div>
      </div>

    </section>

    <!-- =================================================================== -->
    <!-- TAB 3: NOTE-TAKER FIXES & GENTLE PHRASING                           -->
    <!-- =================================================================== -->
    <section id="tab-panel-fixes" class="tab-panel hidden space-y-6">
      
      <!-- Section A: 6 Natural Strengths -->
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4 border-l-4 border-l-autumn-500">
        <div class="flex items-center gap-2">
          <i data-lucide="sparkles" class="w-5 h-5 text-autumn-600"></i>
          <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Your Spoken Strengths Celebrated</h2>
        </div>
        <p class="text-xs text-stone-600">
          Before reviewing grammar or notes, we celebrate these 6 moments where Giulio expressed technical engineering deadlines, cultural traditions, and animal ethics with natural English flair!
        </p>

        <div id="natural-strengths-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-2">
          <!-- Populated via renderStrengths() -->
        </div>
      </div>

      <!-- Section B: 6 Gentle Phrasing Polishes -->
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4 border-l-4 border-l-sage-600">
        <div class="flex items-center gap-2">
          <i data-lucide="wand-sparkles" class="w-5 h-5 text-sage-600"></i>
          <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Gentle Phrasing Polishes</h2>
        </div>
        <p class="text-xs text-stone-600">
          Encouraging, supportive upgrades for phrases used during the lesson. No harsh error marks—simply natural phrasing to build smooth conversational rhythm.
        </p>

        <div id="gentle-polishes-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-2">
          <!-- Populated via renderPhrasing() -->
        </div>
      </div>

      <!-- Section C: Note-Taker Fixes Log -->
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4">
        <div class="flex items-center justify-between border-b border-[#e6decb] pb-3">
          <div class="flex items-center gap-2">
            <i data-lucide="file-check-2" class="w-5 h-5 text-autumn-600"></i>
            <div>
              <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Speech-to-Text Corrections Log</h2>
              <p class="text-xs text-stone-500 mt-0.5">Automated transcription tools mishear proper nouns, place names, and homophones. Here is the forensic record of all 20 sorted fixes!</p>
            </div>
          </div>
          <span class="px-3 py-1 rounded-full bg-sage-100 text-sage-800 font-mono text-xs font-semibold">20 Cleaned Fixes</span>
        </div>

        <div class="overflow-x-auto pt-2">
          <table class="w-full text-left text-xs border-collapse">
            <thead>
              <tr class="border-b border-parchment-200 text-stone-500 font-mono text-[11px] uppercase">
                <th class="py-2.5 px-3">Timestamp</th>
                <th class="py-2.5 px-3">What Was Actually Spoken</th>
                <th class="py-2.5 px-3">Note-Taker Mishearing</th>
                <th class="py-2.5 px-3">Lesson Context</th>
              </tr>
            </thead>
            <tbody id="asr-fixes-tbody" class="divide-y divide-parchment-200/80">
              <!-- Populated via renderAsrFixes() -->
            </tbody>
          </table>
        </div>
      </div>

    </section>

    <!-- =================================================================== -->
    <!-- TAB 4: CULTURAL TOPICS & DIALOGUE SANCTUARY                         -->
    <!-- =================================================================== -->
    <section id="tab-panel-places" class="tab-panel hidden space-y-6">
      
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4">
        <div class="flex items-center gap-2 border-b border-[#e6decb] pb-3">
          <i data-lucide="landmark" class="w-5 h-5 text-autumn-600"></i>
          <div>
            <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Cultural Landscapes &amp; Engineering Realities</h2>
            <p class="text-xs text-stone-500 mt-0.5">Reflections on Venetian bàcari, alpine forest sanctuaries, pharmaceutical testing shifts, and British meeting idioms</p>
          </div>
        </div>

        <div id="editorial-cards-container" class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
          <!-- Populated via renderEditorialTopics() -->
        </div>
      </div>

    </section>

    <!-- =================================================================== -->
    <!-- TAB 5: PEACEFUL PRACTICE SANCTUARY (Flashcards, Quiz, Reflections)   -->
    <!-- =================================================================== -->
    <section id="tab-panel-practice" class="tab-panel hidden space-y-6">
      
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        <!-- Left: Interactive Flashcards -->
        <div class="lg:col-span-6 sanctuary-card rounded-3xl p-6 sm:p-8 space-y-5 flex flex-col justify-between">
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <span class="text-xs font-mono uppercase tracking-widest text-sage-700 font-semibold">Active Recall</span>
              <span id="fc-counter" class="text-xs font-mono text-stone-500">Card 1 of 8</span>
            </div>
            <h3 class="font-serif text-2xl font-bold text-slatewarm-900">Interactive Vocabulary Deck</h3>
            <p class="text-xs text-stone-600">Click the card to flip between definition, spoken lesson context, and Italian equivalent.</p>
          </div>

          <div onclick="flipFlashcard()" class="cursor-pointer sanctuary-subcard rounded-2xl p-7 min-h-[250px] flex flex-col items-center justify-center text-center space-y-3 border-2 border-[#dfd0b5] hover:border-autumn-400 transition select-none">
            <span id="fc-badge" class="px-2.5 py-0.5 rounded-full bg-autumn-100 text-autumn-800 text-[11px] font-mono">01:08 • C1 Culture</span>
            <h4 id="fc-front-title" class="font-serif text-3xl font-bold text-slatewarm-900">crunch time</h4>
            <p id="fc-sub" class="text-xs sm:text-sm text-stone-600 max-w-md leading-relaxed">
              Click anywhere on this card to reveal the definition and lesson context
            </p>
            <div id="fc-back-details" class="hidden space-y-2 pt-2 border-t border-parchment-200 w-full">
              <p id="fc-quote" class="text-xs italic text-sage-800"></p>
              <p id="fc-es" class="text-xs font-semibold text-autumn-700"></p>
            </div>
          </div>

          <div class="flex items-center justify-between gap-2 pt-2">
            <button onclick="prevFlashcard()" class="px-4 py-2 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-xs font-semibold text-stone-700 flex items-center gap-1.5 transition">
              <i data-lucide="arrow-left" class="w-4 h-4"></i> Previous
            </button>
            <button onclick="speakCurrentFlashcard()" class="px-4 py-2 rounded-xl bg-sage-100 hover:bg-sage-200 text-xs font-semibold text-sage-800 flex items-center gap-1.5 transition">
              <i data-lucide="volume-2" class="w-4 h-4"></i> Listen (UK)
            </button>
            <button onclick="nextFlashcard()" class="px-4 py-2 rounded-xl bg-sage-700 hover:bg-sage-800 text-xs font-semibold text-white flex items-center gap-1.5 transition">
              Next <i data-lucide="arrow-right" class="w-4 h-4"></i>
            </button>
          </div>
        </div>

        <!-- Right: 6-Question Context Quiz -->
        <div class="lg:col-span-6 sanctuary-card rounded-3xl p-6 sm:p-8 space-y-5">
          <div class="flex items-center justify-between border-b border-[#e6decb] pb-3">
            <div>
              <span class="text-xs font-mono uppercase tracking-widest text-autumn-700 font-semibold">Self-Assessment</span>
              <h3 class="font-serif text-2xl font-bold text-slatewarm-900 mt-0.5">Context &amp; Conversation Quiz</h3>
            </div>
            <span id="quiz-score-badge" class="px-3 py-1 rounded-full bg-sage-100 text-sage-800 text-xs font-mono font-bold">0 / 6 Completed</span>
          </div>

          <div id="quiz-container" class="space-y-4 max-h-[460px] overflow-y-auto pr-1">
            <!-- Populated via renderQuiz() -->
          </div>
        </div>

      </div>

      <!-- Reflection Prompts for Next Lesson -->
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4 border-2 border-sage-200/90">
        <div class="flex items-center gap-2">
          <i data-lucide="compass" class="w-5 h-5 text-sage-600"></i>
          <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Reflections for Lesson 02</h2>
        </div>
        <p class="text-xs text-stone-600">
          Three thoughtful prompts to reflect on before our next session—including navigating client meetings and planning your post-crunch alpine sanctuary escape!
        </p>

        <div id="reflections-grid" class="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2">
          <!-- Populated via renderReflections() -->
        </div>
      </div>

    </section>

  </main>

  <!-- FOOTER -->
  <footer class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-center text-xs text-stone-500 border-t border-[#e6decb]/80 mt-8 no-print">
    <p class="font-serif italic text-base text-slatewarm-800 mb-1">"Speak freely, reflect quietly, and let the language become second nature."</p>
    <p>Personalized English Study Sanctuary prepared by Louie for Giulio M. • Veneto &amp; London Breeze</p>
  </footer>

  <!-- JAVASCRIPT LOGIC -->
  <script>
'@

$scriptPart = @"
    // Central Data Structures
    const VOCAB_DB = $vocabDbJson;
    const NATURAL_STRENGTHS = $strengthsJson;
    const GENTLE_PHRASINGS = $phrasingsJson;
    const ASR_FIXES = $asrFixesJson;
    const EDITORIAL_TOPICS = $editorialTopicsJson;
    const FLASHCARD_KEYS = $flashcardKeysJson;
    const QUIZ_QUESTIONS = $quizQuestionsJson;
    const REFLECTION_PROMPTS = $reflectionPromptsJson;
    const TRANSCRIPT_TURNS = $turnsJson;

    // State Variables
    let currentCategory = 'all';
    let currentCardIndex = 0;
    let isCardFlipped = false;
    let quizAnswered = new Set();
    let currentQuizScore = 0;
    let highlightsOn = true;
    let asrBadgesOn = true;
    let speechRate = 1.0;

    // Helper functions
    function v(key, word) {
      const item = (typeof VOCAB_DB !== 'undefined' && VOCAB_DB[key]) ? VOCAB_DB[key] : null;
      const label = word || (item ? item.word : key);
      return '<span class="vocab-mark" data-vkey="' + key + '" onclick="inspectVocab(\'' + key + '\')">' + label + '</span>';
    }

    function fixBadge(corrected, rawMistake) {
      return '<span class="asr-fix-pill" title="Note-taker misheard \'' + corrected + '\' as \'' + rawMistake + '\'">✨ Fixed: "' + corrected + '" <span class="text-stone-400">(note-taker: "' + rawMistake + '")</span></span>';
    }

    // 1. RENDER TRANSCRIPT
    function renderTranscript() {
      const container = document.getElementById('transcript-turns-container');
      if (!container) return;

      const searchVal = (document.getElementById('transcript-search')?.value || '').toLowerCase().trim();
      const spkVal = document.getElementById('speaker-filter')?.value || 'all';

      let out = '';
      TRANSCRIPT_TURNS.forEach(turn => {
        // Speaker filter
        if (spkVal !== 'all' && turn.speaker !== spkVal) return;

        // Search filter
        if (searchVal) {
          const hay = (turn.raw + ' ' + turn.speaker + ' ' + turn.time).toLowerCase();
          if (!hay.includes(searchVal)) return;
        }

        // Chapter Header
        if (turn.chapterTitle) {
          out += '<div id="' + turn.chapterId + '" class="pt-6 pb-2 border-b border-[#e6decb]">';
          out += '  <div class="flex items-center gap-2">';
          out += '    <i data-lucide="bookmark" class="w-4 h-4 text-autumn-600"></i>';
          out += '    <h3 class="font-serif text-lg font-bold text-slatewarm-900">' + turn.chapterTitle + '</h3>';
          out += '  </div>';
          out += '</div>';
        }

        const isGiulio = turn.speaker === 'Giulio';
        const cardClass = isGiulio 
          ? 'sanctuary-subcard rounded-2xl p-4 sm:p-5 border-l-4 border-l-autumn-500 bg-[#fffdfa]' 
          : 'sanctuary-subcard rounded-2xl p-4 sm:p-5 border-l-4 border-l-sage-600 bg-[#f8faf8]';
        
        const badgeClass = isGiulio
          ? 'bg-autumn-100 text-autumn-800'
          : 'bg-sage-100 text-sage-800';

        out += '<div id="' + turn.id + '" class="' + cardClass + ' space-y-2 transition">';
        out += '  <div class="flex items-center justify-between gap-2">';
        out += '    <div class="flex items-center gap-2">';
        out += '      <span class="px-2.5 py-0.5 rounded-full font-serif font-bold text-xs ' + badgeClass + '">' + turn.speaker + '</span>';
        out += '      <span class="font-mono text-xs text-stone-500">🕒 ' + turn.time + '</span>';
        out += '    </div>';
        out += '    <button onclick="speakTurn(\'' + turn.id + '\')" class="p-1.5 rounded-lg bg-parchment-100 hover:bg-parchment-200 text-stone-600 hover:text-stone-900 transition" title="Listen to this turn">';
        out += '      <i data-lucide="volume-2" class="w-3.5 h-3.5"></i>';
        out += '    </button>';
        out += '  </div>';
        out += '  <p class="text-xs sm:text-sm text-slatewarm-900 leading-relaxed">' + turn.html + '</p>';
        out += '</div>';
      });

      container.innerHTML = out;
      if (typeof lucide !== 'undefined' && lucide.createIcons) lucide.createIcons();
      if (typeof tippy === 'function') initTippyTooltips();
    }

    function speakTurn(turnId) {
      const turn = TRANSCRIPT_TURNS.find(t => t.id === turnId);
      if (!turn) return;
      speakWord(turn.raw);
    }

    // 2. VOCABULARY SPOTLIGHT & DICTIONARY
    function inspectVocab(key) {
      const item = VOCAB_DB[key];
      if (!item) return;

      document.querySelectorAll('.vocab-mark').forEach(el => {
        el.classList.toggle('active-vocab', el.getAttribute('data-vkey') === key);
      });

      const elTime = document.getElementById('insp-time');
      const elWord = document.getElementById('insp-word');
      const elIpa = document.getElementById('insp-ipa');
      const elPos = document.getElementById('insp-pos');
      const elLevel = document.getElementById('insp-level');
      const elDef = document.getElementById('insp-def');
      const elQuote = document.getElementById('insp-quote');
      const elEs = document.getElementById('insp-es');
      const elAudio = document.getElementById('insp-audio-btn');

      if (elTime) elTime.textContent = '🕒 ' + item.time;
      if (elWord) elWord.textContent = item.word;
      if (elIpa) elIpa.textContent = item.ipa;
      if (elPos) elPos.textContent = item.pos;
      if (elLevel) elLevel.textContent = item.level;
      if (elDef) elDef.textContent = item.def;
      if (elQuote) elQuote.textContent = item.quote;
      if (elEs) elEs.textContent = item.es;
      if (elAudio) elAudio.setAttribute('onclick', "speakWord('" + item.word.replace(/'/g, "\\'") + "')");
    }

    function setVocabCategory(cat) {
      currentCategory = cat;
      document.querySelectorAll('.cat-pill').forEach(btn => {
        btn.className = 'cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition';
      });
      const activeBtn = document.getElementById('cat-btn-' + cat);
      if (activeBtn) {
        activeBtn.className = 'cat-pill px-3 py-1 rounded-xl bg-sage-700 text-white font-semibold transition';
      }
      renderVocabGrid();
    }

    function renderVocabGrid() {
      const grid = document.getElementById('vocab-cards-grid');
      if (!grid) return;

      const searchVal = (document.getElementById('vocab-search')?.value || '').toLowerCase().trim();
      const levelVal = document.getElementById('vocab-level-filter')?.value || 'all';

      const entries = Object.entries(VOCAB_DB).filter(([key, item]) => {
        if (currentCategory !== 'all' && item.cat !== currentCategory) return false;
        if (levelVal !== 'all' && item.level !== levelVal) return false;
        if (searchVal) {
          const hay = (item.word + ' ' + item.def + ' ' + item.es + ' ' + item.quote).toLowerCase();
          if (!hay.includes(searchVal)) return false;
        }
        return true;
      });

      grid.innerHTML = entries.map(([key, item]) => {
        return '<div class="sanctuary-subcard rounded-2xl p-5 flex flex-col justify-between space-y-3 hover:border-autumn-400 transition">' +
          '  <div class="space-y-2">' +
          '    <div class="flex items-center justify-between gap-2">' +
          '      <div class="flex items-center gap-1.5">' +
          '        <span class="px-2 py-0.5 rounded-md bg-autumn-100 text-autumn-800 font-mono text-[11px] font-bold">' + item.level + '</span>' +
          '        <span class="px-2 py-0.5 rounded-md bg-parchment-100 text-stone-600 text-[11px]">' + item.pos + '</span>' +
          '      </div>' +
          '      <button onclick="jumpToTranscriptTurn(\'' + item.turnId + '\', \'' + key + '\')" class="px-2.5 py-0.5 rounded-full bg-sage-100 hover:bg-sage-200 text-sage-800 font-mono text-[11px] font-semibold flex items-center gap-1 transition">' +
          '        <i data-lucide="clock" class="w-3 h-3"></i> ' + item.time + ' ↗' +
          '      </button>' +
          '    </div>' +
          '    <div class="flex items-center justify-between gap-2 pt-1">' +
          '      <div>' +
          '        <h3 class="font-serif text-xl font-bold text-slatewarm-900">' + item.word + '</h3>' +
          '        <span class="text-xs font-mono text-stone-500">' + item.ipa + '</span>' +
          '      </div>' +
          '      <button onclick="speakWord(\'' + item.word.replace(/'/g, "\\'") + '\')" class="p-2 rounded-xl bg-parchment-100 hover:bg-sage-100 text-sage-800 transition">' +
          '        <i data-lucide="volume-2" class="w-4 h-4"></i>' +
          '      </button>' +
          '    </div>' +
          '    <p class="text-xs sm:text-sm text-stone-700 leading-relaxed">' + item.def + '</p>' +
          '    <p class="text-xs italic text-stone-500 bg-parchment-50 p-2.5 rounded-xl border border-parchment-200">' + item.quote + '</p>' +
          '  </div>' +
          '  <div class="pt-2 border-t border-parchment-200 flex items-center justify-between text-xs">' +
          '    <span class="text-sage-800 font-medium font-serif font-bold">' + item.es + '</span>' +
          '    <button onclick="jumpToTranscriptTurn(\'' + item.turnId + '\', \'' + key + '\')" class="text-autumn-700 hover:underline font-semibold text-[11px]">' +
          '      See in Transcript →' +
          '    </button>' +
          '  </div>' +
          '</div>';
      }).join('');

      if (typeof lucide !== 'undefined' && lucide.createIcons) lucide.createIcons();
    }

    function jumpToTranscriptTurn(turnId, vocabKey) {
      switchTab('transcript');
      setTimeout(() => {
        if (vocabKey) inspectVocab(vocabKey);
        const el = document.getElementById(turnId);
        if (el) {
          el.scrollIntoView({ behavior: 'smooth', block: 'center' });
          el.classList.remove('turn-highlight-flash');
          void el.offsetWidth;
          el.classList.add('turn-highlight-flash');
        }
      }, 150);
    }

    // 3. TAB 3: STRENGTHS, PHRASING & ASR FIXES
    function renderStrengths() {
      const container = document.getElementById('natural-strengths-grid');
      if (!container) return;

      container.innerHTML = NATURAL_STRENGTHS.map(s => {
        return '<div class="sanctuary-subcard rounded-2xl p-5 space-y-3 border-t-2 border-t-autumn-400">' +
          '  <div class="flex items-center justify-between">' +
          '    <span class="text-xs font-semibold text-autumn-800">' + s.topic + '</span>' +
          '    <span class="px-2 py-0.5 rounded-full bg-parchment-100 font-mono text-[11px] text-stone-600">🕒 ' + s.time + '</span>' +
          '  </div>' +
          '  <div class="p-3 rounded-xl bg-autumn-50/70 border border-autumn-200 text-xs italic text-slatewarm-900 leading-relaxed font-serif text-sm">' +
          '    "' + s.phrase + '"' +
          '  </div>' +
          '  <p class="text-xs text-stone-600 leading-relaxed">' + s.note + '</p>' +
          '</div>';
      }).join('');
    }

    function renderPhrasing() {
      const container = document.getElementById('gentle-polishes-grid');
      if (!container) return;

      container.innerHTML = GENTLE_PHRASINGS.map(p => {
        return '<div class="sanctuary-subcard rounded-2xl p-5 space-y-2.5 border-l-4 border-l-sage-500">' +
          '  <div class="flex items-center justify-between">' +
          '    <span class="text-xs font-semibold text-sage-800">' + p.topic + '</span>' +
          '    <span class="px-2 py-0.5 rounded-full bg-parchment-100 font-mono text-[11px] text-stone-600">🕒 ' + p.time + '</span>' +
          '  </div>' +
          '  <div class="p-2.5 rounded-xl bg-autumn-50/70 border border-autumn-200/80 text-xs text-stone-600">' +
          '    <span class="font-semibold text-autumn-800">In the moment:</span> "' + p.said + '"' +
          '  </div>' +
          '  <div class="p-2.5 rounded-xl bg-sage-50 border border-sage-200 text-xs text-slatewarm-900 flex items-center justify-between gap-2">' +
          '    <div><span class="font-semibold text-sage-800">Natural Polish:</span> <strong>"' + p.natural + '"</strong></div>' +
          '    <button onclick="speakWord(\'' + p.natural.replace(/'/g, "\\'") + '\')" class="p-1.5 rounded-lg bg-white text-sage-700 hover:bg-sage-100 shrink-0 shadow-xs">' +
          '      <i data-lucide="volume-2" class="w-3.5 h-3.5"></i>' +
          '    </button>' +
          '  </div>' +
          '  <p class="text-[11px] text-stone-500 italic">' + p.note + '</p>' +
          '</div>';
      }).join('');
      if (typeof lucide !== 'undefined' && lucide.createIcons) lucide.createIcons();
    }

    function renderAsrFixes() {
      const tbody = document.getElementById('asr-fixes-tbody');
      if (!tbody) return;

      tbody.innerHTML = ASR_FIXES.map(f => {
        return '<tr class="hover:bg-parchment-50/60 transition">' +
          '  <td class="py-2.5 px-3 font-mono text-stone-500">🕒 ' + f.time + '</td>' +
          '  <td class="py-2.5 px-3 font-semibold text-sage-900">' + f.fixed + '</td>' +
          '  <td class="py-2.5 px-3 text-red-600 line-through">' + f.heard + '</td>' +
          '  <td class="py-2.5 px-3 text-stone-600">' + f.context + '</td>' +
          '</tr>';
      }).join('');
    }

    // 4. TAB 4: EDITORIAL TOPICS
    function renderEditorialTopics() {
      const container = document.getElementById('editorial-cards-container');
      if (!container) return;

      container.innerHTML = EDITORIAL_TOPICS.map(topic => {
        const pTags = topic.paragraphs.map(p => '<p class="text-xs sm:text-sm text-stone-700 leading-relaxed">' + p + '</p>').join('');
        return '<div class="sanctuary-subcard rounded-2xl p-6 space-y-4">' +
          '  <span class="text-[11px] font-mono uppercase tracking-wider text-autumn-700 font-bold">' + topic.tag + '</span>' +
          '  <h3 class="font-serif text-2xl font-bold text-slatewarm-900">' + topic.title + '</h3>' +
          '  <blockquote class="p-3 rounded-xl bg-parchment-100/90 border-l-4 border-l-autumn-500 font-serif italic text-sm text-stone-800">' +
          '    ' + topic.quote +
          '  </blockquote>' +
          '  <div class="space-y-3 pt-1">' + pTags + '</div>' +
          '</div>';
      }).join('');
    }

    // 5. TAB 5: FLASHCARDS
    function renderFlashcard() {
      const key = FLASHCARD_KEYS[currentCardIndex];
      const item = VOCAB_DB[key];
      if (!item) return;

      isCardFlipped = false;
      document.getElementById('fc-counter').textContent = 'Card ' + (currentCardIndex + 1) + ' of ' + FLASHCARD_KEYS.length;
      document.getElementById('fc-badge').textContent = item.time + ' • ' + item.level + ' ' + item.pos;
      document.getElementById('fc-front-title').textContent = item.word;
      document.getElementById('fc-sub').textContent = 'Click anywhere on this card to reveal the definition and lesson context';
      document.getElementById('fc-back-details').classList.add('hidden');
    }

    function flipFlashcard() {
      const key = FLASHCARD_KEYS[currentCardIndex];
      const item = VOCAB_DB[key];
      if (!item) return;

      isCardFlipped = !isCardFlipped;
      const sub = document.getElementById('fc-sub');
      const back = document.getElementById('fc-back-details');
      const quote = document.getElementById('fc-quote');
      const es = document.getElementById('fc-es');

      if (isCardFlipped) {
        sub.textContent = item.def;
        quote.textContent = item.quote;
        es.textContent = '🇮🇹 ' + item.es;
        back.classList.remove('hidden');
      } else {
        sub.textContent = 'Click anywhere on this card to reveal the definition and lesson context';
        back.classList.add('hidden');
      }
    }

    function prevFlashcard() {
      currentCardIndex = (currentCardIndex - 1 + FLASHCARD_KEYS.length) % FLASHCARD_KEYS.length;
      renderFlashcard();
    }

    function nextFlashcard() {
      currentCardIndex = (currentCardIndex + 1) % FLASHCARD_KEYS.length;
      renderFlashcard();
    }

    function speakCurrentFlashcard() {
      const item = VOCAB_DB[FLASHCARD_KEYS[currentCardIndex]];
      if (item) speakWord(item.word);
    }

    // 6. TAB 5: CONTEXT QUIZ (THE TEST)
    function renderQuiz() {
      const container = document.getElementById('quiz-container');
      if (!container) return;

      container.innerHTML = QUIZ_QUESTIONS.map((q, qIdx) => {
        const optionButtons = q.options.map((opt, oIdx) => {
          return '<button id="qbtn-' + qIdx + '-' + oIdx + '" onclick="answerQuiz(' + qIdx + ', ' + oIdx + ')" class="w-full text-left px-3.5 py-2.5 rounded-xl border border-[#dfd0b5] bg-parchment-50 hover:bg-autumn-100 text-xs font-medium text-stone-800 transition flex items-start gap-2.5">' +
            '  <span class="w-5 h-5 rounded-full bg-parchment-200 text-stone-700 flex items-center justify-center font-mono text-[10px] shrink-0 font-bold">' + String.fromCharCode(65 + oIdx) + '</span>' +
            '  <span>' + opt + '</span>' +
            '</button>';
        }).join('');

        return '<div class="sanctuary-subcard rounded-2xl p-4.5 space-y-3">' +
          '  <div class="flex items-center gap-2 text-xs font-mono text-sage-800 font-bold">' +
          '    <i data-lucide="help-circle" class="w-3.5 h-3.5 text-sage-600"></i>' +
          '    <span>Question ' + (qIdx + 1) + ' of ' + QUIZ_QUESTIONS.length + '</span>' +
          '  </div>' +
          '  <p class="text-xs sm:text-sm font-serif font-bold text-slatewarm-900">' + q.question + '</p>' +
          '  <div class="space-y-2 pt-1">' + optionButtons + '</div>' +
          '  <div id="qexp-' + qIdx + '" class="hidden p-3 rounded-xl text-xs mt-2 leading-relaxed"></div>' +
          '</div>';
      }).join('');

      if (typeof lucide !== 'undefined' && lucide.createIcons) lucide.createIcons();
    }

    function answerQuiz(qIdx, oIdx) {
      const q = QUIZ_QUESTIONS[qIdx];
      const expEl = document.getElementById('qexp-' + qIdx);
      if (!q || !expEl) return;

      q.options.forEach((_, idx) => {
        const btn = document.getElementById('qbtn-' + qIdx + '-' + idx);
        if (!btn) return;
        if (idx === q.correctIndex) {
          btn.className = 'w-full text-left px-3.5 py-2.5 rounded-xl border border-sage-500 bg-sage-600 text-white text-xs font-semibold flex items-start gap-2.5';
        } else if (idx === oIdx && oIdx !== q.correctIndex) {
          btn.className = 'w-full text-left px-3.5 py-2.5 rounded-xl border border-autumn-300 bg-autumn-100 text-autumn-900 text-xs font-medium flex items-start gap-2.5';
        } else {
          btn.className = 'w-full text-left px-3.5 py-2.5 rounded-xl border border-stone-200 bg-stone-50 text-stone-400 text-xs flex items-start gap-2.5';
        }
      });

      expEl.classList.remove('hidden');
      if (oIdx === q.correctIndex) {
        expEl.className = 'p-3 rounded-xl text-xs mt-2 leading-relaxed bg-sage-100 text-sage-900 border border-sage-300';
        expEl.innerHTML = '<strong>✅ Correct!</strong> ' + q.explanation;
        if (!quizAnswered.has(qIdx)) {
          quizAnswered.add(qIdx);
          currentQuizScore++;
        }
      } else {
        expEl.className = 'p-3 rounded-xl text-xs mt-2 leading-relaxed bg-autumn-50 text-autumn-900 border border-autumn-200';
        expEl.innerHTML = '<strong>💡 Solution:</strong> ' + q.explanation;
      }

      document.getElementById('quiz-score-badge').textContent = currentQuizScore + ' / ' + QUIZ_QUESTIONS.length + ' Correct';

      if (currentQuizScore === QUIZ_QUESTIONS.length && typeof confetti === 'function') {
        confetti({ particleCount: 65, spread: 65, origin: { y: 0.65 }, colors: ['#be6f38', '#5b826f', '#e2b086'] });
      }
    }

    // 7. TAB 5: REFLECTION PROMPTS
    function renderReflections() {
      const container = document.getElementById('reflections-grid');
      if (!container) return;

      container.innerHTML = REFLECTION_PROMPTS.map(r => {
        return '<div class="sanctuary-subcard rounded-2xl p-5 space-y-2">' +
          '  <span class="px-2 py-0.5 rounded-full bg-sage-100 text-sage-800 font-mono text-xs font-bold">' + r.num + '</span>' +
          '  <h4 class="font-serif font-bold text-base text-slatewarm-900 pt-1">' + r.title + '</h4>' +
          '  <p class="text-xs text-stone-600 leading-relaxed">' + r.text + '</p>' +
          '</div>';
      }).join('');
    }

    // 8. TAB NAVIGATION
    function switchTab(tabName) {
      ['transcript', 'vocab', 'fixes', 'places', 'practice'].forEach(t => {
        const panel = document.getElementById('tab-panel-' + t);
        const btn = document.getElementById('tab-btn-' + t);
        if (t === tabName) {
          if (panel) {
            panel.classList.remove('hidden');
            gsap.fromTo(panel, { opacity: 0, y: 8 }, { opacity: 1, y: 0, duration: 0.28, ease: 'power2.out' });
          }
          if (btn) btn.className = 'tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 bg-sage-700 text-white shadow-sm';
        } else {
          if (panel) panel.classList.add('hidden');
          if (btn) btn.className = 'tab-btn flex-1 sm:flex-initial px-4 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center justify-center gap-2 text-stone-700 hover:bg-parchment-100';
        }
      });
    }

    function filterTranscript() { renderTranscript(); }

    function scrollToChapter(chapId) {
      if (!chapId) return;
      document.getElementById('speaker-filter').value = 'all';
      document.getElementById('transcript-search').value = '';
      renderTranscript();
      const el = document.getElementById(chapId);
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function toggleVocabHighlights() {
      highlightsOn = !highlightsOn;
      document.body.classList.toggle('hide-vocab-highlights', !highlightsOn);
      document.getElementById('btn-toggle-highlights').querySelector('span').textContent = 'Vocab Highlights: ' + (highlightsOn ? 'On' : 'Off');
    }

    function toggleAsrBadges() {
      asrBadgesOn = !asrBadgesOn;
      document.body.classList.toggle('hide-asr-fixes', !asrBadgesOn);
      document.getElementById('btn-toggle-asr').querySelector('span').textContent = 'Note-Taker Fixes: ' + (asrBadgesOn ? 'Visible' : 'Hidden');
    }

    function setThemeMood(mood) {
      document.body.setAttribute('data-theme', mood);
      ['kensington', 'winchester', 'twilight'].forEach(m => {
        const el = document.getElementById('theme-' + m);
        if (el) {
          if (m === mood) {
            el.className = 'px-2 py-0.5 rounded-lg bg-autumn-100 text-autumn-800 font-semibold transition';
          } else {
            el.className = 'px-2 py-0.5 rounded-lg text-stone-600 hover:text-stone-900 transition';
          }
        }
      });
    }

    function setVoiceRate(rate) {
      speechRate = rate;
      const slow = document.getElementById('rate-slow');
      const normal = document.getElementById('rate-normal');
      if (rate === 0.85) {
        if (slow) slow.className = 'px-1.5 py-0.5 rounded-md text-[11px] bg-sage-600 text-white font-semibold transition';
        if (normal) normal.className = 'px-1.5 py-0.5 rounded-md text-[11px] text-stone-600 hover:bg-parchment-100 transition';
      } else {
        if (slow) slow.className = 'px-1.5 py-0.5 rounded-md text-[11px] text-stone-600 hover:bg-parchment-100 transition';
        if (normal) normal.className = 'px-1.5 py-0.5 rounded-md text-[11px] bg-sage-600 text-white font-semibold transition';
      }
    }

    function speakWord(text) {
      if (!('speechSynthesis' in window)) return;
      window.speechSynthesis.cancel();
      const utter = new SpeechSynthesisUtterance(text);
      utter.lang = 'en-GB';
      utter.rate = speechRate;
      window.speechSynthesis.speak(utter);
    }

    // 9. PROCEDURAL SOUNDSCAPE SYNTHESIZER
    let audioCtx = null, soundscapePlaying = false, masterGain = null, lfoTimer = null, currentFilter = null;
    function buildNoiseBuffer(ctx) {
      const bufferSize = ctx.sampleRate * 4;
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const output = buffer.getChannelData(0);
      let b0=0,b1=0,b2=0,b3=0,b4=0,b5=0,b6=0;
      for (let i = 0; i < bufferSize; i++) {
        const white = Math.random() * 2 - 1;
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        output[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.04;
        b6 = white * 0.115926;
      }
      return buffer;
    }

    function toggleSoundscape() {
      const label = document.getElementById('soundscape-label');
      if (!soundscapePlaying) {
        if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        if (audioCtx.state === 'suspended') audioCtx.resume();

        const noiseNode = audioCtx.createBufferSource();
        noiseNode.buffer = buildNoiseBuffer(audioCtx);
        noiseNode.loop = true;

        currentFilter = audioCtx.createBiquadFilter();
        const preset = document.getElementById('soundscape-preset')?.value || 'breeze';
        if (preset === 'breeze') {
          currentFilter.type = 'lowpass';
          currentFilter.frequency.value = 420;
          currentFilter.Q.value = 1.8;
        } else if (preset === 'rain') {
          currentFilter.type = 'bandpass';
          currentFilter.frequency.value = 1100;
          currentFilter.Q.value = 0.8;
        } else {
          currentFilter.type = 'lowpass';
          currentFilter.frequency.value = 260;
          currentFilter.Q.value = 2.4;
        }

        masterGain = audioCtx.createGain();
        const vol = parseFloat(document.getElementById('soundscape-volume')?.value || '0.22');
        masterGain.gain.setValueAtTime(0.001, audioCtx.currentTime);
        masterGain.gain.exponentialRampToValueAtTime(vol, audioCtx.currentTime + 1.2);

        noiseNode.connect(currentFilter);
        currentFilter.connect(masterGain);
        masterGain.connect(audioCtx.destination);
        noiseNode.start();

        lfoTimer = setInterval(() => {
          if (!currentFilter || !audioCtx) return;
          const t = audioCtx.currentTime;
          const base = (preset === 'rain') ? 1100 : (preset === 'study' ? 260 : 420);
          const depth = (preset === 'rain') ? 180 : 120;
          const sweep = base + Math.sin(t * 0.35) * depth;
          currentFilter.frequency.setTargetAtTime(sweep, t, 0.4);
        }, 300);

        soundscapePlaying = true;
        if (label) label.textContent = 'Breeze: Playing';
      } else {
        if (masterGain && audioCtx) {
          masterGain.gain.setValueAtTime(masterGain.gain.value, audioCtx.currentTime);
          masterGain.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + 0.5);
          setTimeout(() => {
            if (audioCtx && audioCtx.state !== 'closed') audioCtx.suspend();
          }, 550);
        }
        clearInterval(lfoTimer);
        soundscapePlaying = false;
        if (label) label.textContent = 'London Breeze: Off';
      }
    }

    function changeSoundscapePreset(preset) {
      if (!currentFilter || !audioCtx) return;
      const t = audioCtx.currentTime;
      if (preset === 'breeze') {
        currentFilter.type = 'lowpass';
        currentFilter.frequency.setTargetAtTime(420, t, 0.5);
        currentFilter.Q.value = 1.8;
      } else if (preset === 'rain') {
        currentFilter.type = 'bandpass';
        currentFilter.frequency.setTargetAtTime(1100, t, 0.5);
        currentFilter.Q.value = 0.8;
      } else {
        currentFilter.type = 'lowpass';
        currentFilter.frequency.setTargetAtTime(260, t, 0.5);
        currentFilter.Q.value = 2.4;
      }
    }

    function updateSoundscapeVolume(val) {
      if (masterGain && audioCtx && soundscapePlaying) {
        masterGain.gain.setTargetAtTime(parseFloat(val), audioCtx.currentTime, 0.1);
      }
    }

    // 10. CALMING FALLING LEAVES CANVAS
    let canvas, ctx, leaves = [], leavesAnimId = null;
    let leafMode = 'gentle';

    function initLeaves() {
      canvas = document.getElementById('autumn-breeze-canvas');
      if (!canvas) return;
      ctx = canvas.getContext('2d');
      resizeCanvas();
      window.addEventListener('resize', resizeCanvas);
      rebuildLeaves();
      animateLeaves();
    }

    function resizeCanvas() {
      if (!canvas) return;
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }

    function rebuildLeaves() {
      leaves = [];
      if (leafMode === 'still') return;
      const count = leafMode === 'breeze' ? 32 : 18;
      const colors = ['#be6f38', '#d38c57', '#e2b086', '#a5bfb1', '#7b9f8d'];
      for (let i = 0; i < count; i++) {
        leaves.push({
          x: Math.random() * canvas.width,
          y: Math.random() * canvas.height,
          size: Math.random() * 8 + 6,
          speedY: Math.random() * 0.7 + 0.35,
          speedX: Math.random() * 0.8 + 0.2,
          rot: Math.random() * 360,
          rotSpeed: (Math.random() - 0.5) * 1.5,
          color: colors[Math.floor(Math.random() * colors.length)],
          swaySpeed: Math.random() * 0.02 + 0.01,
          swayOffset: Math.random() * Math.PI * 2
        });
      }
    }

    function animateLeaves() {
      if (!ctx || !canvas) return;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      if (leafMode !== 'still') {
        leaves.forEach(leaf => {
          leaf.y += leaf.speedY;
          leaf.x += leaf.speedX + Math.sin(Date.now() * leaf.swaySpeed + leaf.swayOffset) * 0.4;
          leaf.rot += leaf.rotSpeed;

          if (leaf.y > canvas.height + 20) {
            leaf.y = -20;
            leaf.x = Math.random() * canvas.width;
          }
          if (leaf.x > canvas.width + 20) {
            leaf.x = -20;
          }

          ctx.save();
          ctx.translate(leaf.x, leaf.y);
          ctx.rotate(leaf.rot * Math.PI / 180);
          ctx.fillStyle = leaf.color;
          ctx.globalAlpha = 0.55;
          ctx.beginPath();
          ctx.ellipse(0, 0, leaf.size, leaf.size * 0.55, 0, 0, Math.PI * 2);
          ctx.fill();
          ctx.restore();
        });
      }
      leavesAnimId = requestAnimationFrame(animateLeaves);
    }

    function cycleLeafBreeze() {
      const label = document.getElementById('leaves-label');
      if (leafMode === 'gentle') {
        leafMode = 'breeze';
        if (label) label.textContent = 'Leaves: Breeze';
      } else if (leafMode === 'breeze') {
        leafMode = 'still';
        if (label) label.textContent = 'Leaves: Still';
      } else {
        leafMode = 'gentle';
        if (label) label.textContent = 'Leaves: Gentle';
      }
      rebuildLeaves();
    }

    // 11. TIPPY TOOLTIPS
    function initTippyTooltips() {
      if (typeof tippy !== 'function') return;
      tippy('.vocab-mark', {
        theme: 'autumn-sanctuary',
        animation: 'shift-away',
        allowHTML: true,
        interactive: true,
        appendTo: () => document.body,
        content(reference) {
          const key = reference.getAttribute('data-vkey');
          const item = VOCAB_DB[key];
          if (!item) return '<span>' + reference.textContent + '</span>';
          return '<div class="p-2.5 space-y-2 text-left max-w-xs">' +
            '  <div class="flex items-center justify-between gap-2 border-b border-parchment-200 pb-1.5">' +
            '    <div>' +
            '      <span class="font-serif font-bold text-base text-slatewarm-900">' + item.word + '</span>' +
            '      <span class="block font-mono text-[10px] text-stone-500">' + item.ipa + ' • ' + item.pos + '</span>' +
            '    </div>' +
            '    <div class="flex items-center gap-1">' +
            '      <span class="px-1.5 py-0.5 rounded bg-autumn-100 text-autumn-800 font-mono text-[10px] font-bold">' + item.level + '</span>' +
            '      <span class="px-1.5 py-0.5 rounded bg-sage-100 text-sage-800 font-mono text-[10px]">🕒 ' + item.time + '</span>' +
            '    </div>' +
            '  </div>' +
            '  <p class="text-xs text-stone-700 leading-snug">' + item.def + '</p>' +
            '  <div class="flex items-center justify-between pt-1 text-[11px] border-t border-parchment-200">' +
            '    <span class="text-sage-800 font-semibold">' + item.es + '</span>' +
            '    <button onclick="speakWord(\'' + item.word.replace(/'/g, "\\'") + '\')" class="px-2 py-0.5 rounded bg-sage-700 text-white text-[10px] font-semibold">🔊 Listen UK</button>' +
            '  </div>' +
            '</div>';
        }
      });
    }

    // 12. INITIALIZATION WRAPPER
    window.addEventListener('DOMContentLoaded', () => {
      [
        ['Transcript', renderTranscript],
        ['VocabGrid', renderVocabGrid],
        ['Strengths', renderStrengths],
        ['Phrasing', renderPhrasing],
        ['AsrFixes', renderAsrFixes],
        ['EditorialTopics', renderEditorialTopics],
        ['Flashcard', renderFlashcard],
        ['Quiz', renderQuiz],
        ['Reflections', renderReflections],
        ['Leaves', initLeaves],
        ['InspectorDefault', () => inspectVocab('crunch-time')]
      ].forEach(([name, fn]) => {
        try {
          fn();
        } catch (err) {
          console.error('Error initializing ' + name + ':', err);
        }
      });
      if (typeof lucide !== 'undefined' && lucide.createIcons) {
        try { lucide.createIcons(); } catch (e) { console.error('Lucide error:', e); }
      }
    });
  </script>
</body>
</html>
"@

$finalHtml = $headPart + "`n" + $scriptPart

# Write out index.html in clean UTF-8 without BOM
$outputPath = "D:\Documents\Giulio M\index.html"
[System.IO.File]::WriteAllText($outputPath, $finalHtml, [System.Text.UTF8Encoding]::new($false))

Write-Host "=========================================================="
Write-Host "Successfully generated index.html at $outputPath"
Write-Host "File size: $((Get-Item $outputPath).Length) bytes"
Write-Host "=========================================================="
