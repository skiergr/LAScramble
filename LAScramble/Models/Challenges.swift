import Foundation

import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station }

    let title: String
    let description: String
    let station: String
    let line: MetroLine?
    let canFail: Bool?
}



let sampleChallenges: [GameChallenge] = [

    GameChallenge(title: "Become a Legislature", description: "Become a Legislature: Enter city hall, write down a proposition for law a law and get 10 signatures supporting it. (you have 20 minutes to complete this)", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Wait...that's art?!? Take a picture of some \"art\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", description: "Wait...that's art?!? Take a picture of some \"art\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Predict Market Flow at Grand Central Market", description: "Predict Market Flow at Grand Central Market: Select any market stall and make a prediction about how many customers it will get in the next ten minutes. A customer is defined as any person who spends money at the stall. If your prediction is more than 40% off, this challenge is failed. If no one visits the stall in the 10 minutes you lose automatically.", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Mariachi Magic", description: "Mariachi Magic: Go to Olvera Street and dance to some magical mariachi music. If there is no music playing, you must create the music yourself", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Heaven's Ascension", description: "Heaven's Ascension: Race your teammate up the angels flight railway (if alone just ride it)", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Criticize the Most Beautiful Building", description: "Criticize the Most Beautiful Building: Go to the Bradbury Building and find 3 critiques of its architecture", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "High-School English Major", description: "High-School English Major: Find a book taught at Harvard-Westlake in the LA Central Library", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "The Last Bookstore", description: "The Last Bookstore: Go to the tunnel of books in the Last Bookstore and create your own miniture arch of books", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Recreate the Banksy", description: "Recreate the Banksy: Go to the Banksy Artwork at 9th and broadway and make human-statue version of the art. The painting may be on paper or via an online art creation platform.", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Check out a book from the LA Public Library", description: "Check out a book from the LA Public Library", station: "7th St/Metro Ctr", line: nil, canFail: false),
    GameChallenge(title: "X Marks the Spot", description: "X Marks the Spot: Find a geocache", station: "7th St/Metro Ctr", line: nil, canFail: false),
    GameChallenge(title: "Act out a scene from interstellar in the bonaventure hotel lobby", description: "Act out a scene from interstellar in the bonaventure hotel lobby", station: "7th St/Metro Ctr", line: nil, canFail: false),
    GameChallenge(title: "Soaked", description: "Soaked: fully submerge a team member's hand in Mararthur Park Lake", station: "Westlake/MacArthur Park", line: nil, canFail: false),
    GameChallenge(title: "Track Star", description: "Track Star: Loop (preferably in a faster than walking pace) around the entire Macarthur Park lake perimeter", station: "Westlake/MacArthur Park", line: nil, canFail: false),
    GameChallenge(title: "Scholars of Douglas Macarthur", description: "Scholars of Douglas Macarthur: Have a 1 minute conversation exclusively about the great General Douglas MacArthur with a stranger on the street (If Grady's group Grady must do it).", station: "Westlake/MacArthur Park", line: nil, canFail: false),
    GameChallenge(title: "Steph Curry", description: "Steph Curry: Shoot a 3 pointer (hint go to lafeyette recreation center). If no basketball available or to ask for then recreate the Michael Jordan logo.", station: "Wilshire/Vermont", line: nil, canFail: false),
    GameChallenge(title: "Attempt to sell something at a local pawn shop", description: "Attempt to sell something at a local pawn shop", station: "Vermont/Beverly", line: nil, canFail: false),
    GameChallenge(title: "Ready to be a Laker", description: "Ready to be a Laker: Challenge a stranger to a 1v1 basketball game at Madison Avenue Park", station: "Vermont/Santa Monica", line: nil, canFail: false),
    GameChallenge(title: "I Swear its Worth It", description: "I Swear its Worth It: Find an item at Erewhon worth 3x more expensive than the same item at a grocery store of your choice.", station: "Vermont/Santa Monica", line: nil, canFail: false),
    GameChallenge(title: "Religion of the Stars", description: "Religion of the Stars: Go to the Church of Scientology and ask to convert?", station: "Vermont/Sunset", line: nil, canFail: false),
    GameChallenge(title: "Leave a handwritten letter at your local Congressman's office.", description: "Leave a handwritten letter at your local Congressman's office.", station: "Hollywood/Western", line: nil, canFail: false),
    GameChallenge(title: "New And Improved Hollywood Sign (Near Hollywood Sign)", description: "New And Improved Hollywood Sign (Near Hollywood Sign): Make a sign that is an advertisement for Hollywood. Then find someone that does not live in LA and give them a compelling argument for why they should move to LA", station: "Hollywood/Western", line: nil, canFail: false),
    GameChallenge(title: "Become a Talkshow Host", description: "Become a Talkshow Host: Create a Jimmy Kimmel-style interview with someone on the Hollywood walk of fame", station: "Hollywood/Vine", line: nil, canFail: false),
    GameChallenge(title: "It Isn't Easy Being Green", description: "It Isn't Easy Being Green: Find Kermit the Frog's Star on the Hollywood Walk of Fame", station: "Hollywood/Highland", line: nil, canFail: false),
    GameChallenge(title: "Find someone trying to break out into an acting career", description: "Find someone trying to break out into an acting career", station: "Hollywood/Highland", line: nil, canFail: false),
    GameChallenge(title: "Your a Wizard, Harry", description: "Your a Wizard, Harry: Recreate a scene in Harry Potter with Hogwarts in the background. (If deemed impossible, curse Universal Studios with a curse from Harry Potter)", station: "Universal City/Studio Ciy", line: nil, canFail: false),
    GameChallenge(title: "NOHO Art district", description: "NOHO Art district:  Find a piece of art in NOHO that has an article written about it online.", station: "North Hollywood", line: nil, canFail: false),
    GameChallenge(title: "Diplomatic Discovery", description: "Diplomatic Discovery: Visit a foreign countries consulate.", station: "Wilshire/Normandie", line: nil, canFail: false),
    GameChallenge(title: "Become Mr. Varney", description: "Become Mr. Varney: Find a K-Pop store and film a 15 second dance to any k-pop song.", station: "Wilshire/Normandie", line: nil, canFail: false),
    GameChallenge(title: "Fermentation Frenzy", description: "Fermentation Frenzy: Find kimchi in a korean grocery store.", station: "Wilshire/Western", line: nil, canFail: false),
    GameChallenge(title: "Amsterdam of Southern California", description: "Amsterdam of Southern California: Ride Metro Bikes between Metro stops", station: "Wilshire/Western", line: nil, canFail: false),
    GameChallenge(title: "The Home of Transit-Oriented Development", description: "The Home of Transit-Oriented Development: Take a picture that includes all modes of public transit offered in Culver City: train, bike, and bus.", station: "Culver City", line: nil, canFail: false),
    GameChallenge(title: "Party Time", description: "Party Time: Find the warehouse from the 2024 Harvard-Westlake Prom (5216 W Jefferson Blvd) and dance to some prom music (music is of the player's choice)", station: "Expo/La Brea", line: nil, canFail: false),
    GameChallenge(title: "Gladiator of LA", description: "Gladiator of LA: With the LA Memorial Coliseum in the background, record a video of your team \"fighting\" a gladiator fight", station: "Expo/Vermont", line: nil, canFail: false),
    GameChallenge(title: "Find a USC student on financial aid or one with legacy", description: "Find a USC student on financial aid or one with legacy", station: "Expo/Vermont", line: nil, canFail: false),
    GameChallenge(title: "Balls", description: "Balls: catch at least ten balls in the ball-glove-contraption catcher thingy in the outdoor Ecosystems exhibit of the Science Center", station: "Expo Park/USC", line: nil, canFail: false),
    GameChallenge(title: "Get a university branded pen", description: "Get a university branded pen", station: "Jefferson/USC", line: nil, canFail: false),
    GameChallenge(title: "Become the Los Angeles Aquaduct", description: "Become the Los Angeles Aquaduct: Transfer water from one water fountain to another", station: "Jefferson/USC", line: nil, canFail: false),
    GameChallenge(title: "The Next Convention", description: "The Next Convention: Go to the LA Convention Center and find out what the next upcoming convention is. You may not use google, you may only look around the Convention Center.", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "What a Dump", description: "What a Dump: Use a restroom of a hotel that costs more that $500 that night", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Futuristic City", description: "Futuristic City: Find someone that owns crypto currency in front of Crypto.com Arena", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Professional Athlete", description: "Professional Athlete: Deliver a 30 second \"post-game interview\" in front of crypto.com arena describing how you feel about your team's progress", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Runnin' up that hill", description: "Runnin' up that hill: run up the Bunker Hill steps", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "Cultured City", description: "Cultured City: In front of the Walt Disney Concert Hall, choose a classical music piece to play a recording of and find someone that can recognize the composer", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "MOCA vs The Broad", description: "MOCA vs The Broad: Go to either MOCA or the Broad and ask an employee to give you 3 reasons why their modern art museum is better than the other", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "Go to an unknown museum", description: "Go to an unknown museum: Spend at least 15 minutes inside a museum with fewer than 50 Google reviews.", station: "Historic Broadway", line: nil, canFail: false),
    GameChallenge(title: "Sky High Adventure", description: "Sky High Adventure: Reach the 20th floor or higher in any building", station: "Historic Broadway", line: nil, canFail: false),
    GameChallenge(title: "Fight for Your Honor", description: "Fight for Your Honor: In Little Tokyo, video two team members having a katana sword fight (Katana's can be aquired from the area near the Japanese Village Plaza)", station: "Little Tokyo/Arts District", line: nil, canFail: false),
    GameChallenge(title: "Worshipping the Buddha", description: "Worshipping the Buddha: Go to the Higashi Honganji Temple and receite a prayer in Japanese", station: "Little Tokyo/Arts District", line: nil, canFail: false),
    GameChallenge(title: "American Public Transportation", description: "American Public Transportation: Spot a freight rail train", station: "Little Tokyo/Arts District", line: nil, canFail: false),
    GameChallenge(title: "Find a student or employee from LATTC", description: "Find a student or employee from LATTC", station: "Grand/LATTC", line: nil, canFail: false),
    GameChallenge(title: "Honor the Buddha", description: "Honor the Buddha: Go to the Thien Hau Temple and ask someone the significance of Mazu", station: "Chinatown", line: nil, canFail: false),
    GameChallenge(title: "Ooo that's strange", description: "Ooo that's strange: Go to a Chinese market, purchase, and consume, something that is quite strange (Must text in group chat for the group to confirm that it is strange enough)", station: "Chinatown", line: nil, canFail: false),
    GameChallenge(title: "Old Car Near the Oldest Freeway in America", description: "Old Car Near the Oldest Freeway in America: Find a car with a license plate starting with the number 4 or below (Hint: there's a park near the station where you can see cars drive on the Arroyo-Seco Freeway", station: "Heritage Square/Arroyo", line: nil, canFail: false),
    GameChallenge(title: "Calm", description: "Calm: meditate for at least 10 minutes at Augustus Hawkins Nature Park", station: "Southwest Museum", line: nil, canFail: false),
    GameChallenge(title: "Purchase an item from the robatic arm shop. If hats are available, you must purchase a hat for Eric or Grady.", description: "Purchase an item from the robatic arm shop. If hats are available, you must purchase a hat for Eric or Grady.", station: "LAX/Metro Transit Center", line: nil, canFail: false),
    GameChallenge(title: "Plane Spotting", description: "Plane Spotting: Photograph three planes landing from three different countries (not including the US).", station: "Aviation/Century", line: nil, canFail: false),
    GameChallenge(title: "Get from the green to silver line platforms at harbor freeway in less than 1 minute. You must get from directly outside the metro car doors to directly infron of the bus doors.", description: "Get from the green to silver line platforms at harbor freeway in less than 1 minute. You must get from directly outside the metro car doors to directly infron of the bus doors.", station: "Harbor Fwy", line: nil, canFail: false),
    GameChallenge(title: "Recite the 14 names of Elon Musks (known) children from memory while standing in front of the SpaceX rocket. You have infintie attempts and may practice as much as possible, but cannot complete the challenge until you recite all of them from memory.", description: "Recite the 14 names of Elon Musks (known) children from memory while standing in front of the SpaceX rocket. You have infintie attempts and may practice as much as possible, but cannot complete the challenge until you recite all of them from memory.", station: "Crenshaw", line: nil, canFail: false),
    GameChallenge(title: "Elon Musk's Children", description: "Recite the 14 names of Elon Musks (known) children from memory while standing in front of the SpaceX rocket. You have infintie attempts and may practice as much as possible, but cannot complete the challenge until you recite all of them from memory.", station: "Crenshaw", line: nil, canFail: false),
    GameChallenge(title: "Get Jiggy With It", description: "Get a stranger to teach you a dance move.", station: "La Cienega/Jefferson", line: nil, canFail: false),
    GameChallenge(title: "Religious Diversity", description: "Across from you sits the West Angeles Church of God, a Pentecostal Church. The Pentecostals believe strongly in the importance of spiritual gifts like speaking in tongues. Los Angeles is a city of great linguistic diversity. As a team say one word in 15 different languages (they do not need to be the same word).", station: "Expo/Crenshaw", line: nil, canFail: false),
    GameChallenge(title: "Gladiator of LA", description: "With the LA Memorial Coliseum in the background, record a video of your team fighting a gladiator fight", station: "Expo/Vermont", line: nil, canFail: false),
    GameChallenge(title: "True Trojan v.s. Unexpected Trojan", description: "Find a USC student with legacy connection or find the rare trojan on on financial aid or one with legacy", station: "Expo/Vermont", line: nil, canFail: false),
    GameChallenge(title: "A Unique College Experience", description: "Los Angeles Trade-Technical College offers an education that is vastly different from a traditional university. Find 3 things on LATTC's campus that you wouldn't see at a traditional 4-year institution (unique departments, student clubs, facilities, etc)", station: "LATTC/Ortho Institute", line: nil, canFail: false),
    GameChallenge(title: "Bridge Troll", description: "Stand on the first street bridge and get a stranger to answer a riddle.", station: "Pico/Aliso", line: nil, canFail: false),
    GameChallenge(title: "Mariachi or Nah?", description: "Approach someone near Mariachi Plaza and confidently ask what instrument they play in the band. If they’re not in one, apologize and offer to be their manager anyway.", station: "Mariachi Plaza", line: nil, canFail: false),
    GameChallenge(title: "Getting Involved in Local Politics", description: "Welcome to Downtown Inglewood! Local politics is an integral piece of our democracy. Embrace this spirit! With the city hall in sight, write a petition and get 5 signatories", station: "Downtown Inglewood", line: nil, canFail: false),
    GameChallenge(title: "OG Taco", description: "Order the OG Taco at the Original Taco Pete", station: "Hyde Park", line: nil, canFail: false),


    
    
    
    
    
    
    
    
    GameChallenge(title: "Get a car to honk using a sign", description: "Get a car to honk using a sign", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Climb a Tree", description: "Climb a Tree: Climb up a tree at least 3 feet off the ground.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Are we that stupid?", description: "Are we that stupid?: show a blank map with borders to pedestrians and find someone that can correctly identify 10 US states", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Find someone that was not born in Los Angeles and ask them why they choose to live in LA", description: "Find someone that was not born in Los Angeles and ask them why they choose to live in LA", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Bella Ciao", description: "Bella Ciao: Find someone whose native language is NOT one of the top five foreign languages in LA (Not Spanish, Not Mandarin Chinese, Not Korean, Not Tagalog, Not Armenian)", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Become Florida Man", description: "Become Florida Man: Recreate a florida man headline from one of you group members birthdays or half-birthdays (whichever is easiest).", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Caffeine Fiend", description: "Caffeine Fiend: Get someone to give you directions to the nearest starbucks not in view.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Subway Cubed", description: "Subway Cubed: Eat a subway sandwich while playing subway surfers on an LA Metro underground train", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Superfan", description: "Superfan: Find someone who knows 5 active players on the Lakers or Kings", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Sell or barter any good/service to a stranger ($1 minimum price)", description: "Sell or barter any good/service to a stranger ($1 minimum price)", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Los Angeles Isn't Just Home to Humans", description: "Los Angeles Isn't Just Home to Humans: Pet 5 stranger's dogs", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Oracle of the Doors", description: "Oracle of the Doors: Stand where you think the doors of the train will open. Challenge is completed once you have successfully guessed.  Only 1 team member is allowed to guess at a time.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Census Taker", description: "Census Taker: Estimate the population of the neighborhood you are in. If you are within 30% of the actual value, you complete the challenge. If failed you can re-attempt when you are in another neighborhood. After 3 attempts you can choose to lose the challenge (without the costs associated with sacrificing) or choose to continue guessing in new neighborhoods. (Neighborhoods can be found at this link https://www.reddit.com/r/LosAngeles/comments/8hr6ix/literally_just_a_comprehensive_list_map_of_los/#lightbox)", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "A Musical People", description: "A Musical People: Find someone that plays a musical instrument", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Metro Ambitions", description: "Metro Ambitions: Ask a Metro Ambassador for their favorite Sepulveda Pass Alternative", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Go do something interesting", description: "Go do something interesting: without researching beforehand go to somewhere that has a YouTube video about it with at least 100k views", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Paint a Local Landscape", description: "Paint a Local Landscape: You must make a reasonable attempt to create a decent painting using several colors and covering the majority of the canvas. The painting may be on paper or via an online art creation platform.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "More than just Korean! Take a photo that contains at least 3 different written languages", description: "More than just Korean! Take a photo that contains at least 3 different written languages", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Draw a team member's name on a Strava map", description: "Draw a team member's name on a Strava map", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Find a Statue and Recreate It", description: "Find a Statue and Recreate It: You may not use the internet to locate a statue. You must hold the pose for at least 2 minutes. The statue does not need to be human, but you still must do your best to recreate it with your bodies", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Correctly date an old thing", description: "Correctly date an old thing: Find an old structure. You have one guess to accurately predict which decade it was built in. You may not use your phone or any concrete information concerning it's construction date. You must make this guess using contextual clues. If your guess is wrong, you cannot find a reliable date of construction, or if your building was constructed after 1990, this challenge is automatically vetoed.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Eat a Fast 3 Course Meal", description: "Eat a Fast 3 Course Meal: Entree, drink, and dessert from 3 different fast food restaraunts", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "International Business", description: "International Business: Acquire a foreign currency", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "The City of the Globe", description: "The City of the Globe: Find a foreign flag", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Find something that has had a song written about it", description: "Find something that has had a song written about it", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "That Star Spangled Banner", description: "That Star Spangled Banner: Find a flag (Could be an American flag, foreign flag, California flag, Los Angeles flag)", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Good Citizen", description: "Good Citizen: Clean up ten pieces of litter", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "You may only take buses for the next 20 minutes, and then you gain control of the station", description: "You may only take buses for the next 20 minutes, and then you gain control of the station", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "What the F*** is a Kilometer", description: "tarting from the entrance to the metro station, without measuring, get as close to one kilometer away as you can (measured as the crow flies). You must be right within 30%. If you fail, you may not reattempt. Apart from a timer/watch, you may not consult your phone, maps, or any other tools before completeing or vetoing this challenge.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "History smtg", description: "History smtg : Find a building made before 1900.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Foreign Foodie", description: "Foreign Foodie: Eat a foreign cuisine", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Eating Like a Local", description: "Eating Like a Local: Get lunch from a local street food.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Make a 30-Second Parkour Video", description: "Make a 30-Second Parkour Video: The video must feature all team members attempting to do parkour.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Spell Your Name in Graffiti", description: "Spell Your Name in Graffiti: Find all the letters in one team member's first name in already-written grafitti", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Take Flight", description: "Take Flight: Throw a paper airplane at least 15 feet.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "One with Nature", description: "One with Nature: Make an arrangment of five different types flora.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Say a prayer at a local church of any denomination", description: "Say a prayer at a local church of any denomination", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Students of Fernandez-Castro", description: "Students of Fernandez-Castro: Find something written in Spanish.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "I seem to have misplaced something", description: "I seem to have misplaced something: ask about lost sunglasses at the Metro Lost & Found", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Taste Test", description: "Acquire a bag of any fruity candy (i.e. Skittles, Gummy Bears, etc.). Close your eyes. Taste three pieces and guess their flavors. You have infinite attempts", station: "GLOBAL", line: nil,  canFail: false),
    GameChallenge(title: "Game of Thrones", description: "LA Metro has implement smart bathrooms known as \"Thrones.\" Relieve yourself in one of these royal bathrooms. ", station: "GLOBAL", line: nil,  canFail: false),
]
