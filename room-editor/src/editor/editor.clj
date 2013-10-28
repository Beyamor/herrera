(ns editor.editor
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]]
        [editor.rooms :only [room-width room-height]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color])
  (:import java.awt.FileDialog))

(def editor-width 600)
(def editor-height 600)

(defn get-tile-width
  [c]
  (/ (.getWidth c) room-width))

(defn get-tile-height
  [c]
  (/ (.getHeight c) room-height))

(defn repaint-editor!
  [c g {:keys [selected-room]} model]
  (.clearRect g 0 0 (.getWidth c) (.getHeight c))
  (when selected-room
    (let [tile-width (get-tile-width c)
          tile-height (get-tile-height c)]
      (doseq [i (range room-width)
              j (range room-height)
              :let [idx (+ i (* j room-width))
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

(defn repaint-on-change
  [c m]
  (b/bind
    m
    (b/b-do
      [m]
      (repaint! c))))

(defn create
  [{:keys [state model]}]
  (let [c (canvas
            :size [editor-width :by editor-height]
            :paint (fn [c g] (repaint-editor! c g @state @model)))]
    (repaint-on-change c model)
    (repaint-on-change c state)
    (listen c
            :mouse-clicked (fn [e]
                             (when-let [selected-room (:selected-room @state)]
                               (when-let [tool (:tool @state)]
                                 (let [tile-width (get-tile-width c)
                                       tile-height (get-tile-height c)
                                       tile-x (-> e .getX (/ tile-width) int)
                                       tile-y (-> e .getY (/ tile-height) int)]
                                   (swap! model assoc-in
                                          [:rooms selected-room :definition (+ tile-x (* room-width tile-y))]
                                          (tool)))))))
    c))
