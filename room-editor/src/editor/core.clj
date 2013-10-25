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
        (when-let [selected-room (get m :selected-room)]
          (let [definition (get-in m [:rooms selected-room :definition])]
            (config! e :items definition)))))
    e))

(defn room-selection
  [model]
  (let [rs (listbox)]
    (b/bind
      model
      (b/transform #(if-let [rooms (get % :rooms)]
                      (-> rooms count range)
                      []))
      (b/property rs :model))
    (b/bind
      (b/selection rs)
      (b/b-swap! model #(assoc %1 :selected-room %2)))
    rs))

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
      (config! :size [1000 :by 600])
      (config! :content
               (top-bottom-split
                 (toolbar :items [load-action])
                 (left-right-split
                   (room-selection model)
                   (editor model))))
      pack!
      show!))))
