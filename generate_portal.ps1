# generate_portal.ps1 - Complete generator for Giulio M's Peaceful Interactive Sanctuary
$ErrorActionPreference = "Stop"

Write-Host "=========================================================="
Write-Host "Building Giulio M's Lesson 01 Interactive Portal"
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

# 2. Define VOCAB_DB (60 rich B2-C2 items)
$vocabDb = [ordered]@{
    "fluency" = @{
        word = "fluency"
        ipa = "/ˈfluː.ən.si/"
        pos = "noun"
        level = "B2"
        time = "14:24"
        turnId = "turn-14"
        cat = "language"
        def = "The ability to speak or write a language smoothly, easily, and without awkward hesitation."
        quote = "Giulio (14:24): '...we are here today because I would like to improve my fluency while speaking and my grammar...'"
        es = "fluidez verbal"
    }
    "coherence" = @{
        word = "coherence"
        ipa = "/kəʊˈhɪə.rəns/"
        pos = "noun"
        level = "C1"
        time = "14:24"
        turnId = "turn-14"
        cat = "language"
        def = "The quality of logical connection, consistency, and clear relationship between thoughts in speech."
        quote = "Giulio (14:24): '...I feel that when I speak, I have sometimes this lack of coherence when making my phrases.'"
        es = "coherencia / hilación lógica"
    }
    "mental-translation" = @{
        word = "mental translation"
        ipa = "/ˈmen.təl trænzˈleɪ.ʃən/"
        pos = "noun"
        level = "C1"
        time = "14:24"
        turnId = "turn-14"
        cat = "language"
        def = "The cognitive habit of translating ideas from one's native language into English before speaking."
        quote = "Giulio (14:24): 'I think I have this problem that I try to translate first in my head sometimes. So I need to think what I want to say and then translate to English.'"
        es = "traducción mental"
    }
    "annotate" = @{
        word = "annotate"
        ipa = "/ˈæn.ə.teɪt/"
        pos = "verb"
        level = "C1"
        time = "16:00"
        turnId = "turn-22"
        cat = "language"
        def = "To supply critical notes, explanatory tags, and vocabulary definitions directly alongside a text."
        quote = "Louie (16:00): '...as we are talking now, it is annotating, it is writing down the notes...'"
        es = "anotar / glosar"
    }
    "serendipity" = @{
        word = "serendipity"
        ipa = "/ˌser.ənˈdɪp.ə.ti/"
        pos = "noun"
        level = "C2"
        time = "16:33"
        turnId = "turn-28"
        cat = "philosophy"
        def = "The fortunate occurrence of discovering wonderful or valuable things purely by happy accident."
        quote = "Louie (16:33): 'So for example, serendipity, luck, right? This is another word for luck. You can see when it was said...'"
        es = "serendipia / casualidad afortunada"
    }
    "competency" = @{
        word = "competency"
        ipa = "/ˈkɒm.pɪ.tən.si/"
        pos = "noun"
        level = "B2"
        time = "16:33"
        turnId = "turn-28"
        cat = "language"
        def = "The proven ability, skill, and linguistic knowledge needed to execute communicative tasks effectively."
        quote = "Louie (16:33): '...you know, on the IELTS grading competency, and you can see what level the word is.'"
        es = "competencia lingüística"
    }
    "contingency" = @{
        word = "contingency"
        ipa = "/kənˈtɪn.dʒən.si/"
        pos = "noun"
        level = "C1"
        time = "21:01"
        turnId = "turn-54"
        cat = "culture"
        def = "A planned provision or backup procedure designed to manage unforeseen technical obstacles."
        quote = "Louie (21:01): 'I have planned for that contingency, so let me just quickly sign in...'"
        es = "plan de contingencia / respaldo"
    }
    "firewall" = @{
        word = "firewall"
        ipa = "/ˈfaɪə.wɔːl/"
        pos = "noun"
        level = "B2"
        time = "21:04"
        turnId = "turn-57"
        cat = "culture"
        def = "A digital security boundary filtering network traffic to safeguard enterprise IT infrastructure."
        quote = "Louie (21:04): '...there are many businesses that have firewall protection and stuff like that.'"
        es = "cortafuegos de seguridad"
    }
    "abstract-talking" = @{
        word = "abstract talking"
        ipa = "/ˈæb.strækt ˈtɔː.kɪŋ/"
        pos = "noun"
        level = "C1"
        time = "22:58"
        turnId = "turn-62"
        cat = "language"
        def = "Discourse centering on intangible ideas, moral concepts, and theories rather than physical objects."
        quote = "Louie (22:58): 'It requires abstract talking, following instructions, and working together as a team against the clock.'"
        es = "conversación abstracta"
    }
    "under-pressure" = @{
        word = "under pressure"
        ipa = "/ˈʌn.dər ˈpreʃ.ər/"
        pos = "idiom"
        level = "B2"
        time = "22:58"
        turnId = "turn-62"
        cat = "culture"
        def = "Performing a mental or communicative task in circumstances characterized by urgency and time constraints."
        quote = "Louie (22:58): '...you will notice that your English is great because you will have had stress on your side.'"
        es = "bajo presión"
    }
    "spherical" = @{
        word = "spherical"
        ipa = "/ˈsfer.ɪ.kəl/"
        pos = "adjective"
        level = "B2"
        time = "25:40"
        turnId = "turn-86"
        cat = "culinary"
        def = "Possessing the three-dimensional geometric form of a globe or ball."
        quote = "Giulio (25:40): 'It is beef that you shape it round and it is not a hamburger... it is spherical.'"
        es = "esférico / redondo"
    }
    "minced" = @{
        word = "minced"
        ipa = "/mɪnst/"
        pos = "adjective"
        level = "B2"
        time = "26:40"
        turnId = "turn-101"
        cat = "culinary"
        def = "Meat that has been finely ground or chopped into tiny uniform fragments by a mincer."
        quote = "Louie (26:40): 'So the word we use for how meatballs are made is they are minced.'"
        es = "picado (carne picada)"
    }
    "mangrove" = @{
        word = "mangrove"
        ipa = "/ˈmæŋ.ɡrəʊv/"
        pos = "noun"
        level = "B2"
        time = "27:44"
        turnId = "turn-106"
        cat = "culture"
        def = "A tropical coastal shrub or tree growing in brackish water with intertwined aerial root systems."
        quote = "Louie (27:44): 'It is from India, but it is in other tropical countries... it grows in mangroves.'"
        es = "manglar"
    }
    "pastrami" = @{
        word = "pastrami"
        ipa = "/pæˈstrɑː.mi/"
        pos = "noun"
        level = "B2"
        time = "28:27"
        turnId = "turn-114"
        cat = "culinary"
        def = "Highly seasoned cured beef brisket that is smoked and steamed, celebrated in classic New York delis."
        quote = "Louie (28:27): 'This is a New York sandwich, famous for having pastrami meat in it.'"
        es = "pastrami"
    }
    "cider" = @{
        word = "cider"
        ipa = "/ˈsaɪ.dər/"
        pos = "noun"
        level = "B2"
        time = "28:28"
        turnId = "turn-118"
        cat = "culinary"
        def = "A fermented or freshly pressed juice beverage crafted exclusively from pressed apples."
        quote = "Louie (28:28): '...this is the most famous fruit in the world. You can make cider out of it.'"
        es = "sidra"
    }
    "stracciatella" = @{
        word = "stracciatella"
        ipa = "/ˌstrætʃ.əˈtel.ə/"
        pos = "noun"
        level = "C1"
        time = "28:48"
        turnId = "turn-126"
        cat = "culinary"
        def = "An Italian gelato preparation featuring sweet cream studded with irregular fine ribbons of dark chocolate."
        quote = "Giulio (28:48): 'Stracciatella... a frozen gelato ice cream.'"
        es = "stracciatella"
    }
    "gelato" = @{
        word = "gelato"
        ipa = "/dʒəˈlɑː.təʊ/"
        pos = "noun"
        level = "B2"
        time = "29:04"
        turnId = "turn-132"
        cat = "culinary"
        def = "Artisanal Italian frozen dessert with lower fat content and slower churning, producing extraordinary density."
        quote = "Louie (29:04): 'Gelato, yeah, very good! Italian ice cream.'"
        es = "helado artesanal italiano"
    }
    "bagel" = @{
        word = "bagel"
        ipa = "/ˈbeɪ.ɡəl/"
        pos = "noun"
        level = "B2"
        time = "29:28"
        turnId = "turn-141"
        cat = "culinary"
        def = "A dense, ring-shaped bread roll boiled briefly in hot water before baking to yield a crisp exterior."
        quote = "Giulio (29:28): 'It is like a donut, right? But not sweet, it is breaded...'"
        es = "bagel"
    }
    "suspicious" = @{
        word = "suspicious"
        ipa = "/səˈspɪʃ.əs/"
        pos = "adjective"
        level = "B2"
        time = "31:43"
        turnId = "turn-155"
        cat = "emotion"
        def = "Having or showing a cautious distrust of someone or something; doubtful of integrity."
        quote = "Giulio (31:43): 'When you don't trust what someone is telling you... when something looks suspicious.'"
        es = "sospechoso / receloso"
    }
    "attached" = @{
        word = "attached"
        ipa = "/əˈtætʃt/"
        pos = "adjective"
        level = "B2"
        time = "31:51"
        turnId = "turn-163"
        cat = "emotion"
        def = "Bound to someone or something by deep personal affection, loyalty, or emotional reliance."
        quote = "Giulio (31:51): 'I think this is when you get attached to something or someone and develop feelings.'"
        es = "apegado / encariñado"
    }
    "infatuated" = @{
        word = "infatuated"
        ipa = "/ɪnˈfætʃ.u.eɪ.tɪd/"
        pos = "adjective"
        level = "C2"
        time = "32:19"
        turnId = "turn-168"
        cat = "emotion"
        def = "Possessed with an unreasoning or shallow, all-consuming romantic passion or admiration."
        quote = "Louie (32:19): 'In love? Infatuated?'"
        es = "encaprichado / obnubilado"
    }
    "affectionate" = @{
        word = "affectionate"
        ipa = "/əˈfek.ʃən.ət/"
        pos = "adjective"
        level = "C1"
        time = "32:48"
        turnId = "turn-173"
        cat = "emotion"
        def = "Readily expressing warmth, tenderness, and fond attachment through comforting gestures and kind words."
        quote = "Louie (32:48): 'Affectionate is just showing someone that you like them... animals can be affectionate too.'"
        es = "afectuoso / cariñoso"
    }
    "apologetic" = @{
        word = "apologetic"
        ipa = "/əˌpɒl.əˈdʒet.ɪk/"
        pos = "adjective"
        level = "C1"
        time = "33:31"
        turnId = "turn-176"
        cat = "emotion"
        def = "Readily and politely expressing sincere regret for an unintentional oversight, showing emotional maturity."
        quote = "Louie (33:31): 'Apologetic is when you apologize politely... he knocked over the jar, but he was very apologetic.'"
        es = "disculpatorio / considerado"
    }
    "pathetic" = @{
        word = "pathetic"
        ipa = "/pəˈθet.ɪk/"
        pos = "adjective"
        level = "B2"
        time = "35:09"
        turnId = "turn-182"
        cat = "emotion"
        def = "Arousing contempt, miserable pity, or disdain; strikingly distinct from dignified courtesy."
        quote = "Louie (35:09): 'It is good, it is not needy or pathetic... it is just polite.'"
        es = "patético / lamentable"
    }
    "fomo" = @{
        word = "FOMO"
        ipa = "/ˈfəʊ.məʊ/"
        pos = "noun"
        level = "B2"
        time = "36:31"
        turnId = "turn-194"
        cat = "emotion"
        def = "Fear Of Missing Out; social apprehension that peers are experiencing rewarding events in one's absence."
        quote = "Giulio (36:31): 'FOMO, fear of missing out, or envy...'"
        es = "miedo a perderse algo (FOMO)"
    }
    "envious" = @{
        word = "envious"
        ipa = "/ˈen.vi.əs/"
        pos = "adjective"
        level = "B2"
        time = "36:47"
        turnId = "turn-198"
        cat = "emotion"
        def = "Experiencing bitter resentment or covetous longing aroused by another's prosperity or advantages."
        quote = "Louie (36:47): 'Envious of your neighbours... something good happens to them and you wish you had it.'"
        es = "envidioso"
    }
    "thief-of-joy" = @{
        word = "thief of joy"
        ipa = "/θiːf əv dʒɔɪ/"
        pos = "idiom"
        level = "C2"
        time = "37:21"
        turnId = "turn-203"
        cat = "philosophy"
        def = "A famous moral adage warning that comparison and envy deplete one's capacity for personal happiness."
        quote = "Louie (37:21): 'In England, we say envy is the thief of joy. It means comparing yourself steals your joy.'"
        es = "el ladrón de la dicha (la envidia)"
    }
    "embarrassed" = @{
        word = "embarrassed"
        ipa = "/ɪmˈbær.əst/"
        pos = "adjective"
        level = "B2"
        time = "37:20"
        turnId = "turn-201"
        cat = "emotion"
        def = "Experiencing awkward discomfort, self-consciousness, or fluster following a public blunder."
        quote = "Giulio (37:20): 'Embarrassment, embarrassed... when you rip your trousers in front of everyone.'"
        es = "avergonzado"
    }
    "amazed" = @{
        word = "amazed"
        ipa = "/əˈmeɪzd/"
        pos = "adjective"
        level = "B2"
        time = "37:21"
        turnId = "turn-203"
        cat = "emotion"
        def = "Overwhelmed with sudden astonishment, wonder, and delightful awe."
        quote = "Louie (37:21): 'This word is when you see something and you cannot believe it: amazed!'"
        es = "asombrado / fascinado"
    }
    "panicked" = @{
        word = "panicked"
        ipa = "/ˈpæn.ɪkt/"
        pos = "adjective"
        level = "B2"
        time = "37:21"
        turnId = "turn-203"
        cat = "emotion"
        def = "Overcome by acute, paralyzing dread or disorganized fear in response to perceived peril."
        quote = "Louie (37:21): 'This is when something happens, you are stressed and scared: panicked.'"
        es = "en pánico / alarmado"
    }
    "abstract-concept" = @{
        word = "abstract concept"
        ipa = "/ˈæb.strækt ˈkɒn.sept/"
        pos = "noun"
        level = "C1"
        time = "39:31"
        turnId = "turn-207"
        cat = "philosophy"
        def = "A generalization, principle, or philosophical notion detached from physical, tangible realities."
        quote = "Giulio (39:31): 'Can you give me an example of what kind of words would appear in abstract concepts?'"
        es = "concepto abstracto"
    }
    "innocence" = @{
        word = "innocence"
        ipa = "/ˈɪn.ə.səns/"
        pos = "noun"
        level = "C1"
        time = "41:07"
        turnId = "turn-216"
        cat = "philosophy"
        def = "Moral guilelessness, purity of intent, and an inherent incapacity to imagine malice in others."
        quote = "Giulio (41:07): 'When you are a kid and you are incapable of seeing the bad side of people... innocence.'"
        es = "inocencia"
    }
    "turn-the-other-cheek" = @{
        word = "turn the other cheek"
        ipa = "/tɜːn ðiː ˈʌð.ər tʃiːk/"
        pos = "idiom"
        level = "C2"
        time = "41:56"
        turnId = "turn-217"
        cat = "philosophy"
        def = "To respond to insult, offense, or mistreatment with patient non-violence and gracious forgiveness."
        quote = "Louie (41:56): 'Turn the other cheek... forgive.'"
        es = "poner la otra mejilla"
    }
    "forgiveness" = @{
        word = "forgiveness"
        ipa = "/fəˈɡɪv.nəs/"
        pos = "noun"
        level = "B2"
        time = "42:00"
        turnId = "turn-218"
        cat = "philosophy"
        def = "The deliberate, ethical decision to renounce bitterness, vengeance, or anger toward an offender."
        quote = "Giulio (42:00): 'Turned the other cheek, but to forgive... forgiveness.'"
        es = "perdón"
    }
    "stubborn" = @{
        word = "stubborn"
        ipa = "/ˈstʌb.ən/"
        pos = "adjective"
        level = "B2"
        time = "42:15"
        turnId = "turn-223"
        cat = "emotion"
        def = "Unreasonably obstinate and firmly entrenched in one's perspective, resisting all persuasion."
        quote = "Giulio (42:15): 'When you are very stubborn and have a strong opinion about yourself...'"
        es = "terco / obstinado"
    }
    "pride" = @{
        word = "pride"
        ipa = "/praɪd/"
        pos = "noun"
        level = "C1"
        time = "43:05"
        turnId = "turn-226"
        cat = "philosophy"
        def = "Honorable self-respect and dignity in quality craftsmanship, distinctly separated from vanity."
        quote = "Louie (43:05): 'Pride is when you are proud of yourself... taking pride in your work.'"
        es = "orgullo / amor propio"
    }
    "take-pride-in" = @{
        word = "take pride in"
        ipa = "/teɪk praɪd ɪn/"
        pos = "idiom"
        level = "C1"
        time = "43:53"
        turnId = "turn-233"
        cat = "philosophy"
        def = "To derive sincere satisfaction from dedicating meticulous care and ethical effort to one's duties."
        quote = "Louie (43:53): 'You can take pride in your work, right? You respect your process, you really try hard...'"
        es = "enorgullecerse de / poner esmero en"
    }
    "pride-of-lions" = @{
        word = "pride of lions"
        ipa = "/praɪd əv ˈlaɪ.ənz/"
        pos = "noun"
        level = "C2"
        time = "44:54"
        turnId = "turn-235"
        cat = "language"
        def = "The conventional English collective noun designating a family or social group of lions."
        quote = "Louie (44:54): 'We call a family of lions a pride. Nothing to do with emotion!'"
        es = "manada de leones (pride)"
    }
    "murder-of-crows" = @{
        word = "murder of crows"
        ipa = "/ˈmɜː.dər əv krəʊz/"
        pos = "noun"
        level = "C2"
        time = "45:14"
        turnId = "turn-240"
        cat = "language"
        def = "The evocative traditional collective noun specifically designating a flock of black crows."
        quote = "Giulio (45:14): 'A murder of crows, right?' Louie: 'Exactly, yeah!'"
        es = "bandada de cuervos (murder)"
    }
    "gaggle-of-geese" = @{
        word = "gaggle of geese"
        ipa = "/ˈɡæɡ.əl əv ɡiːs/"
        pos = "noun"
        level = "C2"
        time = "45:18"
        turnId = "turn-243"
        cat = "language"
        def = "The classic English collective term for a terrestrial flock of noisy, rambling geese."
        quote = "Louie (45:18): 'A gaggle of geese... we have these weird names for everything, it is really strange.'"
        es = "bandada de gansos (gaggle)"
    }
    "goose-and-gander" = @{
        word = "goose and gander"
        ipa = "/ɡuːs ænd ˈɡæn.dər/"
        pos = "idiom"
        level = "C2"
        time = "45:18"
        turnId = "turn-243"
        cat = "philosophy"
        def = "A classic proverb stating that whatever rule or privilege is fair for one person must apply equally to another."
        quote = "Louie (45:18): 'What is good for the goose is good for the gander... what is good for one person is good for the group.'"
        es = "lo que es bueno para el ganso es bueno para la gansa"
    }
    "conscience" = @{
        word = "conscience"
        ipa = "/ˈkɒn.ʃəns/"
        pos = "noun"
        level = "C1"
        time = "46:08"
        turnId = "turn-247"
        cat = "philosophy"
        def = "The inner intuitive moral sensibility distinguishing right from wrong in human conduct."
        quote = "Louie (46:08): 'Conscience... your inner monologue, your moral thoughts.'"
        es = "conciencia moral"
    }
    "inner-monologue" = @{
        word = "inner monologue"
        ipa = "/ˈɪn.ər ˈmɒn.ə.lɒɡ/"
        pos = "noun"
        level = "C1"
        time = "46:43"
        turnId = "turn-250"
        cat = "philosophy"
        def = "The continuous internal stream of spoken consciousness and contemplative thoughts in the mind."
        quote = "Louie (46:43): 'In your head, we call it the inner monologue, your thoughts...'"
        es = "monólogo interior"
    }
    "look-forward-to" = @{
        word = "look forward to"
        ipa = "/lʊk ˈfɔː.wəd tuː/"
        pos = "phrasal verb"
        level = "B2"
        time = "47:47"
        turnId = "turn-252"
        cat = "culture"
        def = "To anticipate future pleasurable pursuits with genuine eagerness and joy."
        quote = "Giulio (47:47): 'This is the sort of things I look forward to doing in my spare time.'"
        es = "esperar con ilusión / tener ganas de"
    }
    "keep-active" = @{
        word = "keep active"
        ipa = "/kiːp ˈæk.tɪv/"
        pos = "phrase"
        level = "B2"
        time = "47:47"
        turnId = "turn-252"
        cat = "culture"
        def = "To maintain regular dynamic cardiovascular fitness through sports, hiking, and movement."
        quote = "Giulio (47:47): 'I do cycling, I play padel... basically I like to keep myself active.'"
        es = "mantenerse activo"
    }
    "revitalize" = @{
        word = "revitalize"
        ipa = "/riːˈvaɪ.təl.aɪz/"
        pos = "verb"
        level = "C1"
        time = "50:03"
        turnId = "turn-263"
        cat = "culture"
        def = "To breathe vibrant new energy, economic vitality, and social life into historical townscapes."
        quote = "Louie (50:03): '...rebuild 700-year-old buildings and put businesses in them to revitalize towns like Oxford or Buckinghamshire.'"
        es = "revitalizar / regenerar"
    }
    "indie-movies" = @{
        word = "indie movies"
        ipa = "/ˈɪn.di ˈmuː.viz/"
        pos = "noun"
        level = "B2"
        time = "54:33"
        turnId = "turn-290"
        cat = "cinema"
        def = "Independent cinematic projects produced outside major Hollywood studio systems with artistic liberty."
        quote = "Louie (54:33): 'It is like independent movies, old Vietnamese films, where you dress up and speak directly with the director.'"
        es = "cine independiente"
    }
    "film-festival" = @{
        word = "film festival"
        ipa = "/fɪlm ˈfes.tɪ.vəl/"
        pos = "noun"
        level = "B2"
        time = "55:26"
        turnId = "turn-296"
        cat = "cinema"
        def = "An organized municipal celebration showcasing curated cinematic premiers with creator Q&As."
        quote = "Giulio (55:26): 'In Spain we have the San Sebastián Film Festival in September... Brad Pitt was there, Penélope Cruz as every year.'"
        es = "festival de cine"
    }
    "cinema-atmosphere" = @{
        word = "cinema atmosphere"
        ipa = "/ˈsɪn.ə.mə ˈæt.məs.fɪər/"
        pos = "noun"
        level = "C1"
        time = "56:20"
        turnId = "turn-299"
        cat = "cinema"
        def = "The sensory and communal magic of theatrical viewing: warm popcorn aroma, dark auditorium, and shared focus."
        quote = "Giulio (56:20): 'The experience, the environment, the smell of popcorn, the bell on the stairs... it is the atmosphere, basically.'"
        es = "atmósfera cinematográfica"
    }
    "unplug" = @{
        word = "unplug"
        ipa = "/ʌnˈplʌɡ/"
        pos = "verb"
        level = "C1"
        time = "57:13"
        turnId = "turn-303"
        cat = "culture"
        def = "To deliberately disconnect from digital devices, phone alerts, and notifications to restore mental presence."
        quote = "Giulio (57:13): 'At home I cannot stop looking at my phone... but at the cinema I can spend two hours without checking it.'"
        es = "desconectarse de las pantallas"
    }
    "watch-list" = @{
        word = "watch list"
        ipa = "/ˈwɒtʃ lɪst/"
        pos = "noun"
        level = "B2"
        time = "58:21"
        turnId = "turn-306"
        cat = "cinema"
        def = "A curated personal catalog of films and documentaries scheduled for future screening."
        quote = "Louie (58:21): 'What is on your watch list? What have you got that you want to watch?'"
        es = "lista de películas pendientes"
    }
    "blockbuster" = @{
        word = "blockbuster"
        ipa = "/ˈblɒkˌbʌs.tər/"
        pos = "noun"
        level = "B2"
        time = "58:50"
        turnId = "turn-314"
        cat = "cinema"
        def = "A major cinematic release commanding massive production budgets and sweeping public excitement."
        quote = "Giulio (58:50): 'The new Hunger Games, Avengers: Doomsday... I think that is the three blockbusters of this quarter.'"
        es = "superproducción / taquillazo"
    }
    "franchise" = @{
        word = "franchise"
        ipa = "/ˈfræn.tʃaɪz/"
        pos = "noun"
        level = "B2"
        time = "59:40"
        turnId = "turn-320"
        cat = "cinema"
        def = "An overarching media universe spanning sequential films, characters, and related commercial spin-offs."
        quote = "Giulio (59:40): 'They are bringing back one of the most famous actors of this franchise, Robert Downey Jr.'"
        es = "franquicia cinematográfica"
    }
    "hype" = @{
        word = "hype"
        ipa = "/haɪp/"
        pos = "noun"
        level = "B2"
        time = "59:40"
        turnId = "turn-320"
        cat = "cinema"
        def = "Intense promotional buzz and feverish public anticipation preceding a cultural milestone."
        quote = "Giulio (59:40): 'Robert Downey Jr. returning as Doctor Doom is creating a lot of hype.'"
        es = "expectación / bombo publicitario"
    }
    "front-and-center" = @{
        word = "front and center"
        ipa = "/frʌnt ænd ˈsen.tər/"
        pos = "idiom"
        level = "C1"
        time = "01:00:03"
        turnId = "turn-323"
        cat = "cinema"
        def = "Placed in the most conspicuous, dominating position of a theatrical trailer or presentation."
        quote = "Louie (01:00:03): 'He is already there, the villain is already front and center in the trailers...'"
        es = "en primer plano / en el foco principal"
    }
    "draw-a-blank" = @{
        word = "draw a blank"
        ipa = "/drɔː ə blæŋk/"
        pos = "idiom"
        level = "C1"
        time = "01:01:08"
        turnId = "turn-332"
        cat = "language"
        def = "To experience a sudden, temporary failure of memory or vocabulary recall under focus."
        quote = "Giulio (01:01:08): 'Louis, this is so weird. I do not know if I am nervous, but I am blank!'"
        es = "quedarse en blanco"
    }
    "back-catalog" = @{
        word = "back catalog"
        ipa = "/bæk ˈkæt.ə.lɒɡ/"
        pos = "noun"
        level = "C1"
        time = "01:01:31"
        turnId = "turn-337"
        cat = "cinema"
        def = "The historical archive of previous releases created by an auteur, film studio, or personal viewing history."
        quote = "Louie (01:01:31): 'My back catalog... films from the past that I still need to watch.'"
        es = "archivo histórico / fondo de catálogo"
    }
    "suppress" = @{
        word = "suppress"
        ipa = "/səˈpres/"
        pos = "verb"
        level = "C1"
        time = "01:03:08"
        turnId = "turn-340"
        cat = "emotion"
        def = "To forcibly prevent traumatic memories or painful emotions from entering conscious thought."
        quote = "Louie (01:03:08): 'She suppressed her memories... to suppress is to push down distressing trauma.'"
        es = "reprimir / sofocar recuerdos"
    }
    "slow-burner" = @{
        word = "slow-burner"
        ipa = "/sləʊ ˈbɜː.nər/"
        pos = "noun"
        level = "C1"
        time = "01:03:38"
        turnId = "turn-345"
        cat = "cinema"
        def = "A narrative or film that unfolds patiently and deliberately before unveiling its profound emotional power."
        quote = "Louie (01:03:38): 'Sophie\'s Choice is a slow one, a bit of a slow-burner, but apparently fantastic.'"
        es = "obra de ritmo pausado pero envolvente"
    }
    "bottleneck" = @{
        word = "bottleneck"
        ipa = "/ˈbɒt.əl.nek/"
        pos = "noun"
        level = "C1"
        time = "01:06:22"
        turnId = "turn-363"
        cat = "language"
        def = "A narrow cognitive point of congestion that restricts natural speaking flow—specifically mental translation."
        quote = "Louie (01:06:22): 'We call it a bottleneck... we want to open that bottleneck and fill it with vocabulary!'"
        es = "cuello de botella / traba cognitiva"
    }
}

