(ns editor.tools
  (:use seesaw.core)
  (:require [cheshire.core :as json]))

(defn tool-button
  [state label tool]
  (button
    :text label
    :listen [:action (fn [e] (swap! state assoc :tool tool))]))

(defn create-list
  [{:keys [state]}]
  (->>
    ["wall" (constantly "W")
     "floor" (constantly ".")
     "entrance" (constantly "i")
     "exit" (constantly "o")]
    (partition 2)
    (map #(apply tool-button state %))))
