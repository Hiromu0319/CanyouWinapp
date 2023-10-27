import SwiftUI
import Foundation

class PlayViewModel: ObservableObject{
    
    @Published var numbers: [String] = []
    @Published var selectedNumbers:[String] = []
    @Published var selectNumber: String = ""
    @Published var bitdp:[[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 1 << 16)
    @Published var remainingTime: Int = 600
    @Published var computerPoint: Int = 0
    @Published var humanPoint: Int = 0
    @Published var computerWinFlag: Bool = false
    @Published var humanWinFlag: Bool = false
    @Published var timer: Timer?
    @Published var isAlertPresented: Bool = false
    @Published var navigateToTopView: Bool = false
    @Published var startTime: Date?
    @Published var endTime: Date?
    private let scoreService: ScoreService = .shared
    let oldScore: Score?
    
    init(oldScore: Score?) {
        self.oldScore = oldScore
        makeNumbers()
        runTheSolveFunction()
        
    }
    
    //16個の数字の配列を作成
    func makeNumbers() -> Void{
        let number = "012345"
        var result: [String] = []
        
        for char1 in number {
            for char2 in number {
                result.append("\(char1)\(char2)")
            }
        }
        
        numbers = Array(result.shuffled().prefix(16))
    }
    
    
    //新しい盤面が作成された時に再度最適解を計算
    func runTheSolveFunction() {
        solve(n: 16, strings: numbers)
    }
    
    
    //最適解を計算する処理
    func solve(n: Int, strings: [String]) -> Void{
        var es: [(Int, Int)] = []
        for s in strings {
            if let firstChar = s.first, let lastChar = s.last,
               let frm = Int(String(firstChar)), let to = Int(String(lastChar)) {
                es.append((frm, to))
            }
        }
        
        var dp: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 1 << n)
        for s in (0..<(1 << n)).reversed() {
            for i in 0..<6 {
                for (ei, e) in es.enumerated() {
                    if (s >> ei) & 1 == 1 || i != e.0 {
                        continue
                    }
                    let ns = s | (1 << ei)
                    if dp[ns][e.1] == 1 {
                        continue
                    }
                    dp[s][i] = 1
                    break
                }
            }
        }
        bitdp = dp
    }
    
    
    //4*4マスの格子マスを作成
    func createColumns(size: CGFloat) -> [GridItem] {
        let columns: [GridItem] = Array(repeating: .init(.fixed(size)), count: 4)
        return columns
    }
    
    
    //選択中のマスを更新
    func toggleSelect(num: String) -> Void{
        if num == selectNumber{
            selectNumber = ""
        }
        else{
            selectNumber = num
        }
    }
    
    
    //タイマー
    func startTimer() -> Void{
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.plusComputerPoint()
                self.initialize()
            }
        }
    }
    
    
    //各種フラグ関係を初期化
    func initialize() -> Void {
        makeNumbers()
        selectNumber = ""
        selectedNumbers = []
        runTheSolveFunction()
        remainingTime = 600
    }
    
    
    func plusComputerPoint() -> Void {
        computerPoint += 1
        if computerPoint == 5 {
            computerWinFlag = true
        }
    }
    
    
    func plusHumanPoint() -> Void {
        humanPoint += 1
        if humanPoint == 5 {
            humanWinFlag = true
            endTime = .now
            Task {
                await uploadScoreButton()
            }
        }
    }
    
    
    //choiceが押された時コンピューター側が次の手で合致する数字を選択できるかどうか
    func pushChoice() -> Bool {
        confirmNumber(num: selectNumber)
        
        var flag = false
        let nowscore = makeBitPointScore()
        let optimalMoveIndex = checkOptimalMove(bitscore: nowscore)
        if optimalMoveIndex != 100 {
            confirmNumber(num: numbers[optimalMoveIndex])
            flag = true
        }
        else {
            let moveIndex = checkMove(bitscore: nowscore)
            if moveIndex != 100 {
                confirmNumber(num: numbers[moveIndex])
                flag = true
            }
        }
        
        return flag
    }
    
    
    //choiceを押した時にselectedNumbers選択中の数字を追加
    func confirmNumber(num: String) -> Void{
        selectedNumbers.append(num)
    }
    
    
    //現在のBitPointScoreを計算
    func makeBitPointScore() -> Int {
        var score = 0
        for i in 0..<16 {
            if selectedNumbers.contains(numbers[i]) {
                score += 1 << i
            }
        }
        return score
    }
    
    
    //最適手があるかチェック(最適手があれば100以外を、なければ100を返す)
    func checkOptimalMove(bitscore: Int) -> Int {
        var index = 100
        for i in 0..<16 {
            selectNumber = numbers[i]
            if check(bitscore: bitscore, point: i) {
                let nxt = Int(numbers[i].last!.asciiValue!) - 48
                if bitdp[bitscore | 1 << i][nxt] == 0 {
                    index = i
                    break
                }
            }
        }
        return index
    }
    
    
    //選べるマスがあるなら選ぶ
    func checkMove(bitscore: Int) -> Int {
        var index = 100
        for i in 0..<16 {
            selectNumber = numbers[i]
            if check(bitscore: bitscore, point: i) {
                index = i
                break
            }
        }
        return index
    }
    
    
    //そのマスを選ぶことが可能か
    func check(bitscore: Int, point: Int) -> Bool {
        guard selectNumber.count == 2, (bitscore | (1 << point)) != bitscore else {
            return false
        }
        
        let secondChar = selectedNumbers.last!.last
        let firstChar = selectNumber.first
        
        var juge = false
        if secondChar == firstChar {
            juge = true
        }
        
        return juge
    }
    
    
    //その数字のボタンが選択できるかどうか
    func notShowButtonToggle() -> Bool {
        guard selectNumber != "" else {
            return true
        }
        guard selectedNumbers.count != 0 else {
            return false
        }
        
        var juge = false
        if selectedNumbers.contains(selectNumber) {
            juge = true
        }
        
        let secondChar = selectedNumbers.last!.last
        let firstChar = selectNumber.first
        if secondChar != firstChar {
            juge = true
        }
        
        return juge
    }
    
    
    //スタート時間を記録
    func onAppear() {
        startTime = .now
    }

    
    //時間の表示形式を「？？：？？」のフォーマットに変更
    func convertDate() -> String? {
        guard let startTime, let endTime else { return nil }
        let time = endTime.timeIntervalSince(startTime)

        let dateFormatter = DateComponentsFormatter()

        dateFormatter.unitsStyle = .positional
        dateFormatter.allowedUnits = [.hour, .minute, .second, .nanosecond]

        return dateFormatter.string(from: time)
    }
    
    
    //終了時間と開始時間の差を計算（スコアを計算）
    func getDuration() -> Double? {
        guard let startTime, let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    
    //計算したスコアをfirebaseにuproad
    func uploadScoreButton() async {
        guard let time = getDuration() else { return }
        
        if let oldScore {
            print(oldScore.time, time)
            if oldScore.time > time {
                do {
                    var score = oldScore
                    score.time = time
                    try await scoreService.updateScore(score)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            do {
                let score: Score = .init(time: time)
                try await scoreService.uploadScore(score)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
}
