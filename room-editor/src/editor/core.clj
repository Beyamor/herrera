(ns editor.core
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color])
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

(def editor-width 600)
(def editor-height 600)

(defn repaint-editor!
  [c g model]
  (.clearRect g 0 0 (.getWidth c) (.getHeight c))
  (when-let [selected-room (:selected-room model)]
    (let [tile-width (/ (.getWidth c) 16)
          tile-height (/ (.getHeight c) 16)]
      (doseq [i (range 16)
              j (range 16)
              :let [idx (+ i (* j 16))
                    tile (get-in model [:rooms selected-room :definition idx])]]
        (when (not= tile " ")
          (let [c (case tile
                    "W" "grey"
                    "." "white"
                    "pink")]
            (doto g
              (.setColor (color/color c))
              (.fillRect (* i tile-width) (* j tile-height) tile-width tile-height))))))))

(defn editor
  [model]
  (let [e (canvas
            :size [editor-width :by editor-height]
            :paint (fn [c g] (repaint-editor! c g @model)))]
    (b/bind
      model
      (b/b-do
        [m]
        (repaint! e)))
    e))

(defn room-selection
  [model]
  (let [rs (listbox :id :room-selection)]
    (b/bind
      (b/selection rs)
      (b/b-swap! model #(assoc %1 :selected-room %2)))
    rs))

(defn -main [& args]
  (let [model (new-model)
        root (frame :title "Room Editor")
        rooms (room-selection model)
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file)]
                                   (load-data-file file model)
                                   (config! rooms :model (-> @model count range))))
                      :name "Load..."
                      :key "menu L")]
  (invoke-later
    (-> root
      (config! :content
               (top-bottom-split
                 (toolbar :items [load-action])
                 (left-right-split
                   (vertical-panel
                     :items [(label "Rooms")
                             rooms])
                   (editor model))))
      pack!
      show!))))
