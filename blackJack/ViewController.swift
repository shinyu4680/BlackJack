//
//  ViewController.swift
//  blackJack
//
//  Created by kevin on 2018/4/25.
//  Copyright © 2018年 KevinChang. All rights reserved.
//

import UIKit
import GameplayKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var comCards: [UIImageView]!
    @IBOutlet var playerCards: [UIImageView]!
    @IBOutlet weak var playerChipLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var comScoreLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var openFoldCardButton: UIButton!
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var plusBetBtn: UIButton!
    @IBOutlet weak var minusBetBtn: UIButton!
    
    
    var playerCloseCard = ""
    var comCloseCard = ""
    var playerOpenedCard = ""
    var comOpenedCard = ""
    var pCards = [String]()
    var cCards = [String]()
    
    let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: cards.count - 1)
    
    var playerScore = 0
    var comScore = 0
    var comTotalScore = 0
    
    var playerChip = 1000
    
    var count = 2
    var playerAceCount = 0
    var comAceCount = 0
    var bet = 100
    
    // MARK: 顯示蓋牌
    @IBAction func closeCard(_ sender: Any){
        playerCards[0].isHighlighted = false
        UIView.transition(with: playerCards[0], duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        
        if playerScore == 21 && pCards.count == 2{
            hitButton.isEnabled = false
        }
    }
    
    @IBAction func seeCard(_ sender: Any) {
        playerCards[0].isHighlighted = true
        playerScoreLabel.isHidden = false
        UIView.transition(with: playerCards[0], duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
        
        hitButton.isEnabled = true
        if playerScore >= 15{
            openButton.isEnabled = true
            alertTextLabel.isHidden = true
        }else {
            alertTextLabel.isHidden = false
        }
    }
    
    
    // MARK: 發牌
    @IBAction func deal(_ sender: Any){
        if playerChip >= bet{
            playerCloseCard = cards[distribution.nextInt()]
            playerOpenedCard = cards[distribution.nextInt()]
            comCloseCard = cards[distribution.nextInt()]
            comOpenedCard = cards[distribution.nextInt()]
            
            pCards += ["\(playerCloseCard)", "\(playerOpenedCard)"]
            cCards += ["\(comCloseCard)", "\(comOpenedCard)"]
            
            comCards[0].isHidden = false
            playerCards[0].image = UIImage(named: "back")
            playerCards[0].highlightedImage = UIImage(named: playerCloseCard)
            playerCards[0].isHidden = false
            playerCards[1].image = UIImage(named: playerOpenedCard)
            playerCards[1].isHidden = false
            comCards[1].image = UIImage(named: comOpenedCard)
            comCards[1].isHidden = false
            
            playerScore += scoreCal(card: playerOpenedCard)
            playerScore += scoreCal(card: playerCloseCard)
            if (playerOpenedCard.contains("A") || playerCloseCard.contains("A")) && playerScore > 21{
                playerScore -= 10
            }
            
            playerScoreLabel.text = "\(playerScore)"
            
            comScore += scoreCal(card: comOpenedCard)
            comScoreLabel.text = "\(comScore)"
            comScoreLabel.isHidden = false
            
            dealButton.isEnabled = false
            openFoldCardButton.isEnabled = true
            giveUpButton.isEnabled = true
            plusBetBtn.isHidden = true
            minusBetBtn.isHidden = true
            
            comTotalScore = comScore + scoreCal(card: comCloseCard)
            if (comCloseCard.contains("A") || comOpenedCard.contains("A")) && comTotalScore > 21{
                comTotalScore -= 10
            }
            
            for pCard in pCards{
                if pCard.contains("A"){
                    playerAceCount += 1
                }
            }
            for cCard in cCards{
                if cCard.contains("A"){
                    comAceCount += 1
                }
            }
        }else{
            noEnougnMoney()
        }
        
    }
    
    // MARK: 加牌
    @IBAction func hit(_ sender: Any){
        var addCard = ""
        addCard = cards[distribution.nextInt()]
        playerCards[count].isHidden = false
        playerCards[count].image = UIImage(named: addCard)
        UIView.transition(with: playerCards[count], duration: 0.8, options: .transitionCurlDown, animations: nil, completion: nil)
        pCards += ["\(addCard)"]
        
        if addCard.contains("A"){
            playerAceCount += 1
        }
        
        playerScore += scoreCal(card: addCard)
        for pCard in pCards{
            if pCard.contains("A") && playerScore > 21{
                playerScore -= 10
                pCards = pCards.filter({(card : String) -> Bool in return !card.contains("A")})
            }
        }
        if addCard.contains("A") && playerAceCount >= 2{
            pCards += ["\(addCard)"]
        }
        
        playerScoreLabel.text = "\(playerScore)"
        
        if playerScore >= 15{
            openButton.isEnabled = true
            alertTextLabel.isHidden = true
        }else {
            alertTextLabel.isHidden = false
        }
        if playerScore == 21{
            hitButton.isEnabled = false
        }
        
        count += 1
        if (count == 5 && playerScore <= 21) && !(comTotalScore == 21){
            fiveCardTrick()
        }else if (count == 5 && playerScore <= 21) && (comTotalScore == 21){
            comBlackJack()
        }else if playerScore > 21{
            bust()
        }
        
    }
    
    // MARK: 開牌
    @IBAction func open(_ sender: Any){
        playerCards[0].image = UIImage(named: playerCloseCard)
        UIView.transition(with: playerCards[0], duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        comCards[0].image = UIImage(named: comCloseCard)
        UIView.transition(with: comCards[0], duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        comScoreLabel.text = "\(comTotalScore)"
        
        
        
        count = 2
        var comAddCard = ""
        while (comTotalScore < 17 && count < 6) || (comTotalScore == 17 && cCards.contains("A") && count == 2){
            comAddCard = cards[distribution.nextInt()]
            comCards[count].isHidden = false
            comCards[count].image = UIImage(named: comAddCard)
            UIView.transition(with: comCards[count], duration: 0.8, options: .transitionCurlDown, animations: nil, completion: nil)
            cCards += ["\(comAddCard)"]
            
            if comAddCard.contains("A"){
                comAceCount += 1
            }
            
            comTotalScore += scoreCal(card: comAddCard)
            for cCard in cCards{
                if cCard.contains("A") && comTotalScore > 21{
                    comTotalScore -= 10
                    cCards = cCards.filter({(card : String) -> Bool in return !card.contains("A")})
                }
            }
            if comAddCard.contains("A") && comAceCount >= 2{
                cCards += ["\(comAddCard)"]
            }
            
            comScoreLabel.text = "\(comTotalScore)"
            count += 1
        }
        
        if comTotalScore == 21 && cCards.count == 2{
            comScoreLabel.text = "\(comTotalScore)"
            comBlackJack()
        }else if playerScore == 21 && pCards.count <= 2{
            playerBlackJack()
        }else if comTotalScore > 21 || playerScore > comTotalScore{
            win()
        }else if comTotalScore > playerScore{
            lose()
        }else if comTotalScore == playerScore{
            tie()
        }else if count == 5 && comTotalScore < 21{
            comFiveCardTrick()
        }
        
    }
    
    // MARK: 投降
    @IBAction func giveUp (_ sender: Any){
        playerScore = 0
        playerScoreLabel.text = "\(playerScore)"
        giveUp()
    }
    
    // MARK: 下一輪(參數歸零重置)
    func nextRound () {
        if playerChip <= 0 {
            performSegue(withIdentifier: "gameOverSegue", sender: nil)
        }
        
        playerCards[0].isHidden = true
        playerCards[1].isHidden = true
        playerCards[2].isHidden = true
        playerCards[3].isHidden = true
        playerCards[4].isHidden = true
        
        comCards[0].image = UIImage(named:"back")
        comCards[0].isHidden = true
        comCards[1].isHidden = true
        comCards[2].isHidden = true
        comCards[3].isHidden = true
        comCards[4].isHidden = true
        
        comScore = 0
        comTotalScore = 0
        playerScore = 0
        comScoreLabel.text = "0"
        comScoreLabel.isHidden = true
        playerScoreLabel.text = "0"
        playerScoreLabel.isHidden = true
        pCards.removeAll()
        cCards.removeAll()
        
        dealButton.isEnabled = true
        hitButton.isEnabled = false
        openButton.isEnabled = false
        giveUpButton.isEnabled = false
        openFoldCardButton.isEnabled = false
        
        playerCloseCard = ""
        comCloseCard = ""
        playerOpenedCard = ""
        comOpenedCard = ""
        count = 2
        playerAceCount = 0
        comAceCount = 0
        
        bet = 100
        betLabel.text = "Bet: \(bet)"
        plusBetBtn.isHidden = false
        minusBetBtn.isHidden = false
    }
    
    
    // MARK: 各種牌面情況
    func nextHandler(action: UIAlertAction) {
        nextRound()
    }
    
    func lose () {
        let controller = UIAlertController(title: "You lose", message: "Lost \(bet)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= bet
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func win () {
        let controller = UIAlertController(title: "You win", message: "Won \(bet)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += bet
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func bust () {
        playerCards[0].image = UIImage(named: playerCloseCard)
        UIView.transition(with: playerCards[0], duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
        let controller = UIAlertController(title: "Bust", message: "Lost \(bet)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= bet
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func tie () {
        let controller = UIAlertController(title: "Tie", message: "Lost \(bet)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= bet
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func fiveCardTrick () {
        playerCards[0].image = UIImage(named: playerCloseCard)
        UIView.transition(with: playerCards[0], duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
        let controller = UIAlertController(title: "Five cards trick", message: "Won \(bet * 2)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += (bet * 2)
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func playerBlackJack () {
        playerCards[0].image = UIImage(named: playerCloseCard)
        UIView.transition(with: playerCards[0], duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
        let controller = UIAlertController(title: "Black Jack", message: "Won \(bet * 2)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += (bet * 2)
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func comBlackJack () {
        comCards[0].image = UIImage(named: comCloseCard)
        UIView.transition(with: comCards[0], duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
        comScoreLabel.text = "\(comTotalScore)"
        let controller = UIAlertController(title: "Com Black Jack", message: "Lost \(bet * 2)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= (bet * 2)
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: "computer black jack")
    }
    
    func comFiveCardTrick () {
        comCards[0].image = UIImage(named: comCloseCard)
        UIView.transition(with: comCards[0], duration: 0.2, options: .transitionFlipFromRight, animations: nil, completion: nil)
        comScoreLabel.text = "\(comTotalScore)"
        let controller = UIAlertController(title: "Com five cards trick", message: "Lost \(bet * 2)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= (bet * 2)
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: "computer five cards trick")
    }
    
    func giveUp () {
        let controller = UIAlertController(title: "Give up", message: "Lost \(bet / 2)! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= (bet / 2)
        playerChipLabel.text = "Your money：\(playerChip)"
        speech(_sender: controller.title!)
    }
    
    func noEnougnMoney () {
        let controller = UIAlertController(title: "No enough money", message: "You can't bet more than you have!", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: nextHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        speech(_sender: controller.title!)
    }
    
    //牌面轉換分數
    func scoreCal (card: String) -> Int {
        var score = 0
        if card.contains("A") {
            score = 11
        } else if card.contains("2") {
            score = 2
        } else if card.contains("3") {
            score = 3
        } else if card.contains("4") {
            score = 4
        } else if card.contains("5") {
            score = 5
        } else if card.contains("6") {
            score = 6
        } else if card.contains("7") {
            score = 7
        } else if card.contains("8") {
            score = 8
        } else if card.contains("9") {
            score = 9
        } else if card.contains("10") {
            score = 10
        } else if card.contains("J") {
            score = 10
        } else if card.contains("Q") {
            score = 10
        } else if card.contains("K") {
            score = 10
        }
        return score
    }
    
    // MARK: unwind
    @IBAction func unwindToMultipleChoicePage(segue: UIStoryboardSegue) {
        playerChip = 1000
        nextRound()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: speech
    func speech(_sender: String){
        let speechUtterence = AVSpeechUtterance(string: _sender)
        let synth = AVSpeechSynthesizer()
        synth.speak(speechUtterence)
    }
    
    // MARK: 調整籌碼
    @IBAction func plusBetBtnPressed(_ sender: Any) {
        if bet >= 100 && bet < 300{
            bet += 100
            betLabel.text = "Bet: \(bet)"
        }
    }
    
    @IBAction func minusBetBtnPressed(_ sender: Any) {
        if bet > 100 && bet <= 300{
            bet -= 100
            betLabel.text = "Bet: \(bet)"
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        
        speech(_sender: "welcome to black jack, let's play")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

