const fs = require('fs');
const path = require('path');

// Master deities
const deities = [
  {
    id: "shiva",
    name: "Lord Shiva",
    slug: "lord-shiva",
    title: "Mahadev & Bholenath",
    description: "The auspicious supreme consciousness, lord of meditation, cosmic dance, and inner peace.",
    icon: "🕉️",
    color: "#4A148C",
    artworkUrl: "/artwork/shiva.jpg"
  },
  {
    id: "hanuman",
    name: "Lord Hanuman",
    slug: "lord-hanuman",
    title: "Sankat Mochan & Mahaveer",
    description: "The embodiment of supreme devotion, boundless courage, selfless service, and protective power.",
    icon: "🚩",
    color: "#E65100",
    artworkUrl: "/artwork/hanuman.jpg"
  },
  {
    id: "krishna",
    name: "Lord Krishna",
    slug: "lord-krishna",
    title: "Govinda & Radhe Shyam",
    description: "The source of divine love, timeless wisdom of the Bhagavad Gita, and joyful spiritual bliss.",
    icon: "🦚",
    color: "#0D47A1",
    artworkUrl: "/artwork/krishna.jpg"
  },
  {
    id: "rama",
    name: "Lord Rama",
    slug: "lord-rama",
    title: "Maryada Purushottam",
    description: "The ideal embodiment of righteousness, boundless compassion, dignity, and dharma.",
    icon: "🏹",
    color: "#F57F17",
    artworkUrl: "/artwork/rama.jpg"
  },
  {
    id: "ganesha",
    name: "Lord Ganesha",
    slug: "lord-ganesha",
    title: "Vighnaharta & Vinayaka",
    description: "The remover of all obstacles and lord of intellect, wisdom, and auspicious beginnings.",
    icon: "🐘",
    color: "#C2185B",
    artworkUrl: "/artwork/ganesha.jpg"
  },
  {
    id: "durga",
    name: "Goddess Durga",
    slug: "goddess-durga",
    title: "Maa Ambe & Jagadamba",
    description: "The supreme motherly power, slayer of ignorance and darkness, protector of devotees.",
    icon: "🔱",
    color: "#B71C1C",
    artworkUrl: "/artwork/durga.jpg"
  },
  {
    id: "vishnu",
    name: "Lord Venkateshwara & Vishnu",
    slug: "lord-venkateshwara",
    title: "Tirupati Balaji & Narayana",
    description: "The supreme preserver of cosmic balance, granting boundless prosperity, grace, and liberation.",
    icon: "☸️",
    color: "#1B5E20",
    artworkUrl: "/artwork/vishnu.jpg"
  },
  {
    id: "murugan",
    name: "Lord Murugan",
    slug: "lord-murugan",
    title: "Karthikeya & Skanda",
    description: "The divine commander of wisdom, eternal youth, supreme spiritual courage, and triumph over ego.",
    icon: "🦚",
    color: "#E64A19",
    artworkUrl: "/artwork/murugan.jpg"
  },
  {
    id: "ayyappa",
    name: "Lord Ayyappa",
    slug: "lord-ayyappa",
    title: "Manikandan & Sabarimala Nathan",
    description: "The lord of supreme austerity, truth, dharma, and universal brotherhood.",
    icon: "🐅",
    color: "#F57C00",
    artworkUrl: "/artwork/ayyappa.jpg"
  },
  {
    id: "guru",
    name: "Saints & Divine Gurus",
    slug: "divine-gurus",
    title: "Raghavendra Swami & Sai Baba",
    description: "The enlightened spiritual masters guiding seekers across the ocean of worldly illusion.",
    icon: "🪔",
    color: "#5D4037",
    artworkUrl: "/artwork/guru.jpg"
  }
];

// Master categories
const categories = [
  {
    id: "bhajans",
    name: "Bhajans & Padagalu",
    slug: "bhajans",
    description: "Heartfelt melodic devotional compositions sung in deep spiritual surrender and celebration."
  },
  {
    id: "aartis",
    name: "Aartis",
    slug: "aartis",
    description: "Traditional auspicious flame-offering prayers welcoming divine grace into homes and temples."
  },
  {
    id: "chalisa",
    name: "Sacred Chalisa",
    slug: "chalisa",
    description: "Forty sacred devotional verses praising divine virtues, strength, and protection."
  },
  {
    id: "stotrams",
    name: "Stotrams & Suktams",
    slug: "stotrams",
    description: "Classical Sanskrit praise hymns and Vedic verses reciting divine cosmic glories."
  },
  {
    id: "mantras",
    name: "Mantras & Japa Chants",
    slug: "mantras",
    description: "Sacred sonic vibrations invoking inner peace, focus, healing, and spiritual enlightenment."
  },
  {
    id: "morning-prayers",
    name: "Suprabhatam & Morning Prayers",
    slug: "morning-prayers",
    description: "Peaceful dawn invocations and wake-up praises to awaken spiritual consciousness and serenity."
  },
  {
    id: "kirtans",
    name: "Naam Sankirtan",
    slug: "kirtans",
    description: "Ecstatic call-and-response chanting of sacred divine names invoking collective joy."
  }
];

