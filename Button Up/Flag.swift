//
//  Flag.swift
//  Button Up
//
//  Created by Ricky Buchanan on 28/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

// Flags that contain information about dice
// Information taken from the BMFlag*.php files in source - not sure if these are all exposed via API at any point

enum Flag: String {
    case AddAuxiliary // owner wants to add this auxiliary dice
    case AddReserve // owner wants to add this reserve die
    case Disabled // used for chance dice that have rerolled and failed to gain initiative
    case Dizzy
    case HasJustGrown
    case HasJustGrownOrShrunk
    case HasJustMorphed
    case HasJustRerolledOrnery
    case HasJustShrunk
    case HasJustSplit
    case IsAttackTarget
    case IsAttacker
    case IsRageTargetReplacement
    case JustPerformedBerserkAttack
    case JustPerformedTripAttack
    case JustPerformedUnsuccessfulAttack
    case Twin
    case ValueRelevantToScore
    case WasJustCaptured
}