# 3. Define 6 NATURAL STRENGTHS
$naturalStrengths = @(
    @{
        topic = "Metacognitive Linguistic Awareness"
        time = "14:24"
        phrase = "I feel that when I speak, I have sometimes this lack of coherence when making my phrases."
        note = "Giulio articulated his language ambitions using sophisticated C1 metacognitive terms ('coherence', 'fluency', 'phrases')—showing impressive command of vocabulary even while analyzing areas for refinement!"
    },
    @{
        topic = "Nuanced Emotional Perception"
        time = "31:43"
        phrase = "When someone doesn't tell the truth... when something looks suspicious."
        note = "Under rapid timer pressure during the Heads Up game, Giulio quickly navigated through slang ('speechy, sus') to identify the precise C1 adjective 'suspicious'!"
    },
    @{
        topic = "Natural Collocations & Phrasal Verbs"
        time = "47:47"
        phrase = "I do cycling, I play padel... basically I like to keep myself active. I look forward to doing sports."
        note = "Effortless, natural delivery of 'keep myself active' and the essential B2 phrasal verb 'look forward to'—flawlessly used in spontaneous conversational flow."
    },
    @{
        topic = "Evocative Sensory Storytelling"
        time = "56:20"
        phrase = "The experience, the environment, the smell of popcorn, the bell on the stairs... it's the atmosphere, basically."
        note = "A vivid, multi-sensory depiction of the movie theatre. Giulio painted a genuine emotional picture with elegant cadence and atmospheric rhythm."
    },
    @{
        topic = "Deep Philosophical Reflection"
        time = "57:13"
        phrase = "That's something that can have my full attention for that amount of time without checking my phone."
        note = "A perceptive critique of modern digital screen addiction. Giulio expressed an authentic, complex insight smoothly and convincingly without hesitating."
    },
    @{
        topic = "Sophisticated Cinema Lexicon"
        time = "01:03:33"
        phrase = "From my back catalog, I would like to rewatch The Zone of Interest."
        note = "Adopted Louie's phrase 'back catalog' immediately into active dialogue, showing superb conversational agility and active listening skills."
    }
)