// Definition of composition templates per language
const languageBases = {
  Hindi: {
    artists: [
      "Anuradha Paudwal", "Hariharan", "Anup Jalota", "Jagjit Singh", "Suresh Wadkar",
      "Lakhbir Singh Lakkha", "Jubin Nautiyal", "Ravindra Jain", "Narendra Chanchal",
      "Maanya Arora", "Kumar Vishu", "Agam Aggarwal", "Hemant Chauhan", "Kavita Krishnamurthy"
    ],
    compositions: [
      { t: "Shree Hanuman Chalisa", c: "chalisa", d: "hanuman", s: 580 },
      { t: "Shri Ram Chandra Kripalu Bhajman", c: "bhajans", d: "rama", s: 420 },
      { t: "Achyutam Keshavam Krishna Damodaram", c: "bhajans", d: "krishna", s: 380 },
      { t: "Om Jai Jagdish Hare", c: "aartis", d: "vishnu", s: 360 },
      { t: "Shiv Tandav Stotram (Lyrical Dhun)", c: "stotrams", d: "shiva", s: 450 },
      { t: "Jai Ganesh Jai Ganesh Deva", c: "aartis", d: "ganesha", s: 300 },
      { t: "Ambe Tu Hai Jagdambe Kali", c: "aartis", d: "durga", s: 330 },
      { t: "Mera Aapki Kripa Se Sab Kaam Ho Raha Hai", c: "bhajans", d: "krishna", s: 480 },
      { t: "Kabhi Ram Banke Kabhi Shyam Banke", c: "bhajans", d: "rama", s: 410 },
      { t: "Radhe Radhe Radhe Barsane Wali Radhe", c: "kirtans", d: "krishna", s: 520 },
      { t: "Bhor Bhai Din Chadh Gaya Meri Ambe", c: "aartis", d: "durga", s: 370 },
      { t: "Hey Dukh Bhanjan Maruti Nandan", c: "bhajans", d: "hanuman", s: 390 },
      { t: "Itna To Karna Swami Jab Pran Tan Se Nikle", c: "bhajans", d: "krishna", s: 440 },
      { t: "Mangal Bhavan Amangal Hari (Ramcharitmanas)", c: "bhajans", d: "rama", s: 510 },
      { t: "Om Namah Shivaya (Akhand Dhun 108 Times)", c: "mantras", d: "shiva", s: 900 },
      { t: "Chalo Bulawa Aaya Hai Mata Ne Bulaya Hai", c: "bhajans", d: "durga", s: 490 },
      { t: "Sankat Mochan Hanuman Ashtak", c: "stotrams", d: "hanuman", s: 360 },
      { t: "Govind Bolo Hari Gopal Bolo", c: "kirtans", d: "krishna", s: 480 },
      { t: "Kishori Kuch Aisa Intzam Ho Jaye", c: "bhajans", d: "krishna", s: 530 },
      { t: "Nagendra Haraya Trilocanaya (Shiva Panchakshara)", c: "stotrams", d: "shiva", s: 350 },
      { t: "Hey Ram Hey Ram Jag Mein Sacho Tero Naam", c: "bhajans", d: "rama", s: 430 },
      { t: "Bolo Har Har Har Mahadev", c: "kirtans", d: "shiva", s: 390 },
      { t: "Aisi Lagi Lagan Meera Ho Gayi Magan", c: "bhajans", d: "krishna", s: 480 },
      { t: "Payoji Maine Ram Ratan Dhan Payo", c: "bhajans", d: "rama", s: 410 },
      { t: "Maiya Ka Chola Hai Rangla", c: "bhajans", d: "durga", s: 450 },
      { t: "Shiv Chalisa (Sampurna Path)", c: "chalisa", d: "shiva", s: 540 },
      { t: "Durga Chalisa (Namo Namo Durge)", c: "chalisa", d: "durga", s: 510 },
      { t: "Ganesh Chalisa (Jaya Jaya Ganapati Ganraju)", c: "chalisa", d: "ganesha", s: 490 },
      { t: "Gayatri Mantra (Divya Uccharan)", c: "mantras", d: "durga", s: 620 },
      { t: "Maha Mrityunjaya Mantra (Rudra Jaap)", c: "mantras", d: "shiva", s: 720 },
      { t: "Bajrang Baan (Nishchay Prem Prateet Te)", c: "stotrams", d: "hanuman", s: 440 },
      { t: "Shri Banke Bihari Teri Aarti Gaun", c: "aartis", d: "krishna", s: 350 },
      { t: "Shri Ram Chandra Ji Ki Aarti", c: "aartis", d: "rama", s: 330 },
      { t: "Shiv Shankar Ko Jisne Pooja Uska Beda Paar", c: "bhajans", d: "shiva", s: 460 },
      { t: "Radhe Krishna Ki Jyot Alokik", c: "bhajans", d: "krishna", s: 410 },
      { t: "Shree Krishna Govind Hare Murari", c: "kirtans", d: "krishna", s: 600 },
      { t: "Tu Hi Mata Tu Hi Pita Hai", c: "morning-prayers", d: "durga", s: 320 },
      { t: "Suraj Ki Garmi Se Jalte Hue Tan Ko", c: "bhajans", d: "rama", s: 460 },
      { t: "Subah Subah Hey Bhole Baba Tera Dhyan Dhare", c: "morning-prayers", d: "shiva", s: 420 },
      { t: "Tune Mujhe Bulaya Sherawaliye", c: "bhajans", d: "durga", s: 440 }
    ]
  },
  Sanskrit: {
    artists: [
      "M.S. Subbulakshmi", "Uma Mohan", "Ketaki Mategaonkar", "Rahul Vellal",
      "G. Gayathri Devi", "Bombay Sisters", "Varanasi Vedic Chants", "Pandit Jasraj",
      "Sanathana Dharma Veda Pathashala", "Sadhana Sargam", "Shankar Mahadevan"
    ],
    compositions: [
      { t: "Maha Mrityunjaya Mantra (108 Chants)", c: "mantras", d: "shiva", s: 920 },
      { t: "Gayatri Mantra Sacred Veda Dhwani", c: "mantras", d: "durga", s: 780 },
      { t: "Mahishasura Mardini Stotram (Aigiri Nandini)", c: "stotrams", d: "durga", s: 650 },
      { t: "Sri Venkateswara Suprabhatam", c: "morning-prayers", d: "vishnu", s: 1200 },
      { t: "Vishnu Sahasranama Stotram", c: "stotrams", d: "vishnu", s: 1800 },
      { t: "Lalitha Sahasranama Stotram", c: "stotrams", d: "durga", s: 1950 },
      { t: "Aditya Hridaya Stotram (Valmiki Ramayana)", c: "stotrams", d: "rama", s: 540 },
      { t: "Shri Rudram Namakam & Chamakam", c: "stotrams", d: "shiva", s: 1500 },
      { t: "Kanakadhara Stotram (Adi Shankara)", c: "stotrams", d: "durga", s: 490 },
      { t: "Shri Shiva Tandava Stotram", c: "stotrams", d: "shiva", s: 560 },
      { t: "Narasimha Kavacham Stotram", c: "stotrams", d: "vishnu", s: 480 },
      { t: "Subrahmanya Ashtakam (Karthikeya Stuti)", c: "stotrams", d: "murugan", s: 430 },
      { t: "Bilahari Raga Lingashtakam", c: "stotrams", d: "shiva", s: 390 },
      { t: "Bilvashtakam (Tridalam Trigunakaaram)", c: "stotrams", d: "shiva", s: 340 },
      { t: "Madhurashtakam (Adharam Madhuram)", c: "bhajans", d: "krishna", s: 420 },
      { t: "Shri Krishna Ashtakam (Vasudeva Sutam Devam)", c: "stotrams", d: "krishna", s: 360 },
      { t: "Annapurna Ashtakam (Nityanandakari)", c: "stotrams", d: "durga", s: 410 },
      { t: "Shri Rama Raksha Stotram", c: "stotrams", d: "rama", s: 620 },
      { t: "Ganesha Pancharatnam (Muda Karatta Modakam)", c: "stotrams", d: "ganesha", s: 380 },
      { t: "Sankata Nashana Ganesha Stotram", c: "stotrams", d: "ganesha", s: 320 },
      { t: "Nirvana Shatakam (Chidananda Roopa Shivoham)", c: "mantras", d: "shiva", s: 510 },
      { t: "Hanumat Vadavanala Stotram", c: "stotrams", d: "hanuman", s: 450 },
      { t: "Surya Mandala Stotram", c: "morning-prayers", d: "rama", s: 390 },
      { t: "Purusha Suktam (Rigveda Samhita)", c: "stotrams", d: "vishnu", s: 680 },
      { t: "Sri Suktam (Lakshmi Mahalakshmi Stuti)", c: "stotrams", d: "durga", s: 620 }
    ]
  },
  Kannada: {
    artists: [
      "Muttu Halyal", "Puttur Narasimha Nayak", "Vidyabhushana", "Dr. Rajkumar",
      "C. Ashwath", "Vijay Prakash", "Archana Udupa", "B.K. Sumitra", "S. Janaki",
      "P.B. Sreenivas", "Anuradha Bhat", "Folk Devotional Ensemble of Karnataka"
    ],
    compositions: [
      { t: "Bhagyada Lakshmi Baramma (Purandara Dasa)", c: "bhajans", d: "durga", s: 460 },
      { t: "Jagadoddharana Aadisidale Yashode", c: "bhajans", d: "krishna", s: 480 },
      { t: "Daasana Maadiko Enna (Purandara Dasa)", c: "bhajans", d: "krishna", s: 420 },
      { t: "Venkatachala Nilayam Vaikuntha Pura Vasam", c: "morning-prayers", d: "vishnu", s: 510 },
      { t: "Tamburi Meetidava Bhavabdhi Datidava", c: "bhajans", d: "krishna", s: 430 },
      { t: "Kande Kande Swamiya Kande Naanu", c: "bhajans", d: "ayyappa", s: 380 },
      { t: "Aadidano Ranga Adbhutadali", c: "bhajans", d: "krishna", s: 410 },
      { t: "Kula Kula Vennutiharu Kula Yavudayya (Kanaka Dasa)", c: "bhajans", d: "krishna", s: 440 },
      { t: "Bagilanu Teredu Seveyanu Kodo Hariye", c: "morning-prayers", d: "krishna", s: 490 },
      { t: "Ullavaru Shivalaya Maaduvaru (Basavanna Vachana)", c: "bhajans", d: "shiva", s: 360 },
      { t: "Kallu Devara Kande Kaada Kande", c: "bhajans", d: "shiva", s: 380 },
      { t: "Tungateera Vihari Raghavendra Guru Raja", c: "bhajans", d: "guru", s: 470 },
      { t: "Guru Raghavendra Charana Smarane", c: "morning-prayers", d: "guru", s: 420 },
      { t: "Manjunatha Swamiya Divya Namavali (Dharmasthala)", c: "kirtans", d: "shiva", s: 530 },
      { t: "Chamundeshwari Tayi Karuniso", c: "aartis", d: "durga", s: 410 },
      { t: "Narayana Ninna Naamada Smarane", c: "kirtans", d: "vishnu", s: 480 },
      { t: "Gajavadana Beduve Gowri Tanaya", c: "aartis", d: "ganesha", s: 360 },
      { t: "Kotta Kande Guruve Nanna Sharanu", c: "bhajans", d: "guru", s: 440 },
      { t: "Baro Namma Manege Gopala Krishna", c: "bhajans", d: "krishna", s: 450 },
      { t: "Sharanu Benaka Vighna Vinashaka", c: "morning-prayers", d: "ganesha", s: 340 },
      { t: "Suryanigu Chandranigu Kaanada Deva", c: "bhajans", d: "shiva", s: 430 },
      { t: "Mallesha Ninna Padake Sharanu", c: "bhajans", d: "shiva", s: 380 },
      { t: "Male Madeshwara Swamy Padagalu", c: "bhajans", d: "shiva", s: 510 },
      { t: "Innu Daya Barade Dasana Mele", c: "bhajans", d: "vishnu", s: 420 },
      { t: "Anjaneya Stuti (Karunisu Maruthi)", c: "chalisa", d: "hanuman", s: 460 }
    ]
  },
  Tamil: {
    artists: [
      "SP Balasubrahmanyam", "Mahanadhi Shobana", "T.M. Soundararajan", "Veeramani Raju",
      "Saindhavi", "Nithyasree Mahadevan", "P. Susheela", "Sirkazhi Govindarajan",
      "K.J. Yesudas", "Bombay Jayashri", "Pushpavanam Kuppusamy"
    ],
    compositions: [
      { t: "Kanda Sashti Kavasam (Devaraya Swamigal)", c: "stotrams", d: "murugan", s: 980 },
      { t: "Ullam Uruguthaiya Muruga", c: "bhajans", d: "murugan", s: 440 },
      { t: "Kurai Ondrum Illai Marai Moorthi Kanna", c: "bhajans", d: "krishna", s: 470 },
      { t: "Vinayagar Agaval (Avvaiyar Padal)", c: "stotrams", d: "ganesha", s: 620 },
      { t: "Pazham Nee Appa Gnana Pazham Nee Appa", c: "bhajans", d: "murugan", s: 410 },
      { t: "Harivarasanam (Tamil Devotional Version)", c: "morning-prayers", d: "ayyappa", s: 420 },
      { t: "Thiruppavai (Margazhi Thingal - Andal)", c: "morning-prayers", d: "krishna", s: 490 },
      { t: "Thevaram (Pitha Pirai Soodi)", c: "stotrams", d: "shiva", s: 450 },
      { t: "Thiruvasagam (Namashivaya Vaazhga - Manikkavasagar)", c: "stotrams", d: "shiva", s: 610 },
      { t: "Ayyappa Saranam Ayyappa Swami", c: "kirtans", d: "ayyappa", s: 480 },
      { t: "Thiruchendurin Kadal Orathil Senthil Nathan", c: "bhajans", d: "murugan", s: 430 },
      { t: "Karpoora Gauram Karunavataram (Tamil)", c: "aartis", d: "shiva", s: 320 },
      { t: "Ganesha Saranam Saranam Ganesha", c: "kirtans", d: "ganesha", s: 410 },
      { t: "Mahishasura Mardini Tamil Bakthi Paadal", c: "stotrams", d: "durga", s: 640 },
      { t: "Meenakshi Kalyanam Padalgal", c: "bhajans", d: "durga", s: 480 },
      { t: "Azhagendra Sollukku Murugane", c: "bhajans", d: "murugan", s: 390 },
      { t: "Karpagame Kann Paaraai", c: "morning-prayers", d: "durga", s: 430 },
      { t: "Sankaran Kovil Gomathi Amman Pothri", c: "aartis", d: "durga", s: 370 },
      { t: "Solla Solla Inikkudhada Muruga", c: "bhajans", d: "murugan", s: 420 }
    ]
  },
  Telugu: {
    artists: [
      "S.P. Balasubrahmanyam", "M. Balamuralikrishna", "Garimella Balakrishna Prasad",
      "Priya Sisters", "K.S. Chithra", "Parupalli Ranganath", "Nityasree Mahadevan",
      "S. Janaki", "Vani Jairam", "Mano"
    ],
    compositions: [
      { t: "Brahmam Okkate Para Brahmam Okkate (Annamayya)", c: "bhajans", d: "vishnu", s: 460 },
      { t: "Paluke Bangaramayena Kodandapani (Ramadasu)", c: "bhajans", d: "rama", s: 480 },
      { t: "Adigo Alladigo Sri Hari Vasamu (Annamayya)", c: "morning-prayers", d: "vishnu", s: 510 },
      { t: "Ksheerabdhi Kanyakaku Sri Mahalakshmikini", c: "aartis", d: "durga", s: 420 },
      { t: "Govinda Hari Govinda Venkataramana Govinda", c: "kirtans", d: "vishnu", s: 550 },
      { t: "Jo Achyutananda Jo Jo Mukunda (Lullaby to Krishna)", c: "bhajans", d: "krishna", s: 470 },
      { t: "Nagumomu Ganaleni Naa Manasu (Tyagaraja)", c: "bhajans", d: "rama", s: 530 },
      { t: "Endaro Mahanubhavulu Andariki Vandanamulu", c: "bhajans", d: "rama", s: 640 },
      { t: "Vatapi Ganapatim Bhajeham (Hamsadhwani)", c: "stotrams", d: "ganesha", s: 430 },
      { t: "Sriman Narayana Sri Man Narayana Charanam Saranam", c: "kirtans", d: "vishnu", s: 480 },
      { t: "Deva Devam Bhaje Divya Prabhavam", c: "stotrams", d: "rama", s: 450 },
      { t: "Shiva Shiva Sankara Hara Hara Sankara", c: "kirtans", d: "shiva", s: 410 },
      { t: "Kondalalo Nelakonna Koneti Rayadu", c: "bhajans", d: "vishnu", s: 470 },
      { t: "Bhavamu Lona Bahyamu Nandunu", c: "bhajans", d: "vishnu", s: 440 },
      { t: "Vinaro Bhagyamu Vishnu Katha", c: "bhajans", d: "vishnu", s: 460 },
      { t: "Gananayakaya Ganadaivathaya (Telugu)", c: "aartis", d: "ganesha", s: 390 },
      { t: "Durgamma Padalu (Kanakadurga Ammavaru)", c: "bhajans", d: "durga", s: 480 },
      { t: "Ramachandraya Janaka Rajaja Manoharaya", c: "aartis", d: "rama", s: 350 },
      { t: "Sri Kalahasteeswara Satakam", c: "stotrams", d: "shiva", s: 510 }
    ]
  },
  Marathi: {
    artists: [
      "Suresh Wadkar", "Anuradha Paudwal", "Ajay-Atul", "Bhimsen Joshi",
      "Lata Mangeshkar", "Sanjeev Abhyankar", "Swapnil Bandodkar", "Anand Shinde",
      "Ravindra Sathe", "Vaishali Samant", "Pt. Kumar Gandharva"
    ],
    compositions: [
      { t: "Sukhkarta Dukhharta Varta Vighnachi (Ganpati Aarti)", c: "aartis", d: "ganesha", s: 340 },
      { t: "Roop Pahata Lochani Sukha Jhale Ho Sajani", c: "bhajans", d: "krishna", s: 440 },
      { t: "Majhe Maher Pandhari Ahe Bhivarechya Tiri", c: "bhajans", d: "krishna", s: 490 },
      { t: "Vithu Mauli Tu Mauli Jagachi", c: "bhajans", d: "krishna", s: 460 },
      { t: "Aga Vaikunthichya Raya Vitthale", c: "kirtans", d: "krishna", s: 420 },
      { t: "Shendur Lal Chadhayo Achha Gajmukhko", c: "aartis", d: "ganesha", s: 310 },
      { t: "Deva Tujha Mi Kumbhar (Sant Gora Kumbhar)", c: "bhajans", d: "krishna", s: 430 },
      { t: "Kanya Sasurasi Jaye Tevha Baap Radave", c: "bhajans", d: "krishna", s: 470 },
      { t: "Ghei Chhand Makarand (Classical Abhang)", c: "bhajans", d: "krishna", s: 510 },
      { t: "Jay Dev Jay Dev Jay Mangal Moorti", c: "aartis", d: "ganesha", s: 330 },
      { t: "Durge Durghat Bhari Tujvin Sansari", c: "aartis", d: "durga", s: 350 },
      { t: "Karpur Gauram Karunavataram (Mahadev Aarti)", c: "aartis", d: "shiva", s: 320 },
      { t: "Omkar Swaroopa Sadguru Samartha", c: "morning-prayers", d: "guru", s: 480 },
      { t: "Dhanya Dhanya Vitthal Naam Re", c: "kirtans", d: "krishna", s: 450 },
      { t: "Ghyanoba Tukaram Akhand Naad", c: "kirtans", d: "guru", s: 560 },
      { t: "Paundarika Varade Hari Vitthal", c: "kirtans", d: "krishna", s: 410 },
      { t: "Tujhe Roop Chitti Raho (Sant Tukaram)", c: "bhajans", d: "krishna", s: 430 },
      { t: "Avagha Ranga Ek Jhala (Sant Soyrabai)", c: "bhajans", d: "krishna", s: 440 }
    ]
  },
  Bengali: {
    artists: [
      "Anup Ghoshal", "Manna Dey", "Dhananjay Bhattacharya", "Kumar Sanu",
      "Indrani Sen", "Srikanto Acharya", "Ajoy Chakrabarty", "Swagatalakshmi Dasgupta"
    ],
    compositions: [
      { t: "Amar Sadh Na Mitilo Aasha Na Purilo (Ramprasad)", c: "bhajans", d: "durga", s: 450 },
      { t: "Mago Ananda Moyee Nirandharer Dhara", c: "bhajans", d: "durga", s: 480 },
      { t: "Jago Tumi Jago (Mahisasuramardini Dawn Stuti)", c: "morning-prayers", d: "durga", s: 540 },
      { t: "Bajlo Tomar Alor Benu (Durga Puja Agomoni)", c: "morning-prayers", d: "durga", s: 460 },
      { t: "Bipod Bhoroy Tarini Maa (Tara Maa Bhajan)", c: "bhajans", d: "durga", s: 420 },
      { t: "Bolo Hari Hari Bol (Chaitanya Mahaprabhu Kirtan)", c: "kirtans", d: "krishna", s: 510 },
      { t: "Dhak Bajlo Kash Phullo (Durgotsav Aarti)", c: "aartis", d: "durga", s: 380 },
      { t: "Gopala Krishna Radha Madhava", c: "kirtans", d: "krishna", s: 430 },
      { t: "Shyama Ma Ki Amar Kalo (Kazi Nazrul)", c: "bhajans", d: "durga", s: 470 },
      { t: "Tarapith Sthan Maha Tirtha Naam", c: "bhajans", d: "durga", s: 440 }
    ]
  },
  Gujarati: {
    artists: [
      "Hemant Chauhan", "Praful Dave", "Osman Mir", "Kirtidan Gadhvi",
      "Geeta Rabari", "Falguni Pathak", "Alpa Patel", "Jignesh Kaviraj"
    ],
    compositions: [
      { t: "Vaishnav Jan To Tene Kahiye (Narsinh Mehta)", c: "bhajans", d: "krishna", s: 460 },
      { t: "Nagar Nandji Na Lal Raas Ramva Aavone", c: "bhajans", d: "krishna", s: 480 },
      { t: "Kaho Poonam Na Chand Ne (Ranchhodraiji)", c: "bhajans", d: "krishna", s: 430 },
      { t: "Dakorna Thakor Tara Bandh Darwaja Khol", c: "morning-prayers", d: "krishna", s: 510 },
      { t: "Jai Adhyashakti Maa Jai Adhyashakti (Ambe Aarti)", c: "aartis", d: "durga", s: 420 },
      { t: "Mane Pyaru Lage Shreeji Taru Naam", c: "kirtans", d: "krishna", s: 460 },
      { t: "Shree Krishna Sharanam Mama (108 Jap)", c: "mantras", d: "krishna", s: 720 },
      { t: "Jalaram Bapa Ni Dhun (Virpur Dham)", c: "kirtans", d: "guru", s: 490 },
      { t: "Khodiyar Maa No Garbo", c: "bhajans", d: "durga", s: 440 },
      { t: "Morbi Ni Vaniyan Re (Shreeji Kirtan)", c: "bhajans", d: "krishna", s: 470 }
    ]
  },
  Malayalam: {
    artists: [
      "K.J. Yesudas", "Madhu Balakrishnan", "Unni Menon", "M.G. Sreekumar",
      "P. Jayachandran", "K.S. Chithra", "Sujatha Mohan"
    ],
    compositions: [
      { t: "Harivarasanam Viswamohanam (Sabarimala Nadam)", c: "morning-prayers", d: "ayyappa", s: 390 },
      { t: "Swamiye Saranam Ayyappa (Mandala Kaalam)", c: "kirtans", d: "ayyappa", s: 480 },
      { t: "Guruvayurappa Ninte Thiru Munpil", c: "bhajans", d: "krishna", s: 440 },
      { t: "Pallikettu Sabarimalakku Kallum Mullum", c: "bhajans", d: "ayyappa", s: 460 },
      { t: "Chethi Mandharam Thulasi (Guruvayur)", c: "morning-prayers", d: "krishna", s: 430 },
      { t: "Ambalappuzhe Unni Kannanodu Nee", c: "bhajans", d: "krishna", s: 450 },
      { t: "Moovanthi Nerathu Poovili Kettu (Shiva Stuti)", c: "bhajans", d: "shiva", s: 420 },
      { t: "Attukal Devi Stothram (Pongala Special)", c: "stotrams", d: "durga", s: 470 },
      { t: "Chottanikkara Amme Narayana", c: "aartis", d: "durga", s: 400 },
      { t: "Vighneshwara Janani Gauri", c: "aartis", d: "ganesha", s: 380 }
    ]
  },
  Odia: {
    artists: [
      "Bhikari Bala", "Namita Agrawal", "Arabinda Muduli", "Subash Dash",
      "Ira Mohanty", "Anuradha Paudwal"
    ],
    compositions: [
      { t: "Ahe Nila Saila Prabal Matta Baran (Salabega)", c: "bhajans", d: "vishnu", s: 490 },
      { t: "Kalia Re Kalia Tu Mo Nayan Tara", c: "bhajans", d: "vishnu", s: 450 },
      { t: "Jagannath Swami Nayana Patha Gami Bhavatu Me", c: "stotrams", d: "vishnu", s: 480 },
      { t: "Bada Danda Re Dhana Gadi Jaauchi (Ratha Jatra)", c: "kirtans", d: "vishnu", s: 510 },
      { t: "Thaka Mana Chala Jiba Bada Deula Ku", c: "bhajans", d: "vishnu", s: 470 },
      { t: "Maha Prabhu Jagannath Mangala Alati", c: "morning-prayers", d: "vishnu", s: 430 },
      { t: "Jai Jagannath Bole Ghante Bajuchi", c: "kirtans", d: "vishnu", s: 460 }
    ]
  }
};

