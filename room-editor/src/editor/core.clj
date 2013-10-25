(ns editor.core
  (:use seesaw.core)
  (:import java.awt.FileDialog))

(defn new-model
  []
  (atom {}))

(defn choose-file
  [frame]
  (->
    (doto (FileDialog. frame "Choose a file", FileDialog/LOAD)
      (.setDirectory "../app/coffee/game")
      (.setVisible true))
    .getFile))

(defn -main [& args]
  (let [model (new-model)
        root (frame :title "Room Editor")
        load-action (action
                      :handler (fn [e]
                                 (when-let [file-name (choose-file root)]
                                   (config! (select root [:#content]) :text file-name)))
                      :name "Load..."
                      :key "menu L")]
  (invoke-later
    (-> root
      (config! :size [600 :by 600])
      (config! :content
               (border-panel
                 :north (toolbar :items [load-action])
                 :center (label :id :content
                                :text "Hello")))
      pack!
      show!))))
