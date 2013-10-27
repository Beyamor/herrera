(ns editor.core
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color])
  (:import java.awt.FileDialog))

(def room-width 16)
(def room-height 16)

(defn file->data
  [file-name]
  (->
    file-name
    slurp
    (subs (count "define "))
    (json/parse-string true)))

(defn load-data-file
  [file-name {:keys [model]}]
  (swap! model merge (file->data file-name)))

(defn save-data-file
  [file {:keys [model state]}]
  (->
    @model
    (select-keys #{:rooms})
    json/generate-string
    (->> (str "define "))
    (->> (spit file))))

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

(defn editor
  [{:keys [state model]}]
  (let [c (canvas
            :size [editor-width :by editor-height]
            :paint (fn [c g] (repaint-editor! c g @state @model)))]
    (b/bind
      model
      (b/b-do
        [m]
        (repaint! c)))

    ; kinda don't wanna do this, but whatever
    (b/bind
      state
      (b/b-do
        [m]
        (repaint! c)))

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

(defn room-selection
  [{:keys [state model]}]
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
          (swap! state assoc :selected-room selection))))
    rs))

(defn tool-button
  [state label tool]
  (button
    :text label
    :listen [:action (fn [e] (swap! state assoc :tool tool))]))

(defn -main [& args]
  (let [app {:model (atom {})
             :state (atom {})}
        root (frame :title "Room Editor")
        rooms (room-selection app)
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file)]
                                   (load-data-file file app)))
                      :name "Load..."
                      :key "menu L")
        save-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file
                                                   :type :save
                                                   :filters [["Coffee" [".coffee"]]])]
                                   (save-data-file file app)))
                      :name "Save..."
                      :key "menu S")]
  (invoke-later
    (-> root
      (config! :content
               (top-bottom-split
                 (toolbar :items [save-action load-action])
                 (left-right-split
                   (left-right-split
                     (vertical-panel
                       :items [(tool-button (:state app) "wall"
                                            (fn []
                                              "W"))])
                     (editor app))
                   (vertical-panel
                     :items [(label "Rooms")
                             rooms]))))
      pack!
      show!))))
