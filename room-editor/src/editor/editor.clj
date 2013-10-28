(ns editor.editor
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]]
        [editor.rooms :only [room-width room-height]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color])
  (:import java.awt.FileDialog
           java.awt.event.InputEvent))

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
        (let [c (case tile
                  "W" "grey"
                  "." "white"
                  "o" "lightblue"
                  "i" "lightgreen"
                  " " "black"
                  "pink")]
          (doto g
            (.setColor (color/color c))
            (.fillRect (* i tile-width) (* j tile-height) tile-width tile-height)))))))

(defn repaint-on-change
  [c m]
  (b/bind
    m
    (b/b-do
      [m]
      (repaint! c))))

(defn has-modifier?
  [e modifier]
  (==
    (bit-and (.getModifiers e) modifier)
    modifier))

(defn is-left?
  [e]
  (has-modifier? e InputEvent/BUTTON1_MASK))

(defn is-right?
  [e]
  (has-modifier? e InputEvent/BUTTON3_MASK))

(defn create-paint-handler
  [c model state]
  (fn [e]
    (when-let [selected-room (:selected-room @state)]
      (when-let [tool (:tool @state)]
        (let [tile-width (get-tile-width c)
              tile-height (get-tile-height c)
              tile-x (-> e .getX (/ tile-width) int)
              tile-y (-> e .getY (/ tile-height) int)
              tile-path [:rooms selected-room :definition (+ tile-x (* room-width tile-y))]]
          (cond
            (is-left? e)
            (swap! model assoc-in tile-path (tool))

            (is-right? e)
            (swap! model assoc-in tile-path " ")

            :else :do-nothing))))))

(defn create
  [{:keys [state model]}]
  (let [c (canvas
            :size [editor-width :by editor-height]
            :paint (fn [c g] (repaint-editor! c g @state @model)))
        paint-handler (create-paint-handler c model state)]
    (repaint-on-change c model)
    (repaint-on-change c state)
    (listen c
            :mouse-clicked paint-handler
            :mouse-dragged paint-handler)
    c))
