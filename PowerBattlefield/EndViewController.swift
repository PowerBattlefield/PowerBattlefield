import UIKit
import Firebase

class EndViewController: UIViewController {
    
    var displayText = ""
    var roomId:String!
    @IBOutlet weak var displayLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLabel.text = displayText
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToRoom(_ sender: Any) {
        Database.database().reference().child(roomId).child("winner").removeValue()
        Database.database().reference().child(roomId).child("player1").removeValue()
        Database.database().reference().child(roomId).child("player2").removeValue()
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