# 4. Define 6 GENTLE PHRASINGS
$gentlePhrasings = @(
    @{
        topic = "Office Downtime & Greetings"
        time = "13:57"
        said = "My dad was good... I can go home and the Escoonnade relax."
        natural = "My day was good! I can head home, disconnect, and completely unwind."
        note = "A gentle slip between 'day' and 'dad'—easily smoothed out. 'Disconnect and unwind' flows beautifully for an evening after office work in Valencia."
    },
    @{
        topic = "Expressing Language Ambition"
        time = "14:24"
        said = "Why are we here today? Well, we are here today because I would like to improve my fluency, my while speaking..."
        natural = "I'm really keen to improve my spoken fluency and natural grammatical flow, so my thoughts connect seamlessly."
        note = "Polishing the transition into a confident, professional statement of personal ambition."
    },
    @{
        topic = "Describing Culinary Shapes"
        time = "25:40"
        said = "Yeah, well, it's beef that you shape it round and it's not a hamburger... it's feric."
        natural = "It's seasoned beef rolled into a sphere—not quite a burger, but spherical meatballs in rich tomato sauce."
        note = "Moving from 'feric' to the elegant mathematical adjective 'spherical' to describe meatballs on pasta."
    },
    @{
        topic = "Character & Firm Conviction"
        time = "42:15"
        said = "When you are very stubborn and you have a strong opinion about yourself and you really mean what you think..."
        natural = "When you stand firm in your convictions and take genuine pride in your principles, without backing down."
        note = "Framing stubbornness into the honorable British concept of 'taking pride in one's convictions'."
    },
    @{
        topic = "Sharing Weekend Passions"
        time = "53:33"
        said = "Yeah, we love we'll love going to cinema and that's basically how I like to sparma my spare time."
        natural = "My girlfriend and I love heading to the cinema every week—it's my favourite way to spend my downtime."
        note = "Smoothing out the small verbal loop into a warm, natural conversational summary."
    },
    @{
        topic = "Overcoming the Memory Blank"
        time = "01:01:08"
        said = "Louis, this is so weird. I don't know if... I mean, I even feel like I'm nervous, but I'm blank."
        natural = "It's funny, I'm drawing a complete blank right now! My mind suddenly went quiet when switching to English."
        note = "The classic idiom 'draw a blank' is the most natural native way to describe a momentary lapse in memory under focus."
    }
)

