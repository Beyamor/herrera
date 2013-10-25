(ns editor.core
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b])
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

(defn editor
  [model]
  (let [e (grid-panel
            :rows 16
            :columns 16
            :items (repeat (* 16 16) " "))]
    (b/bind
      model
      (b/b-do
        [m]
        (when-let [definition (get-in m [:rooms 0 :definition])]
          (config! e :items definition))))
    e))

(defn -main [& args]
  (let [model (new-model)
        root (frame :title "Room Editor")
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file)]
                                   (load-data-file file model)))
                      :name "Load..."
                      :key "menu L")]
  (invoke-later
    (-> root
      (config! :size [600 :by 600])
      (config! :content
               (border-panel
                 :north (toolbar :items [load-action])
                 :center (editor model)))
      pack!
      show!))))
