(ns editor.core
  (:use seesaw.core
        [seesaw.chooser :only [choose-file]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color])
  (:import java.awt.FileDialog))

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
