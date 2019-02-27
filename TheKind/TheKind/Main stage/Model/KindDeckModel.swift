//
//  KindDeckModel.swift
//  TheKind
//
//  Created by Tenny on 2/25/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation

class GameKinds {
    var drivers: [String: [KindCardId: KindCard]]!
    var intellectCards: [KindCardId: KindCard]!
    var intuitionCards: [KindCardId: KindCard]!
    var EmpathyCards: [KindCardId: KindCard]!
    var imaginationCards: [KindCardId: KindCard]!
    static let twelveKindsOriginal: [KindCardId: KindCard] = [.explorer : KindCard(kindId: .explorer, antagonists: nil, kindName: .explorer, iconImageName: .explorer),
                                                  .mentor : KindCard(kindId: .mentor, antagonists: nil, kindName: .mentor, iconImageName: .mentor),
                                                  .rebel : KindCard(kindId: .rebel, antagonists: nil, kindName: .rebel, iconImageName: .rebel),
                                                  .visionary : KindCard(kindId: .visionary, antagonists: nil, kindName: .visionary, iconImageName: .visionary),
                                                  .founder : KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImageName: .founder),
                                                  .leader : KindCard(kindId: .leader, antagonists: nil, kindName: .leader, iconImageName: .leader),
                                                  .grinder : KindCard(kindId: .grinder, antagonists: nil, kindName: .grinder, iconImageName: .grinder),
                                                  .idealist : KindCard(kindId: .idealist, antagonists: nil, kindName: .idealist, iconImageName: .idealist),
                                                  .teamplayer : KindCard(kindId: .teamplayer, antagonists: nil, kindName: .teamplayer, iconImageName: .teamplayer),
                                                  .angel : KindCard(kindId: .angel, antagonists: nil, kindName: .angel, iconImageName: .angel),
                                                  .trailblazer : KindCard(kindId: .trailblazer, antagonists: nil, kindName: .trailblazer, iconImageName: .trailblazer),
                                                  .entertainer : KindCard(kindId: .entertainer, antagonists: nil, kindName: .entertainer, iconImageName: .entertainer)]
    
    static let minorKindsOriginal: [KindCardId: KindCard] = [.achiever : KindCard(kindId: .achiever, antagonists: nil, kindName: .achiever, iconImageName: .achiever),
                                                              .adventurer : KindCard(kindId: .adventurer, antagonists: nil, kindName: .adventurer, iconImageName: .adventurer),
                                                              .aequanimus : KindCard(kindId: .aequanimus, antagonists: nil, kindName: .aequanimus, iconImageName: .aequanimus),
                                                              .agnostic : KindCard(kindId: .agnostic, antagonists: nil, kindName: .agnostic, iconImageName: .agnostic),
                                                              .ally: KindCard(kindId: .ally, antagonists: nil, kindName: .ally, iconImageName: .ally),
                                                              .artist : KindCard(kindId: .artist, antagonists: nil, kindName: .artist, iconImageName: .artist),
                                                              .grinder : KindCard(kindId: .grinder, antagonists: nil, kindName: .grinder, iconImageName: .grinder),
                                                              .idealist : KindCard(kindId: .idealist, antagonists: nil, kindName: .idealist, iconImageName: .idealist),
                                                              .teamplayer : KindCard(kindId: .teamplayer, antagonists: nil, kindName: .teamplayer, iconImageName: .teamplayer),
                                                              .angel : KindCard(kindId: .angel, antagonists: nil, kindName: .angel, iconImageName: .angel),
                                                              .trailblazer : KindCard(kindId: .trailblazer, antagonists: nil, kindName: .trailblazer, iconImageName: .trailblazer),
                                                              .entertainer : KindCard(kindId: .entertainer, antagonists: nil, kindName: .entertainer, iconImageName: .entertainer)]
    
    init() {
        intellectCards = [.explorer : KindCard(kindId: .explorer, antagonists: nil, kindName: .explorer, iconImageName: .explorer),
                          .mentor : KindCard(kindId: .mentor, antagonists: nil, kindName: .mentor, iconImageName: .mentor),
                          .rebel : KindCard(kindId: .rebel, antagonists: nil, kindName: .rebel, iconImageName: .rebel)]
      
        imaginationCards = [.visionary : KindCard(kindId: .visionary, antagonists: nil, kindName: .visionary, iconImageName: .visionary),
                          .founder : KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImageName: .founder)]
        
        intuitionCards = [.leader : KindCard(kindId: .leader, antagonists: nil, kindName: .leader, iconImageName: .leader),
                          .grinder : KindCard(kindId: .grinder, antagonists: nil, kindName: .grinder, iconImageName: .grinder),
                          .idealist : KindCard(kindId: .idealist, antagonists: nil, kindName: .idealist, iconImageName: .idealist),
                          .teamplayer : KindCard(kindId: .teamplayer, antagonists: nil, kindName: .teamplayer, iconImageName: .teamplayer)]
        
        EmpathyCards = [.angel : KindCard(kindId: .angel, antagonists: nil, kindName: .angel, iconImageName: .angel),
                        .trailblazer : KindCard(kindId: .trailblazer, antagonists: nil, kindName: .trailblazer, iconImageName: .trailblazer),
                        .entertainer : KindCard(kindId: .entertainer, antagonists: nil, kindName: .entertainer, iconImageName: .entertainer)]
        
        drivers["intellect"] = intellectCards
        drivers["intution"] = intuitionCards
        drivers["empathy"] = EmpathyCards
        drivers["imagination"] = imaginationCards
    }
}