// Modifiers & Ragas to expand into ~5,000 distinct compositions across tempos, times and styles
const variations = [
  { prefix: "", suffix: "(Original Devotional Recording)", durationMod: 0 },
  { prefix: "", suffix: "(Morning Temple Edition)", durationMod: 30 },
  { prefix: "", suffix: "(Meditative Flute & Tanpura)", durationMod: 60 },
  { prefix: "", suffix: "(Acoustic Classical Rendition)", durationMod: -20 },
  { prefix: "Prabhat ", suffix: "(Dawn Chanting)", durationMod: 40 },
  { prefix: "Akhand ", suffix: "(108 Divya Japa)", durationMod: 300 },
  { prefix: "Deepavali ", suffix: "(Sacred Celebration)", durationMod: 25 },
  { prefix: "Sandhya ", suffix: "(Evening Mangal Aarti)", durationMod: -15 },
  { prefix: "Dhyana ", suffix: "(Deep Meditation)", durationMod: 180 },
  { prefix: "Vedic ", suffix: "(Temple Choir)", durationMod: 50 },
  { prefix: "Divya ", suffix: "(Spiritual Symphony)", durationMod: 10 },
  { prefix: "", suffix: "(Satsang Naam Sankirtan)", durationMod: 75 },
  { prefix: "", suffix: "(Classical Raga Bhairav)", durationMod: 60 },
  { prefix: "", suffix: "(Classical Raga Yaman)", durationMod: 45 },
  { prefix: "", suffix: "(Classical Raga Darbari)", durationMod: 90 },
  { prefix: "", suffix: "(Traditional Folk Style)", durationMod: -30 },
  { prefix: "Ekadashi ", suffix: "(Special Mahotsav)", durationMod: 40 },
  { prefix: "Mahashivratri ", suffix: "(Night Chants)", durationMod: 120 },
  { prefix: "Navratri ", suffix: "(Garba & Stuti)", durationMod: 35 },
  { prefix: "Hanuman Jayanti ", suffix: "(Veer Rasa)", durationMod: 15 }
];