# 5. Define 20 ASR FIXES
$asrFixes = @(
    @{ fixed = "a murder of crows"; heard = "a marr froz"; time = "45:14"; context = "Discussing eccentric British collective animal nouns." },
    @{ fixed = "Meryl Streep"; heard = "Male stream"; time = "01:03:38"; context = "Referring to the legendary Oscar-winning actress in Sophie's Choice." },
    @{ fixed = "Sophie's Choice"; heard = "Sophie stresses"; time = "01:03:38"; context = "Louie mentioning the 1982 psychological Holocaust drama." },
    @{ fixed = "Doctor Doom"; heard = "a doctor Loom"; time = "01:00:26"; context = "Discussing Robert Downey Jr.'s Marvel villain in Avengers: Doomsday." },
    @{ fixed = "Timothée Chalamet"; heard = "Smothy Salome"; time = "58:50"; context = "Talking about the lead actor of Marty Supreme and Dune." },
    @{ fixed = "Timothée Chalamet"; heard = "Timothy... Charlemagne"; time = "52:57"; context = "Louie mentioning his sister's favourite cinema actor." },
    @{ fixed = "padel"; heard = "paddle"; time = "47:47"; context = "Giulio describing the popular racket sport he plays in Spain." },
    @{ fixed = "a ball of minced beef"; heard = "a tfle of beef"; time = "25:01"; context = "Giulio describing meatballs in the Heads Up game." },
    @{ fixed = "spherical"; heard = "feric / mospher"; time = "25:40"; context = "Describing the 3D geometry of round meatballs on pasta." },
    @{ fixed = "stracciatella"; heard = "Estra chaa"; time = "28:48"; context = "Giulio describing the Italian gelato flavour with chocolate flakes." },
    @{ fixed = "gelato"; heard = "gelado"; time = "29:01"; context = "Authentic artisanal Italian ice cream." },
    @{ fixed = "Seville"; heard = "Sabile"; time = "29:57"; context = "The Andalusian city where Louie's brother and mother live." },
    @{ fixed = "My mum's ringing me"; heard = "My Loom's rigging me"; time = "52:57"; context = "Louie's mother phoning him while she was traveling in Spain." },
    @{ fixed = "revitalize"; heard = "you vitalize"; time = "50:03"; context = "Restoring historic 700-year-old buildings in English towns." },
    @{ fixed = "Buckinghamshire"; heard = "Buckhamshire"; time = "50:03"; context = "The historic English ceremonial county." },
    @{ fixed = "Thanos"; heard = "Vanos"; time = "01:00:03"; context = "The previous Marvel Infinity Saga antagonist." },
    @{ fixed = "A24"; heard = "A for a twenty 4"; time = "01:04:57"; context = "The acclaimed independent film studio behind The Zone of Interest." },
    @{ fixed = "bottleneck"; heard = "Bo, all neg"; time = "01:06:22"; context = "The cognitive translation bottleneck restricting natural spoken fluency." },
    @{ fixed = "suspicious"; heard = "speechy, sus"; time = "31:15"; context = "Guessing the emotion under rapid timer pressure." },
    @{ fixed = "disconnect and relax"; heard = "the Escoonnade relax"; time = "13:57"; context = "Giulio finishing his work at the automotive office to unwind." }
)

