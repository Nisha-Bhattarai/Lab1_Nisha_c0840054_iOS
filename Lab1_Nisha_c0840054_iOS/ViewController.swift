//
//  ViewController.swift


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tapButtons: [UIButton]!
    @IBOutlet weak var scoreX: UILabel!
    @IBOutlet weak var scoreO: UILabel!
    
    var playBoard = [String]()
    //To pick the current player
    var currentPlayer = ""
    //To define the rule for this game / represent the logic of the game
    let playRules = [[0,1,2],[3,4,5],
                [6,7,8],[0,3,6],
                [1,4,7],[2,5,8],
                [0,4,8],[2,4,6]]
    //Variable to show the score of X
    var scorePlayerX = 0
    //Variable to show the score of O
    var scorePlayerO = 0
    
    var lastTapped: UIButton!
    
    var savedScores: Score!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //To load the main board
        loadPlayBoard()
        print(playBoard)
        //Call the function to enable swipe gesture
        addSwipeGesture()
        loadScores()
    }

    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            if lastTapped != nil {
                lastTapped.setImage(nil, for: .normal)
                let i = tapButtons.firstIndex(of: lastTapped)!
                currentPlayer = playBoard[i]
                playBoard[i] = ""
            }
        }
    }
    
    @IBAction func tapButtonsAction(_ sender: UIButton) {

        
        // Create an index to get the index of each buttons
        let i = tapButtons.firstIndex(of: sender)!
        
        
        //To avoid the player to press the button that is already pressed
        if !playBoard[i].isEmpty {
           return
        }
        lastTapped = sender
       // Set the title for two players and keep the turns for them
        if currentPlayer == "O" {
            sender.setImage(UIImage(named: "nought"), for: .normal)
            currentPlayer = "X"
            playBoard[i] = "O"
        }
        else {
            sender.setImage(UIImage(named: "cross"), for: .normal)
            currentPlayer = "O"
            playBoard[i] = "X"
        }
        winner()
    }
    
    //A method to reset the game by swiping left in the screen
    func addSwipeGesture() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    
    @objc func swipeGesture(gesture: UISwipeGestureRecognizer)
    {
        let sg = gesture as UISwipeGestureRecognizer
        
        if sg.direction == .left{
            self.reset()
        }
    }
    
    
    
    //To indicate the winner
    func winner() {
        for rule in playRules {
            let playerAt0 = playBoard[rule[0]]
            let playerAt1 = playBoard[rule[1]]
            let playerAt2 = playBoard[rule[2]]

            if playerAt0 == playerAt1,
               playerAt1 == playerAt2,
               !playerAt0.isEmpty {
                print("\(playerAt0) is the winner!")
                alertMSG(msg: "\(playerAt0) is the winner! Click OK to play again OR Swipe left to reset the game!")
                if savedScores == nil {
                    savedScores = Score(context: context)
                }
                // To add score to the players
                if playerAt0 == "O" {
                    scorePlayerO += 1
                    savedScores.o = String(scorePlayerO)
                    scoreO.text = String(scorePlayerO)
                } else if playerAt0 == "X" {
                    scorePlayerX += 1
                    savedScores.x = String(scorePlayerX)
                    scoreX.text = String(scorePlayerX)
                }
                do {
                    try context.save()
                } catch {
                    print("Error", error.localizedDescription)
                }
                return
            }
        }
        if !playBoard.contains(""){
            alertMSG(msg: "It's a tie! Click OK to play again OR Swipe left to reset the game!")
        }
        
    }
    
    //A method to pop up an alert message
    func alertMSG(msg: String) {
        let alertMsg = UIAlertController(title: "Bravo!", message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.playAgain()
        }
        alertMsg.addAction(alertAction)
        present(alertMsg, animated: true, completion: nil)
    }

    func playAgain(){
        //To remove all the elements in the board
        playBoard.removeAll()
        //To initialize the board
        loadPlayBoard()
        //Reset the UI of the play board
        for button in tapButtons {
            button.setImage(nil, for: UIControl.State())
        }
    }
    
    //A method to reset the game
    func reset() {
        playAgain()
        //To reset the scores to 0
        scorePlayerX = 0
        //Variable to show the score of O
        scorePlayerO = 0
        scoreO.text = String(scorePlayerO)
        scoreX.text = String(scorePlayerX)

        //Reset the UI of the play board
        for button in tapButtons {
            button.setImage(nil, for: UIControl.State())
        }
        if savedScores == nil {
            savedScores = Score(context: context)
        }
        // To add score to the players
        savedScores.x = "0"
        savedScores.o = "0"
        do {
            try context.save()
        } catch {
            print("Error", error.localizedDescription)
        }
    }
    
    
    //A method to load the play board
    func loadPlayBoard () {
        for _ in 0..<tapButtons.count {
            playBoard.append("")
        }
       
    }
    
    //CoreData (Fetch)
    func loadScores(){
        let request: NSFetchRequest<Score> = Score.fetchRequest()
                
                do {
                    let scores = try context.fetch(request)
                    if scores.count > 0 {
                        savedScores = scores.first
                        scoreO.text = savedScores.o
                        scoreX.text = savedScores.x
                    }
                } catch {
                    print("Error loading folders \(error.localizedDescription)")
                }
    }
}

