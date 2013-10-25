(ns editor.core
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]])
  (:require [cheshire.core :as json])
  (:import java.awt.FileDialog))

(defn new-model
  []
  (atom {}))

(defn file->data
  [file-name]
  (->
    file-name
    slurp
    clojure.string/split-lines
    rest
    (->> (apply str))
    (json/parse-string true)))

(defn load-data-file
  [file-name model]
  (swap! model merge (file->data file-name)))

(defn set-content!
  [root content]
  (doto (select root [:#content])
    .removeAll
    (.add content))
  root)

(defn -main [& args]
  (let [model (new-model)
        root (frame :title "Room Editor")
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file)]
                                   (load-data-file file model)
                                   (set-content! root (-> @model str label))))
                      :name "Load..."
                      :key "menu L")]
  (invoke-later
    (-> root
      (config! :size [600 :by 600])
      (config! :content
               (border-panel
                 :north (toolbar :items [load-action])
                 :center (vertical-panel :id :content)))
      (set-content! (label "derp"))
      pack!
      show!))))