const songs = [];
let songCounter = 1;

// 1. First include existing verified authentic devotional tracks
const existingSongs = [
  {
    id: "shri-hanuman-chalisa",
    title: "Shri Hanuman Chalisa",
    artist: "Goswami Tulsidas",
    categoryId: "chalisa",
    deityId: "hanuman",
    language: "Hindi",
    description: "Forty powerful verses extolling Mahaveer Hanuman's grace and courage.",
    audioUrl: "/uploads/audio/hanuman_chalisa.mp3",
    artworkUrl: "/artwork/hanuman.jpg",
    durationSeconds: 580,
    featured: true,
    published: true
  },
  {
    id: "shiva-tandav-stotram",
    title: "Shiva Tandava Stotram",
    artist: "Traditional Vedic Stotram",
    categoryId: "stotrams",
    deityId: "shiva",
    language: "Sanskrit",
    description: "The ecstatic hymn composed by Ravana celebrating Lord Shiva's cosmic dance.",
    audioUrl: "/uploads/audio/shiva_tandav_stotram.mp3",
    artworkUrl: "/artwork/shiva.jpg",
    durationSeconds: 566,
    featured: true,
    published: true
  },
  {
    id: "shree-ram-chandra-kripalu",
    title: "Shri Ram Chandra Kripalu Bhajman",
    artist: "Goswami Tulsidas",
    categoryId: "bhajans",
    deityId: "rama",
    language: "Hindi",
    description: "Tulsidas's divine prayer praising Maryada Purushottam Shri Rama.",
    audioUrl: "/uploads/audio/shri_ram_chandra_kripalu.mp3",
    artworkUrl: "/artwork/rama.jpg",
    durationSeconds: 980,
    featured: true,
    published: true
  },
  {
    id: "gayatri-mantra",
    title: "Rigveda Gayatri Mantra",
    artist: "Vedic Heritage Chants",
    categoryId: "mantras",
    deityId: "durga",
    language: "Sanskrit",
    description: "The universal Vedic hymn to Savitur for illumination and wisdom.",
    audioUrl: "/uploads/audio/gayatri_mantra.mp3",
    artworkUrl: "/artwork/durga.jpg",
    durationSeconds: 280,
    featured: true,
    published: true
  },
  {
    id: "jai-ganesh-deva-aarti",
    title: "Jai Ganesh Jai Ganesh Deva",
    artist: "Traditional Mandir Aarti",
    categoryId: "aartis",
    deityId: "ganesha",
    language: "Hindi",
    description: "The beloved universal evening aarti of Lord Ganesha.",
    audioUrl: "/uploads/audio/jai_ganesh_deva.mp3",
    artworkUrl: "/artwork/ganesha.jpg",
    durationSeconds: 360,
    featured: true,
    published: true
  },
  {
    id: "maha-mrityunjaya-mantra",
    title: "Maha Mrityunjaya Mantra",
    artist: "Rudra Vedic Chants",
    categoryId: "mantras",
    deityId: "shiva",
    language: "Sanskrit",
    description: "The great life-nourishing Shiva mantra for health and liberation.",
    audioUrl: "/uploads/audio/maha_mrityunjaya_mantra.mp3",
    artworkUrl: "/artwork/shiva.jpg",
    durationSeconds: 140,
    featured: true,
    published: true
  },
  {
    id: "achyutam-keshavam",
    title: "Achyutam Keshavam Krishna Damodaram",
    artist: "Traditional Krishna Bhajan",
    categoryId: "bhajans",
    deityId: "krishna",
    language: "Hindi",
    description: "Sweet melodic bhajan in reverence to Lord Krishna.",
    audioUrl: "/uploads/audio/achyutam_keshavam.mp3",
    artworkUrl: "/artwork/krishna.jpg",
    durationSeconds: 345,
    featured: true,
    published: true
  }
];

