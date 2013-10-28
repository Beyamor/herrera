(ns editor.app
  (:use seesaw.core
        editor.core
        [seesaw.chooser :only [choose-file]]
        [editor.rooms :only [room-width room-height]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color]
            [editor.editor :as editor]
            [editor.room-management :as rms]
            [editor.tools :as tools])
  (:import java.awt.FileDialog))

(defn -main [& args]
  (let [app {:model (atom {:rooms []})
             :state (atom {})}
        root (frame :title "Room Editor")
        rooms (rms/create-browser app)
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
      (config! :menubar
               (menubar
                 :items [(menu
                           :text "File"
                           :items [save-action
                                   load-action])]))
      (config! :content
               (left-right-split
                 (left-right-split
                   (vertical-panel
                     :items (tools/create-list app))
                   (editor/create app))
                 (vertical-panel
                   :items [(label "Rooms")
                           rooms])))
      pack!
      show!))))