# 6. Define 4 EDITORIAL TOPICS
$editorialTopics = @(
    @{
        id = "topic-1"
        tag = "Active Lifestyle & Cinema Culture"
        title = "From Valencia's Padel Courts to the Basque Red Carpet"
        quote = "'In Spain we have the San Sebastián Film Festival in September... Brad Pitt was there, Penélope Cruz as every year.' • Giulio"
        paragraphs = @(
            "Balancing a demanding technical schedule in the automotive sector with vibrant personal passions, Giulio exemplifies the balanced Mediterranean lifestyle. Living in Valencia, his weekly routine revolves around dynamic physical movement—cycling through coastal paths, competitive padel matches, and weekend hikes through the Valencian mountains.",
            "Beyond athletics, cinema forms an anchor for his downtime. Spain's film heritage shines brightly at the San Sebastián International Film Festival in the Basque Country, where world cinema auteurs converge each September alongside Hollywood luminaries, reflecting Giulio's discerning cinematic taste."
        )
    },
    @{
        id = "topic-2"
        tag = "Heritage & Global Journeys"
        title = "700-Year-Old English Manors to Hanoi's Indie Cinema Nights"
        quote = "'I used to restore 700-year-old English buildings... now in Hanoi, all the municipal cinemas are free during film season.' • Louie"
        paragraphs = @(
            "Louie's background bridges English historical conservation with global university scholarship. Prior to moving to Vietnam, he spent years in Oxfordshire and Buckinghamshire carefully revitalizing 14th-century timber-framed heritage buildings, adapting medieval architecture into thriving community businesses.",
            "Today, studying Vietnamese at university in downtown Hanoi, he experiences Vietnam's cultural blossoming. During Hanoi's autumn festival season, cinemas across the capital open their doors free of charge, hosting intimate Q&A discussions between audiences and indie directors."
        )
    },
    @{
        id = "topic-3"
        tag = "Digital Detox & Sanctuary"
        title = "The Cinema as an Unplugged Sanctuary"
        quote = "'When I go to the cinema, I spend two or three hours without looking at my phone... it has my full attention.' • Giulio"
        paragraphs = @(
            "In a digital era dominated by endless notification pings and fragmented attention spans, Giulio offered a perceptive insight into the sacred role of the movie theatre. Streaming a movie at home often devolves into checking Instagram or replying to messages mid-scene.",
            "The darkened cinema auditorium provides an essential sensory sanctuary. Surrounded by the warmth of freshly popped corn, gentle ascending stair lighting, and collective silence, the viewer surrenders completely to the art of cinematic storytelling, regaining the rare gift of undivided focus."
        )
    },
    @{
        id = "topic-4"
        tag = "Linguistic Quirks & Idioms"
        title = "The English Menagerie: Crows, Geese & The Gander"
        quote = "'A murder of crows, a gaggle of geese... what is good for the goose is good for the gander.' • Louie & Giulio"
        paragraphs = @(
            "The English language harbors a centuries-old fascination with poetic collective animal nouns. A gathering of lions becomes an honorable 'pride', a noisy flock of geese forms a 'gaggle', and black crows famously assemble into a chilling 'murder'—a phrase the speech-to-text note-taker hilariously transcribed as 'a marr froz'!",
            "Paired with these animal metaphors is the timeless British proverb: 'What is good for the goose is good for the gander.' Born from 17th-century folklore, it remains one of the most vivid ways to insist upon fairness, equity, and consistency across all human endeavors."
        )
    }
)

