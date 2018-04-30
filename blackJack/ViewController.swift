//
//  ViewController.swift
//  blackJack
//
//  Created by kevin on 2018/4/25.
//  Copyright © 2018年 KevinChang. All rights reserved.
//

import UIKit
import GameplayKit

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
    
    var playerCloseCard = ""
    var comCloseCard = ""
    var playerOpenedCard = ""
    var comOpenedCard = ""
    
    let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: cards.count - 1)
    
    var playerScore = 0
    var comScore = 0
    var comTotalScore = 0
    
    var playerChip = 1000
    
    var count = 2
    
    // MARK: 顯示蓋牌
    @IBAction func closeCard(_ sender: Any){
        playerCards[0].isHighlighted = false
    }
    
    @IBAction func seeCard(_ sender: Any) {
        playerCards[0].isHighlighted = true
        playerScoreLabel.isHidden = false
    }
    
    
    // MARK: 發牌
    @IBAction func deal(_ sender: Any){
        playerCloseCard = cards[distribution.nextInt()]
        playerOpenedCard = cards[distribution.nextInt()]
        comCloseCard = cards[distribution.nextInt()]
        comOpenedCard = cards[distribution.nextInt()]
        
        comCards[0].isHidden = false
        playerCards[0].image = UIImage(named: "back")
        playerCards[0].highlightedImage = UIImage(named: playerCloseCard)
        playerCards[0].isHidden = false
        playerCards[1].image = UIImage(named: playerOpenedCard)
        playerCards[1].isHidden = false
        comCards[1].image = UIImage(named: comOpenedCard)
        comCards[1].isHidden = false
        
        playerScore += scoreCal(card: playerOpenedCard, scoreSource: playerScore)
        playerScore += scoreCal(card: playerCloseCard, scoreSource: playerScore)
        if (playerOpenedCard.contains("A") || playerCloseCard.contains("A")) && playerScore > 21{
                playerScore -= 10
        }
        
        playerScoreLabel.text = "\(playerScore)"
        
        comScore += scoreCal(card: comOpenedCard, scoreSource: comScore)
        comScoreLabel.text = "\(comScore)"
        comScoreLabel.isHidden = false
        
        dealButton.isEnabled = false
        hitButton.isEnabled = true
        openButton.isEnabled = true
        giveUpButton.isEnabled = true
        
        comTotalScore = comScore + scoreCal(card: comCloseCard, scoreSource: comTotalScore)
        if (comCloseCard.contains("A") || comOpenedCard.contains("A")) && comTotalScore > 21{
            comTotalScore -= 10
        }
        if comTotalScore == 21{
            comScoreLabel.text = "\(comTotalScore)"
            comBlackJack()
        }else if playerScore == 21{
            playerBlackJack()
        }
    }
    
    // MARK: 加牌
    @IBAction func hit(_ sender: Any){
        var addCard = ""
        addCard = cards[distribution.nextInt()]
        playerCards[count].image = UIImage(named: addCard)
        playerCards[count].isHidden = false
        
        playerScore += scoreCal(card: addCard, scoreSource: playerScore)
        /*
        if addCard.contains("A") && playerScore > 21{
                playerScore -= 10
        }*/
        playerScoreLabel.text = "\(playerScore)"
        
        count += 1
        if count == 5 && playerScore <= 21{
            fiveCardTrick()
        }
        if playerScore > 21{
            bust()
        }
    }
    
    // MARK: 開牌
    @IBAction func open(_ sender: Any){
        playerCards[0].image = UIImage(named: playerCloseCard)
        comCards[0].image = UIImage(named: comCloseCard)
        comScoreLabel.text = "\(comTotalScore)"
        
        count = 2
        var comAddCard = ""
        while comTotalScore < 16{
            comAddCard = cards[distribution.nextInt()]
            comCards[count].image = UIImage(named: comAddCard)
            comCards[count].isHidden = false
            comTotalScore += scoreCal(card: comAddCard, scoreSource: comTotalScore)
            if comAddCard.contains("A") && comTotalScore > 21{
                comTotalScore -= 10
            }
            comScoreLabel.text = "\(comTotalScore)"
            count += 1
        }
        
        if comTotalScore > 21 || playerScore > comTotalScore{
            win()
        }else if comTotalScore > playerScore{
            lose()
        }else if comTotalScore == playerScore{
            tie()
        }
    }
    
    // MARK: 投降
    @IBAction func giveUp (_ sender: Any){
        playerScore = 0
        playerScoreLabel.text = "\(playerScore)"
        playerChip -= 100
        
        nextRound()
    }
    
    // MARK: 下一輪(參數歸零重置)
    func nextRound () {
        if playerChip == 0 {
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
        
        dealButton.isEnabled = true
        hitButton.isEnabled = false
        openButton.isEnabled = false
        giveUpButton.isEnabled = false
        
        playerChipLabel.text = "Your money：\(playerChip)"
        
        playerCloseCard = ""
        comCloseCard = ""
        playerOpenedCard = ""
        comOpenedCard = ""
        count = 2
    }
    
    
    // MARK: 各種牌面情況
    func okHandler(action: UIAlertAction) {
        nextRound()
    }
    
    func lose () {
        let controller = UIAlertController(title: "You lose!", message: "Lost 100! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= 100
    }
    
    func win () {
        let controller = UIAlertController(title: "You win!", message: "Won 100! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += 100
    }
    
    func bust () {
        let controller = UIAlertController(title: "Bust!", message: "Lost 100! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= 100
    }
    
    func tie () {
        let controller = UIAlertController(title: "Tie!", message: "Lost 100! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= 100
    }
    
    func fiveCardTrick () {
        let controller = UIAlertController(title: "Five card trick!", message: "Won 100! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += 100
    }
    
    func playerBlackJack () {
        playerCards[0].image = UIImage(named: playerCloseCard)
        let controller = UIAlertController(title: "Black Jack!", message: "Won 200!!! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip += 200
    }
    
    func comBlackJack () {
        comCards[0].image = UIImage(named: comCloseCard)
        let controller = UIAlertController(title: "Black Jack!", message: "Lost 200!!! Score: \(playerScore)", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okHandler)
        controller.addAction(action)
        show(controller, sender: nil)
        playerChip -= 200
    }
    
    
    //牌面轉換分數
    func scoreCal (card: String, scoreSource: Int) -> Int {
        var score = 0
        if card.contains("A") {
            if scoreSource < 21{
                score = 11
            }else if scoreSource > 21{
                score = 1
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

