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

(defn get-tile-width
  [c]
  (/ (.getWidth c) 16))

(defn get-tile-height
  [c]
  (/ (.getHeight c) 16))

(defn repaint-editor!
  [c g model]
  (.clearRect g 0 0 (.getWidth c) (.getHeight c))
  (when-let [selected-room (:selected-room model)]
    (let [tile-width (get-tile-width c)
          tile-height (get-tile-height c)]
      (doseq [i (range 16)
              j (range 16)
              :let [idx (+ i (* j 16))
                    tile (get-in model [:rooms selected-room :definition idx])]]
        (when (not= tile " ")
          (let [c (case tile
                    "W" "grey"
                    "." "white"
                    "o" "lightblue"
                    "i" "lightgreen"
                    "pink")]
            (doto g
              (.setColor (color/color c))
              (.fillRect (* i tile-width) (* j tile-height) tile-width tile-height))))))))

(defn editor
  [model]
  (let [c (canvas
            :size [editor-width :by editor-height]
            :paint (fn [c g] (repaint-editor! c g @model)))]
    (b/bind
      model
      (b/b-do
        [m]
        (repaint! c)))
    (listen c
            :mouse-clicked (fn [e]
                             (when-let [selected-room (:selected-room @model)]
                               (when-let [tool (:tool @model)]
                                 (let [tile-width (get-tile-width c)
                                       tile-height (get-tile-height c)
                                       tile-x (-> e .getX (/ tile-width) int)
                                       tile-y (-> e .getY (/ tile-height) int)]
                                   (swap! model assoc-in
                                          [:rooms selected-room :definition (+ tile-x (* 16 tile-y))]
                                          (tool)))))))
    c))

(defn room-selection
  [model]
  (let [rs (listbox :id :room-selection)]
    (b/bind
      model
      (b/transform #(if-let [rooms (:rooms %)]
                      (-> rooms count range)
                      []))
      (b/property rs :model))
    (b/bind
      (b/selection rs)
      (b/b-do
        [selection]
        (when selection
          (swap! model assoc :selected-room selection))))
    rs))

(defn tool-button
  [model label tool]
  (button
    :text label
    :listen [:action (fn [e] (swap! model assoc :tool tool))]))

(defn -main [& args]
  (let [model (new-model)
        root (frame :title "Room Editor")
        rooms (room-selection model)
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file)]
                                   (load-data-file file model)))
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
                   (top-bottom-split
                     (editor model)
                     (horizontal-panel
                       :items [(tool-button model "wall" (fn []
                                                           "W"))])))))
      pack!
      show!))))