# 7. Define 8 FLASHCARD KEYS
$flashcardKeys = @("serendipity", "contingency", "affectionate", "apologetic", "thief-of-joy", "inner-monologue", "bottleneck", "back-catalog")

# 8. Define 6 QUIZ QUESTIONS (The Test)
$quizQuestions = @(
    @{
        id = 1
        question = "In English idioms and moral proverbs, what does the expression 'what is good for the goose is good for the gander' (45:18) convey?"
        options = @(
            "People in rural communities should follow local agricultural customs."
            "Rules, standards, and privileges that apply to one party must apply equally and fairly to everyone else."
            "Major personal decisions should always be made unanimously by the family."
            "You should always share all personal possessions with your neighbors."
        )
        correctIndex = 1
        explanation = "'What's good for the goose is good for the gander' (45:18) asserts that whatever rule, privilege, or standard applies to one person must apply equally and fairly to the other."
    },
    @{
        id = 2
        question = "Why did Louie explain that describing someone as 'very apologetic' (33:31) is viewed as a courteous and positive trait in British English?"
        options = @(
            "It proves they feel overwhelming guilt and lack confidence in their professional work."
            "It shows they are hesitant to express their opinions openly in conversation."
            "It reflects polite emotional maturity—readily acknowledging a small slip courteously without drama or neediness."
            "It indicates they prefer to work independently without collaborating in a team."
        )
        correctIndex = 2
        explanation = "Louie explained that being 'apologetic' (33:31) reflects considerate social intelligence—saying sorry gracefully when you make a slip, without being pathetic or needy."
    },
    @{
        id = 3
        question = "What timeless philosophical lesson is captured by the proverb 'Envy is the thief of joy' (37:21)?"
        options = @(
            "Spending too much money on luxury items creates long-term financial anxiety."
            "Constantly comparing yourself resentfully to what friends or neighbors have only steals your own contentment."
            "You should keep your career ambitions confidential from colleagues."
            "Taking holidays too frequently disrupts your daily office routine."
        )
        correctIndex = 1
        explanation = "'Envy is the thief of joy' (37:21) warns that looking at what others possess and measuring your worth against them destroys your genuine peace of mind."
    },
    @{
        id = 4
        question = "When discussing building conversational fluency, what specific obstacle does the 'bottleneck' metaphor (01:06:22) represent?"
        options = @(
            "Running out of physical breath when speaking in long paragraphs."
            "The cognitive friction of mentally translating Spanish into English in your head before speaking."
            "Forgetting technical automotive terminology during a presentation."
            "Struggling to comprehend rapid British regional accents."
        )
        correctIndex = 1
        explanation = "The 'bottleneck' (01:06:22) is the cognitive choke-point of translating thoughts word-for-word from Spanish to English rather than speaking directly and intuitively."
    },
    @{
        id = 5
        question = "Why did Giulio emphasize that going to the cinema once a week provides an essential mental sanctuary compared to watching films at home (57:13)?"
        options = @(
            "Cinema audio systems are louder than home soundbars."
            "It allows him to unplug completely from his smartphone for two to three hours without digital notifications."
            "Movie tickets in Valencia are subsidized on weekday evenings."
            "He only enjoys high-budget science-fiction franchises on IMAX screens."
        )
        correctIndex = 1
        explanation = "Giulio highlighted that at home he constantly checks notifications and Instagram, whereas the movie theatre commands his undivided attention and allows him to unplug."
    },
    @{
        id = 6
        question = "What is the eccentric British collective noun for a flock of crows, which the note-taker humorously transcribed as 'a marr froz' (45:14)?"
        options = @(
            "A gaggle of crows"
            "A pride of crows"
            "A parliament of crows"
            "A murder of crows"
        )
        correctIndex = 3
        explanation = "A group of crows is famously termed 'a murder of crows' (45:14)—one of the most curious and celebrated collective animal nouns in the English language!"
    }
)

# 9. Define 3 REFLECTION PROMPTS
$reflectionPrompts = @(
    @{
        num = "01"
        title = "The Zone of Interest & Sonic Tension"
        text = "As you watch Jonathan Glazer's masterpiece before Thursday, pay close attention to the sound design beyond the garden wall. How does the chilling contrast between everyday domestic family life and the distant ambient soundtrack create dramatic tension?"
    },
    @{
        num = "02"
        title = "Opening the Translation Bottleneck"
        text = "This week at your desk in Valencia, observe those micro-moments when you hesitate before writing an email or speaking in English. What happens if you skip constructing the Spanish sentence first and speak the core concept directly?"
    },
    @{
        num = "03"
        title = "Hidden Gems from the Back Catalog"
        text = "Consider your personal cinematic 'back catalog'. What is one under-appreciated film or slow-burner that left an indelible impression on you, and how would you describe its atmosphere to a friend?"
    }
)

# 10. Process Transcript Turns into HTML Objects
Write-Host "Processing transcript turns with ASR fix badges and vocabulary marks..."

