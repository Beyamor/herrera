(ns editor.room-management
  (:use seesaw.core)
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [editor.rooms :as rooms]))

(defn create-selector
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

(defn create-adder
  [{:keys [model]}]
  (button
    :text "New room"
    :listen [:action (fn [_]
                       (swap! model update-in [:rooms] conj rooms/empty-room))]))

(defn create-browser
  [app]
  (vertical-panel
    :items [(create-selector app)
            (create-adder app)]))