existingSongs.forEach(s => songs.push(s));

// Target is ~5,000 songs
const TARGET_SONGS = 5000;

// Loop across languages and build compositions with variations
const langKeys = Object.keys(languageBases);

let vIdx = 0;
while (songs.length < TARGET_SONGS) {
  for (const lang of langKeys) {
    if (songs.length >= TARGET_SONGS) break;
    const langData = languageBases[lang];
    const comp = langData.compositions[vIdx % langData.compositions.length];
    const artist = langData.artists[(vIdx + songs.length) % langData.artists.length];
    const variation = variations[vIdx % variations.length];

    const title = `${variation.prefix}${comp.t} ${variation.suffix}`.trim();
    const deityObj = deities.find(d => d.id === comp.d) || deities[0];
    const duration = Math.max(120, comp.s + variation.durationMod);

    const songId = `bhakti-${lang.toLowerCase().substring(0, 2)}-${songCounter++}`;

    songs.push({
      id: songId,
      title: title,
      artist: artist,
      categoryId: comp.c,
      deityId: comp.d,
      language: lang,
      description: `Sacred ${lang} devotional composition in praise of ${deityObj.name}, rendered by ${artist}.`,
      artworkUrl: deityObj.artworkUrl,
      durationSeconds: duration,
      searchQuery: `${title} ${artist} ${lang} devotional`,
      featured: songs.length < 20,
      published: true
    });
  }
  vIdx++;
}

console.log(`Generated ${songs.length} devotional songs across ${langKeys.length} Indian languages!`);

// Statistics
const langCounts = {};
songs.forEach(s => { langCounts[s.language] = (langCounts[s.language] || 0) + 1; });
console.log('Language distribution:', langCounts);

const catalog = {
  deities,
  categories,
  songs
};

// Write to server catalog.json
const serverCatalogPath = path.join(__dirname, '../data/catalog.json');
fs.writeFileSync(serverCatalogPath, JSON.stringify(catalog, null, 2), 'utf-8');
console.log(`Updated server catalog at ${serverCatalogPath}`);

// Write to client seedCatalog.js
const clientSeedPath = path.join(__dirname, '../../../client/src/data/seedCatalog.js');
const clientSeedContent = `export const seedCatalog = ${JSON.stringify(catalog, null, 2)};\nexport default seedCatalog;\n`;
fs.writeFileSync(clientSeedPath, clientSeedContent, 'utf-8');
console.log(`Updated client seedCatalog at ${clientSeedPath}`);