struct KindCard {
    var kindId: KindCardId
    var antagonists: [KindCard]?
    var kindName: KindName
    let iconImageName: KindImageName
}


enum KindCardId: Int {
    case angel = 1,
    trailblazer = 2,
    entertainer = 3,
    leader = 4,
    grinder = 5,
    idealist = 6,
    teamplayer = 7,
    visionary = 8,
    founder = 9,
    explorer = 10,
    mentor = 11,
    rebel = 12,
    agnostic = 13,
    believer = 14,
    guided = 15,
    simulation = 16,
    onelikethesky = 17,
    aequanimus = 18,
    keeper = 19,
    nomad = 20,
    servant = 21,
    blindfolded = 22,
    original = 23,
    player = 24,
    bonvivant = 25,
    achiever = 26,
    director = 27,
    controller = 28,
    enthusiast = 29,
    optmistic = 30,
    empathetic = 31,
    poet = 32,
    still = 33,
    connector = 34,
    shapeshifter = 35,
    ingenius = 36,
    artist = 37,
    realist = 38,
    ally = 39,
    champion = 40,
    perfectionist = 41,
    juggler = 42,
    adventurer = 43,
    jumper = 44,
    seeker = 45,
    traditionalist = 46,
    modernist = 47,
    moderator = 48
}

enum KindName: String {
    case angel = "The Angel",
    trailblazer = "The Trailblazer",
    entertainer = "The Entertainer",
    leader = "The Leader",
    grinder = "The Grinder",
    idealist = "The Idealist",
    teamplayer = "The Team Player",
    visionary = "The Visionary",
    founder = "The Founder",
    explorer = "The Explorer",
    mentor = "The Mentor",
    rebel = "The rebel",
    agnostic = "The Agnostic",
    believer = "The Believer",
    guided = "The Guided",
    simulation = "The Simulation",
    onelikethesky = "The One Like The Sky",
    aequanimus = "The Aequanimus",
    keeper = "The Keeper",
    nomad = "The Nomad",
    servant = "The Servant",
    blindfolded = "The Blindfolded",
    original = "The Original",
    player = "The Player",
    bonvivant = "The Bon Vivant",
    achiever = "The Achiever",
    director = "The Director",
    controller = "The Controller",
    enthusiast = "The Enthusiast",
    optmistic = "The Optmistic",
    empathetic = "The Empathetic",
    poet = "The Poet",
    still = "The Still",
    connector = "The Connector",
    shapeshifter = "The Shapeshifter",
    ingenius = "The Ingenius",
    artist = "The Artist",
    realist = "The Realist",
    ally = "The Ally",
    champion = "The Champion",
    perfectionist = "The Perfectionist",
    juggler = "The Juggler",
    adventurer =  "The Adventurer",
    jumper = "The Jumper",
    seeker = "The Seeker",
    traditionalist = "The Traditionalist",
    modernist = "The Modernist",
    moderator = "The Moderator"
}

