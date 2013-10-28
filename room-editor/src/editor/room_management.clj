(ns editor.room-management
  (:use seesaw.core)
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]))

(defn room-selector
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
