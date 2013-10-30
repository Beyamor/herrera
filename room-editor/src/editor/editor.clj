(ns editor.editor
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]]
        [editor.rooms :only [room-width room-height]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as c]
            [editor.tools :as tools])
  (:import java.awt.FileDialog
           java.awt.event.InputEvent
           java.awt.BasicStroke))

(def editor-width 600)
(def editor-height 600)

(def slice-color (c/color "red" 40))

(defn set-stroke-width!
  [g width]
  (.setStroke g (BasicStroke. width)))

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
    (let [room (get-in model [:rooms selected-room])
          tile-width (get-tile-width c)
          tile-height (get-tile-height c)
          draw-tile (fn [color i j]
                      (doto g
                        (.setColor color)
                        (.fillRect (* i tile-width) (* j tile-height) tile-width tile-height)))]

      ; tiles
      (doseq [i (range room-width)
              j (range room-height)
              :let [tile (get-in room [:definition i j])]]
        (let [color (c/color
                      (case tile
                        "W" "grey"
                        "." "white"
                        "o" "lightblue"
                        "i" "lightgreen"
                        " " "black"
                        "pink"))]
          (draw-tile color i j)))

      ; slices
      (.setColor g slice-color)
      (set-stroke-width! g 5)
      (doseq [j (get-in room [:slices :rows])
              :let [y (+ (* j tile-height) (/ tile-height 2))]]
        (.drawLine g 0 y (.getWidth c) y))
      (doseq [i (get-in room [:slices :columns])
              :let [x (+ (* i tile-width) (/ tile-height 2))]]
        (.drawLine g x 0 x (.getHeight c)))

      ; grid
      (.setColor g (c/color "lightgray"))
      (set-stroke-width! g 1)
      (doseq [i (range room-width)
              :let [x (* i tile-width)]]
        (.drawLine g x 0 x (.getHeight c)))
      (doseq [j (range room-height)
              :let [y (* j tile-height)]]
        (.drawLine g 0 y (.getWidth c) y)))))

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
      (let [tile-width (get-tile-width c)
            tile-height (get-tile-height c)
            tile-x (-> e .getX (/ tile-width) int)
            tile-y (-> e .getY (/ tile-height) int)]
        (cond
          (is-left? e)
          (when-let [tool (:tool @state)]
            (tools/left-click tool [tile-x tile-y]))

          (is-right? e)
          (when-let [tool (:tool @state)]
            (tools/right-click tool [tile-x tile-y]))

          :else :do-nothing)))))

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