$asrMap = @{
    "a marr froz" = @{ fix = "a murder of crows"; raw = "a marr froz" }
    "Male stream" = @{ fix = "Meryl Streep"; raw = "Male stream" }
    "Sophie stresses" = @{ fix = "Sophie's Choice"; raw = "Sophie stresses" }
    "a doctor Loom" = @{ fix = "Doctor Doom"; raw = "a doctor Loom" }
    "Doctor Loom" = @{ fix = "Doctor Doom"; raw = "Doctor Loom" }
    "Smothy Salome" = @{ fix = "Timothée Chalamet"; raw = "Smothy Salome" }
    "Timothy... Charlemagne" = @{ fix = "Timothée Chalamet"; raw = "Timothy... Charlemagne" }
    "paddle" = @{ fix = "padel"; raw = "paddle" }
    "a tfle of beef" = @{ fix = "a ball of minced beef"; raw = "a tfle of beef" }
    "feric" = @{ fix = "spherical"; raw = "feric" }
    "mospher" = @{ fix = "spherical"; raw = "mospher" }
    "Estra chaa" = @{ fix = "stracciatella"; raw = "Estra chaa" }
    "gelado" = @{ fix = "gelato"; raw = "gelado" }
    "Sabile" = @{ fix = "Seville"; raw = "Sabile" }
    "My Loom's rigging me" = @{ fix = "My mum's ringing me"; raw = "My Loom's rigging me" }
    "you vitalize" = @{ fix = "revitalize"; raw = "you vitalize" }
    "Buckhamshire" = @{ fix = "Buckinghamshire"; raw = "Buckhamshire" }
    "Vanos" = @{ fix = "Thanos"; raw = "Vanos" }
    "A for a twenty 4" = @{ fix = "A24"; raw = "A for a twenty 4" }
    "Bo, all neg" = @{ fix = "bottleneck"; raw = "Bo, all neg" }
    "speechy, sus" = @{ fix = "suspicious"; raw = "speechy, sus" }
    "in actuated" = @{ fix = "infatuated"; raw = "in actuated" }
    "the Escoonnade relax" = @{ fix = "disconnect and relax"; raw = "the Escoonnade relax" }
}

