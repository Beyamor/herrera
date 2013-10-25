(ns editor.core
  (:use seesaw.core))

(defn -main [& args]
  (invoke-later
    (-> (frame :title "Room Editor"
               :content "Hi!"
               :on-close :exit)
      pack!
      show!)))
