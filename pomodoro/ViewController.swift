//
//  ViewController.swift
//  pomodoro
//
//  Created by TH on 2022/08/23.
//

import UIKit
import AudioToolbox

enum TimerStatus {
  case start
  case pause
  case end
}


class ViewController: UIViewController {

  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var datePicker: UIDatePicker!

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var toggleButton: UIButton!
    
    // 초 저장
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer? = nil
    var currentSeconds = 0


  override func viewDidLoad() {
    super.viewDidLoad()
      
      self.configureToggleButton()
    
  }
    

  @IBAction func tapCancelButton(_ sender: UIButton) {
      switch self.timerStatus {
      case .start, .pause:
          self.stopTimer()
          
      default:
          break
      }

  }

  @IBAction func tapToggleButton(_ sender: UIButton) {
      // datePicker.countDownDuration) 몇 초인지
      // 2분 -> 120초
      self.duration = Int(self.datePicker.countDownDuration)
      
      switch self.timerStatus {
      case .end :
          self.currentSeconds = self.duration
          self.timerStatus = .start
          // withDuration : 0.5초마다
          // animations : 최종값으로 변하는 클로저
          UIView.animate(withDuration: 0.5) {
              self.timerLabel.alpha = 1
              self.progressView.alpha = 1
              self.datePicker.alpha = 0
          }
          self.toggleButton.isSelected = true
          self.cancelButton.isEnabled = true
          self.startTimer()
          
      case .start :
          self.timerStatus = .pause
          self.toggleButton.isSelected = false
          self.timer?.suspend()
          
      case .pause :
          self.timerStatus = .start
          self.toggleButton.isSelected = true
          self.timer?.resume()
          
      default:
          break
      }

      
  }

  func configureToggleButton() {
      self.toggleButton.setTitle("시작", for: .normal)
      self.toggleButton.setTitle("일시정지", for: .selected)
  }

  func startTimer() {
      if let timer = timer {
          
      } else {
          // queue에다가 계속 반복 작업을 할꺼다!
          self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
          // 어떤 주기로 타이머를 실행할껀지,,
          // 지금 바로 시작과, 1초마다 반복
          self.timer?.schedule(deadline: .now(), repeating: 1)
          // 타이머가 동작할때마다 이 클로저가 작동
          self.timer?.setEventHandler(handler: { [weak self] in
              guard let self = self else { return }
              self.currentSeconds -= 1
              let hour = self.currentSeconds / 3600 // 시
              let minutes = (self.currentSeconds % 3600) / 60 // 분
              let seconds = (self.currentSeconds % 3600) % 60 // 초
              
              // 시간을 라벨에 출력하게 해주는 포멧
              self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
              
              //프로그레스 퍼센트 출력
              self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
              
              //이미지뷰 뱅글뱅글 도는 애니메이션
              UIView.animate(withDuration: 0.5,delay: 0) {
                  // 이미지뷰의 외형을 변경
                  // 180도 회전되게....
                  // CGAffineTransform은 구조체, 뷰의 프레임을 계산하지 않고 2D 그래픽을 그릴수 있음
                  // CGAffineTransform 이동, 회전
                  self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
              }
              
              //또 똑같은 값을 주니까 360도 도는 애니메이션 완성
              //딜레이 0.5를 줘서 180도가 끝난뒤에 실행 가능
              UIView.animate(withDuration: 0.5,delay: 0.5) {
                  self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
              }
              
              // 타이머가 종료..
              if self.currentSeconds ?? 0 <= 0 {
                  self.stopTimer()
                  // ID는 https://iphonedev.wiki 이것만 검색창에 쳐도 나올듯
                  AudioServicesPlayAlertSound(1005)
              }
          })
          // 핸들러 클로저가 끝나면 다시 시작되게 구현
          self.timer?.resume()
      }
  }

  func stopTimer() {
      // timer에 nil을 넣기위함
      // 이래야지 메모리 해제가 가능함
      if self.timerStatus == .pause {
          self.timer?.resume()
      }
      
      
      self.timerStatus = .end
      self.cancelButton.isEnabled = false
      
      // withDuration : 0.5초마다
      // animations : 최종값으로 변하는 클로저
      UIView.animate(withDuration: 0.5) {
          self.timerLabel.alpha = 0
          self.progressView.alpha = 0
          self.datePicker.alpha = 1
          //타이머가 끝난 뒤에는 원상태로 돌아오게,,,
          self.imageView.transform = .identity
      }
      
      self.toggleButton.isSelected = false
      self.timer?.cancel()
      
      // 타이머를 메모리에서 해제..
      // 해제하지 않으면 계속 작동될수 있음
      self.timer = nil
  }
}