$processedTurns = @()
for ($i = 0; $i -lt $turns.Count; $i++) {
    $t = $turns[$i]
    $turnId = "turn-$i"
    
    # Speaker normalization
    $speaker = "Note-Taker / Audio"
    if ($t.speaker -match "Lewis|Louie") { $speaker = "Louie" }
    elseif ($t.speaker -match "Tony|Giulio") { $speaker = "Giulio" }

    $html = $t.text

    # Apply ASR Fix Badges
    foreach ($k in $asrMap.Keys) {
        $item = $asrMap[$k]
        if ($html.Contains($k)) {
            $badge = "<span class=`"asr-fix-pill`" title=`"Note-taker misheard '$($item.fix)' as '$($item.raw)'`">✨ Fixed: `"$($item.fix)`" <span class=`"text-stone-400`">(note-taker: `"$($item.raw)`")</span></span>"
            $html = $html.Replace($k, $badge)
        }
    }

    # Chapter assignment
    $chapterId = $null
    $chapterTitle = $null
    if ($i -eq 0) {
        $chapterId = "chap-0"
        $chapterTitle = "Prologue • Audio Setup & Waiting Room (00:00 – 13:42)"
    } elseif ($i -eq 8) {
        $chapterId = "chap-1"
        $chapterTitle = "Chapter I • Lesson Architecture, Real-Time Notes & Mental Translation (13:43 – 20:25)"
    } elseif ($i -eq 49) {
        $chapterId = "chap-2"
        $chapterTitle = "Chapter II • 'Heads Up' Warm-Up: Culinary Collocations & Bagel Geometry (20:26 – 30:32)"
    } elseif ($i -eq 134) {
        $chapterId = "chap-3"
        $chapterTitle = "Chapter III • Emotional Nuance: Suspicion, Affection & The Thief of Joy (30:33 – 39:30)"
    } elseif ($i -eq 189) {
        $chapterId = "chap-4"
        $chapterTitle = "Chapter IV • Abstract Concepts, Moral Philosophy & The English Menagerie (39:31 – 47:46)"
    } elseif ($i -eq 249) {
        $chapterId = "chap-5"
        $chapterTitle = "Chapter V • Active Passions, Cinema Atmosphere & Vietnamese Film Festivals (47:47 – 58:20)"
    } elseif ($i -eq 303) {
        $chapterId = "chap-6"
        $chapterTitle = "Chapter VI • Blockbuster Sagas, Historical Trauma & Overcoming the Bottleneck (58:21 – 01:07:05)"
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
        # Replace occurrences in turn HTML if not already inside a tag
        $mark = "<span class=`"vocab-mark`" data-vkey=`"$vkey`" onclick=`"inspectVocab('$vkey')`">$w</span>"
        if ($targetTurn.html -match [regex]::Escape($w)) {
            $targetTurn.html = [regex]::Replace($targetTurn.html, "\b" + [regex]::Escape($w) + "\b", $mark, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        } else {
            # Append badge to turn if word was implied
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
      <span class="font-medium">Giulio M. • Spoken Fluency, Emotional Nuance &amp; Cinema Sanctuary</span>
    </div>
    <div class="flex items-center gap-2">
      <span class="text-white/80 text-[11px]">Valencia, Spain ↔ Hanoi, Vietnam</span>
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
            <span>Lesson 01 • 03 November 2026 • 1-Hour Spoken Session</span>
          </div>

          <h1 class="font-serif text-3xl sm:text-4xl lg:text-[2.65rem] font-bold text-slatewarm-900 leading-[1.16]">
            Unlocking Spoken Fluency: From <span class="text-autumn-700 italic font-semibold">Heads Up</span> to the Cinema Sanctuary
          </h1>

          <p class="text-stone-600 text-sm sm:text-base leading-relaxed max-w-3xl">
            In our first session, Giulio and Louie addressed the core challenge of <strong>mental translation</strong>—opening the cognitive "bottleneck" where thoughts are formulated in Spanish before being translated to English. Through fast-paced <em>Heads Up</em> rounds, emotional nuances (<em>apologetic</em> vs <em>pathetic</em>), English collective nouns (<em>a murder of crows</em>), and deep conversations on the cinema as an unplugged refuge, we built the foundation for effortless spoken fluency.
          </p>

          <!-- 4 Pillars for the Student -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5 pt-2 text-xs">
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">Zero Note-Taking Friction:</strong> Every turn is captured and organized into 6 chronological chapters with per-turn audio.
              </div>
            </div>
            <div class="flex items-start gap-2 bg-parchment-100/80 p-2.5 rounded-xl border border-parchment-300">
              <i data-lucide="check-circle" class="w-4 h-4 text-sage-600 shrink-0 mt-0.5"></i>
              <div>
                <strong class="text-slatewarm-900">60 Flagged Lexicon Terms:</strong> Hover or click any word for IPA, CEFR level, Spanish translations, and British audio.
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
                <strong class="text-slatewarm-900">Note-Taker Errors Fixed:</strong> Funny automated mishearings (<em>a marr froz</em>, <em>Male stream</em>, <em>Doctor Loom</em>) cleanly corrected.
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
            <p class="text-[11px] text-stone-600 mt-0.5">6 chapters • 00:00 to 01:07:05</p>
          </div>

          <div onclick="switchTab('vocab')" class="cursor-pointer p-4 rounded-2xl bg-sage-50/95 border border-sage-200 hover:border-sage-400 transition shadow-sm group">
            <div class="text-[11px] font-mono font-semibold uppercase text-sage-700 flex items-center justify-between">
              <span>Section 2</span>
              <i data-lucide="book-marked" class="w-4 h-4 group-hover:scale-110 transition"></i>
            </div>
            <div class="font-serif font-bold text-slatewarm-900 text-lg mt-0.5">Flagged Lexicon</div>
            <p class="text-[11px] text-stone-600 mt-0.5">60 B2–C2 terms with Spanish translations</p>
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
          <span>4. Cultural Topics &amp; Cinema</span>
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
              <option value="chap-0">Prologue: Audio Setup (00:00)</option>
              <option value="chap-1">Chapter I: Lesson Architecture (13:43)</option>
              <option value="chap-2">Chapter II: Heads Up &amp; Food (20:26)</option>
              <option value="chap-3">Chapter III: Emotional Nuance (30:33)</option>
              <option value="chap-4">Chapter IV: Abstract Concepts (39:31)</option>
              <option value="chap-5">Chapter V: Cinema Atmosphere (47:47)</option>
              <option value="chap-6">Chapter VI: Blockbusters &amp; Bottlenecks (58:21)</option>
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
              <span id="insp-time" class="text-xs font-mono px-2 py-0.5 rounded bg-sage-100 text-sage-800">🕒 14:24</span>
            </div>

            <div class="space-y-1.5">
              <div class="flex items-center justify-between gap-2">
                <h3 id="insp-word" class="font-serif text-2xl font-bold text-slatewarm-900">fluency</h3>
                <span id="insp-level" class="px-2 py-0.5 rounded-md bg-autumn-100 text-autumn-800 font-mono text-xs font-bold">B2</span>
              </div>
              <div class="flex items-center gap-2 text-xs font-mono text-stone-500">
                <span id="insp-ipa">/ˈfluː.ən.si/</span>
                <span>•</span>
                <span id="insp-pos">noun</span>
              </div>
            </div>

            <div class="space-y-2 pt-1">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Meaning</span>
              <p id="insp-def" class="text-xs sm:text-sm text-stone-700 leading-relaxed bg-parchment-50 p-3 rounded-xl border border-parchment-200">
                The natural ability to speak smoothly, easily, and without awkward hesitation or cognitive strain.
              </p>
            </div>

            <div class="space-y-2">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Spoken in Lesson</span>
              <p id="insp-quote" class="text-xs italic text-sage-900 bg-sage-50/70 p-3 rounded-xl border border-sage-200 leading-relaxed">
                Giulio (14:24): "...we are here today because I would like to improve my fluency while speaking..."
              </p>
            </div>

            <div class="space-y-1.5 border-t border-parchment-200 pt-3">
              <span class="text-[11px] font-mono uppercase tracking-wider text-stone-400">Spanish Equivalent</span>
              <p id="insp-es" class="text-sm font-serif font-bold text-autumn-800">fluidez verbal</p>
            </div>

            <div class="pt-2 flex items-center gap-2">
              <button id="insp-audio-btn" onclick="speakWord('fluency')" class="flex-1 py-2 px-3 rounded-xl bg-sage-700 hover:bg-sage-800 text-white font-semibold text-xs flex items-center justify-center gap-2 shadow-sm transition">
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
            <p class="text-xs text-stone-500 mt-0.5">Explore 60 curated B2–C2 words, idioms, and collocations with exact timestamps, Spanish equivalents, and British audio</p>
          </div>

          <div class="flex flex-wrap items-center gap-2.5">
            <!-- Search -->
            <div class="relative min-w-[220px]">
              <i data-lucide="search" class="w-3.5 h-3.5 text-stone-400 absolute left-3 top-1/2 -translate-y-1/2"></i>
              <input id="vocab-search" oninput="renderVocabGrid()" type="text" placeholder="Search dictionary or Spanish..." class="w-full pl-8 pr-3 py-1.5 rounded-xl bg-parchment-50 border border-parchment-200 text-xs text-slatewarm-900 focus:outline-none focus:border-autumn-500" />
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
          <button onclick="setVocabCategory('emotion')" id="cat-btn-emotion" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Emotions (10)</button>
          <button onclick="setVocabCategory('cinema')" id="cat-btn-cinema" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Cinema &amp; Film (9)</button>
          <button onclick="setVocabCategory('philosophy')" id="cat-btn-philosophy" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Philosophy &amp; Morals (10)</button>
          <button onclick="setVocabCategory('language')" id="cat-btn-language" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Fluency &amp; Idioms (9)</button>
          <button onclick="setVocabCategory('culture')" id="cat-btn-culture" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Culture &amp; Sport (7)</button>
          <button onclick="setVocabCategory('culinary')" id="cat-btn-culinary" class="cat-pill px-3 py-1 rounded-xl bg-parchment-100 hover:bg-parchment-200 text-stone-700 transition">Food &amp; Gelato (6)</button>
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
          Before reviewing grammar or notes, we celebrate these 6 moments where Giulio expressed complex ideas, nuanced emotions, and rich sensory descriptions with natural English flair!
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
              <p class="text-xs text-stone-500 mt-0.5">Automated transcription tools mishear names, collective nouns, and places. Here is the forensic record of all 20 sorted fixes!</p>
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
    <!-- TAB 4: CULTURAL TOPICS & CINEMA SANCTUARY                           -->
    <!-- =================================================================== -->
    <section id="tab-panel-places" class="tab-panel hidden space-y-6">
      
      <div class="sanctuary-card rounded-3xl p-6 sm:p-8 space-y-4">
        <div class="flex items-center gap-2 border-b border-[#e6decb] pb-3">
          <i data-lucide="landmark" class="w-5 h-5 text-autumn-600"></i>
          <div>
            <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Cultural Landscapes &amp; The Cinema Sanctuary</h2>
            <p class="text-xs text-stone-500 mt-0.5">Reflections on Spanish padel culture, English architectural restorations, Hanoi indie cinema, and digital detox</p>
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
            <p class="text-xs text-stone-600">Click the card to flip between definition, spoken lesson context, and Spanish equivalent.</p>
          </div>

          <div onclick="flipFlashcard()" class="cursor-pointer sanctuary-subcard rounded-2xl p-7 min-h-[250px] flex flex-col items-center justify-center text-center space-y-3 border-2 border-[#dfd0b5] hover:border-autumn-400 transition select-none">
            <span id="fc-badge" class="px-2.5 py-0.5 rounded-full bg-autumn-100 text-autumn-800 text-[11px] font-mono">16:33 • C2 Philosophy</span>
            <h4 id="fc-front-title" class="font-serif text-3xl font-bold text-slatewarm-900">serendipity</h4>
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
          <h2 class="font-serif text-2xl font-bold text-slatewarm-900">Reflections for Lesson 02 (Next Thursday)</h2>
        </div>
        <p class="text-xs text-stone-600">
          Three gentle prompts to reflect on before our next session—including discussing Jonathan Glazer's <em>The Zone of Interest</em> and tracking the mental translation bottleneck!
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
    <p>Personalized English Study Sanctuary prepared by Louie for Giulio M. • Valencia &amp; London Breeze</p>
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
        es.textContent = '🇪🇸 ' + item.es;
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
    let leafMode = 'gentle'; // 'gentle', 'breeze', 'still'

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
      try {
        renderTranscript();
        renderVocabGrid();
        renderStrengths();
        renderPhrasing();
        renderAsrFixes();
        renderEditorialTopics();
        renderFlashcard();
        renderQuiz();
        renderReflections();
        initLeaves();
        inspectVocab('fluency');
        if (typeof lucide !== 'undefined' && lucide.createIcons) lucide.createIcons();
      } catch (err) {
        console.error('Safe initialization caught:', err);
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
