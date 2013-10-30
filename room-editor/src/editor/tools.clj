(ns editor.tools
  (:use seesaw.core
        [editor.rooms :only [update-room!]])
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

(defrecord Slice [app]
  Tool
  (tool-name [_]
    "Slice")

  (options [_]
    nil)

  (left-click [_ [tile-x tile-y]]
    (cond
      (= tile-x 0)
      (update-room! app update-in [:slices :rows]
                    #(-> % set (conj tile-y)))

      (= tile-y 0)
      (update-room! app update-in [:slices :columns]
                    #(-> % set (conj tile-x)))
      
      :else :do-nothing))

  (right-click [_ [tile-x tile-y]]))

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
    [(->Paint app)
     (->Slice app)]
    (map #(tool-button state root %))))