enum KindImageName: String {
    case angel = "angel",
    trailblazer = "trailblazer",
    entertainer = "entertainer",
    leader = "leader",
    grinder = "grinder",
    idealist = "idealist",
    teamplayer = "team_player",
    visionary = "visionary",
    founder = "founder",
    explorer = "explorer",
    mentor = "mentor",
    rebel = "rebel",
    agnostic = "agnostic",
    believer = "believer",
    guided = "guided",
    simulation = "simulation",
    onelikethesky = "one_like_the_sky",
    aequanimus = "aequanimus",
    keeper = "keeper",
    nomad = "nomad",
    servant = "servant",
    blindfolded = "blindfolded",
    original = "original",
    player = "player",
    bonvivant = "bon_vivant",
    achiever = "achiever",
    director = "director",
    controller = "controller",
    enthusiast = "enthusiast",
    optmistic = "optmistic",
    empathetic = "empathetic",
    poet = "poet",
    still = "still",
    connector = "connector",
    shapeshifter = "shapeshifter",
    ingenius = "ingenius",
    artist = "artist",
    realist = "realist",
    ally = "ally",
    champion = "champion",
    perfectionist = "perfectionist",
    juggler = "juggler",
    adventurer =  "adventurer",
    jumper = "jumper",
    seeker = "seeker",
    traditionalist = "traditionalist",
    modernist = "modernist",
    moderator = "moderator"
}






//enum KindEnum {
//    case angel,
//    trailblazer,
//    entertainer,
//    leader,
//    grinder,
//    idealist,
//    teamplayer,
//    visionary,
//    founder,
//    explorer,
//    mentor,
//    rebel,
//    agnostic,
//    believer,
//    guided,
//    simulation,
//    onelikethesky,
//    aequanimus,
//    keeper,
//    nomad,
//    servant,
//    blindfolded,
//    original,
//    player,
//    bonvivant,
//    achiever,
//    director,
//    controller,
//    enthusiast,
//    optmistic,
//    empathetic,
//    poet,
//    still,
//    connector,
//    shapeshifter,
//    ingenius,
//    artist,
//    realist,
//    ally,
//    champion,
//    perfectionist,
//    juggler,
//    adventurer,
//    jumper,
//    seeker,
//    traditionalist,
//    modernist,
//    moderator
//}

