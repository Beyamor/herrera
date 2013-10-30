(ns editor.tools
  (:use seesaw.core)
  (:require [cheshire.core :as json]))

(defprotocol Tool
  (options [this])
  (left-click [this tile-indices])
  (right-click [this tile-indices])
  (tool-name [this]))

(defn tile-path
  [{:keys [state model]} [tile-x tile-y]]
  (when-let [selected-room (:selected-room @state)]
    [:rooms selected-room :definition tile-x tile-y]))

(defn tiletype-button
  [state label tile-type]
  (button
    :text label
    :listen [:action (fn [e] (swap! state assoc :tile-type tile-type))]))

(defn create-tiletype-list
  [state]
  (->>
    ["wall" "W"
     "floor" "."
     "entrance" "i"
     "exit" "o"]
    (partition 2)
    (map
      (fn [[label terrain-type]]
        (tiletype-button state label terrain-type)))))

(defrecord Paint [app]
  Tool
  (tool-name [_]
    "Paint")

  (options [_]
    (create-tiletype-list (:state app)))

  (left-click [_ tile-indices]
    (when-let [tile-path (tile-path app tile-indices)]
      (when-let [tile-type (:tile-type @(:state app))]
        (swap! (:model app) assoc-in tile-path tile-type))))

  (right-click [_ tile-indices]
    (when-let [tile-path (tile-path app tile-indices)]
      (swap! (:model app) assoc-in tile-path " "))))

(defn tool-button
  [state root tool]
  (button
    :text (tool-name tool)
    :listen [:action
             (fn [& _]
               (swap! state assoc :tool tool)
               (config! (select root [:#tool-options])
                        :items (options tool)))]))

(defn create-list
  [{:keys [state] :as app} root]
  (->>
    [(->Paint app)]
    (map #(tool-button state root %))))
