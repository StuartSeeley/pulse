(defvar radio_shortest_pulse #x18)
(defvar radio_longest_pulse #x28)
(defvar radio_pulse_width (- radio_longest_pulse radio_shortest_pulse))
(defvar radio_average_pulse (+ radio_shortest_pulse (half radio_pulse_width)))

(defun radio-rate (tv)
  (pwm-pulse-rate tv :shortest radio_shortest_pulse
                     :width radio_pulse_width))

(defun make-radio-tap (to in-wav bin)
  (with-output-file out to
    (with-input-file in-bin bin
      (radio2tap out in-wav in-bin))))

(defun make-radio-wav (tv)
  (format t "Making radio…~%")
  (make-wav "radio" "media/radio.ogg" "3" "-32" tv (half (radio-rate tv)))
  (make-conversion "radio" tv (half (radio-rate tv)))
  (alet (downcase (symbol-name tv))
    (with-input-file in-wav (+ "obj/radio.downsampled." ! ".wav")
      (make-radio-tap "obj/radio0.tap" in-wav (+ "obj/8k.crunched." ! ".prg"))
      (make-radio-tap "obj/radio1.tap" in-wav (+ "obj/8k.crunched." ! ".prg"))
      (make-radio-tap "obj/radio2.tap" in-wav (+ "obj/8k.crunched." ! ".prg"))
      (make-radio-tap "obj/radio3.tap" in-wav (+ "obj/8k.crunched." ! ".prg")))))

(defun make-flight ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/flight." ! ".prg")
          '("primary-loader/models.asm"
            "radio/zeropage.asm"
            "radio/start.asm"
            "radio/load-sequence.asm"
            "radio/play-sample.asm"
            "radio/flight.asm"
;            "radio/disc.asm"
            "radio/earth.asm"
            "radio/loader.asm"
            "game/screen.asm"
            "game/high-segment.asm"
            "secondary-loader/start.asm")
          (+ "obj/flight." ! ".prg.vice.txt"))
    (exomize (+ "obj/flight." ! ".prg")
             (+ "obj/flight.crunched." ! ".prg")
             "1002" "20")))