//
//
//
//func getKindCard(type: KindCardId) -> KindCard {
//    switch type {
//    case .achiever:
//        return KindCard(kindId: .achiever, antagonists: nil, kindName: .achiever, iconImage:#imageLiteral(resourceName: "achiever"))
//    case .adventurer:
//        return KindCard(kindId: .adventurer, antagonists: nil, kindName: .adventurer, iconImage:#imageLiteral(resourceName: "adventurer"))
//    case .aequanimus:
//        return KindCard(kindId: .aequanimus, antagonists: nil, kindName: .aequanimus, iconImage:#imageLiteral(resourceName: "aequanimus"))
//    case .agnostic:
//        return KindCard(kindId: .agnostic, antagonists: nil, kindName: .agnostic, iconImage:#imageLiteral(resourceName: "agnostic"))
//    case .ally:
//        return KindCard(kindId: .agnostic, antagonists: nil, kindName: .agnostic, iconImage:#imageLiteral(resourceName: "Ally"))
//    case .angel:
//        return KindCard(kindId: .angel, antagonists: nil, kindName: .angel, iconImage:#imageLiteral(resourceName: "angel"))
//    case .artist:
//        return KindCard(kindId: .artist, antagonists: nil, kindName: .artist, iconImage:#imageLiteral(resourceName: "artist"))
//    case .believer:
//        return KindCard(kindId: .believer, antagonists: nil, kindName: .believer, iconImage:#imageLiteral(resourceName: "believer"))
//    case .blindfolded:
//        return KindCard(kindId: .blindfolded, antagonists: nil, kindName: .blindfolded, iconImage:#imageLiteral(resourceName: "blindfolded"))
//    case .bonvivant:
//        return KindCard(kindId: .bonvivant, antagonists: nil, kindName: .bonvivant, iconImage:#imageLiteral(resourceName: "bonvivant"))
//    case .champion:
//        return KindCard(kindId: .champion, antagonists: nil, kindName: .champion, iconImage:#imageLiteral(resourceName: "champion"))
//    case .connector:
//        return KindCard(kindId: .connector, antagonists: nil, kindName: .connector, iconImage:#imageLiteral(resourceName: "connector"))
//    case .controller:
//        return KindCard(kindId: .controller, antagonists: nil, kindName: .controller, iconImage:#imageLiteral(resourceName: "controller"))
//    case .director:
//        return KindCard(kindId: .director, antagonists: nil, kindName: .director, iconImage:#imageLiteral(resourceName: "director"))
//    case .empathetic:
//        return KindCard(kindId: .empathetic, antagonists: nil, kindName: .empathetic, iconImage:#imageLiteral(resourceName: "empathetic"))
//    case .entertainer:
//        return KindCard(kindId: .entertainer, antagonists: nil, kindName: .entertainer, iconImage:#imageLiteral(resourceName: "entertainer"))
//    case .enthusiast:
//        return KindCard(kindId: .enthusiast, antagonists: nil, kindName: .enthusiast, iconImage:#imageLiteral(resourceName: "enthusiast"))
//    case .explorer:
//        return KindCard(kindId: .explorer, antagonists: nil, kindName: .explorer, iconImage:#imageLiteral(resourceName: "explorer"))
//    case .founder:
//        return KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImage:#imageLiteral(resourceName: "founder"))
//    case .grinder:
//        return KindCard(kindId: .grinder, antagonists: nil, kindName: .grinder, iconImage:#imageLiteral(resourceName: "grinder"))
//    case .guided:
//        return KindCard(kindId: .guided, antagonists: nil, kindName: .guided, iconImage:#imageLiteral(resourceName: "guided"))
//    case .idealist:
//        return KindCard(kindId: .idealist, antagonists: nil, kindName: .idealist, iconImage:#imageLiteral(resourceName: "idealist"))
//    case .ingenius:
//        return KindCard(kindId: .ingenius, antagonists: nil, kindName: .ingenius, iconImage:#imageLiteral(resourceName: "ingenius"))
//    case .juggler:
//        return KindCard(kindId: .juggler, antagonists: nil, kindName: .juggler, iconImage:#imageLiteral(resourceName: "juggler"))
//    case .jumper:
//        return KindCard(kindId: .jumper, antagonists: nil, kindName: .jumper, iconImage:#imageLiteral(resourceName: "jumper"))
//    case .keeper:
//        return KindCard(kindId: .keeper, antagonists: nil, kindName: .keeper, iconImage:#imageLiteral(resourceName: "keeper"))
//    case .leader:
//        return KindCard(kindId: .leader, antagonists: nil, kindName: .leader, iconImage: #imageLiteral(resourceName: "leader"))
//    case .mentor:
//        return KindCard(kindId: .mentor, antagonists: nil, kindName: .mentor, iconImage: #imageLiteral(resourceName: "mentor"))
//    case .still:
//        return KindCard(kindId: .still, antagonists: nil, kindName: .still, iconImage: #imageLiteral(resourceName: "still"))
//    case .rebel:
//        return KindCard(kindId: .rebel, antagonists: nil, kindName: .rebel, iconImage: #imageLiteral(resourceName: "rebel"))
//    case .realist:
//        return KindCard(kindId: .realist, antagonists: nil, kindName: .realist, iconImage: #imageLiteral(resourceName: "realist"))
//    case .seeker:
//        return KindCard(kindId: .seeker, antagonists: nil, kindName: .seeker, iconImage: #imageLiteral(resourceName: "seeker"))
//    case .servant:
//        return KindCard(kindId: .servant, antagonists: nil, kindName: .servant, iconImage: #imageLiteral(resourceName: "servant"))
//    case .shapeshifter:
//        return KindCard(kindId: .shapeshifter, antagonists: nil, kindName: .shapeshifter, iconImage: #imageLiteral(resourceName: "servant"))
//    default:
//        return KindCard(kindId: .adventurer, antagonists: nil, kindName: .adventurer, iconImage:#imageLiteral(resourceName: "noX"))
//    }
//}
