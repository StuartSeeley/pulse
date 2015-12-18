(defconstant +splash-chars-0-127+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    (subseq chars 0 1024)))

(defconstant +splash-chars-128-159+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    (subseq chars 1024 (+ 1024 256))))

(defconstant +splash-screen+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    screen))

(defconstant +splash-colours+
  (with ((chars screen colours) (read-screen-designer-file "media/splash/splash-darkatx.txt"))
    colours))

(defun glued-game-and-splash-gfx (game)
  (+ (subseq (fetch-file game) 0 1024)
     +splash-chars-128-159+
     (subseq (fetch-file game) (+ 1024 256))))

(defun make-splash-prg ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/splash." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "primary-loader/zeropage.asm"
            "splash/main.asm"
            "secondary-loader/start.asm"
            "splash/splash.asm"
            "splash/audio-player.asm")
          (+ "obj/splash." ! ".prg.vice.txt"))
    (exomize (+ "obj/splash." ! ".prg")
             (+ "obj/splash.crunched." ! ".prg")
             "1002" "20")))