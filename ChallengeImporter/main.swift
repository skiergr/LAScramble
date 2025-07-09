
import Foundation
import FirebaseCore
import FirebaseFirestore

struct GameChallenge: Codable, Identifiable, Equatable {
    var id: String { title + station }
    let title: String
    let description: String
    let station: String
    let line: String?
    let canFail: Bool
}

let sampleChallenges: [GameChallenge] = [
    GameChallenge(title: "Eating Like a Local", description: "Get lunch from a local street-food vendor.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Active in Politics", description: "Find someone who knows who their House Representative is.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Recreate the Banksy", description: "Recreate the Banksy: Go to the Banksy Artwork at 9th and broadway and make human-statue version of the art. The painting may be on paper or via an online art creation platform.", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Heaven's Ascension", description: "Heaven's Ascension: Race your teammate up the angels flight railway (if alone just ride it)", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Ticket to the Past", description: "Ticket to the Past: Find a traveler who’s been riding Metro since before 2010. Ask them what’s changed the most.", station: "Union Station", line: nil, canFail: false),
    GameChallenge(title: "Become a Legislature", description: "Become a Legislature: Enter city hall, write down a proposition for law a law and get 10 signatures supporting it. (you have 20 minutes to complete this)", station: "Civic Center / Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Wait...that's art?!? Take a picture of some \"\"art\"\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", description: "Wait...that's art?!? Take a picture of some \"\"art\"\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", station: "Civic Center / Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Predict Market Flow at Grand Central Market", description: "Predict Market Flow at Grand Central Market: Select any market stall and make a prediction about how many customers it will get in the next ten minutes. A customer is defined as any person who spends money at the stall. If your prediction is more than 40% off, this challenge is failed. If no one visits the stall in the 10 minutes you lose automatically.", station: "Civic Center / Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Mariachi Magic", description: "Mariachi Magic: Go to Olvera Street and dance to some magical mariachi music. If there is no music playing, you must create the music yourself", station: "Civic Center / Grand Park", line: nil, canFail: false),
    GameChallenge(title: "Criticize the Most Beautiful Building", description: "Criticize the Most Beautiful Building: Go to the Bradbury Building and find 3 critiques of its architecture", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "The Last Bookstore", description: "The Last Bookstore: Go to the tunnel of books in the Last Bookstore and create your own miniture arch of books", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "Wish Upon a Scoop", description: "Wish Upon a Scoop: Go to 28 Wishes Ice Cream near Pershing Square and buy yourself a scoop. While enjoying it inside the shop, ask another guest to share a wish they have for the futureand film the interaction.", station: "Pershing Square", line: nil, canFail: false),
    GameChallenge(title: "High-School English Major", description: "High-School English Major: Find a book taught at Harvard-Westlake in the LA Central Library", station: "7th Street/Metro Center", line: nil, canFail: false),
    GameChallenge(title: "X Marks the Spot", description: "X Marks the Spot: Find a geocache", station: "7th Street/Metro Center", line: nil, canFail: false),
    GameChallenge(title: "Become a Star", description: "Act out a scene from interstellar in the Bonaventure hotel lobby. The NASA Facility in the move was filmed in this lobby.", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "History smtg", description: "History smtg : Find a building made before 1950.", station: "7th Street/Metro Center", line: nil, canFail: false),
    GameChallenge(title: "Soaked", description: "Soaked: fully submerge a team member's hand in Mararthur Park Lake", station: "Westlake / Macarthur Park", line: nil, canFail: false),
    GameChallenge(title: "Track Star", description: "Track Star: Loop (preferably in a faster than walking pace) around the entire Macarthur Park lake perimeter", station: "Westlake / Macarthur Park", line: nil, canFail: false),
    GameChallenge(title: "As General Mcarthur, command an army of at least 20 birds. Include at least one famous quote from General Mcarthur.", description: "As General Mcarthur, command an army of at least 20 birds. Include at least one famous quote from General Mcarthur.", station: "Westlake / Macarthur Park", line: nil, canFail: false),
    GameChallenge(title: "Donut Debate", description: "Donut Debate: Buy a donut from a shop near the station. Find a stranger and start a lighthearted “debate” on video: what’s the best donut flavor and why?", station: "Westlake / Macarthur Park", line: nil, canFail: false),
    GameChallenge(title: "Steph Curry", description: "Steph Curry: Shoot a 3 pointer (hint go to lafeyette recreation center). If no basketball available or to ask for then recreate the Michael Jordan logo.", station: "Wilshire / Vermont", line: nil, canFail: false),
    GameChallenge(title: "Attempt to sell something at a local pawn shop", description: "Attempt to sell something at a local pawn shop", station: "Vermont / Beverly", line: nil, canFail: false),
    GameChallenge(title: "Ready to be a Laker", description: "Ready to be a Laker: Challenge a stranger to a 1v1 basketball game at Madison Avenue Park", station: "Vermont / Santa Monica", line: nil, canFail: false),
    GameChallenge(title: "Sandwich Scientist", description: "Sandwich Scientist: Buy any sandwich nearby. Disassemble it completely, analyze and describe each ingredient like a food critic, then reassemble and eat it on video while giving a final “lab report.”", station: "Vermont / Santa Monica", line: nil, canFail: false),
    GameChallenge(title: "Religion of the Stars", description: "Religion of the Stars: Go to the Church of Scientology and ask to convert?", station: "Vermont / Sunset", line: nil, canFail: false),
    GameChallenge(title: "Leave a handwritten letter at your local Congressman's office.", description: "Leave a handwritten letter at your local Congressman's office.", station: "Hollywood / Western", line: nil, canFail: false),
    GameChallenge(title: "New And Improved Hollywood Sign (Near Hollywood Sign)", description: "New And Improved Hollywood Sign (Near Hollywood Sign): Make a sign that is an advertisement for Hollywood. Then find someone that does not live in LA and give them a compelling argument for why they should move to LA", station: "Hollywood / Western", line: nil, canFail: false),
    GameChallenge(title: "Become a Talkshow Host", description: "Become a Talkshow Host: Create a Jimmy Kimmel-style interview with someone on the Hollywood walk of fame", station: "Hollywood / Vine", line: nil, canFail: false),
    GameChallenge(title: "It Isn't Easy Being Green", description: "It Isn't Easy Being Green: Find Kermit the Frog's Star on the Hollywood Walk of Fame", station: "Hollywood/Highland", line: nil, canFail: false),
    GameChallenge(title: "Find someone trying to break out into an acting career", description: "Find someone trying to break out into an acting career", station: "Hollywood/Highland", line: nil, canFail: false),
    GameChallenge(title: "Your a Wizard, Harry", description: "Your a Wizard, Harry: Recreate a scene in Harry Potter with Hogwarts in the background. (If deemed impossible, curse Universal Studios with a curse from Harry Potter)", station: "Universal City/Studio Ciy", line: nil, canFail: false),
    GameChallenge(title: "NOHO Art district", description: "NOHO Art district:  Find a piece of art in NOHO that has an article written about it online.", station: "North Hollywood", line: nil, canFail: false),
    GameChallenge(title: "Diplomatic Discovery", description: "Diplomatic Discovery: Visit a foreign countries consulate.", station: "Wilshire / Normandie", line: nil, canFail: false),
    GameChallenge(title: "Become Mr. Varney", description: "Become Mr. Varney: Find a K-Pop store and film a 15 second dance to any k-pop song.", station: "Wilshire / Normandie", line: nil, canFail: false),
    GameChallenge(title: "Fermentation Frenzy", description: "Fermentation Frenzy: Find kimchi in a korean grocery store.", station: "Wilshire / Western", line: nil, canFail: false),
    GameChallenge(title: "Amsterdam of Southern California", description: "Amsterdam of Southern California: Ride Metro Bikes between Metro stops", station: "Wilshire / Western", line: nil, canFail: false),
    GameChallenge(title: "Spice Roulette", description: "Spice Roulette: Go to a Korean restaurant near the station and order the spiciest dish they offer. One team member must eat a full bite on video without drinking water for 30 seconds.", station: "Wilshire / Western", line: nil, canFail: false),
    GameChallenge(title: "I Swear its Worth It", description: "I Swear its Worth It: Find an item at Erewhon worth 3x more expensive than the same item at a grocery store of your choice.", station: "Culver City", line: nil, canFail: false),
    GameChallenge(title: "The Home of Transit-Oriented Development", description: "The Home of Transit-Oriented Development: Take a picture that includes all modes of public transit offered in Culver City: train, bike, and bus.", station: "Culver City", line: nil, canFail: false),
    GameChallenge(title: "Get Jiggy With It", description: "Get Jiggy With It: Get a stranger to teach you a dance move.", station: "La Cienega/Jefferson", line: nil, canFail: false),
    GameChallenge(title: "Party Time", description: "Party Time: Find the warehouse from the 2024 Harvard-Westlake Prom (5216 W Jefferson Blvd) and dance to some prom music (music is of the player's choice)", station: "Expo/La Brea", line: nil, canFail: false),
    GameChallenge(title: "Religious Diversity", description: "Religious Diversity: Across from you sits the West Angeles Church of God, a Pentecostal Church. The Pentecostals believe strongly in the importance of spiritual gifts like speaking in tongues. Los Angeles is a city of great linguistic diversity. As a team say one word in 15 different languages (they do not need to be the same word).", station: "Expo/Crenshaw", line: nil, canFail: false),
    GameChallenge(title: "Gladiator of LA", description: "Gladiator of LA: With the LA Memorial Coliseum in the background, record a video of your team \"\"fighting\"\" a gladiator fight", station: "Expo / Vermont", line: nil, canFail: false),
    GameChallenge(title: "True Trojan v.s. Unexpected Trojan", description: "True Trojan v.s. Unexpected Trojan: Find a USC student with legacy connection or find the rare trojan on financial aid", station: "Expo / Vermont", line: nil, canFail: false),
    GameChallenge(title: "Balls", description: "Balls: catch at least ten balls in the ball-glove-contraption catcher thingy in the outdoor Ecosystems exhibit of the Science Center", station: "Expo Park / USC", line: nil, canFail: false),
    GameChallenge(title: "Get a university branded pen", description: "Get a university branded pen", station: "Jefferson / USC", line: nil, canFail: false),
    GameChallenge(title: "Become the Los Angeles Aquaduct", description: "Become the Los Angeles Aquaduct: Transfer water from one water fountain to another", station: "Jefferson / USC", line: nil, canFail: false),
    GameChallenge(title: "A Unique College Experience", description: "A Unique College Experience: Los Angeles Trade-Technical College offers an education that is vastly different from a traditional university. Find 3 things on LATTC's campus that you wouldn't see at a traditional 4-year institution (unique departments, student clubs, facilities, etc)", station: "LATTC / Ortho Institute", line: nil, canFail: false),
    GameChallenge(title: "The Next Convention", description: "The Next Convention: Go to the LA Convention Center and find out what the next upcoming convention is. You may not use google, you may only look around the Convention Center.", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "What a Dump", description: "What a Dump: Use a restroom of a hotel that costs more that $500 that night", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Futuristic City", description: "Futuristic City: Find someone that owns crypto currency in front of Crypto.com Arena", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Professional Athlete", description: "Professional Athlete: Deliver a 30 second \"\"post-game interview\"\" in front of crypto.com arena describing how you feel about your team's progress.", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Spell Your Names in Graffiti", description: "Spell Your Names in Graffiti: Go to Graffiti Towers and spell your name in graffiti. Find all the letters that spell your team players names (first and last).", station: "Pico", line: nil, canFail: false),
    GameChallenge(title: "Runnin' up that hill", description: "Runnin' up that hill: run up the Bunker Hill steps", station: "Grand Av Arts / Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "Cultured City", description: "Cultured City: In front of the Walt Disney Concert Hall, choose a classical music piece to play a recording of and find someone that can recognize the composer", station: "Grand Av Arts / Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "MOCA vs The Broad", description: "MOCA vs The Broad: Go to either MOCA or the Broad and ask an employee to give you 3 reasons why their modern art museum is better than the other", station: "Grand Av Arts / Bunker Hill", line: nil, canFail: false),
    GameChallenge(title: "Go to an unknown museum", description: "Go to an unknown museum: Spend at least 15 minutes inside a museum with fewer than 50 Google reviews.", station: "Historic Broadway", line: nil, canFail: false),
    GameChallenge(title: "Sky High Adventure", description: "Sky High Adventure: Reach the 20th floor or higher in any building", station: "Historic Broadway", line: nil, canFail: false),
    GameChallenge(title: "Fight for Your Honor", description: "Fight for Your Honor: In Little Tokyo, video two team members having a katana sword fight (Katana's can be aquired from the area near the Japanese Village Plaza)", station: "Little Tokyo / Arts District", line: nil, canFail: false),
    GameChallenge(title: "Worshipping the Buddha", description: "Worshipping the Buddha: Go to the Higashi Honganji Temple and receite a prayer in Japanese", station: "Little Tokyo / Arts District", line: nil, canFail: false),
    GameChallenge(title: "American Public Transportation", description: "American Public Transportation: Spot a freight rail train", station: "Little Tokyo / Arts District", line: nil, canFail: false),
    GameChallenge(title: "Mochi Haiku", description: "Mochi Haiku: Buy mochi. Before eating, compose and recite a haiku about your mochi experience on video. Must follow 5–7–5 syllable rule.", station: "Little Tokyo / Arts District", line: nil, canFail: false),
    GameChallenge(title: "Bridge Troll", description: "Bridge Troll: Stand on the first street bridge and get a stranger to answer a riddle.", station: "Pico / Aliso", line: nil, canFail: false),
    GameChallenge(title: "Mariachi or Nah?", description: "Mariachi or Nah?: Approach someone near Mariachi Plaza and confidently ask what instrument they play in the band. If they’re not in one, apologize and offer to be their manager anyway.", station: "Mariachi Plaza / Boyle Heights", line: nil, canFail: false),
    GameChallenge(title: "International Business", description: "International Business: Acquire a foreign currency", station: "Willowbrook/Rosa Parks", line: nil, canFail: false),
    GameChallenge(title: "Least Populated City in CA", description: "Least Populated City in CA: Find a resident of Vernon, California", station: "Vernon", line: nil, canFail: false),
    GameChallenge(title: "Find a student or employee from LATTC", description: "Find a student or employee from LATTC", station: "Grand / LATTC", line: nil, canFail: false),
    GameChallenge(title: "Honor the Buddha", description: "Honor the Buddha: Go to the Thien Hau Temple and ask someone the significance of Mazu", station: "Chinatown", line: nil, canFail: false),
    GameChallenge(title: "Ooo that's strange", description: "Ooo that's strange: Go to a Chinese market, purchase, and consume, something that is quite strange (Must text in group chat for the group to confirm that it is strange enough)", station: "Chinatown", line: nil, canFail: false),
    GameChallenge(title: "Old Car Near the Oldest Freeway in America", description: "Old Car Near the Oldest Freeway in America: Find a car with a license plate starting with the number 4 or below (Hint: there's a park near the station where you can see cars drive on the Arroyo-Seco Freeway", station: "Heritage Square / Arroyo", line: nil, canFail: false),
    GameChallenge(title: "I seem to have misplaced something", description: "I seem to have misplaced something: ask about lost sunglasses at the Metro Lost & Found", station: "Heritage Square / Arroyo", line: nil, canFail: false),
    GameChallenge(title: "Calm", description: "Calm: meditate for at least 10 minutes at Augustus Hawkins Nature Park", station: "Southwest Museum", line: nil, canFail: false),
    GameChallenge(title: "Bowl a Strike", description: "Bowl a Strike: Bowl a strike at a bowling alley", station: "Highland Park", line: nil, canFail: false),
    GameChallenge(title: "Welcome to Pawnee, Indiana", description: "Welcome to Pawnee, Indiana: Recreate a scene from Parks and Rec in front of the Pasadena City Hall (where Parks and Recs was filmed)", station: "Memorial Park", line: nil, canFail: false),
    GameChallenge(title: "OG Taco", description: "OG Taco: Order the OG Taco at the Original Taco Pete", station: "Hyde Park", line: nil, canFail: false),
    GameChallenge(title: "Getting Involved in Local Politics", description: "Getting Involved in Local Politics: Welcome to Downtown Inglewood! Local politics is an integral piece of our democracy. Embrace this spirit! With the city hall in sight, write a petition and get 5 signatories", station: "Downtown Inglewood", line: nil, canFail: false),
    GameChallenge(title: "Purchase an item from the robotic arm shop. If hats are available, you must purchase a hat for Eric or Grady.", description: "Purchase an item from the robotic arm shop. If hats are available, you must purchase a hat for Eric or Grady.", station: "LAX/Metro Transit Center", line: nil, canFail: false),
    GameChallenge(title: "Plane Spotting", description: "Plane Spotting: Photograph three planes landing from three different countries (not including the US).", station: "Aviation/Century", line: nil, canFail: false),
    GameChallenge(title: "Get from the green to silver line platforms at harbor freeway in less than 1 minute. You must get from directly outside the metro car doors to directly infron of the bus doors.", description: "Get from the green to silver line platforms at harbor freeway in less than 1 minute. You must get from directly outside the metro car doors to directly infron of the bus doors.", station: "Harbor Fwy", line: nil, canFail: false),
    GameChallenge(title: "Recite the 14 names of Elon Musks (known) children from memory while standing in front of the SpaceX rocket. You have infintie attempts and may practice as much as possible, but cannot complete the challenge until you recite all of them from memory.", description: "Recite the 14 names of Elon Musks (known) children from memory while standing in front of the SpaceX rocket. You have infintie attempts and may practice as much as possible, but cannot complete the challenge until you recite all of them from memory.", station: "Crenshaw", line: nil, canFail: false),
    
    
    
    GameChallenge(title: "Become a Legislature", description: "Become a Legislature: Enter city hall, write down a proposition for law a law and get 10 signatures supporting it. (you have 20 minutes to complete this)", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
            GameChallenge(title: "Wait...that's art?!? Take a picture of some \"art\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", description: "Wait...that's art?!? Take a picture of some \"art\" that could be argued could be displayed in the Broad Museum, go to a Broad Museum employee and pitch why that art should be exhibited there", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
            GameChallenge(title: "Predict Market Flow at Grand Central Market", description: "Predict Market Flow at Grand Central Market: Select any market stall and make a prediction about how many customers it will get in the next ten minutes. A customer is defined as any person who spends money at the stall. If your prediction is more than 40% off, this challenge is failed. If no one visits the stall in the 10 minutes you lose automatically.", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
            GameChallenge(title: "Mariachi Magic", description: "Mariachi Magic: Go to Olvera Street and dance to some magical mariachi music. If there is no music playing, you must create the music yourself", station: "Civic Ctr/Grand Park", line: nil, canFail: false),
            GameChallenge(title: "Heaven's Ascension", description: "Heaven's Ascension: Race your teammate up the angels flight railway (if alone just ride it)", station: "Pershing Square", line: nil, canFail: false),
            GameChallenge(title: "Criticize the Most Beautiful Building", description: "Criticize the Most Beautiful Building: Go to the Bradbury Building and find 3 critiques of its architecture", station: "Pershing Square", line: nil, canFail: false),
            GameChallenge(title: "High-School English Major", description: "High-School English Major: Find a book taught at Harvard-Westlake in the LA Central Library", station: "Pershing Square", line: nil, canFail: false),
            GameChallenge(title: "The Last Bookstore", description: "The Last Bookstore: Go to the tunnel of books in the Last Bookstore and create your own miniture arch of books", station: "Pershing Square", line: nil, canFail: false),
            GameChallenge(title: "Check out a book from the LA Public Library", description: "Check out a book from the LA Public Library", station: "7th St/Metro Ctr", line: nil, canFail: false),
            GameChallenge(title: "X Marks the Spot", description: "X Marks the Spot: Find a geocache", station: "7th St/Metro Ctr", line: nil, canFail: false),
            GameChallenge(title: "Act out a scene from interstellar in the bonaventure hotel lobby", description: "Act out a scene from interstellar in the bonaventure hotel lobby", station: "Grand Av Arts / Bunker Hill", line: nil, canFail: false),
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
            GameChallenge(title: "Find a USC student on financial aid or one with legacy", description: "Find a USC student on financial aid or one with legacy", station: "Expo/Vermont", line: nil, canFail: false),
            GameChallenge(title: "Balls", description: "Balls: catch at least ten balls in the ball-glove-contraption catcher thingy in the outdoor Ecosystems exhibit of the Science Center", station: "Expo Park/USC", line: nil, canFail: false),
            GameChallenge(title: "Get a university branded pen", description: "Get a university branded pen", station: "Jefferson/USC", line: nil, canFail: false),
            GameChallenge(title: "Become the Los Angeles Aquaduct", description: "Become the Los Angeles Aquaduct: Transfer water from one water fountain to another", station: "Jefferson/USC", line: nil, canFail: false),
            GameChallenge(title: "The Next Convention", description: "The Next Convention: Go to the LA Convention Center and find out what the next upcoming convention is. You may not use google, you may only look around the Convention Center.", station: "Pico", line: nil, canFail: false),
            GameChallenge(title: "What a Dump", description: "What a Dump: Use a restroom of a hotel that costs more that $500 that night", station: "Pico", line: nil, canFail: false),
            GameChallenge(title: "Futuristic City", description: "Futuristic City: Find someone that owns crypto currency in front of Crypto.com Arena", station: "Pico", line: nil, canFail: false),
            GameChallenge(title: "Professional Athlete", description: "Professional Athlete: Deliver a 30 second \"post-game interview\" in front of crypto.com arena describing how you feel about your team's progress", station: "Pico", line: nil, canFail: false),/*
            GameChallenge(title: "Runnin' up that hill", description: "Runnin' up that hill: run up the Bunker Hill steps", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
            GameChallenge(title: "Cultured City", description: "Cultured City: In front of the Walt Disney Concert Hall, choose a classical music piece to play a recording of and find someone that can recognize the composer", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),
            GameChallenge(title: "MOCA vs The Broad", description: "MOCA vs The Broad: Go to either MOCA or the Broad and ask an employee to give you 3 reasons why their modern art museum is better than the other", station: "Grand Av Arts/Bunker Hill", line: nil, canFail: false),*/
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
           
    

    GameChallenge(title: "Climb a Tree", description: "Climb up a tree at least three feet off the ground.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Fighting the Stereotype", description: "Show a blank map with borders to pedestrians and find someone that can correctly identify 10 U.S. states.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Welcome to LA", description: "Find a tourist and ask them what they are most excited about on their visit to LA.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Become Florida Man", description: "Recreate a Florida-man headline from a date of your choice. Use https://floridamanbirthday.org/ to help with your search.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Caffeine Fiend", description: "Get someone to give you directions to the nearest Starbucks not already in view.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "LA Superfan", description: "Find someone who can name seven active players on any professional Los Angeles sports teams (from one or multiple teams).", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Merchant of Venice (Beach)", description: "Sell or barter any good or service to a stranger for at least $1.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Los Angeles Isn't Just Home to Humans", description: "Pet five strangers' dogs.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Oracle of the Doors", description: "Stand where you think the train doors will open. You have up to three attempts. Only one team member may guess at a time and both feet must be between the edges of the doors.", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Census Taker", description: "Estimate the population of the neighborhood you are in. If you are within 30 %, you succeed. You only may guess for three different neighborhoods. If you get all three wrong, you fail. (Neighborhood list: https://www.reddit.com/r/LosAngeles/comments/8hr6ix/literally_just_a_comprehensive_list_map_of_los/#lightbox)", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "A Musical People", description: "Find someone who plays a musical instrument.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Metro Ambitions", description: "Ask a Metro Ambassador which Sepulveda Pass alternative they prefer and why. If the ambassador is unfamiliar, find another.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Go Do Something Interesting", description: "Without researching beforehand, go somewhere that has a YouTube video about it with at least 50 k views. You have three attempts.", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Paint a Local Landscape", description: "Create a decent painting of a local landscape using several colors and covering most of the canvas (physical or digital).", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Multilingual City", description: "Take a photo that contains at least three different written languages.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Make Your Mark", description: "Draw a team member's name on a Strava map.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Find a Statue and Recreate It", description: "Without using the internet, locate a statue and recreate its pose with your bodies for at least one minute.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Correctly Date an Old Thing", description: "Find an old structure and guess which decade it was built in (one guess only, no phone or concrete info).", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Global City", description: "Find and photograph a foreign flag.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Something to Sing About", description: "Find an LA landmark that has a song written about it and sing 15 seconds of that song at the location.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Good Citizen", description: "Pick up and properly dispose of 30 pieces of litter.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Multimodal City", description: "For the next 20 minutes you may only ride buses. You must ride at least one stop, then gain control of the station.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "What the F*** Is a Kilometer", description: "Starting from the station entrance, walk to where you think one kilometer away is (as the crow flies) without measuring. You must be within 30 %. No re-attempts; no maps or tools except a timer.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Foreign Foodie", description: "Eat a foreign cuisine dish.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "One with Nature", description: "Create a floral arrangement using five different types of flowers.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Spiritual Connection", description: "Say a prayer at a local church of any denomination.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Taste Test", description: "Acquire a bag of fruity candy (e.g., Skittles). Close your eyes, taste three pieces, and guess their flavors. All three must be correct or the station is sacrificed.", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Game of Thrones", description: "LA Metro has implemented smart bathrooms known as \"Thrones.\" Relieve yourself in one of these royal bathrooms.", station: "GLOBAL", line: nil, canFail: false),
    GameChallenge(title: "Be Funnier than ChatPGT", description: "Write an original joke and generate one with ChatGPT, then send both to another team. If they choose yours, you win; otherwise you fail.", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Kill Time, then Tell Time", description: "Complete one time-wasting task (soak and dry an item, 200 jumping jacks, or name 100 real people) and then guess how long it took. If within five minutes, you win; otherwise you fail. No clocks during the challenge.", station: "GLOBAL", line: nil, canFail: true),
    GameChallenge(title: "Find Something Good", description: "Without using a mapping app, visit a place with a Google rating of 4.5+ stars. No internet research. You have three attempts.", station: "GLOBAL", line: nil, canFail: true)


]

func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}

func dict(from ch: GameChallenge) -> [String: Any] {
    var d: [String: Any] = [
        "title": ch.title,
        "description": ch.description,
        "station": ch.station,
        "canFail": ch.canFail
    ]
    if let l = ch.line { d["line"] = l }
    return d
}

func uploadChallenges() async {
    configureFirebaseIfNeeded()
    let db = Firestore.firestore()
    let batch = db.batch()
    let col = db.collection("challenges")
    for ch in sampleChallenges {
        batch.setData(dict(from: ch), forDocument: col.document())
        print("Queued \(ch.title)")
    }
    do {
        try await batch.commit()
        print("Uploaded \(sampleChallenges.count) challenges.")
    } catch {
        print("Upload failed: \(error)")
        exit(EXIT_FAILURE)
    }
}

Task {
    await uploadChallenges()
    exit(EXIT_SUCCESS)
}
RunLoop.main.run()
